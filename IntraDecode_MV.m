function [ict_Y,ict_Cb,ict_Cr] = IntraDecode_MV( enc, BinaryTree_MV, len, sz_Y, coe )
% huffman decode and inverse transform coding
% decode runlevel_out from huffman stream
dec = dec_huffman_new( enc, BinaryTree_MV, len ) - 3001;
% decode zigzag_out from runlevel_out, i.e. inverse run level 
derunlevel_out = ZeroRunDec_MV( dec, 64 );
derunlevel_out = reshape( derunlevel_out, 1, 64, [] );
% pre-allocation
dezigzag_out = zeros( 8, 8, size(derunlevel_out,3) );
dequant_out = zeros( 8, 8, size(derunlevel_out,3) );
idct_out = zeros( 8, 8, size(derunlevel_out,3) );
ict_Y=zeros(sz_Y);
ict_Cb=zeros(sz_Y(1)/2,sz_Y(2)/2);
ict_Cr=zeros(sz_Y(1)/2,sz_Y(2)/2);
% do following to all blocks
for j = 1:size( derunlevel_out, 3 )
    % inverse zigzag
    dezigzag_out(:,:,j) = DeZigZag8x8( derunlevel_out(:,:,j) );
    % dequantization
    if j <= size( derunlevel_out, 3 )*2/3                  % luminance
        dequant_out(:,:,j) = DeQuantL8x8( dezigzag_out(:,:,j), coe );
    else                                                 % chrominance
        dequant_out(:,:,j) = DeQuantC8x8( dezigzag_out(:,:,j), coe );
    end
    % inverse dct
    idct_out(:,:,j) = IDCT8x8( dequant_out(:,:,j) );
    % order every block back to original image size
end
block_num=1;
for m=1:size(ict_Y,1)/8
    for n=1:size(ict_Y,2)/8
        ict_Y((m-1)*8+1:(m-1)*8+8,(n-1)*8+1:(n-1)*8+8)=idct_out(:,:,block_num);
        block_num=block_num+1;
    end
end
block_num_Cb=1585;
block_num_Cr=1981;
for m=1:size(ict_Y,1)/2/8
    for n=1:size(ict_Y,2)/2/8
        ict_Cb((m-1)*8+1:(m-1)*8+8,(n-1)*8+1:(n-1)*8+8)=idct_out(:,:,block_num_Cb);
        block_num_Cb=block_num_Cb+1;
        ict_Cr((m-1)*8+1:(m-1)*8+8,(n-1)*8+1:(n-1)*8+8)=idct_out(:,:,block_num_Cr);
        block_num_Cr=block_num_Cr+1;
    end
end
    
end
