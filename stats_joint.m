function [pmf_joint]=stats_joint(in_image)
in_image=double(in_image);
% [h,w,d]=size(in_image);
pmf=zeros(2^8,2^8);
im1=in_image(:,1:2:end,:);
im2=in_image(:,2:2:end,:);
E1=im1(:)+1;
E2=im2(:)+1;
ind=sub2ind([256,256],E1,E2);
for i=1:length(ind)
pmf(ind(i))=pmf(ind(i))+1;
end
% for k=1:d
%     for i=1:h
%         for j=1:2:w
%             pmf(in_image(i,j,k)+1,in_image(i,j+1,k)+1)=pmf(in_image(i,j,k)+1,in_image(i,j+1,k)+1)+1;
%         end
%     end
% end
pmf_joint=pmf/sum(sum(pmf));
end