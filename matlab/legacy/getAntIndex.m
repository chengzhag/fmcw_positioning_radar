%% 判断触发时间对应同步信号的天线编号
% iAnt: 天线编号
% ysTr: 一帧triger信号
% tRamp: 斜坡开始时间，以第一个采样点为参考时间0
% fS: 采样率
% tPul: 脉冲/比特宽度
% trThres: 触发电平
% antBits: 天线编号
function iAnt=getAntNum(ysTr, tRamp, fS, tPul, trThres, antBits)
if isnan(tRamp)
    iAnt=nan;
    return
end
%% 准备参数
lPul=fS*tPul;%length pulse

%% 抽取天线编号的比特电平
iBit1=ceil((tRamp+1.5*tPul)*fS)+1;
isBits=linspace(iBit1,iBit1+lPul*(size(antBits,2)-1),size(antBits,2));

ysBits=ysTr(isBits);
isAnt=find(all(~xor(antBits,repmat((ysBits>trThres),size(antBits,1),1)),2),1);
if isempty(isAnt)
    iAnt=nan;
    return
end
iAnt=isAnt(1);%为simulink推理iAnt大小提供帮助

end
