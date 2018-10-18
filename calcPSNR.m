function [ PSNR ] = calcPSNR( ORIGINAL_dimensions,ORIGINAL_image, RECONSTRUCTED_image)
%ORIGINAL_dimensions - number of color planes

MSE = calcMSE( ORIGINAL_dimensions,ORIGINAL_image, RECONSTRUCTED_image );
PSNR = 10*log10(255.^2/MSE);
end

