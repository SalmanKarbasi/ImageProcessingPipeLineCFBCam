%%%Thie file is written by Salman Karbasi salman.karbasi@gmail.com
%%%Denoising will be the last stage of of the processing pipeline
%%Load the input image 
 yRGB = im2double(imread('CCMgamma1-HistAdjustSshaped.tif'));
%%%sigma parameter in BM3D denosoising method
sigma=15;
[NA, yRGB_est] = CBM3D(1, yRGB, sigma, 'yCbCr');
%%%the output imahe is in yRGB_est
imwrite(1*yRGB_est, 'CCMgamma1-HistAdjustSshaped-BM3Dsigma15.tif', 'tif')
%%%%harpern the image if needed using unsharp masking
Sharpened = imsharpen(yRGB_est,'Radius', 2, 'Amount', 0.5); 
imwrite(Sharpened, 'CCMgamma1-HistAdjustSshaped-BM3Dsigma15-SharpenedR2A1.tif', 'tif')


    