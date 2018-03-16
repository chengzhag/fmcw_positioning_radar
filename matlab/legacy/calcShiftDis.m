%% 通过天线序号、时间偏移计算循环移位位移量
% dis: 位移量
% iAnt: 天线序号，从1开始
% tFramp: 第一个触发信号时间
% fS: 采样率
% nRx: 天线数量
function dis=calcShiftDis(iAnt,tFramp,lRamp,fS,nRx)
    dis=-((nRx+1-iAnt)*lRamp+(tFramp*fS));
end
