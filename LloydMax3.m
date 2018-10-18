function [ Q_data ] = LloydMax3( train_data )
%train_data takes values between 0 and 255 and is a vector, not matrix
%search for representatives between 0 and 255
epsilon = 0.001;
%M=8;
intervals1 = linspace(0,255, 9);
%C1:initial codebook
C1 = intervals1(1:end-1) + (intervals1(2:end) - intervals1(1:end-1))/2; 
Q_data = zeros(size(train_data));
%dis:distortion
dis = zeros(size(train_data));
J = mean((Q_data - train_data).^2);
check = J;
%rep:representative vector (8*1)
rep = C1';


% while(check >= epsilon)
%     bins = zeros(8,1);
%     sum_bins = zeros(8,1);
%     for i = 1:length(train_data)
%         [ind,dis(i)] = knnsearch(rep, train_data(i));
%         Q_data(i)=rep(ind);
%         bins(ind) = bins(ind) + 1;
%         sum_bins(ind) = sum_bins(ind) + train_data(i);
%     end
%     averages = sum_bins./bins;
%     rep = averages
%     J_1 = mean(dis.^2);
%     check = (abs(J-J_1))/J
%     J = J_1;
% end    

while(check >= epsilon)
       bins = zeros(8,1);
    sum_bins = zeros(8,1);
        [ind,dis] = knnsearch(rep, train_data);%
        Q_data=rep(ind);%
        for i = 1:length(sum_bins)
            y=find(ind==i);
            z=size(y,1);
            bins(i)=z;
            sum_bins(i) = sum(train_data(y));
        end
    averages = sum_bins./bins;
    rep = averages
    J_1 = mean(dis.^2);
    check = (abs(J-J_1))/J
    J = J_1;
end 
end


