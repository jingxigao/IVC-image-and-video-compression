clear all;
clc;
input_image_filename1 = 'data\images\lena_small.tif';
ORIGINAL_image = double(imread( input_image_filename1 ))/255;
M = 1;

for k = 1:3
    for i = 1:size(ORIGINAL_image,1)
        for j = 1:size(ORIGINAL_image,2)
            Quantized_image(i,j,k) = UniQuant(ORIGINAL_image(i,j,k), M);
            Recon_image(i,j,k) = InvUniQuant(Quantized_image(i,j,k), M);
        end
    end
end

figure(1)
imagesc(Recon_image)

PSNR = calcPSNR2( 3,(2^M-1)*ORIGINAL_image, (2^M-1)*Recon_image, M );
