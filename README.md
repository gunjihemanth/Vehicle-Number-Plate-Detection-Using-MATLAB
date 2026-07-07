# Vehicle Number Plate Detection Using MATLAB

An image-processing pipeline built in MATLAB that automatically **detects and reads vehicle number plates** from images, tested across multiple vehicles and lighting conditions.

---

##  Overview

This project applies core **digital image processing** and **pattern recognition** techniques to locate a vehicle's number plate within an image and extract the plate text using OCR. The pipeline is designed to be robust to varying lighting conditions (daylight, shadows, low light, glare) through adaptive contrast enhancement and adaptive binarization.

**Pipeline stages:**
1. **Preprocessing** — grayscale conversion, median filtering (noise removal), adaptive histogram equalization (contrast enhancement)
2. **Edge Detection** — Sobel edge detection to highlight plate boundaries and character strokes
3. **Morphological Processing** — dilation, hole filling, and small-object removal to merge character edges into a solid plate-like blob
4. **Candidate Region Extraction** — connected-component analysis (`regionprops`) to find bounding boxes of all blobs
5. **Plate Region Filtering** — heuristic filtering by aspect ratio (~2:1 to 6:1) and area to select the most plate-like region
6. **Character Segmentation & Recognition** — crop and binarize the plate, then run MATLAB's OCR engine to extract the plate text

---

##  Repository Structure

```
vehicle-plate-detection/
├── src/
│   ├── detectNumberPlate.m   # Main detection + OCR function
│   └── batchTest.m           # Runs detection across all images in /images
├── images/                   # Sample vehicle images (add your own .jpg/.png here)
├── results/                  # Output logs / batch_results.csv (generated after running)
├── docs/
│   └── methodology.md        # Detailed explanation of each processing stage
├── README.md
├── LICENSE
└── .gitignore
```

---

##  Requirements

- MATLAB (R2018b or later recommended)
- **Image Processing Toolbox** (for `imread`, `edge`, morphology functions, `regionprops`)
- **Computer Vision Toolbox** (for the built-in `ocr()` function)

> If the Computer Vision Toolbox isn't available, the pipeline still detects and crops the plate region — only character recognition (OCR) will be skipped, with a warning printed to the console.

---

### Batch test (multiple images / lighting conditions)
```matlab
cd src
batchTest
```
This processes every image in `images/`, prints a results table, and saves it to `results/batch_results.csv`.

---

##  Testing Notes

The system was validated against sample images captured under different conditions to check robustness:

| Condition | Handling Technique |
|---|---|
| Low light / underexposed | Adaptive histogram equalization (`adapthisteq`) boosts local contrast |
| Glare / overexposed | Median filtering suppresses bright noise before edge detection |
| Angled / skewed plates | Aspect-ratio filtering tolerant of moderate skew (2:1–6:1 range) |
| Cluttered background | `bwareaopen` and morphological filtering remove non-plate blobs |

---

## Key Concepts Applied

- Grayscale conversion & noise filtering
- Adaptive contrast enhancement (CLAHE)
- Sobel edge detection
- Morphological operations (dilation, hole filling, area opening)
- Connected component / blob analysis (`regionprops`)
- Heuristic region-of-interest filtering
- Adaptive image binarization
- Optical Character Recognition (OCR)

---

## Possible Extensions
- Replace heuristic filtering with a trained plate-detector (e.g., YOLO / Haar cascade / `vehicleDetectorFasterRCNN`)
- Add perspective correction for angled plates before OCR
- Extend OCR character set to support regional/international plate formats
- Package as a MATLAB App (`appdesigner`) with a simple upload-and-detect GUI

---

##  License
This project is licensed under the [MIT License](LICENSE).v
