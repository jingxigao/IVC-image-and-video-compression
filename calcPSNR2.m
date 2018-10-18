function [ PSNR ] = calcPSNR( ORIGINAL_dimensions,ORIGINAL_image, RECONSTRUCTED_image, BITS )
%ORIGINAL_dimensions - number of color planes

MSE = calcMSE( ORIGINAL_dimensions,ORIGINAL_image, RECONSTRUCTED_image );
PSNR = 10*log10((2.^BITS-ones(size(BITS))).^2/MSE);

end

