function [ mv, error_Y,error_Cb,error_Cr, pred_Y,pred_Cb,pred_Cr] = blockmatch( ict_prev_Y,ict_prev_Cb, ict_prev_Cr,ict_curr_Y,ict_curr_Cb,ict_curr_Cr )


% pad previous frame
ict_prev_Y = padarray(ict_prev_Y, [4,4], 'replicate');
ict_prev_Cb = padarray(ict_prev_Cb, [4,4], 'replicate');
ict_prev_Cr = padarray(ict_prev_Cr, [4,4], 'replicate');
% use luminance dimension to find motion vectors
lum_prev = ict_prev_Y;
lum_curr = ict_curr_Y;
% total number of blocks = mvs
num_block = size(lum_curr,1) * size(lum_curr,2)/(8*8);
% pre-allocation
ssd = zeros(9,9);
% mv1 = zeros(num_block,2);
% mv2 = zeros(num_block,2);
mv = zeros(num_block,2);
%to do the prediction for Y,Cb,Cr seperately xu
pred_Y = zeros(size(ict_curr_Y));
pred_Cb = zeros(size(ict_curr_Cb));
pred_Cr = zeros(size(ict_curr_Cr));
% do following to all blocks
num = 1;
for r = 1:8:size(lum_curr,1)
    for c = 1:8:size(lum_curr,2)
        block = lum_curr(r:r+7,c:c+7);   % start index = (r,c) in current frame
        for sr = 0:8
            for sc = 0:8  % 81 possible blocks in previous frame
                sd = (lum_prev(r+sr:r+sr+7,c+sc:c+sc+7) - block).^2;
                ssd(sr+1,sc+1) = sum(sd(:)); % 81 possible ssd values
            end
        end
       [ min1, I1 ] = min(ssd(:)); % find the minimum ssd
       mv_block = [ I1-(ceil(I1/9)-1)*9 ceil(I1/9) ] - [5 5]; % convert index I into [row, col], minus offset to have range [-4,4]
       pred_index = [r c] + mv_block + [4,4]; % corresponding index in previous frame, +[4,4] due to pading
       
