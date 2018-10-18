function [ BinaryTree_MV, enc, len ] = IntraEncode_MV( ict_Y,ict_Cb,ict_Cr , coe )
% transform coding, train Huffman and encode 
% seperate into 8*8 blocks
block_out = block8x8( ict_Y,ict_Cb,ict_Cr );
% pre-allocation
dct_out = zeros( size( block_out ) );
quant_out = zeros( size( block_out ) );
zigzag_out = zeros( 1, 64, size( block_out, 3 ) );
runlevel_out = [];
% do following to all blocks
for i = 1:size( block_out, 3 )
    % dct to 8*8 block
    dct_out(:,:,i) = DCT8x8( block_out(:,:,i) );
    % quantization to 8*8 block
    if i <= size( block_out, 3 )*2/3      % luminance quantization table
        quant_out(:,:,i) = QuantL8x8( dct_out(:,:,i), coe );
    else                                % chrominance quantization table
        quant_out(:,:,i) = QuantC8x8( dct_out(:,:,i), coe );
    end
    % zigzag to 8*8 block
    zigzag_out(:,:,i) = ZigZag8x8( quant_out(:,:,i) );
    % runlevel to 1*64 zigzag stream
    runlevel_out = [ runlevel_out ZeroRunEnc_MV( zigzag_out(:,:,i) )];
end
% train huffman table
PMF = stats_marg( runlevel_out, -3000:1000 );
[BinaryTree_MV, ~, BinCode, Codelengths] = buildHuffman(PMF);
% huffman encode
enc = enc_huffman_new( runlevel_out + 3001, BinCode, Codelengths);
% output the length of runlevel_out for decoding
len = length(runlevel_out);

end