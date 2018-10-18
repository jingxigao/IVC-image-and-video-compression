%% start with E4_1e

clear all;
path(path,'encoder')            % make the encoder-functions visible to matlab
path(path,'decoder')            % make the encoder-functions visible to matlab
path(path,'analysis')           % make the encoder-functions visible to matlab

names = 'sequences/foreman20_40_RGB/foreman0020.bmp';
names2 = 'sequences/foreman20_40_RGB/foreman00';

PSNR = zeros(21,6);
b_rate = zeros(21,6);

% 6 iterations ( 6 different rate with different PSNR ) 
PSNR_av = zeros(6,1);
b_rate_av = zeros(6,1);

for f = 20:40
    input_image_filename = [names2,num2str(f), '.bmp'];
    ORIGINAL_image(:,:,:,f-19) = double( imread( input_image_filename ) ) ;
    [ORIGINAL_image_Y(:,:,f-19), ORIGINAL_image_Cb(:,:,f-19), ORIGINAL_image_Cr(:,:,f-19)] = ictRGB2YCbCr(ORIGINAL_image(:,:,1,f-19), ORIGINAL_image(:,:,2,f-19),ORIGINAL_image(:,:,3,f-19));
end

groups=3;   
factor = [0.3,0.4,0.6,1,1.5,2];
for it=1:6
    a = factor(it);  %scalar factor quantization
    for g= 1:groups
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

[bytestream,L,ss1,ss2] = IntraEncode(ORIGINAL_image_Y(:,:,(g-1)*7+1), ORIGINAL_image_Cb(:,:,(g-1)*7+1), ORIGINAL_image_Cr(:,:,(g-1)*7+1),BinCode,Codelengths,a);
%% decode
RECONS_image(:,:,:,(g-1)*7+1)  = IntraDecode(bytestream, BinaryTree, L,ss1,ss2,a);
[RECONS_image_Y(:,:,(g-1)*7+1),RECONS_image_Cb(:,:,(g-1)*7+1),RECONS_image_Cr(:,:,(g-1)*7+1)] = ictRGB2YCbCr (RECONS_image(:,:,1,(g-1)*7+1),RECONS_image(:,:,2,(g-1)*7+1),RECONS_image(:,:,3,(g-1)*7+1));
PSNR((g-1)*7+1,it)= calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+1), RECONS_image(:,:,:,(g-1)*7+1));
b_rate_ini = 8*length(bytestream)/(size(ORIGINAL_image,1) *size(ORIGINAL_image,2));
b_rate((g-1)*7+1,it)= b_rate_ini; 

%% transmit the other frames  (only calculate in Y)
    %% ---------use 1st frame to predict the 4th frame-----------    
        [Y_curr_sub,Cb_curr_sub,Cr_curr_sub]=chroma_sample(ORIGINAL_image_Y(:,:,(g-1)*7+4), ORIGINAL_image_Cb(:,:,(g-1)*7+4), ORIGINAL_image_Cr(:,:,(g-1)*7+4));
        [Y_recon_sub1,Cb_recon_sub1,Cr_recon_sub1]=chroma_sample(RECONS_image_Y(:,:,(g-1)*7+1),RECONS_image_Cb(:,:,(g-1)*7+1),RECONS_image_Cr(:,:,(g-1)*7+1));
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub1,Cb_recon_sub1,Cr_recon_sub1,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
            
        [ bit_rate_temp, Y_recon, Cb_recon, Cr_recon] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        Y_recon_sub4=Y_recon;
        Cb_recon_sub4=Cb_recon;
        Cr_recon_sub4=Cr_recon;
        [Cb_up,Cr_up] = chroma_upsample(Cb_recon_sub4,Cr_recon_sub4);
        b_rate((g-1)*7+4,it)= bit_rate_temp;   
     [RECONS_image(:,:,1,(g-1)*7+4),RECONS_image(:,:,2,(g-1)*7+4),RECONS_image(:,:,3,(g-1)*7+4)] = ictYCbCr2RGB(Y_recon_sub4,Cb_up,Cr_up);
     
     RECONS_image_Y(:,:,(g-1)*7+4)=Y_recon_sub4;
     RECONS_image_Cb(:,:,(g-1)*7+4)=Cb_up;
     RECONS_image_Cr(:,:,(g-1)*7+4)=Cr_up;
     PSNR((g-1)*7+4,it) = calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+4), RECONS_image(:,:,:,(g-1)*7+4));
     %% --------use 1st or 4th frame to predict 2nd frame---------------
        [Y_curr_sub,Cb_curr_sub,Cr_curr_sub]=chroma_sample(ORIGINAL_image_Y(:,:,(g-1)*7+2), ORIGINAL_image_Cb(:,:,(g-1)*7+2), ORIGINAL_image_Cr(:,:,(g-1)*7+2));
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub1,Cb_recon_sub1,Cr_recon_sub1,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
        [ bit_rate_temp1, Y_recon1, Cb_recon1, Cr_recon1] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        [Cb_up1,Cr_up1] = chroma_upsample(Cb_recon1,Cr_recon1);
