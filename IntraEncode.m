function [bytestream,L,ss1,ss2] = IntraEncode(ORIGINAL_image_Y, ORIGINAL_image_Cb, ORIGINAL_image_Cr,BinCode,Codelengths,a )
%encode YCbCr image: dct 8x8, quantization 8x8, zigzag scan, zero run
%length encoding, huffman encoding

% at this point, have YCbCr image, with coefficients between 0 and whatever

ss1=size(ORIGINAL_image_Y,1);
ss2=size(ORIGINAL_image_Y,2);

%go through each 8x8 block
z_enc_Y = [];
z_enc_Cb = [];
z_enc_Cr = [];

%blocks are read from left to right and then from top to bottom
for i = 1:8:size(ORIGINAL_image_Y,1)
    for j = 1:8:size(ORIGINAL_image_Y,2)
        [block_Y] = DCT8x8(ORIGINAL_image_Y(i:i+7, j:j+7)); %perform DCT
        [block_Cb] = DCT8x8(ORIGINAL_image_Cb(i:i+7, j:j+7));
        [block_Cr] = DCT8x8(ORIGINAL_image_Cr(i:i+7, j:j+7));
        
        %for each block perform quatization(E4-1b)
        [ block_quant_Y, block_quant_Cb, block_quant_Cr ] = Quant8x8( block_Y, block_Cb, block_Cr,a);

        %for each block perform zigzag scan
        scan_Y_inst = ZigZag8x8(block_quant_Y)';
        scan_Cb_inst = ZigZag8x8(block_quant_Cb)';
        scan_Cr_inst = ZigZag8x8(block_quant_Cr)';
        
        %for each scan perform zero run encoding
        z_enc_Y_inst = ZeroRunEnc(scan_Y_inst);
        z_enc_Cb_inst = ZeroRunEnc(scan_Cb_inst);
        z_enc_Cr_inst = ZeroRunEnc(scan_Cr_inst);
        
        %add the encoded block to a vector to find the encoded values for
        %each color plane
        z_enc_Y = [z_enc_Y, z_enc_Y_inst];
        z_enc_Cb = [z_enc_Cb, z_enc_Cb_inst];
        z_enc_Cr = [z_enc_Cr, z_enc_Cr_inst];
    end
end

%% 

z_enc = [z_enc_Y, z_enc_Cb, z_enc_Cr];
L=length(z_enc);
data = z_enc + 201;

bytestream = enc_huffman_new(data, BinCode, Codelengths);

end

