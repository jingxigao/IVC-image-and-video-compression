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

for f = 20:40
    input_image_filename = [names2,num2str(f), '.bmp'];
    ORIGINAL_image(:,:,:,f-19) = double( imread( input_image_filename ) ) ;
    [ORIGINAL_image_Y(:,:,f-19), ORIGINAL_image_Cb(:,:,f-19), ORIGINAL_image_Cr(:,:,f-19)] = ictRGB2YCbCr(ORIGINAL_image(:,:,1,f-19), ORIGINAL_image(:,:,2,f-19),ORIGINAL_image(:,:,3,f-19));
end

co6 = [1,0.4,0.6,1,1.5,2];
for it=1:6
      coe = co6(it);  %scalar factor quantization
groups=3;    %7 frames in one group
%% transmit the other frames  (only calculate in Y)
for g= 1:groups
%%
%     imageseq_YCbCr1=cat(3,ORIGINAL_image_Y, ORIGINAL_image_Cb, ORIGINAL_image_Cr);
%     [ bit_rate_still, PSNR_still, Y_recon, Cb_recon, Cr_recon] = Intra_Mode(imageseq_YCbCr1,coe ); 
%     [RECONS_image_Y(:,:,1),RECONS_image_Cb(:,:,1),RECONS_image_Cr(:,:,1)] =ictRGB2YCbCr( Y_recon,Cb_recon,Cr_recon);
%     [recon_RGB(:,:,1),recon_RGB(:,:,2),recon_RGB(:,:,3)]=ictYCbCr2RGB(Y_recon,Cb_recon,Cr_recon);
%     PSNR((g-1)*7+1,1)=PSNR_still;
%     b_rate((g-1)*7+1,1)= bit_rate_still;
            %% ---------use first frame to predict the 4th frame-----------
            %search for +-4pixel find the least ssd vector
        [Y_curr_sub,Cb_curr_sub,Cr_curr_sub]=chroma_sample(ORIGINAL_image_Y(:,:,(g-1)*7+4), ORIGINAL_image_Cb(:,:,(g-1)*7+4), ORIGINAL_image_Cr(:,:,(g-1)*7+4));
        [Y_recon_sub1,Cb_recon_sub1,Cr_recon_sub1]=chroma_sample(RECONS_image_Y(:,:,(g-1)*7+1),RECONS_image_Cb(:,:,(g-1)*7+1),RECONS_image_Cr(:,:,(g-1)*7+1));
        [ mv, error_Y,error_Cb,error_Cr, pred_Y1,pred_Cb1,pred_Cr1 ] = blockmatch( Y_recon_sub1,Cb_recon_sub1,Cr_recon_sub1,Y_curr_sub,Cb_curr_sub,Cr_curr_sub);
            
        [ bit_rate_temp, Y_recon, Cb_recon, Cr_recon] =InterMode( mv, error_Y,error_Cb,error_Cr,  pred_Y1,pred_Cb1,pred_Cr1, coe,size(Y_curr_sub));
        Y_recon_sub4=Y_recon;
        Cb_recon_sub4=Cb_recon;
        Cr_recon_sub4=Cr_recon;
        [Cb_up,Cr_up] = chroma_upsample(Cb_recon_sub4,Cr_recon_sub4);
        b_rate((g-1)*7+4)= bit_rate_temp;
        imageseq((g-1)*7+4).psnr(c)=calcPSNR(imageseq((g-1)*7+4).recon,imageseq((g-1)*7+4).YCbCr,8);
     
     [RECONS_image(:,:,1,(g-1)*7+4),RECONS_image(:,:,2,(g-1)*7+4),RECONS_image(:,:,3,(g-1)*7+4)] = ictYCbCr2RGB(Y_recon_sub4,Cb_up,Cr_up);
     
     RECONS_image_Y(:,:,f-19)=Y_recon_sub4;
     RECONS_image_Cb(:,:,f-19)=Cb_up;
     RECONS_image_Cr(:,:,f-19)=Cr_up;

     PSNR((g-1)*7+4,1) = calcPSNR( 3,ORIGINAL_image(:,:,:,(g-1)*7+1), RECONS_image(:,:,:,(g-1)*7+4));   
%      figure(1)
%      imshow(RECONS_image(:,:,:,f-19)/255)
%      figure(2)
%      imshow(ORIGINAL_image(:,:,:,f-19)/255)


end

PSNR_av(it,1) = mean(PSNR(:));
b_rate_av(it,1) = mean(b_rate(:));


end

figure(3)
hold on
plot(b_rate_av(:,1),PSNR_av(:,1), '*-b')
legend('Foreman')