%% 清理
close all;

%% 加载数据、参数
load '../data/foreground_1MHz_400rps_5rpf_1t3r_walking.mat'

nRx=size(antBits,1);
fo=log2array(logsout,'foregroundSim');
fo=fo(:,:,100:end);
fo=permute(fo,[1,3,2]);
lRamp=fS/fTr;%length ramp
lSp=size(fo,1);
fF=fTr/nRx/nCyclePF;

fBw=2e9;%frequency bandwidth
fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
fs=linspace(fD,fD*lSp,lSp);
ds=fs/fPm;
ts=linspace(0,size(fo,2)/fF,size(fo,2));%3Rx，5帧平均

%% 截取前景有效时间和距离范围
tMi=2;
dMa=50;
fo=fo(ds<dMa,ts>tMi,:);
ts=ts(ts>tMi);
ds=ds(ds<dMa);


%% 显示三根天线瀑布图
figure
for iRx=1:3
    subplot(1,3,iRx);
    imagesc(ds,ts,fo(:,:,iRx)');
    xlabel('d(m)');
    ylabel('t(s)');
    title(['Rx' num2str(iRx)]);
end



