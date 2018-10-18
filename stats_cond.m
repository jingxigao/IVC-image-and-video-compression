function [pmf_joint,pmf_cond]=stats_cond(in_image)
in_image=double(in_image);
[h,w,d]=size(in_image);
pmf=zeros(2^8,2^8);
pmf_cond=zeros(2^8,2^8);
for k=1:d
    for i=1:h
        for j=1:w-1
            pmf(in_image(i,j,k)+1,in_image(i,j+1,k)+1)=pmf(in_image(i,j,k)+1,in_image(i,j+1,k)+1)+1;
        end
    end
end
pmf_joint=pmf/sum(sum(pmf));
pmf_colume=sum(pmf_joint+eps);
for m=1:256
    if pmf_colume(m)>0
        pmf_cond(:,m)=pmf_joint(:,m)/pmf_colume(m);
    end
end

end