function [ RECONS_image ] = IntraDecode(bytestream, BinaryTree, L,ss1,ss2,a)
%decode an encoded image (result is in RGB from 0 to 255)
%ss is size of original image (one dimension)

output = dec_huffman (bytestream, BinaryTree, L);


output = output - 201;

%decode whole string (all color planes)
i = 1;
dec_output = [];
while i <= length(output)

    [dec_output_inst,loc] = ZeroRunDec(output(i:end), 500, 64);
    dec_output = [dec_output dec_output_inst];
    
    i = i + loc - 1;
end

%split into color planes
l = length(dec_output);
dec_output_Y = dec_output(1:l/3);
dec_output_Cb = dec_output(l/3+1:2*l/3);
dec_output_Cr = dec_output(2*l/3+1:end);

j = 1;
    
for r = 1:8:ss1
    for c = 1:8:ss2
        
        %split decoder output in blocks of length 64
        block_64_Y = dec_output_Y(j:j+63);
        block_64_Cb = dec_output_Cb(j:j+63);
        block_64_Cr = dec_output_Cr(j:j+63);
        
        %undo the zigzag scan
        block_8x8_Y = DeZigZag8x8(block_64_Y);
        block_8x8_Cb = DeZigZag8x8(block_64_Cb);
        block_8x8_Cr = DeZigZag8x8(block_64_Cr);
        
        %dequantize each block
        [ block_out_Y, block_out_Cb, block_out_Cr ] = DeQuant8x8( block_8x8_Y, block_8x8_Cb, block_8x8_Cr,a);
        
        %undo DCT
        block_IDCT_Y = IDCT8x8(block_out_Y);
        block_IDCT_Cb = IDCT8x8(block_out_Cb);
        block_IDCT_Cr = IDCT8x8(block_out_Cr);
        
        %concatenate blocks
        recon_Y(r:r+7, c:c+7) = block_IDCT_Y;
        recon_Cb(r:r+7, c:c+7) = block_IDCT_Cb;
        recon_Cr(r:r+7, c:c+7) = block_IDCT_Cr;
   
    
        j = j + 64;
    end
end

[RECONS_image_R, RECONS_image_G, RECONS_image_B] = ictYCbCr2RGB(recon_Y, recon_Cb, recon_Cr);

RECONS_image(:,:,1) = [RECONS_image_R];
RECONS_image(:,:,2) = [RECONS_image_G];
RECONS_image(:,:,3) = [RECONS_image_B];

end

