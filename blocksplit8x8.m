function block_out = block8x8( block_in )
% input 2d or 3d image; output all 8x8 blocks
sz = size(block_in);
% if 2d image, set dim = 1
if length(sz)==2
    sz = [sz 1];
end
block_out = zeros(8,8,sz(1)*sz(2)*sz(3)/64);
i = 1;
for d = 1:sz(3)
    for r = 1:8:sz(1)
        for c = 1:8:sz(2)
            block_out(:,:,i) = block_in(r:r+7,c:c+7,d);
            i = i + 1;
        end
    end
end

end