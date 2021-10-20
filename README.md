# Star-DGT for CS and Denoising

Code for implementation of the experiments of the articles (1) "Kouni, V., & Rauhut, H. (2021). Spark Deficient Gabor Frame Provides a Novel Analysis Operator for Compressed Sensing. arXiv preprint arXiv:2103.11233" (`Compressed Sensing` folder) and (2) "Kouni, V., & Rauhut, H. (2021). Star DGT: a Robust Gabor Transform for Speech Denoising. arXiv preprint arXiv:2104.14468" (`Speech Denoising` folder).

To run the scripts, the following dependencies are needed:
a) packages `LTFAT` (http://ltfat.org/), `TFOCS` (http://cvxr.com/tfocs/) and `Wavelab` (https://statweb.stanford.edu/~wavelab/)

b) TIMIT dataset (https://deepai.org/dataset/timit).

## Compressed Sensing

The corresponding folder contains three MATLAB scripts. `star_window.m` calculates the desired star window vector. `starCS_synthetic.m` and `starCS_realworld.m` implement the experiments regarding analysis CS of synthetic and real-world data respectively, as written in article (1).

## Speech Denoising

The corresponding folder contains four MATLAB scripts. `star_window.m` calculates the desired star window vector. `gaussian_denoise.m`, `blue_denoise.m` and `pink_denoise.m` implement the experiments regarding robustness of star-DGT transform in the case of Gaussian, blue and pink noise respectively, as written in article (2).
