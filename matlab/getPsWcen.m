function psWcen = getPsWcen(xy, xsB, ysB, psWl)
psWcen=zeros(1,3,'single');
xsB=xsB(xsB>=xsB(1)+psWl(1)/2 & xsB<=xsB(end)-psWl(1)/2);
ysB=ysB(ysB>=ysB(1)+psWl(2)/2 & ysB<=ysB(end)-psWl(2)/2);
psWcen(1)=interp1(xsB,xsB,xy(1),'nearest','extrap');
psWcen(2)=interp1(ysB,ysB,xy(2),'nearest','extrap');
end

