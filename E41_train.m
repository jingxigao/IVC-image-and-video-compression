path(path,'encoder')            % make the encoder-functions visible to matlab
path(path,'decoder')            % make the encoder-functions visible to matlab
path(path,'analysis')           % make the encoder-functions visible to matlab

clear all;
input_image_filename = 'data/images/lena_small.tif';
ORIGINAL_image = double( imread( input_image_filename ) ) ;
[ORIGINAL_image_Y, ORIGINAL_image_Cb, ORIGINAL_image_Cr] = ictRGB2YCbCr(ORIGINAL_image(:,:,1), ORIGINAL_image(:,:,2),ORIGINAL_image(:,:,3));

%go through each 8x8 block
enc_Y = [];
enc_Cb = [];
enc_Cr = [];
%blocks are read from left to right and then from top to bottom
for i = 1:8:size(ORIGINAL_image_Y,1)
    for j = 1:8:size(ORIGINAL_image_Y,2)
        [block_Y] = DCT8x8(ORIGINAL_image_Y(i:i+7, j:j+7)); %perform DCT
        [block_Cb] = DCT8x8(ORIGINAL_image_Cb(i:i+7, j:j+7));
        [block_Cr] = DCT8x8(ORIGINAL_image_Cr(i:i+7, j:j+7));

        %for each block perform quatization(E4-1b)
        [ block_quant_Y, block_quant_Cb, block_quant_Cr ] = Quant8x8( block_Y, block_Cb, block_Cr,1 );

        
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
        enc_Y = [enc_Y, z_enc_Y_inst];
        enc_Cb = [enc_Cb, z_enc_Cb_inst];
        enc_Cr = [enc_Cr, z_enc_Cr_inst];
    end
end

%% 

z_enc = [enc_Y, enc_Cb, enc_Cr];

extended_z_enc = -200:500; %this contains all values between the minimum 
                            %and the maximum value in the encoded vector 
occur = histc(z_enc, extended_z_enc);
PMF = occur/sum(occur);
[ BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman( PMF );

%%
%Start encode and decode of lena
input_image_filename_L = 'data/images/lena.tif';
ORIGINAL_image_L = double( imread( input_image_filename_L ) ) ;
[ORIGINAL_image_Y_L, ORIGINAL_image_Cb_L, ORIGINAL_image_Cr_L] = ictRGB2YCbCr(ORIGINAL_image_L(:,:,1), ORIGINAL_image_L(:,:,2),ORIGINAL_image_L(:,:,3));
[bytestream,L,ss1,ss2]= IntraEncode(ORIGINAL_image_Y_L, ORIGINAL_image_Cb_L, ORIGINAL_image_Cr_L,BinCode,Codelengths,1 );
b_rate = 8*length(bytestream)/(size(ORIGINAL_image_L,1) *size(ORIGINAL_image_L,2));
RECONS_image  = IntraDecode(bytestream, BinaryTree, L,ss1,ss2,1);
PSNR = calcPSNR( 3,ORIGINAL_image_L, RECONS_image);

%%
%Analyse
figure (1)
imshow(ORIGINAL_image_L/255)
title('ORIGINAL_image')

figure(2)
imshow(RECONS_image/255)
title('RECONS_image')




