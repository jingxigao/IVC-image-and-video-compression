clear all
close all
clc
im1=imread('data/images/lena.tif');
[pmf_joint,pmf_cond]=stats_cond(im1);
pmf1=pmf_joint(pmf_joint>0);
pmf2=pmf_cond(pmf_cond>0);
H=-sum(pmf1(:).*log2(pmf2(:)));