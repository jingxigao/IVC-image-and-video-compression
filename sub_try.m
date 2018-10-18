%% start with E4_1e

clear all;
path(path,'encoder')            % make the encoder-functions visible to matlab
path(path,'decoder')            % make the encoder-functions visible to matlab
path(path,'analysis')           % make the encoder-functions visible to matlab

names = 'sequences/foreman20_40_RGB/foreman0020.bmp';
names2 = 'sequences/foreman20_40_RGB/foreman00';

PSNR = zeros(21,1);
b_rate = zeros(21,1);

% 6 iterations ( 6 different rate with different PSNR ) 
PSNR_av = zeros(6,1);
b_rate_av = zeros(6,1);

factor = [0.3,0.4,0.6,1,1.5,2];
for it=1:6
    
a = factor(it);  %scalar factor quantization
input_image_filename = names;
ORIGINAL_image = double( imread( input_image_filename ) ) ;
[ORIGINAL_image_Y, ORIGINAL_image_Cb, ORIGINAL_image_Cr] = ictRGB2YCbCr(ORIGINAL_image(:,:,1), ORIGINAL_image(:,:,2),ORIGINAL_image(:,:,3));

%% use lena_small to build Huffman table
lena = 'data/images/lena_small.tif';
Huffman_image = double( imread( lena ) ) ;
[Huffman_image_Y, Huffman_image_Cb, Huffman_image_Cr] = ictRGB2YCbCr(Huffman_image(:,:,1), Huffman_image(:,:,2),Huffman_image(:,:,3));

%go through each 8x8 block
enc_Y = [];
enc_Cb = [];
enc_Cr = [];
%blocks are read from left to right and then from top to bottom
for i = 1:8:size(Huffman_image_Y,1)
    for j = 1:8:size(Huffman_image_Y,2)
        [block_Y] = DCT8x8(Huffman_image_Y(i:i+7, j:j+7)); %perform DCT
        [block_Cb] = DCT8x8(Huffman_image_Cb(i:i+7, j:j+7));
        [block_Cr] = DCT8x8(Huffman_image_Cr(i:i+7, j:j+7));

        %for each block perform quatization(E4-1b)
        [ block_quant_Y, block_quant_Cb, block_quant_Cr ] = Quant8x8( block_Y, block_Cb, block_Cr,a );

        
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
 

z_enc = [enc_Y, enc_Cb, enc_Cr];

extended_z_enc = -200:500; %this contains all values between the minimum 
                            %and the maximum value in the encoded vector 
occur = histc(z_enc, extended_z_enc);
PMF = occur/sum(occur);
[ BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman( PMF );

%% encode foreman

[bytestream,L,ss1,ss2] = IntraEncode(ORIGINAL_image_Y, ORIGINAL_image_Cb, ORIGINAL_image_Cr,BinCode,Codelengths,a);


%% decode
RECONS_image  = IntraDecode(bytestream, BinaryTree, L,ss1,ss2,a);
[RECONS_image_Y(:,:,1),RECONS_image_Cb(:,:,1),RECONS_image_Cr(:,:,1)] = ictRGB2YCbCr (RECONS_image(:,:,1,1),RECONS_image(:,:,2,1),RECONS_image(:,:,3,1));
PSNR(1,1)= calcPSNR( 3,ORIGINAL_image(:,:,:,1), RECONS_image(:,:,:,1));
b_rate_ini = 8*length(bytestream)/(size(ORIGINAL_image,1) *size(ORIGINAL_image,2));
b_rate(1,1)= b_rate_ini; 


%% For the PMF of the motion vectors - min and max (+-4 pixels)
m1 = -8;
m2 =8;


%% transmit the other frames  (only calculate in Y)
for f = 21:40
    
    %read all frames
    input_image_filename = [names2,num2str(f), '.bmp'];
    ORIGINAL_image(:,:,:,f-19) = double( imread( input_image_filename ) ) ;
    
    %do color transform for all frames 
    %(e51-b)
    [ORIGINAL_image_Y(:,:,f-19), ORIGINAL_image_Cb(:,:,f-19), ORIGINAL_image_Cr(:,:,f-19)] = ictRGB2YCbCr(ORIGINAL_image(:,:,1,f-19), ORIGINAL_image(:,:,2,f-19),ORIGINAL_image(:,:,3,f-19));

     
            
            %search for +-4pixel find the least ssd vector
        [Y_curr_sub,Cb_curr_sub,Cr_curr_sub]=chroma_sample(ORIGINAL_image_Y(:,:,f-19), ORIGINAL_image_Cb(:,:,f-19), ORIGINAL_image_Cr(:,:,f-19));
        [Y_recon_sub4,Cb_recon_sub4,Cr_recon_sub4]=chroma_sample(RECONS_image_Y(:,:,f-20),RECONS_image_Cb(:,:,f-20),RECONS_image_Cr(:,:,f-20));
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub4,Cb_recon_sub4,Cr_recon_sub4,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
            
        [ b_rate(f-19), Y_recon, Cb_recon, Cr_recon] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        Y_recon_sub4=Y_recon;Cb_recon_sub4=Cb_recon;Cr_recon_sub4=Cr_recon;
        [Cb_up,Cr_up] = chroma_upsample(Cb_recon_sub4,Cr_recon_sub4);

     
     [RECONS_image(:,:,1,f-19),RECONS_image(:,:,2,f-19),RECONS_image(:,:,3,f-19)] = ictYCbCr2RGB(Y_recon_sub4,Cb_up,Cr_up);
     
     RECONS_image_Y(:,:,f-19)=Y_recon_sub4;
     RECONS_image_Cb(:,:,f-19)=Cb_up;
     RECONS_image_Cr(:,:,f-19)=Cr_up;
%      
%      figure
%      imshow(RECONS_image(:,:,:,f-19)/255)
        

    PSNR(f-19,1) = calcPSNR( 3,ORIGINAL_image(:,:,:,f-19), RECONS_image(:,:,:,f-19));


end

PSNR_av(it,1) = mean(PSNR(:));
b_rate_av(it,1) = mean(b_rate(:));


end

figure(3)
hold on
plot(b_rate_av(:,1),PSNR_av(:,1), '*-b')
legend('Foreman')