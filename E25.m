clc
clear all
close all

path(path,'encoder')            % make the encoder-functions visible to matlab
path(path,'decoder')            % make the encoder-functions visible to matlab
path(path,'analysis')           % make the encoder-functions visible to matlab

im= double(imread('data/images/lena_small.tif'));
[h,w,d]=size(im);
[im2(:,:,1), im2(:,:,2), im2(:,:,3)] = ictRGB2YCbCr(im(:,:,1), im(:,:,2),im(:,:,3));
pre_im2=zeros(h,w,d);
for j=1:h-1
     for k=1:w-1
         pre_im2(j+1,k+1,1) = (7/8)*im2(j+1,k,1) -(1/2)*im2(j,k,1) +(5/8)*im2(j,k+1,1);
         pre_im2(j+1,k+1,2) = (3/8)*im2(j+1,k,2) -(1/4)*im2(j,k,2) +(7/8)*im2(j,k+1,2);
         pre_im2(j+1,k+1,3) = (3/8)*im2(j+1,k,3) -(1/4)*im2(j,k,3) +(7/8)*im2(j,k+1,3);
    end
end
err_im2=im2-pre_im2;
A=err_im2;
H = hist(A(:),-255:255);
H = H/sum(H);

[ BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman( H );
l_max=max(Codelengths);
l_min=min(Codelengths);

save huffman.mat BinaryTree HuffCode BinCode Codelengths;
