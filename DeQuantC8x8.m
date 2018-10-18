function dequant_out = DeQuantC8x8( dequant_in, coe )
% in, out matrix 8 * 8 block chrominance
C = 99 * ones(8);
C(1,1:4) = [17 18 24 47];
C(2,1:4) = [18 21 26 66];
C(3,1:3) = [24 13 56];
C(4,1:2) = [47 66]; 
dequant_out = dequant_in.*C*coe;

end