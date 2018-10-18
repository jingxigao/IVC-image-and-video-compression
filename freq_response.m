W1 = [1 2 1; 2 4 2; 1 2 1];
W1 = [1 2 1; 2 4 2; 1 2 1]/sum(sum(W1));%Normalization the filter

Filter1 = fftshift(fft2(W1));

Filter1 = abs(Filter1); % Get the magnitude
surf(Filter1)
title('Frequency response of the filter W1 ')

%imshow(F); % Display the result
