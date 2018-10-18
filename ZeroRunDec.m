function [ vect, index ] = ZeroRunDec( seq, EOB, bl_size )
%decode a sequence encoded by zero run encoding
%input the encoded sequence, the End of block value and the block size. in
%order to know how many symbols we want to decode

%also return the index in case we want to decode only one part of the
%sequence and we need the index to decode the next part

vect = [];
i = 0;  %entries in output
index = 1; %goes through the encoded sequence

while(length(vect) < bl_size)
   
    if (index <= length(seq))
        if(seq(index) == 0)
            
            vect1 = zeros(1, seq(index+1)+1);
            vect = [vect vect1];
            index = index + 2;
        

        else if(seq(index) ~= 0 && seq(index) ~= EOB)
            
            vect = [vect seq(index)];
            index = index +1;
                
        
            else if(seq(index) == EOB)
            
                    vect1 = zeros(1, bl_size-length(vect));
                    vect = [vect vect1];
                    index = index + 1;
                end
            end
        end
            
    end
    
    
    
end
%index
end

