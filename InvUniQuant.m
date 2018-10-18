function [ output ] = InvUniQuant( input, M )
%Input from 0 to 2^M-1

output=(input)/(2^M)+1/(2^(M+1));


end



