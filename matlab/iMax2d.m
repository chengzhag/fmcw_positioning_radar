%% 二维数组最大值索引
function [isX,isY]=iMax2d(m)
[xsMax,isY]=max(m,[],2);
[~,isX]=max(xsMax,[],1);
isX=shiftdim(isX);
isY=permute(isY,[3,1,2]);
isY=isY((isX-1)*size(isY,1)+(1:size(isY,1))');
end