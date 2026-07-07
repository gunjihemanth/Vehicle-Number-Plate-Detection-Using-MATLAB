%  Image processing pipeline for locating and extracting a vehicle's
%  number plate region and reading the characters with OCR.
%
%  Pipeline:
%   1. Read & preprocess image (grayscale, noise removal, contrast)
%   2. Edge detection (Sobel) + morphological operations
%   3. Candidate region extraction (connected components)
%   4. Plate region filtering by aspect ratio / area heuristics
%   5. Crop plate, binarize, segment characters
%   6. Recognize characters using MATLAB's OCR (Computer Vision Toolbox)
%
%  Usage:
%   detectNumberPlate('images/car1.jpg');

function plateText = detectNumberPlate(imagePath)

    if nargin < 1
        imagePath = 'images/car1.jpg';   % default sample image
    end

    %% ---------------- 1. Read & Preprocess ----------------
    img = imread(imagePath);
    imgGray = im2gray(img);

    % Reduce noise while preserving edges
    imgFiltered = medfilt2(imgGray, [3 3]);

    % Improve contrast (helps in varying lighting conditions)
    imgEnhanced = adapthisteq(imgFiltered);

    %% ---------------- 2. Edge Detection + Morphology ----------------
    edgeImg = edge(imgEnhanced, 'sobel');

    % Dilate to connect edges that belong to plate characters
    se = strel('rectangle', [5 15]);
    dilatedImg = imdilate(edgeImg, se);

    % Fill holes and remove small noise blobs
    filledImg = imfill(dilatedImg, 'holes');
    cleanedImg = bwareaopen(filledImg, 500);

    %% ---------------- 3. Candidate Region Extraction ----------------
    stats = regionprops(cleanedImg, 'BoundingBox', 'Area', 'Extent');

    %% ---------------- 4. Filter Candidates by Plate Heuristics ----------------
    % Typical number plates: wide rectangular shape, aspect ratio ~ 2:1 to 5:1
    bestBox = [];
    bestScore = -inf;

    for k = 1:numel(stats)
        bb = stats(k).BoundingBox;
        w = bb(3); h = bb(4);
        aspectRatio = w / h;

        if aspectRatio > 2 && aspectRatio < 6 && stats(k).Area > 800
            % Score candidates: prefer plausible plate-like aspect ratio & area
            score = stats(k).Area * stats(k).Extent;
            if score > bestScore
                bestScore = score;
                bestBox = bb;
            end
        end
    end

    if isempty(bestBox)
        warning('No plate-like region found. Try adjusting thresholds or use a clearer image.');
        plateText = '';
        return;
    end

    %% ---------------- 5. Crop, Binarize & Segment Characters ----------------
    plateImg = imcrop(imgGray, bestBox);
    plateBW = imbinarize(plateImg, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.45);
    plateBW = bwareaopen(plateBW, 20);   % remove tiny speckle noise

    %% ---------------- 6. Character Recognition (OCR) ----------------
    plateText = '';
    if license('test', 'video_and_image_blockset') || exist('ocr', 'file') == 2
        try
            ocrResults = ocr(plateBW, 'CharacterSet', ...
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', ...
                'TextLayout', 'Word');
            plateText = strtrim(strrep(ocrResults.Text, sprintf('\n'), ''));
        catch
            warning('OCR could not be run. Ensure Computer Vision Toolbox is installed.');
        end
    else
        warning('ocr() not found. Install the Computer Vision Toolbox for character recognition.');
    end

    %% ---------------- Display Results ----------------
    figure('Name', 'Vehicle Number Plate Detection');

    subplot(2, 2, 1); imshow(img);          title('Original Image');
    subplot(2, 2, 2); imshow(imgEnhanced);  title('Enhanced Grayscale');
    subplot(2, 2, 3); imshow(cleanedImg);   title('Candidate Regions (Morphology)');

    subplot(2, 2, 4); imshow(img); hold on;
    rectangle('Position', bestBox, 'EdgeColor', 'g', 'LineWidth', 2);
    title('Detected Plate Region');
    hold off;

    figure('Name', 'Extracted Plate');
    subplot(1, 2, 1); imshow(plateImg); title('Cropped Plate');
    subplot(1, 2, 2); imshow(plateBW);  title('Binarized Plate');

    if ~isempty(plateText)
        fprintf('Detected Plate Number: %s\n', plateText);
    else
        fprintf('Plate region located, but no text could be recognized.\n');
    end
end
