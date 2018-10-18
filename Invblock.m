function [im]=Invblock(im_block,h,w,d,n)
%Reform the block back to the image
h2=ceil(h/n)*n;
w2=ceil(w/n)*n;
im_big=zeros(h2,w2,d);
a=1;
for k=1:d
    for i=1:n:1+n*(h2/n-1)
        for j=1:n:1+n*(w2/n-1)
            im_big(i:i+n-1,j:j+n-1,k)=im_block(:,:,a);
            a=a+1;
        end
    end
end
im=im_big(1:h,1:w,1:d);
end