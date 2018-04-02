function coor = isPo2coor(is, dsVal, angs)
coor=zeros(1,2,'single');
d=dsVal(is(1));
ang=angs(is(2));
coor(1)=d*sind(ang);
coor(2)=d*cosd(ang);
