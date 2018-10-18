function [ bit_rate, Y_recon, Cb_recon, Cr_recon ] = InterMode( mv, error_Y,error_Cb,error_Cr, pred_Y,pred_Cb,pred_Cr, coe, sz  )

% deal with motion vector
% use current mv vector to train its huffman table then encode
PMF_mv = stats_marg( mv, -4.75:0.25:4.75 );
[BinaryTree_mv, ~, BinCode_mv, Codelengths_mv] = buildHuffman(PMF_mv);
enc_mv = enc_huffman_new( 4*mv(:) + 20, BinCode_mv, Codelengths_mv);
% decode Huffman at receiver 
dec_mv = ( reshape( dec_huffman_new( enc_mv, BinaryTree_mv, length(mv(:)) ), [], 2 )  - 20 ) * 0.25;
    
% deal with error
% transform coding and huffman coding to current error frame
[ BinaryTree_error, enc_error, len_error ] =  IntraEncode_MV( error_Y,error_Cb,error_Cr, coe );
% calculate bit rate, sum of encoded mv and encoded error
bit_rate = 8 * ( length(enc_mv) + length(enc_error) ) / ( sz(1) * sz(2) );
% huffman decode and inverse transform coding to error frame
[ recon_error_Y, recon_error_Cb, recon_error_Cr ] = IntraDecode_MV( enc_error, BinaryTree_error, len_error, sz, coe );
    
% predict current frame from reconstructed previous frame and decoded motion vector
% pred = PredBasedMV( recon_ict, dec_mv );
% reconstruct current frame by adding pred + error
Y_recon = recon_error_Y + pred_Y;
Cb_recon = recon_error_Cb + pred_Cb;
Cr_recon = recon_error_Cr + pred_Cr;

end