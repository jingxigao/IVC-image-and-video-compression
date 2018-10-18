% input_image_filename = 'data\images\sail.tif';
% 
% ORIGINAL_image = double( imread( input_image_filename ) ) ;
% [ORIGINAL_image_Y(:,:,1), ORIGINAL_image_Y(:,:,2), ORIGINAL_image_Y(:,:,3)] = ictRGB2YCbCr(ORIGINAL_image(:,:,1), ORIGINAL_image(:,:,2),ORIGINAL_image(:,:,3));
% ORIGINAL_image_Y = ORIGINAL_image_Y / 256;
% 
% down1 = [];
% down2 = [];
% up1 = [];
% up2 = [];
% output_im = [];
% 
% input_im_pad = padarray(ORIGINAL_image_Y,[4 4],'replicate');
% 
% %downsample
% down1(:,:,1) = resample(input_im_pad(:,:,2), 1,2, 3);
% down1(:,:,2) = resample(input_im_pad(:,:,3), 1,2, 3);
% 
% down2(:,:,1) = resample(down1(:,:,1)', 1,2,3)';
% down2(:,:,2) = resample(down1(:,:,2)', 1,2,3)';
% 
% down2 = down2(3:end-2, 3:end-2, :);
% 
% %upsample
% down2_pad = padarray(down2,[4 4],'replicate');
% up1(:,:,1) = resample(down2_pad(:,:,1), 2,1, 3);
% up1(:,:,2) = resample(down2_pad(:,:,2), 2,1, 3);
% 
% up2(:,:,1) = resample(up1(:,:,1)',2,1,3)';
% up2(:,:,2) = resample(up1(:,:,2)',2,1,3)';
% 
% output_im(:,:,1) = ORIGINAL_image_Y(:,:,1);
% output_im(:,:,2:3) = up2(9:end-8, 9:end-8, :);
% 
% RECONSTRUCTED_image = output_im * 256;
% [RECONSTRUCTED_image_2(:,:,1), RECONSTRUCTED_image_2(:,:,2), RECONSTRUCTED_image_2(:,:,3)] = ictYCbCr2RGB(RECONSTRUCTED_image(:,:,1), RECONSTRUCTED_image(:,:,2),RECONSTRUCTED_image(:,:,3));
% 
% RECONSTRUCTED_image_2 = round(RECONSTRUCTED_image_2);
% 
% 
% figure(1)
% imshow(ORIGINAL_image/256)
% title('Original Image')
% 
% figure(2)
% imshow(RECONSTRUCTED_image_2/256)
% title('Reconstructed Image');
% 
% [ ORIGINAL_height, ORIGINAL_width, ORIGINAL_dimensions ] = size( ORIGINAL_image );
% 
% c_ratio = (size(ORIGINAL_image_Y,1)*size(ORIGINAL_image_Y,2)*ORIGINAL_dimensions)/(size(down2,1)*size(down2,2)*2 + size(ORIGINAL_image_Y,1) * size(ORIGINAL_image_Y,2));
% b_rate = 24 / c_ratio;
% 
% PSNR1 = calcPSNR( ORIGINAL_dimensions,ORIGINAL_image, RECONSTRUCTED_image_2);


input_image_filename = 'data\images\sail.tif';
load mydata

ORIGINAL_image = double( imread( input_image_filename ) ) ;
[ORIGINAL_image_Y(:,:,1), ORIGINAL_image_Y(:,:,2), ORIGINAL_image_Y(:,:,3)] = ictRGB2YCbCr(ORIGINAL_image(:,:,1), ORIGINAL_image(:,:,2),ORIGINAL_image(:,:,3));
ORIGINAL_image_Y = ORIGINAL_image_Y / 256;

down1 = [];
down2 = [];
up1 = [];
up2 = [];
output_im = [];


%downsample
down1(:,:,1) = resample(ORIGINAL_image_Y(:,:,2), 1,2, 3);
down1(:,:,2) = resample(ORIGINAL_image_Y(:,:,3), 1,2, 3);

down2(:,:,1) = resample(down1(:,:,1)', 1,2,3)';
down2(:,:,2) = resample(down1(:,:,2)', 1,2,3)';


%upsample

up1(:,:,1) = resample(down2(:,:,1), 2,1, 3);
up1(:,:,2) = resample(down2(:,:,2), 2,1, 3);

up2(:,:,1) = resample(up1(:,:,1)',2,1,3)';
up2(:,:,2) = resample(up1(:,:,2)',2,1,3)';

output_im(:,:,1) = ORIGINAL_image_Y(:,:,1);
output_im(:,:,2) = up2(:,:,1);
output_im(:,:,3) = up2(:,:,2);

RECONSTRUCTED_image = output_im * 256;
[RECONSTRUCTED_image_2(:,:,1), RECONSTRUCTED_image_2(:,:,2), RECONSTRUCTED_image_2(:,:,3)] = ictYCbCr2RGB(RECONSTRUCTED_image(:,:,1), RECONSTRUCTED_image(:,:,2),RECONSTRUCTED_image(:,:,3));

RECONSTRUCTED_image_2 = round(RECONSTRUCTED_image_2);


% figure(1)
% imshow(ORIGINAL_image/256)
% title('Original Image')
% 
% figure(2)
% imshow(RECONSTRUCTED_image_2/256)
% title('Reconstructed Image');

[ ORIGINAL_height, ORIGINAL_width, ORIGINAL_dimensions ] = size( ORIGINAL_image );

c_ratio_1 = (size(ORIGINAL_image_Y,1)*size(ORIGINAL_image_Y,2)*ORIGINAL_dimensions)/(size(down2,1)*size(down2,2)*2 + size(ORIGINAL_image_Y,1) * size(ORIGINAL_image_Y,2));
b_rate_1 = 24 / c_ratio_1;
b_rate=[b_rate;b_rate_1];
PSNR1 = calcPSNR( ORIGINAL_dimensions,ORIGINAL_image, RECONSTRUCTED_image_2);
PSNR=[PSNR;PSNR1]
save mydata  b_rate PSNR