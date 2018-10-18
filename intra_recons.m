function rim_intra=intra_recons(im_recons,intra_mode,i,j,N)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This Function Intra_RECONS preforms the Intra ReConstruction,            %
% also known as Spatial Predictiion, in image "im_recons"'s current block,%
%(i,j) of size N. The function implements all modes. Which ever mode has  %
%earlier been selected,That mode's reconsrtuction is performed.           %
%The function returns the reconstructed block                             %
% I and J are pixel numbers, N is the block size                          %
%This function is used for H.264 video format encoding and decoding       %
%                                                                         %
%Example:                                                                 %
%rim_intra=intra_recons(image,'Mode 1',1,1,8)                             %
%                                                                         %  
%Author:Santhana Raj.A                          						  %
%https://sites.google.com/site/santhanarajarunachalam/      			  % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rows=i;cols=j;

for k=1:2*N
    T(k)=double(im_recons(rows-1,cols+k-1)); %TOP pixels above the block
    L(k)=double(im_recons(rows+k-1,cols-1)); %LEFT pixels before the block
end
LT=im_recons(rows-1,cols-1); % Not used in Mode 1 & Mode 2

if N==4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% N=4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch intra_mode
        case 'Mode 0'
            recons=mode0(T,N);
        case 'Mode 1'     
            recons=mode1(L,N);
        case 'Mode 2'
            recons=mode2(L,T,N);
        case 'Mode 3'
            recons=mode3(T);
        case 'Mode 4'
            recons=mode4(L,T,LT);
        case 'Mode 5'
            recons=mode5(L,T,LT);
        case 'Mode 6'
            recons=mode6(L,T,LT);
        case 'Mode 7'
            recons=mode7(T);
        case 'Mode 8'
            recons=mode8(L);
        otherwise
            error('Unknown Mode for N=4');
    end
elseif N==8 || N==16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%N=8 or N=16 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch intra_mode
        case 'Mode 0'
            recons=mode0(T,N);
        case 'Mode 1'     
            recons=mode1(L,N);
        case 'Mode 2'
            recons=mode2(L,T,N);
        case 'Mode 3'
            recons=mode3_big(L,T,LT,N);
        otherwise
            error('Unknown Mode for N=8 or 16');
    end
end

rim_intra=uint8(recons);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%MODE FUNCTIONS DEFINITIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mode Function Definitions can be checked from Wikipedia

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