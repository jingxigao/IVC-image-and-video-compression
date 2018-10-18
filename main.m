
%--------------------------------------------------------------
%
%
%
%           %%%    %%%       %%%      %%%%%%%%
%           %%%    %%%      %%%     %%%%%%%%%            
%           %%%    %%%     %%%    %%%%
%           %%%    %%%    %%%    %%%
%           %%%    %%%   %%%    %%%
%           %%%    %%%  %%%    %%%
%           %%%    %%% %%%    %%%
%           %%%    %%%%%%    %%%
%           %%%    %%%%%     %%% 
%           %%%    %%%%       %%%%%%%%%%%%
%           %%%    %%%          %%%%%%%%%   MAIN.M
%
%
% main program for IVC scheme prototype
%
%
% input:       none
%
% Course:      Image and Video Compression
%              Prof. Eckehard Steinbach
%
% Author:      Dipl.-Ing. Ingo Bauermann 
%              02.01.2003 (created)
%              15.03.2004 (easier structure implemented)
%
%
%---------------------------------------------------------------

clear all                   % clear workspace
close all                   % close all figures
clc                         % clear command window

path( path, 'analysis' )    % make the analysis-functions visible to matlab
load data/config.mat        % load Parameters and filenames from config.mat
load mydata
%----------------------------------------------------------------
%
%   Main Loop for Parameter Sets
%
%----------------------------------------------------------------

[ dummy SetSize ] = size( ParameterStruct );  % get number of different parameter sets available (defined in config.m)
MSE=[];

for akSet = 1:SetSize                         % and loop through all of them
        
    %---------------------------------------------------------
    % invoke image compressor with current parameter set index
    %---------------------------------------------------------
    if( encode( akSet ) == 0 )      
        fprintf('\n\n-----------------------------------\n ENCODING FAILED - ABORTING\n\n'); % warn the user if encoding fails for some reason
        return;                                         % and leave the program
    else
        if( ParameterStruct( akSet ).verbose == ID_verbose_on ) fprintf('\n- ENCODING COMPLETE\n-----------------------------------\n\n'); end;        % everything seems to be OK
    end;
        
    %-----------------------------------------------------------
    % invoke image decompressor with current parameter set index
    %-----------------------------------------------------------
    if( decode( akSet ) == 0 )
        fprintf('\n\n-----------------------------------\n DECODING FAILED - ABORTING\n\n');
        return
    else
        if( ParameterStruct( akSet ).verbose == ID_verbose_on ) fprintf('\n- DECODING COMPLETE\n-----------------------------------\n\n');   end; 
    end;
    
    
    %----------------------------
    % analyse results
    %----------------------------
    if( ParameterStruct( akSet ).verbose == ID_verbose_on ) fprintf( '\n-----------------------------------\n- ANALYSING\n' ); end;
    
    ORIGINAL_image = double( imread( ParameterStruct( akSet ).input_image_filename ) ) / 256;                 % load original image and convert it to double with value range from 0 to 1
    RECONSTRUCTED_image = double( imread( ParameterStruct( akSet ).reconstructed_image_filename ) ) / 256;    % load reconstructed image...
    [ ORIGINAL_height ORIGINAL_width ORIGINAL_dimensions ] = size( ORIGINAL_image );                          % size of the original image
    [ RECONSTRUCTED_height RECONSTRUCTED_width RECONSTRUCTED_dimensions ] = size( RECONSTRUCTED_image );      % size of reconstructed image
        
    RECONSTRUCTED_image = resizeImage( RECONSTRUCTED_image, ORIGINAL_height, ORIGINAL_width);  % bring the reconstructed image back to the original size

    figure( 'Name', ParameterStruct( akSet ).name )                 % open window  
    
