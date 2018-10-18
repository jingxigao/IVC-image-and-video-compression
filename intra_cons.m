function [intra_image,intra_mode,blk_size]=intra_cons(im_new,i,j,N)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This Function intra_cons does the function of Intra Prediction on a block%
%If Block Size is 4x4, then there are 9 modes defined and if Block size is%
%either 8x8 or 16x16, then there are 4 modes defined by H.264 std. All the%
%modes are implemented seperately below, as  functions. Mode selection is %
%based on which mode results in smaller SAD (Sum of Absolute Difference). %
% I and J are pixel numbers, N is the block size                          %
%This function is used for H.264 video format encoding and decoding       %
%                                                                         %
%Example:                                                                 %
%[intra_image,intra_mode,blk_size]=intra_cons(image,1,1,8)                %
%                                                                         %  
%Author:Santhana Raj.A                          						  %
%https://sites.google.com/site/santhanarajarunachalam/      			  % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rows=i+N;cols=j+N;

  for k=1:2*N
        T(k)=im_new(rows-1,cols+k-1); %TOP pixels above the block
        L(k)=im_new(rows+k-1,cols-1); %LEFT pixels before the block
  end
  LT=im_new(rows-1,cols-1); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% N=4 %%%%%%%%%%%%%%%%%%%%%%%
  if N==4
      % Call Different Mode Functions for N=4
     c0=mode0(T,N);   %Vertical Replication
     c1=mode1(L,N);   %Horizonatal Replication
     c2=mode2(L,T,N); %Mean / DC
     c3=mode3(T);     %Diagonal Down Left
     c4=mode4(L,T,LT);%diagonal Down right
     c5=mode5(L,T,LT);%vertical right
     c6=mode6(L,T,LT);%Horizontal Down
     c7=mode7(T);     %Vertical Left
     c8=mode8(L);     %Horizontal UP
  
    %Selection of Mode
    image_bk=double(im_new(rows:rows+N-1,cols:cols+N-1));
    
    % Calculte SAD for each image from the modes
    SAD(1)=sum(sum(abs(c0-image_bk)));
    SAD(2)=sum(sum(abs(c1-image_bk)));
    SAD(3)=sum(sum(abs(c2-image_bk)));
    SAD(4)=sum(sum(abs(c3-image_bk)));
    SAD(5)=sum(sum(abs(c4-image_bk)));
    SAD(6)=sum(sum(abs(c5-image_bk)));
    SAD(7)=sum(sum(abs(c6-image_bk)));
    SAD(8)=sum(sum(abs(c7-image_bk)));
    SAD(9)=sum(sum(abs(c8-image_bk)));
    
    % Selection based on Min SAD
    [~,min_SAD]=min(SAD);
    switch min_SAD
        case 1
           %fprintf('Spatial Prediction Mode 1 Selected \n');
            intra_image=c0;
            intra_mode='Mode 0';
        case 2
           %fprintf('Spatial Prediction Mode 1 Selected \n');
            intra_image=c1;
            intra_mode='Mode 1';
        case 3
            %fprintf('Spatial Prediction Mode 2 Selected \n');
            intra_image=c2;
            intra_mode='Mode 2';
        case 4
            %fprintf('Spatial Prediction Mode 3 Selected \n');
            intra_image=c3;
            intra_mode='Mode 3';
        case 5
            %fprintf('Spatial Prediction Mode 4 Selected \n');
            intra_image=c4;
            intra_mode='Mode 4';
        case 6
           %fprintf('Spatial Prediction Mode 5 Selected \n');
            intra_image=c5;
            intra_mode='Mode 5';
        case 7
            %fprintf('Spatial Prediction Mode 6 Selected \n');
            intra_image=c6;
            intra_mode='Mode 6';
        case 8
            %fprintf('Spatial Prediction Mode 7 Selected \n');
            intra_image=c7;
            intra_mode='Mode 7';
        case 9
            %fprintf('Spatial Prediction Mode 8 Selected \n');
            intra_image=c8;
            intra_mode='Mode 8';     
    end
    blk_size=N;
    return;
  
  %%%%%%%%%%%%%%%%%%%%N=8 or N=16%%%%%%%%%%%%%%%%%%%%%
  
  elseif N==8 || N==16
     
      % Call Different Mode Functions for N=8 or N=16
     c0=mode0(T,N);         %Vertical Replication
     c1=mode1(L,N);         %Horizonatal Replication
     c2=mode2(L,T,N);       %Mean / DC
     c3=mode3_big(L,T,LT,N);%Plane
     
     image_bk=double(im_new(rows:rows+N-1,cols:cols+N-1));
    
     % Compute SAD for All images from different modes
     SAD(1)=sum(sum(abs(c0-image_bk)));
     SAD(2)=sum(sum(abs(c1-image_bk)));
     SAD(3)=sum(sum(abs(c2-image_bk)));
     SAD(4)=sum(sum(abs(c3-image_bk)));
  
     % Selection based on min SAD
     [~,min_SAD]=min(SAD);
     switch min_SAD
        case 1
           %fprintf('Spatial Prediction Mode 1 Selected \n');
            intra_image=c0;
            intra_mode='Mode 0';
        case 2
           %fprintf('Spatial Prediction Mode 1 Selected \n');
            intra_image=c1;
            intra_mode='Mode 1';
        case 3
            %fprintf('Spatial Prediction Mode 2 Selected \n');
            intra_image=c2;
            intra_mode='Mode 2';
        case 4
            %fprintf('Spatial Prediction Mode 3 Selected \n');
            intra_image=c3;
            intra_mode='Mode 3';
  
     end
     blk_size=N;
     return;
  end
  
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%MODE FUNCTIONS DEFINITIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Chk Wikipedia for the Function Definitions

