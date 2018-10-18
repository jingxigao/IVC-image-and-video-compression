function recon_lum = LumaIntraDec( y_block, y_mode, szl )
% input sz - size of luminance image

% load('block_out.mat')
% load('block_mode.mat')
% y_block = block_out;
% y_mode = block_mode;
% szl = size(lum);
% pred = zeros(8);

% how many rows and columns of blocks
sz = szl/8;
% total number of blocks
total_block = size( y_block,3 );
% pre_allocation
recon_lum = zeros(szl);

id = 1;
while id<=total_block     % i-th block
    % find out correponding pixel index in image
    if mod(id,sz(2))==0
        row_start_index = (id/sz(2)-1)*8+1;
        col_start_index = szl(2)-7;
    else
        row_start_index = floor(id/sz(2))*8+1;
        col_start_index = (mod(id,sz(2))-1)*8+1;
    end
    % no prediction for blocks located on 1st row and 1st column    
    if ( id<=sz(2) ) || ( mod((id-1),sz(2))==0 )
        pred = y_block(:,:,id); 
        recon_lum( row_start_index:row_start_index+7, col_start_index:col_start_index+7 ) = pred;
%         imshow(recon_lum/255)
    % prediction for other blocks, 7 or 9 modes
    else 
        if mod(id,sz(2))==0 % last block of each row, 7 modes without mode 3 and mode 7
            % decide reference pixels for current block
            row_refer = recon_lum( row_start_index-1, col_start_index-1:col_start_index+7 ); % previous row, col -1~7 -> 1~9
            col_refer = recon_lum( row_start_index-1:row_start_index+7, col_start_index-1 ); % previous column, row -1~7 ->1~9
            % inverse block prediction, 7 modes
            switch y_mode(id)
                case 1            % mode 0 - vertical, row_refer(2:9)
                    pred = repmat( row_refer(2:9), [8,1] );
                case 2            % mode 1 - horizontal, col_refer(2:9)
                    pred = repmat( col_refer(2:9), [1,8] );
                case 3            % mode 2 - DC, row_refer(2:9), col_refer(2:9)
                    pred = ( mean( [row_refer(2:9) col_refer(2:9)'] ) + 8 ) * ones(8);
                case 4            % mode 4 - diagonal down right, row_refer(1:9), col_refer(1:9)
                    for x = 1:8
                        for y = 1:8
                            if x>y
                                pred(y,x) = ( row_refer(x-y) + 2*row_refer(x-y+1) + row_refer(x-y+2) + 2 )*0.25;
                            elseif x<y
                                pred(y,x) = ( col_refer(y-x) + 2*col_refer(y-x+1) + col_refer(y-x+2) + 2 )*0.25;
                            else
                                pred(y,x) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                            end
                        end
                    end
                case 5            % mode 5 - vertical right, row_refer(1:9), col_refer(1:9)
                    for x = 1:8
                        for y = 1:8
                            zVR = 2*(x-1)-(y-1);
                            if zVR==0 || zVR==2 || zVR==4 || zVR==6 || zVR==8 || zVR==10 || zVR==12 || zVR==14
                                pred(y,x) = ( row_refer(x-y/2+0.5) + row_refer(x-y/2+1.5) + 1 )*0.5;
                            elseif zVR==1 || zVR==3 || zVR==5 || zVR==7 || zVR==9 || zVR==11 || zVR==13
                                pred(y,x) = ( row_refer(x-y/2) + 2*row_refer(x-y/2+1) + row_refer(x-y/2+2) + 2 )*0.25;
                            elseif zVR==-1
                                pred(y,x) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                            else
                                pred(y,x) = ( col_refer(y-2*x+2) + 2*col_refer(y-2*x+1) + col_refer(y-2*x) + 2 )*0.25;
                            end
                        end
                    end
                case 6            % mode 6 - horizontal down, row_refer(1:9), col_refer(1:9)
                    for x = 1:8
                        for y = 1:8
                            zHD = 2*(y-1)-(x-1);
                            if zHD==0 || zHD==2 || zHD==4 || zHD==6 || zHD==8 || zHD==10 || zHD==12 || zHD==14
                                pred(y,x) = ( col_refer(y-x/2+0.5) + col_refer(y-x/2+1.5) + 1 )*0.5;
                            elseif zHD==1 || zHD==3 || zHD==5 || zHD==7 || zHD==9 || zHD==11 || zHD==13
                                pred(y,x) = ( col_refer(y-x/2) + 2*col_refer(y-x/2+1) + col_refer(y-x/2+2) + 2 )*0.25;
                            elseif zHD==-1
                                pred(y,x) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                            else
                                pred(y,x) = ( row_refer(x-2*y+2) + 2*row_refer(x-2*y+1) + row_refer(x-2*y) + 2 )*0.25;
                            end
                        end
                    end
                case 7            % mode 8 - horizontal up, col_refer(2,9)
                    for x = 1:8
                        for y = 1:8
                            zHU = (x-1)+2*(y-1);
                            if zHU==0 || zHU==2 || zHU==4 || zHU==6 || zHU==8 || zHU==10 || zHU==12
                                pred(y,x) = ( col_refer(y+x/2+0.5) + col_refer(y+x/2+1.5) + 1 )*0.5;
                            elseif zHU==1 || zHU==3 || zHU==5 || zHU==7 || zHU==9 || zHU==11
                                pred(y,x) = ( col_refer(y+x/2) + 2*col_refer(y+x/2+1) + col_refer(y+x/2+2) + 2 )*0.25;
                            elseif zHU==13
                                pred(y,x) = ( col_refer(8) + 3*col_refer(9) + 2 )*0.25;
                            else
                                pred(y,x) = col_refer(9);
                            end
                        end
                    end
            end
        else  % other blocks, 9 modes
            % decide reference pixels for current block
            row_refer = recon_lum( row_start_index-1, col_start_index-1:col_start_index+15 ); % previous row, col -1~15 -> 1~17
            col_refer = recon_lum( row_start_index-1:row_start_index+7, col_start_index-1 ); % previous column, row -1~7 -> 1~9 
            % inverse block prediction
            switch y_mode(id)
                case 1            % mode 0 - vertical, row_refer(2:9)
                    pred = repmat( row_refer(2:9), [8,1] );
                case 2            % mode 1 - horizontal, col_refer(2:9)
                    pred = repmat( col_refer(2:9), [1,8] );
                case 3            % mode 2 - DC, row_refer(2:9), col_refer(2:9)
                    pred = ( mean( [row_refer(2:9) col_refer(2:9)'] ) + 8 ) * ones(8);
                case 4            % mode 3 - diagonal down left, row_refer(1:17)
                    for x = 1:8
                        for y = 1:8
                            if x==8 && y==8
                                pred(y,x) = ( row_refer(16) + 3*row_refer(17) + 2 )*0.25;
                            else
                                pred(y,x) = ( row_refer(x+y) + 2*row_refer(x+y+1) + row_refer(x+y+2) + 2 )*0.25;
                            end
                        end
                    end
                case 5            % mode 4 - diagonal down right, row_refer(1:9), col_refer(1:9)
                    for x = 1:8
                        for y = 1:8
                            if x>y
                                pred(y,x) = ( row_refer(x-y) + 2*row_refer(x-y+1) + row_refer(x-y+2) + 2 )*0.25;
                            elseif x<y
                                pred(y,x) = ( col_refer(y-x) + 2*col_refer(y-x+1) + col_refer(y-x+2) + 2 )*0.25;
                            else
                                pred(y,x) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                            end
                        end
                    end
                case 6            % mode 5 - vertical right, row_refer(1:9), col_refer(1:9)
                    for x = 1:8
                        for y = 1:8
                            zVR = 2*(x-1)-(y-1);
                            if zVR==0 || zVR==2 || zVR==4 || zVR==6 || zVR==8 || zVR==10 || zVR==12 || zVR==14
                                pred(y,x) = ( row_refer(x-y/2+0.5) + row_refer(x-y/2+1.5) + 1 )*0.5;
                            elseif zVR==1 || zVR==3 || zVR==5 || zVR==7 || zVR==9 || zVR==11 || zVR==13
                                pred(y,x) = ( row_refer(x-y/2) + 2*row_refer(x-y/2+1) + row_refer(x-y/2+2) + 2 )*0.25;
                            elseif zVR==-1
                                pred(y,x) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                            else
                                pred(y,x) = ( col_refer(y-2*x+2) + 2*col_refer(y-2*x+1) + col_refer(y-2*x) + 2 )*0.25;
                            end
                        end
                    end
                case 7            % mode 6 - horizontal down, row_refer(1:9), col_refer(1:9)
                    for x = 1:8
                        for y = 1:8
                            zHD = 2*(y-1)-(x-1);
                            if zHD==0 || zHD==2 || zHD==4 || zHD==6 || zHD==8 || zHD==10 || zHD==12 || zHD==14
                                pred(y,x) = ( col_refer(y-x/2+0.5) + col_refer(y-x/2+1.5) + 1 )*0.5;
                            elseif zHD==1 || zHD==3 || zHD==5 || zHD==7 || zHD==9 || zHD==11 || zHD==13
                                pred(y,x) = ( col_refer(y-x/2) + 2*col_refer(y-x/2+1) + col_refer(y-x/2+2) + 2 )*0.25;
                            elseif zHD==-1
                                pred(y,x) = ( row_refer(2) + row_refer(1) + col_refer(2) + col_refer(1) + 2 )*0.25;
                            else
                                pred(y,x) = ( row_refer(x-2*y+2) + 2*row_refer(x-2*y+1) + row_refer(x-2*y) + 2 )*0.25;
                            end
                        end
                    end
                case 8            % mode 7 - vertical left, row_refer(2:17)
                    for x = 1:8
                        for y = 1:8
                            if mod(y-1,2)==0
                                pred(y,x) = ( row_refer(x+y/2+0.5) + row_refer(x+y/2+1.5) + 1 )*0.5;
                            else
                                pred(y,x) = ( row_refer(x+y/2) + 2*row_refer(x+y/2+1) + row_refer(x+y/2+2) + 2 )*0.25;
                            end
                        end
                    end
                case 9            % mode 8 - horizontal up, col_refer(2,9)
                    for x = 1:8
                        for y = 1:8
                            zHU = (x-1)+2*(y-1);
                            if zHU==0 || zHU==2 || zHU==4 || zHU==6 || zHU==8 || zHU==10 || zHU==12
                                pred(y,x) = ( col_refer(y+x/2+0.5) + col_refer(y+x/2+1.5) + 1 )*0.5;
                            elseif zHU==1 || zHU==3 || zHU==5 || zHU==7 || zHU==9 || zHU==11
                                pred(y,x) = ( col_refer(y+x/2) + 2*col_refer(y+x/2+1) + col_refer(y+x/2+2) + 2 )*0.25;
                            elseif zHU==13
                                pred(y,x) = ( col_refer(8) + 3*col_refer(9) + 2 )*0.25;
                            else
                                pred(y,x) = col_refer(9);
                            end
                        end
                    end
            end
        end
        recon_lum( row_start_index:row_start_index+7, col_start_index:col_start_index+7 ) = pred + y_block(:,:,id);
%         imshow(recon_lum/255)
    end
    id = id + 1;
end


end

