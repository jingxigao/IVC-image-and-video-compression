function [ output, SE_min, index ] = closest_VQ( input, reps )
%function returns the closest 2x2 representative  for a given 2x2 input
%MSE_min is the mean squared error of the chosen representative
%index is the index of the representative in the vector of representatives

input_vect = repmat(input, [1,1,size(reps,3)]);
MSE = 1/4*sum(sum((input_vect - reps).^2,1),2);

index = min(find(MSE == min(MSE)));
output = reps(:,:,index);
SE_min = 4*min(MSE);


end

