%% 运行参数设置
doFindpeaksTest_findpeaks=0;
doFindFirstpeakSampleTest_findpeaks=0;
doFindFirstpeakTest_findpeaks=0;

%% 清理
close all;

%% 加载/提取数据、参数
load '../data/foreground_1MHz_400rps_1rpf_1t8r_walking.mat'

nRx=size(antBits,1);
fo=log2array(logsout,'foregroundSim');
fo=permute(fo,[1,3,2]);
lRamp=fS/fTr;%length ramp
lSp=size(fo,1);
fF=fTr/nRx/nCyclePF;

fBw=2e9;%frequency bandwidth
fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
dPs=fD/fPm;%distance per sample
fs=linspace(0,fD*(lSp-1),lSp);
ds=fs/fPm;
ts=linspace(0,size(fo,2)/fF,size(fo,2));

%% 计算每根天线的参数
% 计算发射天线到各接收天线之间的距离
dsTxRxi=zeros(nRx,1);%暂时只做一根发射天线
for iRx=1:nRx
    dsTxRxi(iRx,:)=pdist([antCoor(iRx,:);antCoor(nRx+1,:)]);
end

% 排除线缆长度，截取有效距离
fo=fo(ds>=dCa,:,:);
ds=ds(ds>=dCa)-dCa;

%% 截取前景有效时间和距离范围
tMi=4;
tMa=20;
dMi=max(dsTxRxi);
dMa=20;
valT=ts>=tMi & ts<=tMa;
valD=ds>=dMi & ds<=dMa;

fo=fo(valD,valT,:);
ts=ts(valT);
ds=ds(valD);


%% 显示三根天线瀑布图
figure('name','三根天线瀑布图');
for iRx=1:nRx
    subplot(1,nRx,iRx);
    imagesc(ds,ts,log(fo(:,:,iRx)'));
    xlabel('d(m)');
    ylabel('t(s)');
    title(['Rx' num2str(iRx)]);
end

%% 测试findpeaks函数
if doFindpeaksTest_findpeaks
    hFP=figure('name','测试findpeaks函数');
    for iF=1:5:size(fo,2)
        figure(hFP);
        for iRx=1:nRx
            subplot(1,nRx,iRx);
            findpeaks(fo(:,iF,iRx),ds,'MinPeakProminence',max(fo(:,iF,iRx))*0.8,'Annotate','extents','NPeaks',1);
            title(['第' num2str(ts(iF)) 's Rx' num2str(iRx) '的频谱']);
        end
        pause(0.5);
    end
end

%% 显示示例帧，检验findFirstPeak函数
if doFindFirstpeakSampleTest_findpeaks
    iSam=find(ts>10,1);
    foSam=permute(fo(:,iSam,:),[1,3,2]);
    hSam=figure('name','示例帧寻峰测试');
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        plot(ds,foSam(:,iRx));
        xlabel('d(m)');
        title(['第' num2str(ts(iSam)) 's Rx' num2str(iRx) '的频谱']);
    end
    
    iFp=findFirstPeak(foSam,0.7);
    figure(hSam);
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        hold on;
        plot(ds(iFp(iRx)),foSam(iFp(iRx),iRx),'o');
        hold off;
    end
end

%% 检测所有帧的峰值，测试findFirstPeak函数
if doFindFirstpeakTest_findpeaks
    dsTa=zeros(size(fo,2),nRx);
    for iF=1:size(fo,2);
        dsTa(iF,:)=findFirstPeak(permute(fo(:,iF,:),[1,3,2]),0.7);
    end
    dsTa=dsTa.*dPs;
    hDT=figure('name','寻峰得到的距离——时间曲线');
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        plot(dsTa(:,iRx),ts);
        ylabel('t(s)');
        xlabel('d(m)');
        title(['Rx' num2str(iRx) '的距离——时间曲线']);
    end
    
    %% 对距离——时间曲线做异常值剔除和滤波处理
    dsTaHampel=hampel(dsTa,11,0.5);
    figure(hDT);
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        hold on;
        plot(dsTaHampel(:,iRx),ts);
    end
    
    dsTaFiltered=filter(0.2,[1,-0.8],dsTaHampel);
    figure(hDT);
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        hold on;
        plot(dsTaFiltered(:,iRx),ts);
    end
end

%% 