%% prediction for component Y       
       % area for half pel search
       ict_prev2 = padarray( ict_prev_Y, [1,1], 'replicate' );  %?
       half_area = ict_prev2( pred_index(1):pred_index(1)+9, pred_index(2):pred_index(2)+9, : );
       % interpolated area for half pel search
       interp_half_area = BilinearInterp( half_area );
       % eight half indexes
       index2 = zeros(1,2,8);
       index2(:,:,1) = [-0.5 -0.5];
       index2(:,:,2) = [-0.5 0];
       index2(:,:,3) = [-0.5 0.5];
       index2(:,:,4) = [0 -0.5];
       index2(:,:,5) = [0 0.5];
       index2(:,:,6) = [0.5 -0.5];
       index2(:,:,7) = [0.5 0];
       index2(:,:,8) = [0.5 0.5];
       % eight half comparisons
       half_block = zeros(8,8,8);
       half_block(:,:,1) = interp_half_area(2:2:16, 2:2:16); % (-0.5,-0.5)
       half_block(:,:,2) = interp_half_area(2:2:16, 3:2:17); % (-0.5,0)
       half_block(:,:,3) = interp_half_area(2:2:16, 4:2:18); % (-0.5,0.5)
       half_block(:,:,4) = interp_half_area(3:2:17, 2:2:16); % (0,-0.5)
       half_block(:,:,5) = interp_half_area(3:2:17, 4:2:18); % (0,0.5)
       half_block(:,:,6) = interp_half_area(4:2:18, 2:2:16); % (0.5,-0.5)
       half_block(:,:,7) = interp_half_area(4:2:18, 3:2:17); % (0.5,0)
       half_block(:,:,8) = interp_half_area(4:2:18, 4:2:18); % (0.5,0.5)
       % calculate eight new half ssd
       ssd2 = zeros(1,8);
       for i = 1:8
           sd2 = ( half_block(:,:,i) - block ).^2;
           ssd2(i) = sum(sd2(:));
       end
       [ min2, I2 ] = min(ssd2);
       if min1<min2
           half_index = [0 0];
       else
           half_index = index2(I2);
       end
       
       % quarter pel search only if half pel works
       if half_index==[0 0]
           quarter_index = [0 0];
       else
           % decide quarter pel search area
           switch I2
               case 1
                   quarter_area = interp_half_area(1:10, 1:10);
               case 2
                   quarter_area = interp_half_area(1:10, 2:11);
               case 3
                   quarter_area = interp_half_area(1:10, 3:12);
               case 4
                   quarter_area = interp_half_area(2:11, 1:10);
               case 5
                   quarter_area = interp_half_area(2:11, 3:12);
               case 6
                   quarter_area = interp_half_area(3:12, 1:10);
               case 7
                   quarter_area = interp_half_area(3:12, 2:11);
               case 8
                   quarter_area = interp_half_area(3:12, 3:12);
           end
           % bilinear in quarter pel area
           interp_quarter_area = BilinearInterp( quarter_area );
           % eight quarter indexes
           index3 = zeros(1,2,8);
           index3(:,:,1) = [-0.25 -0.25];
           index3(:,:,2) = [-0.25 0];
           index3(:,:,3) = [-0.25 0.25];
           index3(:,:,4) = [0 -0.25];
           index3(:,:,5) = [0 0.25];
           index3(:,:,6) = [0.25 -0.25];
           index3(:,:,7) = [0.25 0];
           index3(:,:,8) = [0.25 0.25];
           % eight quarter comparisons
           quarter_block = zeros(8,8,8);
           quarter_block(:,:,1) = interp_quarter_area(2:2:16, 2:2:16); % (-0.25,-0.25)
           quarter_block(:,:,2) = interp_quarter_area(2:2:16, 3:2:17); % (-0.25,0)
           quarter_block(:,:,3) = interp_quarter_area(2:2:16, 4:2:18); % (-0.25,0.25)
           quarter_block(:,:,4) = interp_quarter_area(3:2:17, 2:2:16); % (0,-0.25)
           quarter_block(:,:,5) = interp_quarter_area(3:2:17, 4:2:18); % (0,0.25)
           quarter_block(:,:,6) = interp_quarter_area(4:2:18, 2:2:16); % (0.25,-0.25)
           quarter_block(:,:,7) = interp_quarter_area(4:2:18, 3:2:17); % (0.25,0)
           quarter_block(:,:,8) = interp_quarter_area(4:2:18, 4:2:18); % (0.25,0.25)
           % calculate eight new quarter ssd
           ssd3 = zeros(1,8);
           for j = 1:8
               sd3 = ( quarter_block(:,:,j) - block ).^2;
               ssd3(j) = sum(sd3(:));
           end
           [ min3, I3 ] = min(ssd3);
           if min2<min3
               quarter_index = [0 0];
           else
               quarter_index = index3(I3);
           end
       end
       % combine integer, half pel and quarter pel motion vectors, put mv for all blocks together
       mv( num,: ) = mv_block + half_index + quarter_index;
       % extract predicted block correpondingly from previous frame xu
       if half_index==[0 0]
           pred_Y( r:r+7, c:c+7 ) = ict_prev_Y( pred_index(1):pred_index(1)+7, pred_index(2):pred_index(2)+7 );
       elseif quarter_index==[0 0]
           pred_Y( r:r+7, c:c+7) = half_block(:,:,I2);
       else
           pred_Y( r:r+7, c:c+7 ) = quarter_block(:,:,I3);
       end
       
       num = num + 1;
    end
end

%% do prediction for Cb
Cb_prev = ict_prev_Cb;
Cb_curr = ict_curr_Cb;
n=1;     %number of the block
for r=1:4:size(Cb_curr,1)
    for c=1:4:size(Cb_curr,2)
        f=0;
        mv_curr=mv(n,:);
        if mv_curr(1)==fix(mv_curr(1)) && mv_curr(2)==fix(mv_curr(2))
            mv1=mv_curr;mv2=[0 0]; mv3=[0 0];
        else
        mv1=floor(abs(mv_curr)).*mv_sign(mv_curr);
        mv23=mv_curr-mv1;     %mv2+mv3
        mv2=floor(abs(mv23)./0.5)*0.5;
        sign=mv_sign(mv23);
        mv2=mv2.*sign;
        mv3=mv23-mv2;
        end
        pred_index_cb = [r c] + mv1 + [4,4];
