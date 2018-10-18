function [ seq ] = ZeroRunEnc( vect )

seq = [];
i = 1;
while(i <= length(vect))
    count = 1;
   
    while(i < length(vect) && vect(i) == 0 && vect(i+1) == vect(i))
        count = count + 1;
        i = i+1;
    end %here i is the index to the last 0 element 
    
    if(vect(i) == 0 && i == length(vect))
        seq = [seq, 500];
        i = i+1;
        
    else if(vect(i) == 0)
        seq = [seq, vect(i), count-1];
        i = i+1;
       
        else
            seq = [seq, vect(i)];
            i = i + 1;
        end
    end
    


end


end

