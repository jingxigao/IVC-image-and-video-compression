function sign=mv_sign( mv_curr)
        if mv_curr(1)>0
            sign(1)=1;
        elseif mv_curr(1)<0
            sign(1)=-1;
        else
            sign(1)=0;
        end
        if mv_curr(2)>0
            sign(2)=1;
        elseif mv_curr(2)<0
            sign(2)=-1;
        else
            sign(2)=0;
        end

end

