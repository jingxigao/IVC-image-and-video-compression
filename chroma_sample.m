function [Y,Cb,Cr]=chroma_sample(Y,Cb,Cr)
%this function is used to subsample the chroma components of the image
%The default ratio is 4:2:0


Cb=Cb(1:2:end,1:2:end);
Cr=Cr(2:2:end,1:2:end);

end