%     subplot(1,2,1);                                                 % prepare to show two images in one window (left)
%     imagesc( ORIGINAL_image, [0 1] );                               % show original image
%     axis image;                                                     % set aspect ratio
%     title('Original Image')                                         % draw title
%     
%     subplot(1,2,2);                                                 % prepare to show two images in one window (right)
%     imagesc( RECONSTRUCTED_image, [0 1] );                          % show reconstructed image
%     axis image;                                                     % set aspect ratio
%     title('Reconstructed Image')                                    % draw title
    
    fid = fopen( ParameterStruct( akSet ).output_stream_filename );      % open bitstream
    if(fid<0)                                                            % if open fails -> bail out
        fprintf( 'Could`n open file "%s" !', output_stream_filename );
        return;
    end
    stream = fread( fid, inf, 'uchar' );                             % read bitstream
    fclose( fid );                                                   % close bitstream
    
    ORIGINAL_size = size( ORIGINAL_image( : ) );                     % get size of original image (Bytes)
    COMPRESSED_size = size( stream( : ) );                           % get size of stream (Bytes)

    if( ParameterStruct( akSet ).verbose == ID_verbose_on ) 
        fprintf('\nParameter set: "%s" (no. %d)\n', ParameterStruct( akSet ).name, akSet );
        fprintf('\nOriginal file:     ~%d kB (%d Bytes)\nBit stream:        ~%d kB (%d Bytes)', round( ORIGINAL_size( 1, 1) / 1000 ), ORIGINAL_size( 1, 1 ), round( COMPRESSED_size( 1, 1) / 1000 ), COMPRESSED_size( 1, 1 ) );
        fprintf('\nCompressionratio:  ~%.2f \n\n',ORIGINAL_size( 1, 1 )/COMPRESSED_size( 1, 1));
		fprintf( '- ANALYSING\n-----------------------------------\n\n' );
    end;
    
    b_rate_8 = round(8*COMPRESSED_size(1)/(ORIGINAL_height *ORIGINAL_width));
    b_rate=[b_rate; b_rate_8]
    MSE = [MSE;calcMSE( ORIGINAL_dimensions,256*ORIGINAL_image, 256*RECONSTRUCTED_image )];
    PSNR_1 =calcPSNR( ORIGINAL_dimensions,256*ORIGINAL_image, 256*RECONSTRUCTED_image);
    PSNR=[PSNR;PSNR_1]   
    

end;

%----------------------------------------------------------------
%
%   Rate-Distortion Analysis

        

%
%----------------------------------------------------------------
% place distortion calculation etc. here
 
% test_satpic1
% psnr_satpic_1_pre = PSNR1;
% psnr_satpic_1_nopre = PSNR2;
% b_rate_1 = b_rate;
% 
% test_satpic2
% psnr_satpic_2_pre = PSNR1;
% psnr_satpic_2_nopre = PSNR2;
% b_rate_2 = b_rate;
% 
% test_subsampling 
% psnr_sail_3 = PSNR1;
% psnr_lena_3 = PSNR2;
% b_rate_3 = b_rate;
% 
% test_ICT
% psnr_4 = PSNR1;
% b_rate_4 = b_rate;
% 
% %Plot figure
% figure('name', 'Rate vs Distortion')
% 
% plot(b_rate_8, PSNR, '*')
% hold on
% 
% plot(b_rate_1, psnr_satpic_1_pre,'bo')
% plot(b_rate_1, psnr_satpic_1_nopre,'bo')
% 
% plot(b_rate_2, psnr_satpic_2_pre,'ro')
% plot(b_rate_2, psnr_satpic_2_nopre,'ro')
% 
% plot(b_rate_3, psnr_sail_3,'yo')
% plot(b_rate_3, psnr_lena_3,'yo')
% 
% plot(b_rate_4, psnr_4,'ko')
% 
% xlim([0,40])
% ylim([10, 50])
% legend(ParameterStruct(1).name,ParameterStruct(2).name,ParameterStruct(3).name,'Downsample filter 1(pre)','Downsample filter 1(nopre)','Downsample filter 2(pre)','Downsample filter 2(nopre)','resample function(sail)','resample function(lena)', 'ICT' )



%----------------------------------------------------------------
%
%   Main Loop for Parameter Sets ends
%
%----------------------------------------------------------------

save mydata b_rate PSNR