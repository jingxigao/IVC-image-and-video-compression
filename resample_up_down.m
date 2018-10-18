function [ output_image,down] = resample_up_down( input_image )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
input_im_padding = padarray(input_image,[4 4],'symmetric');

down_column(:,:,1) = resample(input_im_padding(:,:,1), 1,2,3);
down_column(:,:,2) = resample(input_im_padding(:,:,2), 1,2,3);
down_column(:,:,3) = resample(input_im_padding(:,:,3), 1,2,3);

down(:,:,1) = resample(down_column(:,:,1)', 1,2,3)';
down(:,:,2) = resample(down_column(:,:,2)', 1,2,3)';
down(:,:,3) = resample(down_column(:,:,3)', 1,2,3)';

down = down(3:end-2, 3:end-2, :);



%upsample
down2_padding = padarray(down,[2 2],'symmetric');
up_column(:,:,1) = resample(down2_padding(:,:,1), 2,1,3);
up_column(:,:,2) = resample(down2_padding(:,:,2), 2,1,3);
up_column(:,:,3) = resample(down2_padding(:,:,3), 2,1,3);

up(:,:,1) = resample(up_column(:,:,1)',2,1,3)';
up(:,:,2) = resample(up_column(:,:,2)',2,1,3)';
up(:,:,3) = resample(up_column(:,:,3)',2,1,3)';

output_image = up(5:end-4, 5:end-4, :);

end


