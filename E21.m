clear all
close all
clc
im1=imread('data/images/lena.tif');
im2=imread('data/images/smandril.tif');
im3=imread('data/images/sail.tif');
pmf1=stats_marg(im1);
pmf2=stats_marg(im2);
pmf3=stats_marg(im3);
h1=calc_entropy(pmf1);
h2=calc_entropy(pmf2);
h3=calc_entropy(pmf3);
im = [im1(:);im2(:);im3(:)];
pmf= stats_marg(im);
H1 = - sum(pmf1.*log2(pmf'));
H2 = - sum(pmf2.*log2(pmf'));
H3 = - sum(pmf3.*log2(pmf'));
delt1=H1-h1;
delt2=H2-h2;
delt3=H3-h3;