load mydata
%(c)----Prefiltering
%Step 1
ORIGINAL_image=double(imread('data/images/satpic1.bmp'))/256;
FILTERED_image_R=prefilterlowpass2d_2(ORIGINAL_image(:,:,1));
FILTERED_image_G=prefilterlowpass2d_2(ORIGINAL_image(:,:,2));
FILTERED_image_B=prefilterlowpass2d_2(ORIGINAL_image(:,:,3));
%Step 2
FILTERED_image(:,:,1)=FILTERED_image_R;
FILTERED_image(:,:,2)=FILTERED_image_G;
FILTERED_image(:,:,3)=FILTERED_image_B;
%Step 3: Plot
% subplot(1,2,1);                                                 % prepare to show two images in one window (left)
% imshow(ORIGINAL_image)                              % show original image
% axis image;                                                     % set aspect ratio
% title('Original Image')                                         % draw title
%     
% subplot(1,2,2);                                                 % prepare to show two images in one window (right)
% imshow(FILTERED_image)                       % show reconstructed image
% axis image;                                                     % set aspect ratio
% title('Pre-filtered Image')


%(d)Down and up sampling
%Step 1 Down
FILTERED_image_subsampled_cols = downsample(FILTERED_image,2);
FILTERED_image_subsampled_cols = permute(FILTERED_image_subsampled_cols, [2 1 3]);
FILTERED_image_subsampled = permute(downsample(FILTERED_image_subsampled_cols,2), [2 1 3]);
%Step 2 up
FILTERED_image_2 = upsample(FILTERED_image_subsampled,2);
FILTERED_image_2 = permute(upsample(permute(FILTERED_image_2, [2 1 3]),2),[2 1 3]);
%Step 3 plot
% figure(2)
% imshow(FILTERED_image_2)
% title('Pre-filtered + down&upsample')

%(e) Post-filter
%Step 1
FILTERED_image_RR = prefilterlowpass2d_2( FILTERED_image_2(:,:,1) );
FILTERED_image_GG = prefilterlowpass2d_2( FILTERED_image_2(:,:,2) );
FILTERED_image_BB = prefilterlowpass2d_2( FILTERED_image_2(:,:,3) );
%Step 2
FILTERED_image_3(:,:,1) = 4*FILTERED_image_RR;
FILTERED_image_3(:,:,2) = 4*FILTERED_image_GG;
FILTERED_image_3(:,:,3) = 4*FILTERED_image_BB;
%Step 3: Plot
% figure(3)
% imshow(FILTERED_image_3)
% title('Pre-filtered + down&upsample+Post-filtered')

%calcPSNR
 [ ORIGINAL_height ORIGINAL_width ORIGINAL_dimensions ] = size( ORIGINAL_image ); 
 PSNR1 =calcPSNR( ORIGINAL_dimensions,256*ORIGINAL_image, 256*FILTERED_image_3)
 PSNR=[PSNR;PSNR1];

 c_ratio_1 =  (size(ORIGINAL_image,1)*size(ORIGINAL_image,2)*ORIGINAL_dimensions)/(size(FILTERED_image_subsampled,1)*size(FILTERED_image_subsampled,2)*3);
 b_rate_1 =  (24 / c_ratio_1);
 c_ratio = [c_ratio; c_ratio_1];
 b_rate =  [b_rate;b_rate_1];
%------------------------------------------------------------------------------------------------------------------------------------------------------%
%(e) Without Prefiltering
%Step 1:Down and up sampling
%Down
FILTERED_image_subsampled_cols2 = downsample(ORIGINAL_image,2);
FILTERED_image_subsampled_cols2 = permute(FILTERED_image_subsampled_cols2, [2 1 3]);
FILTERED_image_subsampled2 = permute(downsample(FILTERED_image_subsampled_cols2,2), [2 1 3]);
%Up
FILTERED_image_22 = upsample(FILTERED_image_subsampled2,2);
FILTERED_image_22 = permute(upsample(permute(FILTERED_image_22, [2 1 3]),2),[2 1 3]);
%plot
% figure(4)
% imshow(FILTERED_image_22)
% title('Without Pre-filtered + down&upsample')
%Step 2 Post-filter
%
FILTERED_image_RRR = prefilterlowpass2d_2( FILTERED_image_22(:,:,1) );
FILTERED_image_GGG = prefilterlowpass2d_2( FILTERED_image_22(:,:,2) );
FILTERED_image_BBB = prefilterlowpass2d_2( FILTERED_image_22(:,:,3) );
%
FILTERED_image_4(:,:,1) = 4*FILTERED_image_RRR;
FILTERED_image_4(:,:,2) = 4*FILTERED_image_GGG;
FILTERED_image_4(:,:,3) = 4*FILTERED_image_BBB;
%Plot
% figure(5)
% imshow(FILTERED_image_4)
% title('Pre-filtered + down&upsample+Post-filtered')

%calcPSNR
 [ ORIGINAL_height ORIGINAL_width ORIGINAL_dimensions ] = size( ORIGINAL_image ); 
 PSNR2 =calcPSNR( ORIGINAL_dimensions,256*ORIGINAL_image, 256*FILTERED_image_4);
 PSNR=[PSNR;PSNR2];
 c_ratio=[c_ratio_1;c_ratio];
 b_rate = [b_rate;b_rate_1];




save mydata  b_rate PSNR