function runlevel_out = ZeroRunEnc( runlevel_in )
% in 1 * rand vector
% runlevel_in = [0 0 1 0 1 1 0 0 1 0 0 0];

i = 1;                                              % input index
k = 1;                                              % output index
count = 0;                                          % how many continuous zero

while i<= length(runlevel_in)
        if runlevel_in(i) == 0                      % value zero
            if runlevel_in(i:length(runlevel_in)) == 0   % all zero behind?
                runlevel_out(k) = -1000;
                break;
            end
            if count == 0                           % 1st zero
                runlevel_out(k) = runlevel_in(i);
                count = count + 1;
                k = k + 1;
            else
                count = count + 1;                  % not 1st zero
            end
        else                                        % value non-zero
            if count == 0
                runlevel_out(k) = runlevel_in(i);
                k = k + 1;
            else
                runlevel_out(k) = count - 1;        % stop zero count, record how many zeros
                count = 0;
                k = k + 1;                          % record this non-zero value into next output
                runlevel_out(k) = runlevel_in(i);
                k = k + 1;
            end
        end
    i = i + 1;   
end

end
