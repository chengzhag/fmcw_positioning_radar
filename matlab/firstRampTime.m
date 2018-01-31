%% 同步斜坡信号起始时间函数，返回所有斜坡信号起始时间点
% tFramp: 第一个斜坡开始时间，精确到采样时间之下，以第一个采样点为参考时间0
% ysTr: 一帧triger信号
% fS: 采样率
% fTr: 触发信号频率
% tPul: 脉冲/比特宽度
% nPul: 脉冲/比特总数
% trEdge: 触发沿：1上升沿 0下降沿
% trThres: 触发电平
function tFramp=firstRampTime(ysTr, fS, fTr, tPul, nPul, trEdge, trThres)
%% 准备参数
lRamp=fS/fTr;%length ramp
lPul=fS*tPul;%length pulse

if(mod(size(ysTr,2),lRamp)~=0)
    error('The length of frame is not integer multiple of the length of ramp .');
end

%% 分析第一个完整斜坡同步信号
%第一个完整斜坡同步信号触发沿位于1:lRamp,为了容错，扩大范围到1:lRamp+lPul*nPul
isFramp=1:lRamp+lPul*nPul;%indexs first ramp
ysTrFf=ysTr(isFramp);%ys triger first ramp
isTrF=[];
if trEdge==0
    isTrF=find(ysTrFf(2:end)<trThres & ysTrFf(1:end-1)>=trThres)+1;%index triger first
else
    isTrF=find(ysTrFf(2:end)>trThres & ysTrFf(1:end-1)<=trThres)+1;
end
if isempty(isTrF)
    tFramp=single(nan);
    return
else
    iTrF=isTrF(find([true diff(isTrF)>lPul*nPul],1,'last'));%要求脉冲和比特总时长小于斜坡周期的一半,选取最后一个触发信号
end

% 在调试错误触发时启用
% if ysTr(iTrF+150)>trThres && ysTr(iTrF+250)>trThres
%     tFramp=single(nan);
%     return
% end

%% 线性插值分析上升沿的精确时间
tFramp=interp1([ysTr(iTrF-1),ysTr(iTrF)],([iTrF-1,iTrF]-1)/fS,trThres);
end
