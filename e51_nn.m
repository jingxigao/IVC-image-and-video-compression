%% start with E4_1e

clear all;
path(path,'encoder')            % make the encoder-functions visible to matlab
path(path,'decoder')            % make the encoder-functions visible to matlab
path(path,'analysis')           % make the encoder-functions visible to matlab

names = 'sequences/akiyo20_40_RGB/akiyo0020.bmp';
names2 = 'sequences/akiyo20_40_RGB/akiyo00';

tic

PSNR = zeros(21,1);
b_rate = zeros(21,1);

% 6 iterations ( 6 different rate with different PSNR ) 
PSNR_av = zeros(6,1);
b_rate_av = zeros(6,1);


factor = [0.3,0.4,0.6,1,1.5,2];
for it=4:4
    
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
m1 = -4;
m2 = 4;


%% transmit the other frames  (only calculate in Y)
for f = 21:40
    
    %read all frames
    input_image_filename = [names2,num2str(f), '.bmp'];
    ORIGINAL_image(:,:,:,f-19) = double( imread( input_image_filename ) ) ;
    
    %do color transform for all frames 
    %(e51-b)
    [ORIGINAL_image_Y(:,:,f-19), ORIGINAL_image_Cb(:,:,f-19), ORIGINAL_image_Cr(:,:,f-19)] = ictRGB2YCbCr(ORIGINAL_image(:,:,1,f-19), ORIGINAL_image(:,:,2,f-19),ORIGINAL_image(:,:,3,f-19));
    
    %{
    [~, ~, ~, data_fr_next , ss1, ss2 ] = IntraEncode(ORIGINAL_image_Y(:,:,f-19), ORIGINAL_image_Cb(:,:,f-19), ORIGINAL_image_Cr(:,:,f-19));
    bytestream_fr_next = enc_huffman_new(data_fr_next, BinCode, Codelengths);
    %}
    
    %e51-c
    CONCAT_im_Y = [];
    CONCAT_im_Cb = [];
    CONCAT_im_Cr = [];
    M = [];
    
    for i = 1:8:ss1
        for j = 1:8:ss2
            
            ssd = inf;
            %search for +-4pixel find the least ssd vector
            for t1 = -4:4
                for t2 = -4:4
                    if(i+t1 > 0 && i+7+t1 <= ss1 && j+t2 > 0 && j+7+t2 <= ss2)                        
                        reference_block = RECONS_image_Y(i+t1:i+7+t1, j+t2:j+7+t2, f-20);
                        ssd_curr = sum(sum((ORIGINAL_image_Y(i:i+7, j:j+7, f-19) - reference_block).^2));
                                                  
                        if(ssd_curr < ssd) % replace with the new vector
                            motion_vect = [t1 t2];
                            ssd = ssd_curr;
                            good_block = reference_block;
                        end
                    end   
                end   
            end
            
            M = [M; motion_vect];
                
            y = motion_vect(1); 
            x = motion_vect(2);
            
            block_curr_Y = RECONS_image_Y(i+y:i+7+y, j+x:j+7+x, f-20);
            block_curr_Cb = RECONS_image_Cb(i+y:i+7+y, j+x:j+7+x, f-20);
            block_curr_Cr = RECONS_image_Cr(i+y:i+7+y, j+x:j+7+x, f-20);
            
            %this is the image obtained by shifting blocks with the motion
            %vectors
            CONCAT_im_Y(i:i+7, j:j+7, f-19) = block_curr_Y;
            CONCAT_im_Cb(i:i+7, j:j+7, f-19) = block_curr_Cb;            
            CONCAT_im_Cr(i:i+7, j:j+7, f-19) = block_curr_Cr;
            
            
        end
    end
    
    %e51-d
    %error between the shifted previous frame and the current frame (YCbCr)
    err_Y = ORIGINAL_image_Y(:,:,f-19) - CONCAT_im_Y(:, :, f-19);
    err_Cb = ORIGINAL_image_Cb(:,:,f-19) - CONCAT_im_Cb(:, :, f-19);
    err_Cr = ORIGINAL_image_Cr(:,:,f-19) - CONCAT_im_Cr(:, :, f-19);

    
%% e&f 
%% f ) find huffman code for prediction error
%% new f for huffman table bulid
if( f==21)
enc_Y = [];
enc_Cb = [];
enc_Cr = [];
%blocks are read from left to right and then from top to bottom
for i = 1:8:size(err_Y,1)
    for j = 1:8:size(err_Y,2)
        [block_Y] = DCT8x8(err_Y(i:i+7, j:j+7)); %perform DCT
        [block_Cb] = DCT8x8(err_Cb(i:i+7, j:j+7));
        [block_Cr] = DCT8x8(err_Cr(i:i+7, j:j+7));

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
data_curr = z_enc + 201; %add 201 so that the first value is not negative but 1


extended_z_enc = -200:500; %this contains all values between the minimum 
                            %and the maximum value in the encoded vector 
