function [Cb_up,Cr_up] = chroma_upsample(cb,cr)

Cb_up=zeros(size(cb,1)*2,size(cb,2)*2);
Cr_up=zeros(size(cr,1)*2,size(cr,2)*2);
cr=flip(cr);
cb_mid=zeros(size(cb,1)*2,size(cb,2));
cr_mid=zeros(size(cr,1)*2,size(cr,2));
cb_mid(1:2:end,:)=cb;
cr_mid(1:2:end,:)=cr;
cb_mid=padarray(cb_mid,[1 0],'replicate','post');
cr_mid=padarray(cr_mid,[1 0],'replicate','post');
cb_mid(end,:)=cb(end,:);
cr_mid(end,:)=cr(end,:);
for i=2:2:size(cb,1)*2
    cb_mid(i,:)=(cb_mid(i-1,:)+cb_mid(i+1,:))./2;
    cr_mid(i,:)=(cr_mid(i-1,:)+cr_mid(i+1,:))./2;
end
cb_mid=cb_mid(1:end-1,:);
cr_mid=cr_mid(1:end-1,:);
Cb_up(:,1:2:end)=cb_mid;
Cr_up(:,1:2:end)=cr_mid;
Cb_up=padarray(Cb_up,[0 1],'replicate','post');
Cr_up=padarray(Cr_up,[0 1],'replicate','post');
Cb_up(:,end)=cb_mid(:,end);
Cr_up(:,end)=cr_mid(:,end);
for i=2:2:size(cb,2)*2
    Cb_up(:,i)=(Cb_up(:,i-1)+Cb_up(:,i+1))./2;
    Cr_up(:,i)=(Cr_up(:,i-1)+Cr_up(:,i+1))./2;
end
Cb_up=Cb_up(:,1:end-1);
Cr_up=Cr_up(:,1:end-1);
Cr_up=flip(Cr_up);
end

