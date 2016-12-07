##Image processing pipeline
This pipeline was collected using off the shelf methods for calibrating the fiber-couled camera images. 
The BM3D denoising is a standard denosing technique that worked fine for CFB camera images. 

The image processing pipeline read an image of the fiber-coupled camera. 
Using a pre-taken flat-field, we mitigate the moir\'{e} pattern inherent to the two overlapping grids of the image sensor and the fiber bundles pixel.
This stage should automatically take care of the white balancing, if the white image is taken with the same illumination spectrum. 
In cases that the the white image at the same illumination is not available, a seperate white balance in reqired. 
The next step is demosaicing that was done using the gradient corrected method that is the default function of "demosaic" in in Matlab.

Up to this point, these steps provides us with a colorful image, however, the colored image may not have true colors, because of not correcting for the transmission spectrum of the hardware system, for example the transmission efficiency of the fiber bundle. 
We use the standard color checker pattern to corrrect the colors. The next step is actually straightforward and is just a system gamma correction followed by a constrast adjustment fucntion is case that for example, we need to reduce the noise in the low SNR (dark regions) of the scenes. 