occur = histc(z_enc, extended_z_enc);
PMF = occur/sum(occur);
[ BinaryTree_err, HuffCode_err, BinCode_err, Codelengths_err] = buildHuffman( PMF );
        BTree = BinaryTree_err;
        BCode = BinCode_err;
        CLen = Codelengths_err;
end


%% e )find huffman code for motion vectors
    data_motion = M(:);
    occur_mv = histc(data_motion, m1:m2); %limit the searching area to +-4pixels
if(f == 21)
    PMF_mv = occur_mv/sum(occur_mv);
%     H_mv = calc_entropy(occur_mv);
    [ BinaryTree_mv, HuffCode_mv, BinCode_mv, Codelengths_mv] = buildHuffman( PMF_mv );
end

    data_motion = data_motion + m2 + 1; %add 4+1 so that the first value is not negative but 1


   %% encode----- errors and motion vectors (e&f)
    
    bytestream_mv = enc_huffman_new(data_motion, BinCode_mv, Codelengths_mv); %code for MV
  [bytestream_curr,L,ss1,ss2] = IntraEncode(err_Y,err_Cb,err_Cr, BinCode_err, Codelengths_err,a); %code for error in YCbCr
%     disp(['err_bit_rate=', num2str(length(bytestream_curr)*8/size(ORIGINAL_image,1) /size(ORIGINAL_image,2))]);
%     disp(['mv_bit_rate=', num2str(length(bytestream_mv)*8/size(ORIGINAL_image,1) /size(ORIGINAL_image,2))]);
    
    %% decode
%     [RECONS_err_Y(:,:,f-19),RECONS_err_Cb(:,:,f-19),RECONS_err_Cr(:,:,f-19)] = IntraDecode2(bytestream_curr, BTree, data_curr,ss1, ss2,a );  %here RGB
  RECONS_err  = IntraDecode(bytestream_curr, BTree, L,ss1,ss2,a);
   [RECONS_err_Y(:,:,f-19),RECONS_err_Cb(:,:,f-19),RECONS_err_Cr(:,:,f-19)]= ictRGB2YCbCr(RECONS_err(:,:,1),RECONS_err(:,:,2),RECONS_err(:,:,3));
%decode motion vectors
    output_mv = dec_huffman (bytestream_mv, BinaryTree_mv, max(size(data_motion)));
    output_mv = output_mv - m2 -1; %subtract back to original value 
    
    M1 = reshape(output_mv, size(M));
    count = 1;
%% Reconstruct    
    %reconstruct the matrix consisting of shifting blocks
    for i = 1:8:ss1
        for j = 1:8:ss2
            
            r1 = M1(count,1);
            c1 = M1(count,2);
            block_curr_Y1 = RECONS_image_Y(i+r1:i+7+r1, j+c1:j+7+c1, f-20);
            block_curr_Cb1 = RECONS_image_Cb(i+r1:i+7+r1, j+c1:j+7+c1, f-20);
            block_curr_Cr1 = RECONS_image_Cr(i+r1:i+7+r1, j+c1:j+7+c1, f-20);

            CONCAT_im_Y2(i:i+7, j:j+7, f-19) = block_curr_Y1;
            CONCAT_im_Cb2(i:i+7, j:j+7, f-19) = block_curr_Cb1;            
            CONCAT_im_Cr2(i:i+7, j:j+7, f-19) = block_curr_Cr1;
            
            count = count +1 ;
        end
    end
  
    RECONS_image_Y(:, :, f-19) = CONCAT_im_Y2(:, :, f-19) + RECONS_err_Y(:,:,f-19);
    RECONS_image_Cb(:, :, f-19) = CONCAT_im_Cb2(:, :, f-19) + RECONS_err_Cb(:,:,f-19);
    RECONS_image_Cr(:, :, f-19) = CONCAT_im_Cr2(:, :, f-19) + RECONS_err_Cr(:,:,f-19);
    
      
    [RECONS_image(:,:,1,f-19),RECONS_image(:,:,2,f-19),RECONS_image(:,:,3,f-19)] = ictYCbCr2RGB(RECONS_image_Y(:, :, f-19),RECONS_image_Cb(:, :, f-19),RECONS_image_Cr(:, :, f-19));
 
    figure(1)
    imshow(RECONS_image(:,:,:,f-20)/255)
    
    figure(2)
    imshow(RECONS_image(:,:,:,f-19)/255)
  
    PSNR(f-19,1) = calcPSNR( 3,ORIGINAL_image(:,:,:,f-19), RECONS_image(:,:,:,f-19));
    
    b_rate_curr = 8*(length(bytestream_curr)+length(bytestream_mv))/(size(ORIGINAL_image,1) *size(ORIGINAL_image,2));
    b_rate(f-19,1) = b_rate_curr;

end

PSNR_av(it,1) = mean(PSNR(:));
b_rate_av(it,1) = mean(b_rate(:));


end

toc


figure(3)
hold on
plot(b_rate_av(:,1),PSNR_av(:,1), '*-b')
legend('Foreman')