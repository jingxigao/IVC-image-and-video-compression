%E(2-4) b.
clear;
clc;

lena = double(imread('data/images/lena.tif'));
lena_ycbcr = ictRGB2YCbCr(lena);
[row, col, dim] = size(lena_ycbcr);

for i = 2:row
    for j = 1:col-1
        predicted_lena2(i,j+1,1) = (7/8)*lena_ycbcr(i,j,1)+(-1/2)*lena_ycbcr(i-1,j,1)+(5/8)*lena_ycbcr(i-1,j+1,1);
    end
end
predicted_lena2(1,:,1) = lena_ycbcr(1,:,1);
predicted_lena2(:,1,1) = lena_ycbcr(:,1,1);

for k = 2:3
    for i = 2:row
        for j = 1:col-1
            predicted_lena2(i,j+1,k) = (3/8)*lena_ycbcr(i,j,k)+(-1/4)*lena_ycbcr(i-1,j,k)+(7/8)*lena_ycbcr(i-1,j+1,k);
        end
    end
end
predicted_lena2(1,:,2) = lena_ycbcr(1,:,2);
predicted_lena2(:,1,2) = lena_ycbcr(:,1,2);

predicted_lena2(1,:,3) = lena_ycbcr(1,:,3);
predicted_lena2(:,1,3) = lena_ycbcr(:,1,3);

error_2 = lena_ycbcr - predicted_lena2;
pmf_error_2 = stats_marg(error_2);
h_error_2 = calc_entropy(pmf_error_2);