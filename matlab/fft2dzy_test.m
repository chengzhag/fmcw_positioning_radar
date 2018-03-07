%% 清理
clear;
close all;

%% 运行参数设置
% doFindpeaksTest_findpeaks=0;
% doFindFirstpeakSampleTest_findpeaks=0;
% doFindFirstpeakTest_findpeaks=0;
doShowHeatMapsBefore=0;
doShowHeatMapsAfter=1;

%% 加载/提取数据、参数
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mat'

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));
tsRamp=(0:lFft-1)/fS*fftDownFac;

% %% 计算每根天线的参数
% % 计算发射天线到各接收天线之间的距离
% dsTxRxi=zeros(nRx,1);%暂时只做一根发射天线
% for iRx=1:nRx
%     dsTxRxi(iRx,:)=pdist([antCoor(iRx,:);antCoor(nRx+1,:)]);
% end

% %% 截取有效时间
% tMi=5;
% tMa=38;
% valT=ts>=tMi & ts<=tMa;
%
% yLoCut=yLoCut(:,:,valT);
% ts=ts(valT);

%% 竖直zy方向2DFFT
yLoTsrampTRTs=permute(yLoReshape,[1,3,2,4]);
heatMaps=fft2(yLoTsrampTRTs,lFft,nAng);
heatMaps=heatMaps(isD,:,:,:);

heatMaps=circshift(heatMaps,ceil(size(heatMaps,2)/2),2);
% heatMaps=flip(heatMaps,2);
%% 背景消除
heatMapsB=filter(0.2,[1,-0.8],heatMaps,0,4);
heatMapsF=abs(heatMaps-heatMapsB);
% heatMapsF=permute(prod(heatMapsF,3),[1,2,4,3]);
% heatMapsF=permute(sum(heatMapsF,3),[1,2,4,3]);
heatMapsF=permute(prod(heatMapsF(:,:,5:8,:),3),[1,2,4,3]);

%% 显示坐标转换前功率分布
if doShowHeatMapsBefore
    hHea=figure('name','空间热度图');
    for iFrame=1:size(heatMapsF,3)
        figure(hHea);
        heatMap=heatMapsF(:,:,iFrame);
        heatMap=heatMap./max(max(heatMap));
        imagesc(angs,dsC,heatMap);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['第' num2str(ts(iFrame)) 's 的空间热度图']);
        ylabel('y(m)');
        xlabel('angle(°)');
        pause(0.01);
    end
end

%% 显示坐标转换后功率分布
if doShowHeatMapsAfter
    % 极坐标转换
    zsCoor=single(-1:0.2:3);
    ysCoor=single(dMi:0.2:dMa);
    
    [xsMesh,ysMesh]=meshgrid(zsCoor,ysCoor);
    heatMapsCarF=zeros(length(ysCoor),length(zsCoor),length(ts),'single');
    
    % 计算坐标映射矩阵
    dsPo2Car=sqrt(xsMesh.^2+ysMesh.^2);
    angsPo2Car=atand(xsMesh./ysMesh);
    angsPo2Car(isnan(angsPo2Car))=0;
    
    for iFrame=1:length(ts)
        heatMapsCarF(:,:,iFrame)=interp2(angs,dsC,heatMapsF(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
    end
    
    % 显示功率分布
    hHea=figure('name','空间热度图');
    for iFrame=1:size(heatMapsCarF,3)
        figure(hHea);
        heatMap=heatMapsCarF(:,:,iFrame);
        heatMap=heatMap./max(max(heatMap));
        imagesc(zsCoor,ysCoor,heatMap);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['第' num2str(ts(iFrame)) 's 的空间热度图']);
        ylabel('y(m)');
        xlabel('z(m)');
        pause(0.01);
    end
end