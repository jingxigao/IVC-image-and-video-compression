clear all;
clc;
clear;

lena = double(imread('data/images/lena.tif'));
[width, length, dim] = size(lena);

for k = 1:dim
    for i = 1:width
        for j = 1:length-1
            predicted_lena(i,j+1,k) = lena(i,j,k);
        end
        predicted_lena(i,1,k) = lena(i,1,k);
    end
end
error = (lena - predicted_lena);
pmf_error = stats_marg(error);
h_error = calc_entropy(pmf_error);
% max(error)
% 
% pre_lina= predicted_lena/256;
% imshow( pre_lina, [0 1] );