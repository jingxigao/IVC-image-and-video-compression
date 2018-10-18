function recon_chroma = ChromaIntraDec( c_block, c_mode, szl )
% input sz - size of chrominance image

% c_block = block_out;
% c_mode = block_mode;
% szl = size(chroma);
% pred = zeros(8);

% how many rows and columns of blocks
sz = szl/8;
% total number of blocks
total_block = size( c_block,3 );
% pre_allocation
recon_chroma = zeros(szl);

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
        pred = c_block(:,:,id); 
        recon_chroma( row_start_index:row_start_index+7, col_start_index:col_start_index+7 ) = pred;
%         imshow(recon_chroma/255)
    % prediction for other blocks, 4 modes
    else 
        row_refer = recon_chroma( row_start_index-1, col_start_index-1:col_start_index+7 ); % previous row, col -1~7 -> 1~9
        col_refer = recon_chroma( row_start_index-1:row_start_index+7, col_start_index-1 ); % previous column, row -1~7 -> 1~9 
        % inverse block prediction
        switch c_mode(id)
            case 1        % mode 0 - vertical, row_refer(2:9)
                pred = repmat( row_refer(2:9), [8,1] );
            case 2        % mode 1 - horizontal, col_refer(2:9)
                pred = repmat( col_refer(2:9), [1,8] );
            case 3        % mode 2 - DC, row_refer(2:9), col_refer(2:9)
                pred = ( mean( [row_refer(2:9) col_refer(2:9)'] ) + 8 ) * ones(8);
            case 4        % mode 3 - plane, row_refer(1:9), col_refer(1:9)
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
                        pred(y,x) = a + b*(x-8) + c*(y-8);
                    end
                end
        end
        recon_chroma( row_start_index:row_start_index+7, col_start_index:col_start_index+7 ) = pred + c_block(:,:,id);
%         imshow(recon_chroma/255)
    end
    id = id + 1;
end


end

