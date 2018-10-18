function [ block_out_Y, block_out_Cb, block_out_Cr ] = DeQuant8x8( block_in_Y, block_in_Cb, block_in_Cr,factor )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

bl_sz = length(block_in_Y);

L = factor*[16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56
    14 17 22 29 51 87 80 62
    18 55 37 56 68 109 103 77
    24 35 55 64 81 104 113 92
    49 64 78 87 103 121 120 101
    72 92 95 98 112 100 103 99];


C = factor*[17 18 24 47 99 99 99 99;
    18 21 26 66 99 99 99 99;
    24 13 56 99 99 99 99 99;
    47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    ];


        block_out_Y = block_in_Y.* L;
        block_out_Cb = block_in_Cb .* C;
        block_out_Cr = block_in_Cr .* C;

end



