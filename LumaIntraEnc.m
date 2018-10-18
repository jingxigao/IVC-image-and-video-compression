function [ block_out, block_mode ] = LumaIntraEnc( lum )
% input - 2d luminance image, output - original/error block and corresponding mode

% how many rows and columns of blocks
sz = size(lum)/8;
% seperate into 8*8 blocks
block = blocksplit8x8( lum );
% total number of blocks
total_block = size( block,3 );
% pre_allocation
block_out = zeros( size(block) ); % later -> dct transform
block_pred = zeros( size(block) );
block_mode = zeros( 1,total_block );
recon = zeros( size(lum) );


id = 1;
while id<=total_block     % i-th block
    % find out correponding pixel index in image
    if mod(id,sz(2))==0
        row_start_index = (id/sz(2)-1)*8+1;
        col_start_index = size(lum,2)-7;
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
    % prediction for other blocks, 7 or 9 modes
    else 
        if mod(id,sz(2))==0 % last block of each row
            % 7 modes without mode 3 and mode 7
            pred = zeros(8,8,7);
            error = zeros(8,8,7);
            sad = zeros(1,7);
            % decide reference pixels for current block
            row_refer = recon( row_start_index-1, col_start_index-1:col_start_index+7 ); % previous row, col -1~7 -> 1~9
            col_refer = recon( row_start_index-1:row_start_index+7, col_start_index-1 ); % previous column, row -1~7 ->1~9
            % block prediction, 7 modes
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
            % mode 4 - diagonal down right, row_refer(1:9), col_refer(1:9)
            for x = 1:8
                for y = 1:8
                    if x>y
                        pred(y,x,4) = ( row_refer(x-y) + 2*row_refer(x-y+1) + row_refer(x-y+2) + 2 )*0.25;
                    elseif x<y
                        pred(y,x,4) = ( col_refer(y-x) + 2*col_refer(y-x+1) + col_refer(y-x+2) + 2 )*0.25;
                    else
                        pred(y,x,4) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                    end
                end
            end
            error(:,:,4) = block(:,:,id) - pred(:,:,4);
            sad(4) = sum(sum(abs(error(:,:,4))));
            % mode 5 - vertical right, row_refer(1:9), col_refer(1:9)
            for x = 1:8
                for y = 1:8
                    zVR = 2*(x-1)-(y-1);
                    if zVR==0 || zVR==2 || zVR==4 || zVR==6 || zVR==8 || zVR==10 || zVR==12 || zVR==14
                        pred(y,x,5) = ( row_refer(x-y/2+0.5) + row_refer(x-y/2+1.5) + 1 )*0.5;
                    elseif zVR==1 || zVR==3 || zVR==5 || zVR==7 || zVR==9 || zVR==11 || zVR==13
                        pred(y,x,5) = ( row_refer(x-y/2) + 2*row_refer(x-y/2+1) + row_refer(x-y/2+2) + 2 )*0.25;
                    elseif zVR==-1
                        pred(y,x,5) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                    else
                        pred(y,x,5) = ( col_refer(y-2*x+2) + 2*col_refer(y-2*x+1) + col_refer(y-2*x) + 2 )*0.25;
                    end
                end
            end
            error(:,:,5) = block(:,:,id) - pred(:,:,5);
            sad(5) = sum(sum(abs(error(:,:,5))));
            % mode 6 - horizontal down, row_refer(1:9), col_refer(1:9)
            for x = 1:8
                for y = 1:8
                    zHD = 2*(y-1)-(x-1);
                    if zHD==0 || zHD==2 || zHD==4 || zHD==6 || zHD==8 || zHD==10 || zHD==12 || zHD==14
                        pred(y,x,6) = ( col_refer(y-x/2+0.5) + col_refer(y-x/2+1.5) + 1 )*0.5;
                    elseif zHD==1 || zHD==3 || zHD==5 || zHD==7 || zHD==9 || zHD==11 || zHD==13
                        pred(y,x,6) = ( col_refer(y-x/2) + 2*col_refer(y-x/2+1) + col_refer(y-x/2+2) + 2 )*0.25;
                    elseif zHD==-1
                        pred(y,x,6) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                    else
                        pred(y,x,6) = ( row_refer(x-2*y+2) + 2*row_refer(x-2*y+1) + row_refer(x-2*y) + 2 )*0.25;
                    end
                end
            end
            error(:,:,6) = block(:,:,id) - pred(:,:,6);
            sad(6) = sum(sum(abs(error(:,:,6))));
            % mode 8 - horizontal up, col_refer(2,9)
            for x = 1:8
                for y = 1:8
                    zHU = (x-1)+2*(y-1);
                    if zHU==0 || zHU==2 || zHU==4 || zHU==6 || zHU==8 || zHU==10 || zHU==12
                        pred(y,x,7) = ( col_refer(y+x/2+0.5) + col_refer(y+x/2+1.5) + 1 )*0.5;
                    elseif zHU==1 || zHU==3 || zHU==5 || zHU==7 || zHU==9 || zHU==11
                        pred(y,x,7) = ( col_refer(y+x/2) + 2*col_refer(y+x/2+1) + col_refer(y+x/2+2) + 2 )*0.25;
                    elseif zHU==13
                        pred(y,x,7) = ( col_refer(8) + 3*col_refer(9) + 2 )*0.25;
                    else
                        pred(y,x,7) = col_refer(9);
                    end
                end
            end
            error(:,:,7) = block(:,:,id) - pred(:,:,7);
            sad(7) = sum(sum(abs(error(:,:,7))));
            % take the mode with minimal sad
            [ ~, mode ] = min(sad);
       
        else  % other blocks, 9 modes
            pred = zeros(8,8,9);
            error = zeros(8,8,9);
            sad = zeros(1,9);
            % decide reference pixels for current block
            row_refer = recon( row_start_index-1, col_start_index-1:col_start_index+15 ); % previous row, col -1~15 -> 1~17
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
            % mode 3 - diagonal down left, row_refer(1:17)
            for x = 1:8
                for y = 1:8
                    if x==8 && y==8
                        pred(y,x,4) = ( row_refer(16) + 3*row_refer(17) + 2 )*0.25;
                    else
                        pred(y,x,4) = ( row_refer(x+y) + 2*row_refer(x+y+1) + row_refer(x+y+2) + 2 )*0.25;
                    end
                end
            end
            error(:,:,4) = block(:,:,id) - pred(:,:,4);
            sad(4) = sum(sum(abs(error(:,:,4))));
            % mode 4 - diagonal down right, row_refer(1:9), col_refer(1:9)
            for x = 1:8
                for y = 1:8
                    if x>y
                        pred(y,x,5) = ( row_refer(x-y) + 2*row_refer(x-y+1) + row_refer(x-y+2) + 2 )*0.25;
                    elseif x<y
                        pred(y,x,5) = ( col_refer(y-x) + 2*col_refer(y-x+1) + col_refer(y-x+2) + 2 )*0.25;
                    else
                        pred(y,x,5) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                    end
                end
            end
            error(:,:,5) = block(:,:,id) - pred(:,:,5);
            sad(5) = sum(sum(abs(error(:,:,5))));
            % mode 5 - vertical right, row_refer(1:9), col_refer(1:9)
            for x = 1:8
                for y = 1:8
                    zVR = 2*(x-1)-(y-1);
                    if zVR==0 || zVR==2 || zVR==4 || zVR==6 || zVR==8 || zVR==10 || zVR==12 || zVR==14
                        pred(y,x,6) = ( row_refer(x-y/2+0.5) + row_refer(x-y/2+1.5) + 1 )*0.5;
                    elseif zVR==1 || zVR==3 || zVR==5 || zVR==7 || zVR==9 || zVR==11 || zVR==13
                        pred(y,x,6) = ( row_refer(x-y/2) + 2*row_refer(x-y/2+1) + row_refer(x-y/2+2) + 2 )*0.25;
                    elseif zVR==-1
                        pred(y,x,6) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                    else
                        pred(y,x,6) = ( col_refer(y-2*x+2) + 2*col_refer(y-2*x+1) + col_refer(y-2*x) + 2 )*0.25;
                    end
                end
            end
            error(:,:,6) = block(:,:,id) - pred(:,:,6);
            sad(6) = sum(sum(abs(error(:,:,6))));
            % mode 6 - horizontal down, row_refer(1:9), col_refer(1:9)
            for x = 1:8
                for y = 1:8
                    zHD = 2*(y-1)-(x-1);
                    if zHD==0 || zHD==2 || zHD==4 || zHD==6 || zHD==8 || zHD==10 || zHD==12 || zHD==14
                        pred(y,x,7) = ( col_refer(y-x/2+0.5) + col_refer(y-x/2+1.5) + 1 )*0.5;
                    elseif zHD==1 || zHD==3 || zHD==5 || zHD==7 || zHD==9 || zHD==11 || zHD==13
                        pred(y,x,7) = ( col_refer(y-x/2) + 2*col_refer(y-x/2+1) + col_refer(y-x/2+2) + 2 )*0.25;
                    elseif zHD==-1
                        pred(y,x,7) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                    else
                        pred(y,x,7) = ( row_refer(x-2*y+2) + 2*row_refer(x-2*y+1) + row_refer(x-2*y) + 2 )*0.25;
                    end
                end
            end
            error(:,:,7) = block(:,:,id) - pred(:,:,7);
            sad(7) = sum(sum(abs(error(:,:,7))));
            % mode 7 - vertical left, row_refer(2:17)
            for x = 1:8
                for y = 1:8
                    if mod(y-1,2)==0
                        pred(y,x,8) = ( row_refer(x+y/2+0.5) + row_refer(x+y/2+1.5) + 1 )*0.5;
                    else
                        pred(y,x,8) = ( row_refer(x+y/2) + 2*row_refer(x+y/2+1) + row_refer(x+y/2+2) + 2 )*0.25;
                    end
                end
            end
            error(:,:,8) = block(:,:,id) - pred(:,:,8);
            sad(8) = sum(sum(abs(error(:,:,8))));
            % mode 8 - horizontal up, col_refer(2,9)
            for x = 1:8
                for y = 1:8
                    zHU = (x-1)+2*(y-1);
                    if zHU==0 || zHU==2 || zHU==4 || zHU==6 || zHU==8 || zHU==10 || zHU==12
                        pred(y,x,9) = ( col_refer(y+x/2+0.5) + col_refer(y+x/2+1.5) + 1 )*0.5;
                    elseif zHU==1 || zHU==3 || zHU==5 || zHU==7 || zHU==9 || zHU==11
                        pred(y,x,9) = ( col_refer(y+x/2) + 2*col_refer(y+x/2+1) + col_refer(y+x/2+2) + 2 )*0.25;
                    elseif zHU==13
                        pred(y,x,9) = ( col_refer(8) + 3*col_refer(9) + 2 )*0.25;
                    else
                        pred(y,x,9) = col_refer(9);
                    end
                end
            end
            error(:,:,9) = block(:,:,id) - pred(:,:,9);
            sad(9) = sum(sum(abs(error(:,:,9))));
            % take the mode with minimal sad 
            [ ~, mode ] = min(sad);
        end
        
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

% save block_out; save block_mode;
end