%         b_rate((g-1)*7+2)= bit_rate_temp1;   
     [RECONS_image1(:,:,1,(g-1)*7+2),RECONS_image1(:,:,2,(g-1)*7+2),RECONS_image1(:,:,3,(g-1)*7+2)] = ictYCbCr2RGB(Y_recon1,Cb_up1,Cr_up1);
     
     PSNR1= calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+2), RECONS_image1(:,:,:,(g-1)*7+2));
  %    
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub4,Cb_recon_sub4,Cr_recon_sub4,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
        [ bit_rate_temp2, Y_recon2, Cb_recon2, Cr_recon2] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        [Cb_up2,Cr_up2] = chroma_upsample(Cb_recon2,Cr_recon2);
%         b_rate((g-1)*7+2)= bit_rate_temp2;   
     [RECONS_image2(:,:,1,(g-1)*7+2),RECONS_image2(:,:,2,(g-1)*7+2),RECONS_image2(:,:,3,(g-1)*7+2)] = ictYCbCr2RGB(Y_recon2,Cb_up2,Cr_up2);
     
     PSNR2= calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+2), RECONS_image2(:,:,:,(g-1)*7+2));
     
        if PSNR1>=PSNR2
        b_rate((g-1)*7+2,it)= bit_rate_temp1;
        RECONS_image_Y(:,:,(g-1)*7+2)=Y_recon1;
        RECONS_image_Cb(:,:,(g-1)*7+2)=Cb_up1;
        RECONS_image_Cr(:,:,(g-1)*7+2)=Cr_up1;
        RECONS_image(:,:,:,(g-1)*7+2)=RECONS_image1(:,:,:,(g-1)*7+2);
        PSNR((g-1)*7+2,it)= PSNR1;
        Y_recon_sub2=Y_recon1;Cb_recon_sub2=Cb_recon1;Cr_recon_sub2=Cr_recon1;
        else
        b_rate((g-1)*7+2,it)= bit_rate_temp2;
        RECONS_image_Y(:,:,(g-1)*7+2)=Y_recon2;
        RECONS_image_Cb(:,:,(g-1)*7+2)=Cb_up2;
        RECONS_image_Cr(:,:,(g-1)*7+2)=Cr_up2;
        RECONS_image(:,:,:,(g-1)*7+2)=RECONS_image2(:,:,:,(g-1)*7+2);
        PSNR((g-1)*7+2,it)= PSNR2;
        Y_recon_sub2=Y_recon2;Cb_recon_sub2=Cb_recon2;Cr_recon_sub2=Cr_recon2;
        end
 
   %% -------------use 1st or 4th frame to predict 3rd frame------
        [Y_curr_sub,Cb_curr_sub,Cr_curr_sub]=chroma_sample(ORIGINAL_image_Y(:,:,(g-1)*7+3), ORIGINAL_image_Cb(:,:,(g-1)*7+3), ORIGINAL_image_Cr(:,:,(g-1)*7+3));
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub1,Cb_recon_sub1,Cr_recon_sub1,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
        [ bit_rate_temp1, Y_recon1, Cb_recon1, Cr_recon1] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        [Cb_up1,Cr_up1] = chroma_upsample(Cb_recon1,Cr_recon1);  
        [RECONS_image1(:,:,1,(g-1)*7+3),RECONS_image1(:,:,2,(g-1)*7+3),RECONS_image1(:,:,3,(g-1)*7+3)] = ictYCbCr2RGB(Y_recon1,Cb_up1,Cr_up1);
        PSNR1= calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+3), RECONS_image1(:,:,:,(g-1)*7+3));
  %    
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub4,Cb_recon_sub4,Cr_recon_sub4,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
        [ bit_rate_temp2, Y_recon2, Cb_recon2, Cr_recon2] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        [Cb_up2,Cr_up2] = chroma_upsample(Cb_recon2,Cr_recon2);
        [RECONS_image2(:,:,1,(g-1)*7+3),RECONS_image2(:,:,2,(g-1)*7+3),RECONS_image2(:,:,3,(g-1)*7+3)] = ictYCbCr2RGB(Y_recon2,Cb_up2,Cr_up2);
        PSNR2= calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+3), RECONS_image2(:,:,:,(g-1)*7+3));
     
        if PSNR1>=PSNR2
        b_rate((g-1)*7+3,it)= bit_rate_temp1;
        RECONS_image(:,:,:,(g-1)*7+3)=RECONS_image1(:,:,:,(g-1)*7+3);
        RECONS_image_Y(:,:,(g-1)*7+3)=Y_recon1;
        RECONS_image_Cb(:,:,(g-1)*7+3)=Cb_up1;
        RECONS_image_Cr(:,:,(g-1)*7+3)=Cr_up1;
        PSNR((g-1)*7+3,it)= PSNR1;
        Y_recon_sub3=Y_recon1;Cb_recon_sub3=Cb_recon1;Cr_recon_sub3=Cr_recon1;
        else
        b_rate((g-1)*7+3,it)= bit_rate_temp2;
        RECONS_image(:,:,:,(g-1)*7+3)=RECONS_image2(:,:,:,(g-1)*7+3);
        RECONS_image_Y(:,:,(g-1)*7+3)=Y_recon2;
        RECONS_image_Cb(:,:,(g-1)*7+3)=Cb_up2;
        RECONS_image_Cr(:,:,(g-1)*7+3)=Cr_up2;
        PSNR((g-1)*7+3,it)= PSNR2;
        Y_recon_sub3=Y_recon2;Cb_recon_sub3=Cb_recon2;Cr_recon_sub3=Cr_recon2;
        end
         %% use 4th frame to predict 7th frame
        [Y_curr_sub,Cb_curr_sub,Cr_curr_sub]=chroma_sample(ORIGINAL_image_Y(:,:,(g-1)*7+7), ORIGINAL_image_Cb(:,:,(g-1)*7+7), ORIGINAL_image_Cr(:,:,(g-1)*7+7));
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub4,Cb_recon_sub4,Cr_recon_sub4,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
            
        [ bit_rate_temp, Y_recon, Cb_recon, Cr_recon] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        Y_recon_sub7=Y_recon;
        Cb_recon_sub7=Cb_recon;
        Cr_recon_sub7=Cr_recon;
        [Cb_up,Cr_up] = chroma_upsample(Cb_recon_sub7,Cr_recon_sub7);
        b_rate((g-1)*7+7,it)= bit_rate_temp;   
     [RECONS_image(:,:,1,(g-1)*7+7),RECONS_image(:,:,2,(g-1)*7+7),RECONS_image(:,:,3,(g-1)*7+7)] = ictYCbCr2RGB(Y_recon_sub7,Cb_up,Cr_up);
     
     RECONS_image_Y(:,:,(g-1)*7+7)=Y_recon_sub7;
     RECONS_image_Cb(:,:,(g-1)*7+7)=Cb_up;
     RECONS_image_Cr(:,:,(g-1)*7+7)=Cr_up;
     PSNR((g-1)*7+7,it) = calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+7), RECONS_image(:,:,:,(g-1)*7+7));
