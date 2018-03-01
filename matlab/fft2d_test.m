%% 清理
clear;
close all;

%% 运行参数设置
doFindpeaksTest_findpeaks=0;
doFindFirstpeakSampleTest_findpeaks=0;
doFindFirstpeakTest_findpeaks=0;
doShowHeatMapsBefore=0;
doShowHeatMapsAfter=1;
delAng=0.5;

%% 加载/提取数据、参数
load '../data/yLoCut_1MHz_400rps_1rpf_1t8r_walking.mat'

nRx=size(antBits,1);
yLoCut=log2array(logsout,'yLoCutSim');

% 降采样
yLoCut=yLoCut(1:5:size(yLoCut,1),:,:);
fS=fS/5;
lFft=lFft/5;

lRamp=fS/fTr;%length ramp
lSp=size(yLoCut,1);
fF=fTr/nRx/nCyclePF;

dLambda=3e8/3e9;
fBw=2e9;%frequency bandwidth
fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
dPs=fD/fPm;%distance per sample
fs=linspace(0,fD*(lSp/2-1),floor(lSp/2));
ds=fs/fPm;
ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

angMax=asind(dLambda/2/abs(antCoor(1,1)-antCoor(2,1)));
nAng=floor(angMax*2/delAng);
angs=linspace(-angMax,angMax,nAng);

%% 计算每根天线的参数
% 计算发射天线到各接收天线之间的距离
dsTxRxi=zeros(nRx,1);%暂时只做一根发射天线
for iRx=1:nRx
    dsTxRxi(iRx,:)=pdist([antCoor(iRx,:);antCoor(nRx+1,:)]);
end

%% 截取有效时间
tMi=5;
tMa=38;
valT=ts>=tMi & ts<=tMa;

yLoCut=yLoCut(:,:,valT);
ts=ts(valT);

%% 2DFFT
% yLoCut=yLoCut...
%     .*repmat(hamming(size(yLoCut,2))',size(yLoCut,1),1,size(yLoCut,3))...
%     .*repmat(hamming(size(yLoCut,1)),1,size(yLoCut,2),size(yLoCut,3));
heatMaps=fft2(yLoCut,size(yLoCut,1),nAng);

% 排除线缆长度，截取有效距离
heatMaps=heatMaps(ds>=dCa,:,:);
dsC=(ds(ds>=dCa)-dCa)/2;

% 截取有效距离范围
dMi=0;
dMa=10;
valD=dsC>=dMi & dsC<=dMa;

heatMaps=heatMaps(valD,:,:);
dsC=dsC(valD);

heatMaps=flip(heatMaps,2);
heatMaps=circshift(heatMaps,ceil(size(heatMaps,2)/2),2);

if doShowHeatMapsBefore
    %% 背景消除
    heatMapsB=filter(0.05,[1,-0.95],heatMaps,0,3);
    heatMapsF=abs(heatMaps-heatMapsB);
    
    %% 显示功率分布
    hHea=figure('name','空间热度图');
    for iFrame=1:size(heatMapsF,3)
        figure(hHea);
        heatMap=heatMapsF(:,:,iFrame);
        imagesc(angs,dsC,heatMap);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['第' num2str(ts(iFrame)) 's 的空间热度图']);
        ylabel('y(m)');
        xlabel('angle(°)');
        pause(0.01);
    end
end

if doShowHeatMapsAfter
    %% 极坐标转换
    xsCoor=single(-8:0.2:8);
    ysCoor=single(0:0.2:10);
    
    [xsMesh,ysMesh]=meshgrid(xsCoor,ysCoor);
    heatMapsCar=zeros(length(ysCoor),length(xsCoor),length(ts),'single');
    
    % 计算坐标映射矩阵
    dsPo2Car=sqrt(xsMesh.^2+ysMesh.^2);
    angsPo2Car=atand(xsMesh./ysMesh);
    angsPo2Car(isnan(angsPo2Car))=0;
    
    for iFrame=1:length(ts)
        heatMapsCar(:,:,iFrame)=interp2(angs,dsC,heatMaps(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
    end
    
    %% 背景消除
    heatMapsCarB=filter(0.05,[1,-0.95],heatMapsCar,0,3);
    heatMapsCarF=abs(heatMapsCar-heatMapsCarB);
    
    %% 显示功率分布
    hHea=figure('name','空间热度图');
    for iFrame=1:size(heatMapsCarF,3)
        figure(hHea);
        heatMap=heatMapsCarF(:,:,iFrame);
        imagesc(xsCoor,ysCoor,heatMap);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['第' num2str(ts(iFrame)) 's 的空间热度图']);
        ylabel('y(m)');
        xlabel('x(m)');
        pause(0.01);
    end
end
