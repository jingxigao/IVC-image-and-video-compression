function [ output ] = UniQuant( input, M )
%Input - any number between 0 and 1

int_bounds = 0:1/(2^M):1;

check = 0;
i = 1;
index =0;

while(check == 0 && i <= length(int_bounds))
    
    if(input < int_bounds(i))
        check = 1;
    end
    i = i + 1;
    index = index + 1;
    
end

output = index - 2;  % a bias of 2

end

