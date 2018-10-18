function [ block_out, block_mode ] = ChromaIntraEnc( chroma )
% input - 2d chrominance image, output - original/error block and corresponding mode

% clear;
% im = double( imread( 'lena_small.tif' ) );
% [ lum, ~, ~ ] = ictRGB2YCbCr( im(:,:,1), im(:,:,2), im(:,:,3) );
% chroma = padarray( lum,[0,8],'post' );

% how many rows and columns of blocks
sz = size(chroma)/8;
% seperate into 8*8 blocks
block = blocksplit8x8( chroma );
% total number of blocks
total_block = size( block,3 );
% pre_allocation
block_out = zeros( size(block) ); % later -> dct transform
block_pred = zeros( size(block) );
block_mode = zeros( 1,total_block );
recon = zeros( size(chroma) );
sad = zeros(1,4);
pred = zeros(8,8,4);
error = zeros(8,8,4);

id = 1;
while id<=total_block     % i-th block
    % find out correponding pixel index in image
    if mod(id,sz(2))==0
        row_start_index = (id/sz(2)-1)*8+1;
        col_start_index = size(chroma,2)-7;
    else
        row_start_index = floor(id/sz(2))*8+1;
        col_start_index = (mod(id,sz(2))-1)*8+1;
    end
    % no prediction for blocks located on 1st row and 1st column    
    if ( id<=sz(2) ) || ( mod((id-1),sz(2))==0 )   
        block_pred(:,:,id) = block(:,:,id);
        block_out(:,:,id) = block(:,:,id); 
        recon( row_start_index:row_start_index+7, col_start_index:col_start_index+7 ) = block_pred(:,:,id);
%         imshow(recon/255)
    % prediction for other blocks, 4 modes
    else 
        % decide reference pixels for current block
        row_refer = recon( row_start_index-1, col_start_index-1:col_start_index+7 ); % previous row, col -1~7 -> 1~9
        col_refer = recon( row_start_index-1:row_start_index+7, col_start_index-1 ); % previous column, row -1~7 -> 1~9 
        % block prediction
        % mode 0 - vertical, row_refer(2:9)
        pred(:,:,1) = repmat( row_refer(2:9), [8,1] );
        error(:,:,1) = block(:,:,id) - pred(:,:,1);
        sad(1) = sum(sum(abs(error(:,:,1))));
        % mode 1 - horizontal, col_refer(2:9)
        pred(:,:,2) = repmat( col_refer(2:9), [1,8] );
        error(:,:,2) = block(:,:,id) - pred(:,:,2);
        sad(2) = sum(sum(abs(error(:,:,2))));
        % mode 2 - DC, row_refer(2:9), col_refer(2:9)
        pred(:,:,3) = ( mean( [row_refer(2:9) col_refer(2:9)'] ) + 8 ) * ones(8);
        error(:,:,3) = block(:,:,id) - pred(:,:,3);
        sad(3) = sum(sum(abs(error(:,:,3))));
        % mode 3 - plane, row_refer(1:9), col_refer(1:9)
        H = 0; V = 0;
        for t = 0:7
            H = H + (t+1) * ( row_refer(9-t) - row_refer(8-t) );
            V = V + (t+1) * ( col_refer(9-t) - col_refer(8-t) );
        end
        a = 16 * ( row_refer(9) + col_refer(9) );
        b = (5*H+32)/64;
        c = (5*V+32)/64;
        for x = 1:8
            for y = 1:8
                pred(y,x,4) = a + b*(x-8) + c*(y-8);
            end
        end
        error(:,:,4) = block(:,:,id) - pred(:,:,4);
        sad(4) = sum(sum(abs(error(:,:,4))));
        % take the mode with minimal sad 
        [ ~, mode ] = min(sad);
        % record correponding predicted block and error block->output
        block_pred(:,:,id) = pred(:,:,mode);
        block_out(:,:,id) = error(:,:,mode);
        block_mode(id) = mode;
        % reconstruct current block based on predicted and error (same in decode)
        recon( row_start_index:row_start_index+7, col_start_index:col_start_index+7 ) = block_pred(:,:,id) + block_out(:,:,id);
%         imshow(recon/255);
    end
    id = id + 1;
end


end