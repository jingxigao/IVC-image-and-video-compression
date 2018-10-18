function [ dec_y_block, dec_cb_block, dec_cr_block ] = IntraDecodeReal( enc, BinaryTree, len, coe )
% huffman decode and inverse transform coding
% decode runlevel_out from huffman stream
dec = dec_huffman_new( enc, BinaryTree, len ) - 3001;
% decode zigzag_out from runlevel_out, i.e. inverse run level 
derunlevel_out = ZeroRunDec1( dec, 64 );
derunlevel_out = reshape( derunlevel_out, 1, 64, [] );
% pre-allocation
dezigzag_out = zeros( 8, 8, size(derunlevel_out,3) );
dequant_out = zeros( 8, 8, size(derunlevel_out,3) );
idct_out = zeros( 8, 8, size(derunlevel_out,3) );
dec_y_block = zeros( 8, 8, size(derunlevel_out,3)/3 );
dec_cb_block = zeros( 8, 8, size(derunlevel_out,3)/3 );
dec_cr_block = zeros( 8, 8, size(derunlevel_out,3)/3 );
% do following to all blocks
for j = 1:size( derunlevel_out, 3 )
    % inverse zigzag
    dezigzag_out(:,:,j) = DeZigZag8x8( derunlevel_out(:,:,j) );
    % dequantization
    if j <= size( derunlevel_out, 3 )/3                  % luminance
        dequant_out(:,:,j) = DeQuantL8x8( dezigzag_out(:,:,j), coe );
    else                                                 % chrominance
        dequant_out(:,:,j) = DeQuantC8x8( dezigzag_out(:,:,j), coe );
    end
    % inverse dct
    idct_out(:,:,j) = IDCT8x8( dequant_out(:,:,j) );
    % split luminance and chrominance blocks
    if j <= size( derunlevel_out, 3 )/3                  % luminance
        dec_y_block(:,:,j) = idct_out(:,:,j);
    elseif j <= size( derunlevel_out, 3 )/3*2            % cb              
        dec_cb_block(:,:,j-size( derunlevel_out, 3 )/3) = idct_out(:,:,j);
    else
        dec_cr_block(:,:,j-size( derunlevel_out, 3 )/3*2) = idct_out(:,:,j);
    end
end

end

