clear all;
clc;
input_image_filename1 = 'data\images\lena.tif';
ORIGINAL_image = double(imread( input_image_filename1 ))/255;
M = 3;

Quantized_image_LM = LloydMax3(255*ORIGINAL_image(:));
Quantized_image_LM = reshape(Quantized_image_LM, size(ORIGINAL_image));

figure(1)
imagesc(Quantized_image_LM/255)

PSNR_LM = calcPSNR2( 3,255*ORIGINAL_image, Quantized_image_LM, 8 );
