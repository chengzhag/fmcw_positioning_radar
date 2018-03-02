%% 清理
clear;
close all;

%% 运行参数设置
doShowSampleFtnyx=0;
doShowDsYXN=0;
useGPU=1;

%% 加载/提取数据、参数
load '../data/yLoCut_1MHz_400rps_1rpf_1t8r_walking.mat'

nRx=size(antBits,1);
yLoCut=log2array(logsout,'yLoCutSim');

fF=fTr/nRx/nCyclePF;

dLambda=3e8/fCen;
fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
dPs=fD/fPm;%distance per sample
ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

tsRamp=(0:lFft-1)/fS*fftDownFac;

% %% 截取有效时间
% tMi=5;
% tMa=38;
% valT=ts>=tMi & ts<=tMa;
% 
% yLoCut=yLoCut(:,:,valT);
% ts=ts(valT);

%% 为硬算公式准备参数
xsCoor=single(-8:0.2:8);
ysCoor=single(dMi:0.2:dMa);

[xsMesh,ysMesh]=meshgrid(xsCoor,ysCoor);
dsYXN=zeros(length(ysCoor),length(xsCoor),nRx);
for iRx=1:nRx
    dsYXN(:,:,iRx)=sqrt((xsMesh-antCoor(iRx,1)).^2+(ysMesh-antCoor(iRx,2)).^2) ...
        +sqrt((xsMesh-antCoor(end,1)).^2+(ysMesh-antCoor(end,2)).^2) ...
        +dCa;
end

fxytn=single(zeros(length(ysCoor),length(xsCoor),size(yLoCut,1),nRx));
for iRx=1:nRx
    for iT=1:size(yLoCut,1)
        fxytn(:,:,iT,iRx)=single(exp(j*2*pi*fBw*fTr*dsYXN(:,:,iRx)/3e8*tsRamp(iT))...
            .*exp(j*2*pi*dsYXN(:,:,iRx)/dLambda));
    end
end
ftnyx=permute(fxytn,[3,4,1,2]);

%% 可视化各天线到平面各点的来回距离
if doShowDsYXN
    hSample=figure('name','各天线到平面各点的来回距离');
    for iRx=1:nRx
        figure(hSample);
        imagesc(dsYXN(:,:,iRx));
        title(['Rx' num2str(iRx) '到平面各点的来回距离']);
        pause(0.2);
    end
end

%% 可视化某平行于x轴直线上各天线的频率和相位
if doShowSampleFtnyx
    ySample=0;
    iYSample=find(ySample<=ysCoor,1);
    hSample=figure('name',['y=' num2str(ySample) '直线上各天线的频率和相位']);
    for iXSample=1:size(ftnyx,4)
        figure(hSample);
        imagesc(angle(ftnyx(:,:,iYSample,iXSample)));
        title(['x=' num2str(xsCoor(iXSample)) ', y=' num2str(ySample) '点上各天线的频率和相位']);
        pause(0.1);
    end
end

%% 可视化某平行于y轴直线上各天线的频率和相位
if doShowSampleFtnyx
    xSample=0;
    iXSample=find(xSample<=xsCoor,1);
    hSample=figure('name',['x=' num2str(xSample) '直线上各天线的频率和相位']);
    for iYSample=1:size(ftnyx,3)
        figure(hSample);
        imagesc(angle(ftnyx(:,:,iYSample,iXSample)));
        title(['x=' num2str(xSample) ', y=' num2str(ysCoor(iYSample)) '点上各天线的频率和相位']);
        pause(0.1);
    end
end

%% 硬算功率分布
if useGPU
    ftnyxGPU=gpuArray(ftnyx);
    yLoCutGPU=gpuArray(yLoCut);
    heatMapsGPU=zeros(length(ysCoor),length(xsCoor),length(ts),'single','gpuArray');
    tic;
    for iFrame=1:length(ts)
        yLoRe=repmat(yLoCutGPU(:,:,iFrame),1,1,length(ysCoor),length(xsCoor));
        sf=sum(sum(yLoRe.*ftnyxGPU,1),2);
        heatMapsGPU(:,:,iFrame)=permute(sf,[3,4,1,2]);
        
        disp(['第' num2str(iFrame) '帧' num2str(iFrame/length(ts)*100,'%.1f') ...
            '% 用时' num2str(toc/60,'%.2f') 'min ' ...
            '剩余' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
    heatMaps=gather(heatMapsGPU);
else
    heatMaps=zeros(length(ysCoor),length(xsCoor),length(ts),'single');
    tic;
    for iFrame=1:length(ts)
        yLoRe=repmat(yLoCut(:,:,iFrame),1,1,length(ysCoor),length(xsCoor));
        sf=sum(sum(yLoRe.*ftnyx,1),2);
        heatMaps(:,:,iFrame)=permute(sf,[3,4,1,2]);
        
        disp(['第' num2str(iFrame) '帧' num2str(iFrame/length(ts)*100,'%.1f') ...
            '% 用时' num2str(toc/60,'%.2f') 'min ' ...
            '剩余' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end

%% 背景消除
heatMapsB=filter(0.2,[1,-0.8],heatMaps,0,3);
heatMapsF=abs(heatMaps-heatMapsB);

%% 显示功率分布
hHea=figure('name','空间热度图');
for iFrame=1:length(ts)
    figure(hHea);
    imagesc(xsCoor,ysCoor,heatMapsF(:,:,iFrame));
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['第' num2str(ts(iFrame)) 's 的空间热度图']);
    xlabel('x(m)');
    ylabel('y(m)');
    pause(0.01)
end