%                figure(1)
%           imshow(RECONS_image(:,:,:,(g-1)*7+7)/255)  
%           figure(2)
%           imshow(ORIGINAL_image(:,:,:,(g-1)*7+7)/255) 
        %% use 4th or 7th frame to predict 5th frame
        [Y_curr_sub,Cb_curr_sub,Cr_curr_sub]=chroma_sample(ORIGINAL_image_Y(:,:,(g-1)*7+5), ORIGINAL_image_Cb(:,:,(g-1)*7+5), ORIGINAL_image_Cr(:,:,(g-1)*7+5));
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub4,Cb_recon_sub4,Cr_recon_sub4,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
        [ bit_rate_temp1, Y_recon1, Cb_recon1, Cr_recon1] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        [Cb_up1,Cr_up1] = chroma_upsample(Cb_recon1,Cr_recon1);  
        [RECONS_image1(:,:,1,(g-1)*7+5),RECONS_image1(:,:,2,(g-1)*7+5),RECONS_image1(:,:,3,(g-1)*7+5)] = ictYCbCr2RGB(Y_recon1,Cb_up1,Cr_up1);
        PSNR1= calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+5), RECONS_image1(:,:,:,(g-1)*7+5))
  %    
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub7,Cb_recon_sub7,Cr_recon_sub7,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
        [ bit_rate_temp2, Y_recon2, Cb_recon2, Cr_recon2] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        [Cb_up2,Cr_up2] = chroma_upsample(Cb_recon2,Cr_recon2);
        [RECONS_image2(:,:,1,(g-1)*7+5),RECONS_image2(:,:,2,(g-1)*7+5),RECONS_image2(:,:,3,(g-1)*7+5)] = ictYCbCr2RGB(Y_recon2,Cb_up2,Cr_up2);
        PSNR2= calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+5), RECONS_image2(:,:,:,(g-1)*7+5))
     
        if PSNR1>=PSNR2
        b_rate((g-1)*7+5,it)= bit_rate_temp1;
        RECONS_image(:,:,:,(g-1)*7+5)=RECONS_image1(:,:,:,(g-1)*7+5);
        RECONS_image_Y(:,:,(g-1)*7+5)=Y_recon1;
        RECONS_image_Cb(:,:,(g-1)*7+5)=Cb_up1;
        RECONS_image_Cr(:,:,(g-1)*7+5)=Cr_up1;
        PSNR((g-1)*7+5,it)= PSNR1;
        Y_recon_sub5=Y_recon1;Cb_recon_sub5=Cb_recon1;Cr_recon_sub5=Cr_recon1;
        else
        b_rate((g-1)*7+5,it)= bit_rate_temp2;
        RECONS_image(:,:,:,(g-1)*7+5)=RECONS_image2(:,:,:,(g-1)*7+5);
        RECONS_image_Y(:,:,(g-1)*7+5)=Y_recon2;
        RECONS_image_Cb(:,:,(g-1)*7+5)=Cb_up2;
        RECONS_image_Cr(:,:,(g-1)*7+5)=Cr_up2;
        PSNR((g-1)*7+5,it)= PSNR2;
        Y_recon_sub5=Y_recon2;Cb_recon_sub5=Cb_recon2;Cr_recon_sub5=Cr_recon2;
        end        
        %% use 4th or 7th frame to predict 6th frame
         [Y_curr_sub,Cb_curr_sub,Cr_curr_sub]=chroma_sample(ORIGINAL_image_Y(:,:,(g-1)*7+6), ORIGINAL_image_Cb(:,:,(g-1)*7+6), ORIGINAL_image_Cr(:,:,(g-1)*7+6));
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub4,Cb_recon_sub4,Cr_recon_sub4,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
        [ bit_rate_temp1, Y_recon1, Cb_recon1, Cr_recon1] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        [Cb_up1,Cr_up1] = chroma_upsample(Cb_recon1,Cr_recon1);  
        [RECONS_image1(:,:,1,(g-1)*7+6),RECONS_image1(:,:,2,(g-1)*7+6),RECONS_image1(:,:,3,(g-1)*7+6)] = ictYCbCr2RGB(Y_recon1,Cb_up1,Cr_up1);
        PSNR1= calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+6), RECONS_image1(:,:,:,(g-1)*7+6))
  %    
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub7,Cb_recon_sub7,Cr_recon_sub7,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
        [ bit_rate_temp2, Y_recon2, Cb_recon2, Cr_recon2] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, a,size(Y_curr_sub));
        [Cb_up2,Cr_up2] = chroma_upsample(Cb_recon2,Cr_recon2);
        [RECONS_image2(:,:,1,(g-1)*7+6),RECONS_image2(:,:,2,(g-1)*7+6),RECONS_image2(:,:,3,(g-1)*7+6)] = ictYCbCr2RGB(Y_recon2,Cb_up2,Cr_up2);
        PSNR2= calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+6), RECONS_image2(:,:,:,(g-1)*7+6))
     
        if PSNR1>=PSNR2
        b_rate((g-1)*7+6,it)= bit_rate_temp1;
        RECONS_image(:,:,:,(g-1)*7+6)=RECONS_image1(:,:,:,(g-1)*7+6);
        RECONS_image_Y(:,:,(g-1)*7+6)=Y_recon1;
        RECONS_image_Cb(:,:,(g-1)*7+6)=Cb_up1;
        RECONS_image_Cr(:,:,(g-1)*7+6)=Cr_up1;
        PSNR((g-1)*7+6,it)= PSNR1;
        Y_recon_sub6=Y_recon1;Cb_recon_sub6=Cb_recon1;Cr_recon_sub6=Cr_recon1;
        else
        b_rate((g-1)*7+6,it)= bit_rate_temp2;
        RECONS_image(:,:,:,(g-1)*7+6)=RECONS_image2(:,:,:,(g-1)*7+3);
        RECONS_image_Y(:,:,(g-1)*7+6)=Y_recon2;
        RECONS_image_Cb(:,:,(g-1)*7+6)=Cb_up2;
        RECONS_image_Cr(:,:,(g-1)*7+6)=Cr_up2;
        PSNR((g-1)*7+6,it)= PSNR2;
        Y_recon_sub6=Y_recon2;Cb_recon_sub6=Cb_recon2;Cr_recon_sub6=Cr_recon2;
        end       
        
    end
PSNR_av(it,1) = mean(PSNR(:,it));
b_rate_av(it,1) = mean(b_rate(:,it));

end

figure(3)
hold on
plot(b_rate_av(:,1),PSNR_av(:,1), '*-b')
legend('Foreman')