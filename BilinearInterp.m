function interp_out = BilinearInterp( interp_in )
% input, output - any dim images
for dim = 1:size(interp_in, 3)
    interp_mid = upsample( upsample(interp_in(:,:,dim),2)', 2 )';
    interp_mid = interp_mid( 1:end-1, 1:end-1 );
    sz = size(interp_mid);
    interp_mid2 = interp_mid;
    for i = 2:2:sz(1)
        interp_mid2( i,: ) = ( interp_mid( i-1,: ) + interp_mid( i+1,: ) )/2;
    end
    interp_out(:,:,dim) = interp_mid2;
    for j = 2:2:sz(2)
        interp_out( :,j,dim ) = ( interp_mid2( :,j-1 ) + interp_mid2( :,j+1 ) )/2;
    end
end
end