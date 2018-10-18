function derunlevel_out = ZeroRunDec( derunlevel_in, N )
% derunlevel_in = [0 1 1 0 0 1 1 0 1 1 -100]; N = 12;

i = 1;                                              % input index
k = 1;                                              % output index
% derunlevel_out = zeros(1,N);
while i<= length(derunlevel_in)
        if derunlevel_in(i) == 0
            derunlevel_out(k: k + derunlevel_in(i+1)) = 0;
            k = k + derunlevel_in(i+1) + 1;
            i = i + 2;
        elseif derunlevel_in(i) == -1000
            derunlevel_out(k: ceil(k/N) * N) = 0;
            k = ceil(k/N) * N + 1;
            i = i + 1;
        else
            derunlevel_out(k) = derunlevel_in(i);
            k = k + 1;
            i = i + 1;
        end
end

end