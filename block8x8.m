function block_out = block8x8( ict_Y,ict_Cb,ict_Cr )
% input 3d image; output all 8x8 blocks

block_out = zeros( 8, 8, ( size(ict_Y,1)*size(ict_Y,2)+2*size(ict_Cb,1)*size(ict_Cb,2) )/64 );
i = 1;
for r = 1:8:size(ict_Y,1)
    for c = 1:8:size(ict_Y,2)        
        block_out(:,:,i) = ict_Y(r:r+7,c:c+7);
        i = i + 1;
    end
end

for r = 1:8:size(ict_Cb,1)    
    for c = 1:8:size(ict_Cb,2)        
        block_out(:,:,i) =ict_Cb(r:r+7,c:c+7);
        i = i + 1;
    end
end

for r = 1:8:size(ict_Cr,1)
    for c = 1:8:size(ict_Cr,2)        
        block_out(:,:,i) =ict_Cr(r:r+7,c:c+7);
        i = i + 1;
    end
end

end