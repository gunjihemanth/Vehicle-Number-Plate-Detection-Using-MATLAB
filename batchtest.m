%  Runs detectNumberPlate() over every image in the /images folder and
%  logs the recognized plate text for each, so the pipeline can be
%  validated across different lighting conditions (day, night, glare,
%  shadow, etc.).

clear; clc; close all;

imageFolder = fullfile(fileparts(mfilename('fullpath')), '..', 'images');
imageFiles  = dir(fullfile(imageFolder, '*.jpg'));
imageFiles  = [imageFiles; dir(fullfile(imageFolder, '*.png'))];

if isempty(imageFiles)
    error('No images found in %s. Add sample vehicle images to test.', imageFolder);
end

results = table('Size', [numel(imageFiles) 2], ...
    'VariableTypes', {'string', 'string'}, ...
    'VariableNames', {'Image', 'DetectedPlate'});

for i = 1:numel(imageFiles)
    imgPath = fullfile(imageFiles(i).folder, imageFiles(i).name);
    fprintf('\nProcessing: %s\n', imageFiles(i).name);

    try
        plateText = detectNumberPlate(imgPath);
    catch ME
        warning('Failed on %s: %s', imageFiles(i).name, ME.message);
        plateText = 'ERROR';
    end

    results.Image(i) = imageFiles(i).name;
    results.DetectedPlate(i) = plateText;
end

disp(results);

resultsPath = fullfile(fileparts(mfilename('fullpath')), '..', 'results', 'batch_results.csv');
writetable(results, resultsPath);
fprintf('\nBatch results saved to: %s\n', resultsPath);
