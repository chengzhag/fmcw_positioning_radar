%% 二维数组最大值索引
function [is1,is2]=iMax2d(m)
[xsMax,is2]=max(m,[],2);
[~,is1]=max(xsMax,[],1);
is1=shiftdim(is1);
is2=permute(is2,[3,1,2]);
is2=is2((is1-1)*size(is2,1)+(1:size(is2,1))');
end