%         disp(num2str(mv_curr));
%         disp(num2str(pred_index_cb));
        current_block_cb=ict_prev_Cb(pred_index_cb(1):pred_index_cb(1)+3, pred_index_cb(2):pred_index_cb(2)+3);
        current_block_cr=ict_prev_Cr(pred_index_cb(1):pred_index_cb(1)+3, pred_index_cb(2):pred_index_cb(2)+3);
        
       if mv2~=[0 0]
       % area for half pel search
       ict_prev2_cb = padarray( ict_prev_Cb, [1,1], 'replicate' );  %?
       half_area_cb = ict_prev2_cb( pred_index_cb(1):pred_index_cb(1)+5, pred_index_cb(2):pred_index_cb(2)+5);
       ict_prev2_cr = padarray( ict_prev_Cr, [1,1], 'replicate' );  %?
       half_area_cr = ict_prev2_cr( pred_index_cb(1):pred_index_cb(1)+5, pred_index_cb(2):pred_index_cb(2)+5);
       % interpolated area for half pel search
       interp_half_area_cb = BilinearInterp( half_area_cb );
       interp_half_area_cr = BilinearInterp( half_area_cr );
       % eight half indexes
       index2 = zeros(1,2,8);
       index2(:,:,1) = [-0.5 -0.5];
       index2(:,:,2) = [-0.5 0];
       index2(:,:,3) = [-0.5 0.5];
       index2(:,:,4) = [0 -0.5];
       index2(:,:,5) = [0 0.5];
       index2(:,:,6) = [0.5 -0.5];
       index2(:,:,7) = [0.5 0];
       index2(:,:,8) = [0.5 0.5];
       % eight half comparisons
       half_block_cb = zeros(4,4,8);
       half_block_cb(:,:,1) = interp_half_area_cb(2:2:8, 2:2:8); % (-0.5,-0.5)
       half_block_cb(:,:,2) = interp_half_area_cb(2:2:8, 3:2:9); % (-0.5,0)
       half_block_cb(:,:,3) = interp_half_area_cb(2:2:8, 4:2:10); % (-0.5,0.5)
       half_block_cb(:,:,4) = interp_half_area_cb(3:2:9, 2:2:8); % (0,-0.5)
       half_block_cb(:,:,5) = interp_half_area_cb(3:2:9, 4:2:10); % (0,0.5)
       half_block_cb(:,:,6) = interp_half_area_cb(4:2:10, 2:2:8); % (0.5,-0.5)
       half_block_cb(:,:,7) = interp_half_area_cb(4:2:10, 3:2:9); % (0.5,0)
       half_block_cb(:,:,8) = interp_half_area_cb(4:2:10, 4:2:10); % (0.5,0.5)
       half_block_cr = zeros(4,4,8);
       half_block_cr(:,:,1) = interp_half_area_cr(2:2:8, 2:2:8); % (-0.5,-0.5)
       half_block_cr(:,:,2) = interp_half_area_cr(2:2:8, 3:2:9); % (-0.5,0)
       half_block_cr(:,:,3) = interp_half_area_cr(2:2:8, 4:2:10); % (-0.5,0.5)
       half_block_cr(:,:,4) = interp_half_area_cr(3:2:9, 2:2:8); % (0,-0.5)
       half_block_cr(:,:,5) = interp_half_area_cr(3:2:9, 4:2:10); % (0,0.5)
       half_block_cr(:,:,6) = interp_half_area_cr(4:2:10, 2:2:8); % (0.5,-0.5)
       half_block_cr(:,:,7) = interp_half_area_cr(4:2:10, 3:2:9); % (0.5,0)
       half_block_cr(:,:,8) = interp_half_area_cr(4:2:10, 4:2:10); % (0.5,0.5)
       for f=1:8
       if index2(:,:,f)==mv2
           current_block_cb=half_block_cb(:,:,f);
           current_block_cr=half_block_cr(:,:,f);
           break
       end
       end
       end
       
       if mv3~=[0 0]
           % decide quarter pel search area
           if f==0
               break
           else
           switch f
               case 1
                   quarter_area_cb = interp_half_area_cb(1:6, 1:6);
                   quarter_area_cr = interp_half_area_cr(1:6, 1:6);
               case 2
                   quarter_area_cb = interp_half_area_cb(1:6, 2:7);
                   quarter_area_cr = interp_half_area_cr(1:6, 2:7);
               case 3
                   quarter_area_cb = interp_half_area_cb(1:6, 3:8);
                   quarter_area_cr = interp_half_area_cr(1:6, 3:8);
               case 4
                   quarter_area_cb = interp_half_area_cb(2:7, 1:6);
                   quarter_area_cr = interp_half_area_cr(2:7, 1:6);
               case 5
                   quarter_area_cb = interp_half_area_cb(2:7, 3:8);
                   quarter_area_cr = interp_half_area_cr(2:7, 3:8);
               case 6
                   quarter_area_cb = interp_half_area_cb(3:8, 1:6);
                   quarter_area_cr = interp_half_area_cr(3:8, 1:6);
               case 7
                   quarter_area_cb = interp_half_area_cb(3:8, 2:7);
                   quarter_area_cr = interp_half_area_cr(3:8, 2:7);
               case 8
                   quarter_area_cb = interp_half_area_cb(3:8, 3:8);
                   quarter_area_cr = interp_half_area_cr(3:8, 3:8);
           end
           % bilinear in quarter pel area
           interp_quarter_area_cb = BilinearInterp( quarter_area_cb );
           interp_quarter_area_cr = BilinearInterp( quarter_area_cr );
           % eight quarter indexes
           index3 = zeros(1,2,8);
           index3(:,:,1) = [-0.25 -0.25];
           index3(:,:,2) = [-0.25 0];
           index3(:,:,3) = [-0.25 0.25];
           index3(:,:,4) = [0 -0.25];
           index3(:,:,5) = [0 0.25];
           index3(:,:,6) = [0.25 -0.25];
           index3(:,:,7) = [0.25 0];
           index3(:,:,8) = [0.25 0.25];
           % eight quarter comparisons
           quarter_block_cb = zeros(4,4,8);
           quarter_block_cb(:,:,1) = interp_quarter_area_cb(2:2:8, 2:2:8); % (-0.25,-0.25)
           quarter_block_cb(:,:,2) = interp_quarter_area_cb(2:2:8, 3:2:9); % (-0.25,0)
           quarter_block_cb(:,:,3) = interp_quarter_area_cb(2:2:8, 4:2:10); % (-0.25,0.25)
           quarter_block_cb(:,:,4) = interp_quarter_area_cb(3:2:9, 2:2:8); % (0,-0.25)
           quarter_block_cb(:,:,5) = interp_quarter_area_cb(3:2:9, 4:2:10); % (0,0.25)
           quarter_block_cb(:,:,6) = interp_quarter_area_cb(4:2:10, 2:2:8); % (0.25,-0.25)
           quarter_block_cb(:,:,7) = interp_quarter_area_cb(4:2:10, 3:2:9); % (0.25,0)
           quarter_block_cb(:,:,8) = interp_quarter_area_cb(4:2:10, 4:2:10); % (0.25,0.25)
           quarter_block_cr = zeros(4,4,8);
           quarter_block_cr(:,:,1) = interp_quarter_area_cr(2:2:8, 2:2:8); % (-0.25,-0.25)
           quarter_block_cr(:,:,2) = interp_quarter_area_cr(2:2:8, 3:2:9); % (-0.25,0)
           quarter_block_cr(:,:,3) = interp_quarter_area_cr(2:2:8, 4:2:10); % (-0.25,0.25)
           quarter_block_cr(:,:,4) = interp_quarter_area_cr(3:2:9, 2:2:8); % (0,-0.25)
           quarter_block_cr(:,:,5) = interp_quarter_area_cr(3:2:9, 4:2:10); % (0,0.25)
           quarter_block_cr(:,:,6) = interp_quarter_area_cr(4:2:10, 2:2:8); % (0.25,-0.25)
           quarter_block_cr(:,:,7) = interp_quarter_area_cr(4:2:10, 3:2:9); % (0.25,0)
           quarter_block_cr(:,:,8) = interp_quarter_area_cr(4:2:10, 4:2:10); % (0.25,0.25)
       for e=1:8
       if index3(:,:,e)==mv3
           current_block_cb=quarter_block_cb(:,:,e);
           current_block_cr=quarter_block_cr(:,:,e);
           break
       end
       end
           end
       end
       pred_Cb(r:r+3,c:c+3)=current_block_cb;
       pred_Cr(r:r+3,c:c+3)=current_block_cr;
       n=n+1;
    end
end


%%
error_Y = ict_curr_Y - pred_Y;
error_Cb= ict_curr_Cb - pred_Cb;
error_Cr = ict_curr_Cr - pred_Cr;
end