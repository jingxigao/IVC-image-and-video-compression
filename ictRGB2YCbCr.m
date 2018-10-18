function [ Y,Cb,Cr ] = ictRGB2YCbCr( R,G,B )

Y = 0.299 * R + 0.587 * G + 0.114 * B;
Cb = -0.169 * R - 0.331 * G + 0.5 * B;
Cr = 0.5 * R - 0.419 * G - 0.081 * B;

end
