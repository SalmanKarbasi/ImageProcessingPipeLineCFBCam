%%%%%%%
%This code was written by Salman Karbasi for the processing of the SCENICC
%images from curved fiber bundle imager, salman.karbasi@gmail.com
%%%%%%%
function ImageProcessingPipeLine()
%%%%%%%
%%%%%%%
%%Adress of the directory containing your scene images
Address='/Volumes/PSI_LAB 1/01-25-2016-CFB1_35_Indoor/WithAPO/';
DataScene = dir(strcat(Address, '*.dng'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reading the already averaged flat-field
WhiteIm = 0.1*im2double(imread('/Volumes/PSI_LAB 1/01-25-2016-CFB1_35_Indoor/WithAPO/WhiteIms/WhiteIm01_25_Indoor.tiff'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calibrated all the dng images in the "Address"
%%Here I saved the transition images for sake of the paper, feel free to
%%comment out the line containing imwrite 
for kk=1:1%size(DataScene, 1)
Sceneimage = 0.1*im2double(imread(strcat(Address, DataScene(kk).name(1:end))));
%%wiritng the un-calibrated image
imwrite(1*Sceneimage./max(max(Sceneimage)), strcat('GrayRAWSceneimageBeforeCalibration', sprintf('%0.5d', kk),'.tif'), 'tif');
%%%%%%%%flat-field calibaration
CI = 0.2*Sceneimage./WhiteIm; 
%%%% Normalization 
black = 5.1*1e-4; % calculated from the indoor Images I asked Noah to take
saturation = 1;
lin = (CI-black)/(saturation-black);
lin = max(0,min(lin,1));
% writing the flat-field calibrated image in gray scale
imwrite(3*lin./max(max(lin)), strcat('GrayRAWSceneimageAfterCalibration0116_Index',sprintf('%0.5d', kk),'.tif'), 'tif');
%%%%White balanced coefficients, I look at a white or gray region and
%%%%choose these parameters by visually checking the white region
whitebalance_Coeff = [1.2 1.1 1.3]; 
whitebalance_Coeff = whitebalance_Coeff/whitebalance_Coeff(2);
mask = WhiteBalanceFunc(size(lin,1),size(lin,2),whitebalance_Coeff);
balanced_bayer = lin .*mask;
%%%%%%Demosaicing
temp = im2uint16(balanced_bayer);
lin_rgb = im2double(demosaic(temp,'rggb'));
%writing the demosaicking image, the brightness factor was can be ajdusted
%manually or you can normalized your image
imwrite(im2uint16(200*lin_rgb), strcat('Demosaicked_',sprintf('%.5d', kk),'.tif'), 'tif');
%%%Color correction matrix
%%%The demosaicked image in the previous section can be used in Imatest to
%%%caluclate the color correction matrix 
rgb2cam = [5.5796 -0.60044 -0.42857;-1.8265 3.9183 -1.4239;-0.49596 -0.2421 4.2066;-0.055972 -0.051893 -0.023845];
%%%
rgb2cam = rgb2cam(1:3, 1:3);
rgb2cam = inv(rgb2cam');
rgb2cam = rgb2cam ./ repmat(sum(rgb2cam,2),1,3);
cam2rgb = rgb2cam^-1;
lin_srgb = ccmFunc(lin_rgb, cam2rgb);
lin_srgb = max(0,min(lin_srgb,1));
%%%%%%%%%%%%Gamma correction 
 grayim = rgb2gray(lin_srgb);
 grayscale = 0.25/mean(grayim(:));
 bright_srgb = min(1,lin_srgb*grayscale);
 %nl_srgb = bright_srgb.^(0.45); %0.45 % regular gamma correction 
 nl_srgb = GammaFunc(bright_srgb, 0.001, 0.45, 4.5); %(Image, Linearity, gamma, ts) %0.01, 0.4, 4.5)
 %Writing the final calibrated image
 imwrite(1*nl_srgb, strcat('CalibAve5Whites_3391Z_',sprintf('%.5d', kk),'.tif'),'tif');

end
%%%%%%%White balance function using white balance multipliers 
function Out = WhiteBalanceFunc(m,n,whitebalance_Coeff)
    Out = whitebalance_Coeff(2)*ones(m,n); % pre-allocate green values
    Out(1:2:end,1:2:end) = whitebalance_Coeff(1); %red
    Out(2:2:end,2:2:end) = whitebalance_Coeff(3); %blue
end
%%%%%%%%%%%%Color correction matrix 
function corrected = ccmFunc(im,cmatrix)
    r = cmatrix(1,1)*im(:,:,1)+cmatrix(1,2)*im(:,:,2)+cmatrix(1,3)*im(:,:,3);
    g = cmatrix(2,1)*im(:,:,1)+cmatrix(2,2)*im(:,:,2)+cmatrix(2,3)*im(:,:,3);
    b = cmatrix(3,1)*im(:,:,1)+cmatrix(3,2)*im(:,:,2)+cmatrix(3,3)*im(:,:,3);
    corrected = cat(3,r,g,b);
end
%%%%****Gamma correction based on Chapter 6 of the book by Charles Poynton, "A technical
%%%%introduction to Digital Video", Gamma correction, you will find this paper by searching online 
    function CorrectedIm=GammaFunc(Image, Linearity, gamma, ts)
        %ts = 4.5;
        %Linearity=0.018
        %gamma=0.45
        Amap = (Image<=Linearity);
        Bmap = (Image>Linearity);
        %Image(Amap) = ts*Image(Amap); 
        Image(Amap) = ts*Image(Amap); 
        Image(Bmap) = 1.099*Image(Bmap).^gamma-0.099;
        CorrectedIm = Image; 
    end

end