function out=mode0(T,N)
    for i=1:N
       for j=1:N
            out(i,j)=T(i); % Vertical Replication
        end
    end
end


function out=mode1(L,N)
    for i=1:N
        for j=1:N
           out(i,j)=L(i);  % Horizonatal Replication
        end
    end
end


function out=mode2(L,T,N)
    for i=1:N
        for j=1:N
            out(i,j)=round(mean([L(1:N) T(1:N) 4]));  % Mean / DC
        end
    end
end


function out=mode3(T)
%Diagonal Down Left
 a = (T(1) + 2*T(2) + T(3) + 2) / 4;
 b = (T(2) + 2*T(3) + T(4) + 2) / 4;
 c = (T(3) + 2*T(4) + T(5) + 2) / 4;
 d = (T(4) + 2*T(5) + T(6) + 2) / 4;
 e = (T(5) + 2*T(6) + T(7) + 2) / 4;
 f = (T(6) + 2*T(7) + T(8) + 2) / 4;
 g = (T(7) + 3*T(8)      + 2) / 4;
 
 out(1,1)=a;out(1,2)=b;out(1,3)=c;out(1,4)=d;
 out(2,1)=b;out(2,2)=c;out(2,3)=d;out(2,4)=e;
 out(3,1)=c;out(3,2)=d;out(3,3)=e;out(3,4)=f;
 out(4,1)=d;out(4,2)=e;out(4,3)=f;out(4,4)=g;
 
end


function out=mode3_big(L,T,LT,N)
%Plane for N=8 & 16
 H_bar = 1* (T(9) - T(7)) + 2* (T(10) - T(6))+ 3*(T(11) - T(5))+4*(T(12) - T(4))+ 5*(T(13)- T(3))+ 6*(T(14) - T(2))+ 7*(T(15)- T(1))+ 8*(T(16)- LT);
 
 V_bar = 1* (L(9) - L(6)) + 2* (L(10) - L(6))+ 3*(L(11) - L(5))+4*(L(12) - L(4))+ 5*(L(13)- L(3))+ 6*(L(14) - L(2))+ 7*(L(15)- L(1))+ 8*(L(16)- LT);
     
 H = (5*H_bar + 32) / 64;
 V = (5*V_bar + 32) / 64;
 
 a = 16 * (L(16) + T(16) + 1) - 7*(V+H);
 for j = 1: N
   for i = 1: N
     b = a + V * j + H * i;
     out(i,j) = (b/32);
   end
 end

end




function out=mode4(L,T,LT)
%diagonal Down right
 a = (L(4) + 2*L(3) + L(2) + 2) / 4;
 b = (L(3) + 2*L(2) + L(1) + 2) / 4;
 c = (L(2) + 2*L(1) + LT + 2) / 4;
 d = (L(1) + 2*LT + T(1) + 2) / 4;
 e = (LT + 2*T(1) + T(2) + 2) / 4;
 f = (T(1) + 2*T(2) + T(3) + 2) / 4;
 g = (T(1) + 2*T(3) + T(4) + 2) / 4;
 
 out(1,1)=d;out(1,2)=e;out(1,3)=f;out(1,4)=g;
 out(2,1)=c;out(2,2)=d;out(2,3)=e;out(2,4)=f;
 out(3,1)=b;out(3,2)=c;out(3,3)=d;out(3,4)=e;
 out(4,1)=a;out(4,2)=b;out(4,3)=c;out(4,4)=d;
 
