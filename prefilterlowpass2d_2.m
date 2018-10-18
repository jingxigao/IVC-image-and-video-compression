function [Prefilter2]=prefilterlowpass2d_2( M )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
w=fir1(40,0.5);
w2=w'*w;
Prefilter2 = conv2(M,w2,'same');
end