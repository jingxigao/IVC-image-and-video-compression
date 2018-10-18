clear all
close all
clc
im1=imread('data/images/lena.tif');
pmf_joint=stats_joint(im1);
pmf=pmf_joint(pmf_joint>0);
H=calc_entropy(pmf);
figure
mesh(1:256,1:256,pmf_joint);