end

 
function out=mode5(L,T,LT)
%vertical right
 a = (LT + T(1) + 1) / 2;
 b = (T(1) + T(2) + 1) / 2;
 c = (T(2) + T(3) + 1) / 2;
 d = (T(3) + T(4) + 1) / 2;
 e = (L(1) + 2*LT + T(1) + 2) / 4;
 f = (LT + 2*T(1) + T(2) + 2) / 4;
 g = (T(1) + 2*T(2) + T(3) + 2) / 4;
 h = (T(2) + 2*T(3) + T(4) + 2) / 4;
 i = (LT + 2*L(1) + L(2) + 2) / 4;
 j = (L(1) + 2*L(2) + L(3) + 2) / 4;
 
 out(1,1)=a;out(1,2)=b;out(1,3)=c;out(1,4)=d;
 out(2,1)=e;out(2,2)=f;out(2,3)=g;out(2,4)=h;
 out(3,1)=i;out(3,2)=a;out(3,3)=b;out(3,4)=c;
 out(4,1)=j;out(4,2)=e;out(4,3)=f;out(4,4)=g;
 
end
 
function out=mode6(L,T,LT)
%Horizontal Down
 a = (LT + L(1) + 1) / 2;
 b = (L(1) + 2*LT + T(1) + 2) / 4;
 c = (LT + 2*T(1) + T(2) + 2) / 4;
 d = (T(1) + 2*T(2) + T(3) + 2) / 4;
 e = (L(1) + L(2) + 1) / 2;
 f = (LT + 2*L(1) + L(2) + 2) / 4;
 g = (L(2) + L(3) + 1) / 2;
 h = (L(1) + 2*L(2) + L(3) + 2) / 4;
 i = (L(3) + L(4) + 1) / 2;
 j = (L(2) + 2*L(3) + L(4) + 2) / 4;
 
 out(1,1)=a;out(1,2)=b;out(1,3)=c;out(1,4)=d;
 out(2,1)=e;out(2,2)=f;out(2,3)=a;out(2,4)=b;
 out(3,1)=g;out(3,2)=h;out(3,3)=e;out(3,4)=f;
 out(4,1)=i;out(4,2)=j;out(4,3)=g;out(4,4)=h;
 
end


function out=mode7(T)
%Vertical Left
 a = (T(1) + T(2) + 1) / 2;
 b = (T(2) + T(3) + 1) / 2;
 c = (T(3) + T(4) + 1) / 2;
 d = (T(4) + T(5) + 1) / 2;
 e = (T(5) + T(6) + 1) / 2;
 f = (T(1) + 2*T(2) + T(3) + 2) / 4;
 g = (T(2) + 2*T(3) + T(4) + 2) / 4;
 h = (T(3) + 2*T(4) + T(5) + 2) / 4;
 i = (T(4) + 2*T(5) + T(6) + 2) / 4;
 j = (T(5) + 2*T(6) + T(7) + 2) / 4;
 
 out(1,1)=a;out(1,2)=b;out(1,3)=c;out(1,4)=d;
 out(2,1)=f;out(2,2)=g;out(2,3)=h;out(2,4)=i;
 out(3,1)=b;out(3,2)=c;out(3,3)=d;out(3,4)=e;
 out(4,1)=g;out(4,2)=h;out(4,3)=i;out(4,4)=j;
 
end

function out=mode8(L)
%Horizontal UP
 a = (L(1) + L(2) + 1) / 2;
 b = (L(1) + 2*L(2) + L(3) + 2) / 4;
 c = (L(2) + L(3) + 1) / 2;
 d = (L(2) + 2*L(3) + L(4) + 2) / 4;
 e = (L(3) + L(4) + 1) / 2;
 f = (L(3) + 3*L(4)      + 2) / 4;
 g = L(4);
 
 out(1,1)=a;out(1,2)=b;out(1,3)=c;out(1,4)=d;
 out(2,1)=c;out(2,2)=d;out(2,3)=e;out(2,4)=f;
 out(3,1)=e;out(3,2)=f;out(3,3)=g;out(3,4)=g;
 out(4,1)=g;out(4,2)=g;out(4,3)=g;out(4,4)=g;
 
end