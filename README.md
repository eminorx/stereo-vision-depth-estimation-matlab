# Stereo Vision Depth Estimation with MATLAB

This project was developed as part of a Computer Vision course. It focuses on estimating object depth using a stereo vision approach in MATLAB.

Two images of the same scene were captured from slightly different horizontal camera positions. The camera was shifted approximately **10 cm**, and the horizontal pixel differences between corresponding objects were used to calculate **disparity** and analyze the relationship between disparity and real-world depth.

## Main Steps

- Loaded left and right stereo images
- Added salt & pepper noise to test filtering
- Applied median filtering for noise reduction
- Used ROI-based local segmentation for object detection
- Extracted object features using MATLAB `regionprops`
- Calculated centroid, bounding box, ellipse, aspect ratio, circularity, and Hu moments
- Matched objects using SSD-based feature comparison
- Calculated disparity values from centroid differences
- Estimated approximate focal length from the disparity-depth relationship

## Results

| Metric | Result |
|---|---:|
| Baseline distance | 0.10 m |
| Number of objects | 10 |
| Estimated focal length | 1001.70 pixels |
| Linear fit R² | 0.6516 |

## Files

src/main.m
images/sol.jpg.jpeg
images/sag.jpg.jpeg
data/sol_goruntu_ozellikleri.csv
data/sag_goruntu_ozellikleri.csv
data/ssd_eslestirme_tablosu.csv
data/disparite_z_tablosu.csv

## Key Learnings

This project helped me practice stereo vision geometry, image filtering, ROI-based segmentation, feature extraction, object matching, disparity calculation, and focal length estimation using MATLAB.

## Author

Emin Imanov
Electrical and Electronics Engineering Student
Interested in Computer Vision, Data Science, Machine Learning, and Deep Learning
