clc
clear all
close all

path(path,'encoder')            % make the encoder-functions visible to matlab
path(path,'decoder')            % make the encoder-functions visible to matlab
path(path,'analysis')           % make the encoder-functions visible to matlab
load huffman.mat;
im=double(imread('data/images/lena.tif'));
[h,w,d]=size(im);

%RGB2YCbCr
[im1(:,:,1), im1(:,:,2), im1(:,:,3)] = ictRGB2YCbCr(im(:,:,1), im(:,:,2),im(:,:,3));
Y=im1(:,:,1);
%downsample
Cb=resample(resample(im1(:,:,2),1,2)',1,2)';
Cr=resample(resample(im1(:,:,3),1,2)',1,2)';
Dy=Y;
Dcb=Cb;
Dcr=Cr;

pre_Y=zeros(h,w);
pre_Cb=zeros(h/2,w/2);
pre_Cr=zeros(h/2,w/2);
err_Y=zeros(h-1,w-1);
err_Cb=zeros(h/2-1,w/2-1);
err_Cr=zeros(h/2-1,w/2-1);
%%
% produce the error image
for i=1:h-1
    for j=1:w-1
      pre_Y(i+1,j+1) = (7/8)*Dy(i+1,j)-(1/2)*Dy(i,j)+(5/8)*Dy(i,j+1);
      err_Y(i,j)=round(Y(i+1,j+1)-pre_Y(i+1,j+1));
      Dy(i+1,j+1)=err_Y(i,j)+pre_Y(i+1,j+1);
      
    end
end

for i=1:h/2-1
    for j=1:w/2-1
     pre_Cb(i+1,j+1) = (3/8)*Dcb(i+1,j)-(1/4)*Dcb(i,j)+(7/8)*Dcb(i,j+1);
     err_Cb(i,j)=round(Cb(i+1,j+1)-pre_Cb(i+1,j+1));
     Dcb(i+1,j+1)=err_Cb(i,j)+pre_Cb(i+1,j+1);
    
     pre_Cr(i+1,j+1) = (3/8)*Dcr(i+1,j)-(1/4)*Dcr(i,j)+(7/8)*Dcr(i,j+1);
     err_Cr(i,j)=round(Dcr(i+1,j+1)-pre_Cr(i+1,j+1));
     Dcr(i+1,j+1)=err_Cr(i,j)+pre_Cr(i+1,j+1);
    end
end

a=err_Y(:);
b=err_Cb(:);
c=err_Cr(:);
err=[a;b;c];
minerr=min(err);
%%
bytestream=enc_huffman_new(err+256,BinCode,Codelengths);
e=length(bytestream);
br=8*e/(h*w);
%%
err_re=dec_huffman_new(bytestream,BinaryTree,length(err))-256;
err_re_Y=err_re(1,1:511*511);
err_re_Cb=err_re(1,511*511+1:511*511+255*255);
err_re_Cr=err_re(1,511*511+1+255*255:end);


err_re_Y=reshape(err_re_Y,511,511);
err_re_Cb=reshape(err_re_Cb,255,255);
err_re_Cr=reshape(err_re_Cr,255,255);

R_Y=zeros(h,w);
R_Cb=zeros(h/2,w/2);
R_Cr=zeros(h/2,w/2);
R_Y(1,:)=Y(1,:);
R_Y(:,1)=Y(:,1);
R_Cb(1,:)=Cb(1,:);
R_Cb(:,1)=Cb(:,1);
R_Cr(1,:)=Cr(1,:);
R_Cr(:,1)=Cr(:,1);
pre_Y=zeros(h,w);
pre_Cb=zeros(h/2,w/2);
pre_Cr=zeros(h/2,w/2);

for i=1:h-1
    for j=1:w-1
      pre_Y(i+1,j+1) =(7/8)*R_Y(i+1,j)-(1/2)*R_Y(i,j) +(5/8)*R_Y(i,j+1);
      R_Y(i+1,j+1)=err_re_Y(i,j)+pre_Y(i+1,j+1);
    end   
end

for i=1:h/2-1
    for j=1:w/2-1
     pre_Cb(i+1,j+1) = (3/8)*R_Cb(i+1,j) -(1/4)*R_Cb(i,j) +(7/8)*R_Cb(i,j+1);
     R_Cb(i+1,j+1)=err_re_Cb(i,j)+pre_Cb(i+1,j+1);
     
     pre_Cr(i+1,j+1) = (3/8)*R_Cr(i+1,j) -(1/4)*R_Cr(i,j) +(7/8)*R_Cr(i,j+1);
     R_Cr(i+1,j+1)=err_re_Cr(i,j)+pre_Cr(i+1,j+1);
    end
end

Cb_new=resample(resample(R_Cb,2,1)',2,1)';
Cr_new=resample(resample(R_Cr,2,1)',2,1)';

im_re(:,:,1)=R_Y;
im_re(:,:,2)=Cb_new;
im_re(:,:,3)=Cr_new;

[im_re_RGB(:,:,1), im_re_RGB(:,:,2), im_re_RGB(:,:,3)] = ictYCbCr2RGB(im_re(:,:,1), im_re(:,:,2),im_re(:,:,3));
cr=24/br;
PSNR=calcPSNR(d, im,im_re_RGB);
figure
imshow(im/256);
figure
imshow(im_re_RGB/256);
