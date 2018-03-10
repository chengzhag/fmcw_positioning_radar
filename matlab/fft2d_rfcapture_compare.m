%% 清理
clear;
close all;

%% 加载/提取数据、参数
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mat'

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

%% 坐标设置
dx=0.15;
dy=0.15;
xsCoor=single(-8:dx:8);
ysCoor=single(dMi:dy:dMa);

%% rfcapture2d测试
[xsMesh,ysMesh]=meshgrid(xsCoor,ysCoor);
pointCoor=[reshape(xsMesh,numel(xsMesh),1),reshape(ysMesh,numel(ysMesh),1),zeros(numel(xsMesh),1)];

% 硬算功率分布
heatMapsCap=zeros(length(ysCoor),length(xsCoor),nTx,length(ts),'single','gpuArray');
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
        heatMapsCap(:,:,iTx,iFrame)=reshape(ps,length(ysCoor),length(xsCoor));
    end
    
    
    if mod(iFrame,10)==0
    disp(['第' num2str(iFrame) '帧' num2str(iFrame/length(ts)*100,'%.1f') ...
        '% 用时' num2str(toc/60,'%.2f') 'min ' ...
        '剩余' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end

% 背景消除
heatMapsBCap=filter(0.2,[1,-0.8],heatMapsCap,0,4);
heatMapsFCap=abs(heatMapsCap-heatMapsBCap);
heatMapsFCap=permute(prod(heatMapsFCap,3),[1,2,4,3]);

%% fft2d测试
heatMapsFft=fft2(yLoReshape,lFft,nAng);
heatMapsFft=heatMapsFft(isD,:,:,:);

heatMapsFft=circshift(heatMapsFft,floor(size(heatMapsFft,2)/2)+1,2);
heatMapsFft=flip(heatMapsFft,2);

% 背景消除
heatMapsBFft=filter(0.2,[1,-0.8],heatMapsFft,0,4);
heatMapsFFft=abs(heatMapsFft-heatMapsBFft);
heatMapsFFft=permute(prod(heatMapsFFft,3),[1,2,4,3]);

% 极坐标转换
heatMapsCarFFft=zeros(length(ysCoor),length(xsCoor),length(ts),'single');

% 计算坐标映射矩阵
dsPo2Car=sqrt(xsMesh.^2+ysMesh.^2);
angsPo2Car=atand(xsMesh./ysMesh);
angsPo2Car(isnan(angsPo2Car))=0;

for iFrame=1:length(ts)
    heatMapsCarFFft(:,:,iFrame)=interp2(angs,dsC,heatMapsFFft(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
end

%% 显示功率分布
hHea=figure('name','空间热度图');
for iFrame=1:length(ts)
    figure(hHea);
    subplot(1,2,1);
    imagesc(xsCoor,ysCoor,heatMapsFCap(:,:,iFrame));
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['第' num2str(ts(iFrame)) 's 的rfcapture2d空间热度图']);
    xlabel('x(m)');
    ylabel('y(m)');
    
    subplot(1,2,2);
    imagesc(xsCoor,ysCoor,heatMapsCarFFft(:,:,iFrame));
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['第' num2str(ts(iFrame)) 's 的fft2d空间热度图']);
    xlabel('x(m)');
    ylabel('y(m)');
    
    pause(0.01)
end

%% 比较目标坐标
[isXTarCap,isYTarCap]=iMax2d(heatMapsFCap);
[isXTarFft,isYTarFft]=iMax2d(heatMapsCarFFft);

xsTarCap=xsCoor(isXTarCap);
ysTarCap=ysCoor(isYTarCap);
xsTarFft=xsCoor(isXTarFft);
ysTarFft=ysCoor(isYTarFft);

hCoor=figure('name','比较两种方法所得目标坐标');
subplot(1,2,1);
plot(ts,xsTarCap,ts,xsTarFft);
legend('xsTarCap','xsTarFft');
title('比较两种方法所得目标x坐标');
xlabel('t(s)');
ylabel('x(m)');

subplot(1,2,2);
plot(ts,ysTarCap,ts,ysTarFft);
legend('ysTarCap','ysTarFft');
title('比较两种方法所得目标y坐标');
xlabel('t(s)');
ylabel('y(m)');

%% 二维数组最大值索引
function [isX,isY]=iMax2d(m)
[xsMax,isX]=max(m,[],2);
[~,isY]=max(xsMax,[],1);
isY=shiftdim(isY);
isX=permute(isX,[3,1,2]);
isX=isX((isY-1)*size(isX,1)+(1:size(isX,1))');
end