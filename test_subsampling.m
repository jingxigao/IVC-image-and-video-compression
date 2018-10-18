%Second Test sail.tif
ORIGINAL_image = double( imread( 'data\images\sail.tif' ) ) / 256;

figure(1)
imshow(ORIGINAL_image)

[RECONSTRUCTED_image, down] = resample_up_down(ORIGINAL_image);

figure(2)
imshow(RECONSTRUCTED_image)

ORIGINAL_dimensions = size(ORIGINAL_image, 3);
PSNR1 = calcPSNR( ORIGINAL_dimensions,ORIGINAL_image*256, RECONSTRUCTED_image*256);

c_ratio = (size(ORIGINAL_image,1)*size(ORIGINAL_image,2)*ORIGINAL_dimensions)/(size(down,1)*size(down,2)*3);
b_rate = 24 / c_ratio;


%Second Test lena.tif
ORIGINAL_image2 = double( imread( 'data\images\lena.tif') ) / 256;

figure(3)
imshow(ORIGINAL_image2)

[RECONSTRUCTED_image2, down2] = resample_up_down(ORIGINAL_image2);

figure(4)
imshow(RECONSTRUCTED_image2)

ORIGINAL_dimensions2 = size(ORIGINAL_image2, 3);
PSNR2 = calcPSNR( ORIGINAL_dimensions2,ORIGINAL_image2*256, RECONSTRUCTED_image2*256 );

