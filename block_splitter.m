function [im_block,h1,w1]=block_splitter(im,n)
[h,w,d]=size(im);
block_num=ceil(h/n)*ceil(w/n)*d;
im_block=zeros(n,n,block_num);
im_new=zeros(ceil(h/n)*n,ceil(w/n)*n,d);
im_new(1:h,1:w,1:d)=im;
for k=1:d
  for j=w+1:ceil(h/n)*n
     im_new(1:h,j,k)=im(:,w,k);
  end
end
for k=1:d
    for i=h+1:ceil(h/n)*n
        im_new(i,:,k)=im_new(h,:,k);
    end
end
a=1;
for k=1:d
   for i=1:n:1+(ceil(h/n)-1)*n
       for j=1:n:1+(ceil(w/n)-1)*n
      
       block=im_new(i:i+n-1,j:j+n-1,k);
       im_block(:,:,a)=block;
       a=a+1;
       end
   end
end
h1=ceil(h/n)*n;
w1=ceil(w/n)*n;
end
