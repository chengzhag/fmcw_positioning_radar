function psWcen = getPsWcen(xy, xsB, ysB, psWl)
x=limitUD(xy(1),xsB(1)+psWl(1)/2,xsB(end)-psWl(1)/2);
y=limitUD(xy(2),ysB(1)+psWl(2)/2,ysB(end)-psWl(2)/2);
[~,ix]=min(abs(xsB-x));
[~,iy]=min(abs(ysB-y));
psWcen = [xsB(ix),ysB(iy),0];
end

function ar=limitUD(a,d,u)
if a<d
    ar=d;
elseif a>u
    ar=u;
else
    ar=a;
end

end
