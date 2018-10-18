function [ Prefilter1 ] = prefilterlowpass2d( M )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

w1 = [1 2 1; 2 4 2; 1 2 1];
w1 = [1 2 1; 2 4 2; 1 2 1]/(sum(sum(w1)));%Normalization the filter
Prefilter1 = conv2(M,w1,'same');
end

