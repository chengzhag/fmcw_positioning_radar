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
tMa=20;
dMi=0;
dMa=30;
valT=ts>=tMi & ts<=tMa;
valD=ds>=dMi & ds<=dMa;

fo=fo(valD,valT,:);
ts=ts(valT);
ds=ds(valD);


%% 显示三根天线瀑布图
figure('name','三根天线瀑布图');
for iRx=1:3
    subplot(1,3,iRx);
    imagesc(ds,ts,fo(:,:,iRx)');
    xlabel('d(m)');
    ylabel('t(s)');
    title(['Rx' num2str(iRx)]);
end

%% 测试findpeaks函数
hFP=figure('name','测试findpeaks函数');
for iF=1:5:size(fo,2)
    figure(hFP);
    for iRx=1:3
        subplot(1,3,iRx);
        findpeaks(fo(:,iF,iRx),ds,'MinPeakProminence',max(fo(:,iF,iRx))/2,'Annotate','extents','NPeaks',1);
        title(['第' num2str(ts(iF)) 's Rx' num2str(iRx) '的频谱']);
    end
    pause(0.5);
end

%% 显示示例帧
iSam=find(ts>10,1);
foSam=permute(fo(:,iSam,:),[1,3,2]);
hSam=figure('name','示例帧寻峰测试');
for iRx=1:3
    subplot(1,3,iRx);
    plot(ds,foSam(:,iRx));
    xlabel('d(m)');
    title(['第' num2str(ts(iSam)) 's Rx' num2str(iRx) '的频谱']);
end

% 
% % 检验findFirstPeak函数
% iFp=findFirstPeak(foSam);
% figure(hSam);
% for iRx=1:3
%     subplot(1,3,iRx);
%     hold on;
%     plot(ds(iFp(iRx)),foSam(iFp(iRx),iRx),'o');
%     hold off;
% end


