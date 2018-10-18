clc
clear all
close all

path(path,'encoder')            % make the encoder-functions visible to matlab
path(path,'decoder')            % make the encoder-functions visible to matlab
path(path,'analysis')           % make the encoder-functions visible to matlab

%%
%Training by lena_small and get the codetable
im=double(imread('data/images/lena_small.tif'));
[h,w,d]=size(im);
[im2(:,:,1),im2(:,:,2),im2(:,:,3)]=ictRGB2YCbCr(im(:,:,1),im(:,:,2),im(:,:,3));
im_block=block_splitter(im2,8);
[hb,wb,db]=size(im_block);
%1st DCT
for i=1:db
    im_block_d(:,:,i)=DCT8x8(im_block(:,:,i));
end
%2nd Quantilize
for i=1:db/d
block_q(:,:,1)=im_block_d(:,:,i);
block_q(:,:,2)=im_block_d(:,:,i+db/d);
block_q(:,:,3)=im_block_d(:,:,i+2*db/d);
block_q=Quant8x8(block_q);
im_block_dq(:,:,i)=block_q(:,:,1);
im_block_dq(:,:,i+db/d)=block_q(:,:,2);
im_block_dq(:,:,i+2*db/d)=block_q(:,:,3);
end
%3rd ZigZag 64*64*3-->1*12288
im_c_q_V=zeros(1,64*64*3);
for i=1:db
im_c_q_V((i-1)*64+(1:64))=ZigZag8x8(im_block_dq(:,:,i));
end
%4th RL Enc
zr=ZeroRunEnc(im_c_q_V,h,w,d);
%5th distribution and bulid huffman tree
pmf=hist(zr,-500:1000);
%  aa=max(zr);
%  bb=min(zr);
in_pmf=pmf/sum(pmf)+eps;
[BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman(in_pmf);



%%
%Start codec of lena by using Func IntraEncode and IntraDecode
im_lena=double(imread('data/images/lena.tif'));
[hl,wl,dl]=size(im_lena);
[im_lenna_YCbCr(:,:,1),im_lenna_YCbCr(:,:,2),im_lenna_YCbCr(:,:,3)]=ictRGB2YCbCr(im_lena(:,:,1),im_lena(:,:,2),im_lena(:,:,3));
%1st encode
[bytestream,L,dc]=IntraEncode(im_lenna_YCbCr,BinCode, Codelengths);
br=8*length(bytestream)/(hl*wl);
%2rd decode
im_r=IntraDecode(bytestream,BinaryTree,L,dc,hl,wl,dl);
[im_re(:,:,1),im_re(:,:,2),im_re(:,:,3)]=ictYCbCr2RGB(im_r(:,:,1),im_r(:,:,2),im_r(:,:,3));

%%
%Analyse the re_image br and PSNR
figure
subplot(1,2,1)
imshow(im_lena/256);
title('lena');
subplot(1,2,2)
imshow(im_re/256);
title('reconstructed lena')
% mse=calcMSE(dl,im_lena,im_re);
PSNR=calcPSNR(dl,im_lena,im_re);