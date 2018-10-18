function [ MSE ] = calcMSE( ORIGINAL_dimensions,ORIGINAL_image, RECONSTRUCTED_image )

D = [];
for i = 1:ORIGINAL_dimensions
    D(i) = size(ORIGINAL_image,i);
end
MSE = 1/prod(D) * sum(sum(sum((ORIGINAL_image - RECONSTRUCTED_image).^2)));

end

