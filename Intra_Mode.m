function [ bit_rate_still, PSNR_still, Y_recon, Cb_recon, Cr_recon ] = Intra_Mode( imageseq, coe )
% intra prediction to first frame

% intra prediction -> predicted block and corresponding mode
[ y_block, y_mode ] = LumaIntraEnc( imageseq(:,:,1) );
[ cb_block, cb_mode ] = ChromaIntraEnc( imageseq(:,:,2) );
[ cr_block, cr_mode ] = ChromaIntraEnc( imageseq(:,:,3) );

% encode mode
% stack all modes together
mode = [ y_mode cb_mode cr_mode ];
% use current mode to train its huffman table then encode
PMF_mode = stats_marg( mode, 0:9 );
[BinaryTree_mode, ~, BinCode_mode, Codelengths_mode] = buildHuffman(PMF_mode);
enc_mode = enc_huffman_new( mode + 1, BinCode_mode, Codelengths_mode);
        
% encode original/error blocks
% stack all blocks together
intra_block( :,:,1:size(y_block,3) ) = y_block;
intra_block( :,:,size(y_block,3)+1:size(y_block,3)+size(cb_block,3) ) = cb_block;
intra_block( :,:,size(y_block,3)+size(cb_block,3)+1:size(y_block,3)+size(cb_block,3)+size(cr_block,3) ) = cr_block;
% transform coding and huffman encode 
[ BinaryTree_first, enc_first, len_first ] = IntraEncodeReal( intra_block, coe );
% calculate bit rate, no encoded mv for first frame
bit_rate_still = 8 * ( length(enc_first) + length(enc_mode) ) / ( size(imageseq,1) * size(imageseq,2) );

% decode mode
% Huffman decoding at receiver 
dec_mode = dec_huffman_new( enc_mode, BinaryTree_mode, length(mode) ) - 1; % dec_mode = mode
% split dec_mode
dec_y_mode = dec_mode(1:length(dec_mode)/3);
dec_cb_mode = dec_mode(length(dec_mode)/3+1:length(dec_mode)/3*2);
dec_cr_mode = dec_mode(length(dec_mode)/3*2+1:end);

% decode original/error blocks
% huffman decode and inverse transform coding
[ dec_y_block, dec_cb_block, dec_cr_block ] = IntraDecodeReal( enc_first, BinaryTree_first, len_first, coe );
% inverse intra prediction
recon_ict(:,:,1) = LumaIntraDec( dec_y_block, dec_y_mode, size(imageseq(:,:,1)) );
recon_ict(:,:,2) = ChromaIntraDec( dec_cb_block, dec_cb_mode, size(imageseq(:,:,2)) );
recon_ict(:,:,3) = ChromaIntraDec( dec_cr_block, dec_cr_mode, size(imageseq(:,:,3)) );
% 2:1 subsample for the Y Cb Cr for the reconstruct image of the first frame xu
Y_recon=recon_ict(:,:,1);
Cb_recon=recon_ict(:,:,2);
Cr_recon=recon_ict(:,:,3);
% calculate PSNR for first frames
[imageseq_RGB(:,:,1),imageseq_RGB(:,:,2),imageseq_RGB(:,:,3)]=ictYCbCr2RGB(imageseq(:,:,1),imageseq(:,:,2),imageseq(:,:,3));
[recon_RGB(:,:,1),recon_RGB(:,:,2),recon_RGB(:,:,3)]=ictYCbCr2RGB(Y_recon,Cb_recon,Cr_recon);
PSNR_still = calcPSNR(3, imageseq_RGB,recon_RGB );
     figure(1)
     imshow(recon_RGB/255)
     figure(2)
     imshow(imageseq_RGB/255)

% PSNR_still = calcPSNR( 3,imageseq,recon_ict );
end

