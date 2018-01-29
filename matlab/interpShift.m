%% 循环移位，通过线性插值实现小数位数的移位
% vOut: 输出向量
% vIn: 输入向量
% dis: 向右移位距离
function vOut=interpShift(vIn, dis)
    isZeroBased=0:length(vIn)-1;
    if dis>=0
        iShift=floor(dis);
        iAdd=dis-iShift;
    else
        iShift=ceil(dis);
        iAdd=iShift-dis;
    end
    
    isShifted=circshift(isZeroBased,iShift);
    iInterp=isShifted+iAdd;
    vOut=interp1(isZeroBased,vIn,iInterp,'linear','extrap');
end