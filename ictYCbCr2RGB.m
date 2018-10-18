function  [ R , G , B ] = ictYCbCr2RGB( Y , Cb , Cr )

R = Y + 1.402 * Cr;
G = Y - 0.344 * Cb - 0.714 * Cr;
B = Y + 1.772 * Cb;

end