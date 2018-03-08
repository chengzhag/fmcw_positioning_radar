%% 清理
clear;
close all;

%% 运行参数设置
doShowSampleFtnyx=0;
doShowDsYXN=0;
useGPU=1;

%% 加载/提取数据、参数
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mat'

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));
tsRamp=(0:size(yLoCut,1)-1)/fS*fftDownFac;

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
xsMesh=permute(xsMesh,[2,1]);
ysMesh=permute(ysMesh,[2,1]);
pointCoor=[reshape(xsMesh,numel(xsMesh),1),reshape(ysMesh,numel(ysMesh),1),zeros(numel(xsMesh),1)];

%% 硬算功率分布
heatMaps=zeros(length(xsCoor),length(ysCoor),nTx,length(ts),'single','gpuArray');
fTsrampRTZ=zeros(length(tsRamp),nRx,1,numel(xsMesh),nTx,'single','gpuArray');
for iTx=1:nTx
fTsrampRTZ(:,:,:,:,iTx)=rfcaptureCo2F(pointCoor, ...
    [antCoor(1:nRx,:);antCoor(iTx+nRx,:)], ...
    nRx,1,dCa,tsRamp,fBw,fTr,dLambda,1);
end
tic;
for iFrame=1:length(ts)
    for iTx=1:nTx
        ps=rfcaptureF2ps(fTsrampRTZ(:,:,:,:,iTx),yLoReshape(:,:,iTx,iFrame),1);
        heatMaps(:,:,iTx,iFrame)=reshape(ps,length(xsCoor),length(ysCoor));
    end
    
    
    if mod(iFrame,10)==0
    disp(['第' num2str(iFrame) '帧' num2str(iFrame/length(ts)*100,'%.1f') ...
        '% 用时' num2str(toc/60,'%.2f') 'min ' ...
        '剩余' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end

%% 背景消除
heatMapsB=filter(0.2,[1,-0.8],heatMaps,0,4);
heatMapsF=abs(heatMaps-heatMapsB);
heatMapsF=permute(prod(heatMapsF,3),[1,2,4,3]);

%% 显示功率分布
hHea=figure('name','空间热度图');
for iFrame=1:length(ts)
    figure(hHea);
    imagesc(ysCoor,xsCoor,heatMapsF(:,:,iFrame));
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['第' num2str(ts(iFrame)) 's 的空间热度图']);
    xlabel('y(m)');
    ylabel('x(m)');
    pause(0.01)
end
