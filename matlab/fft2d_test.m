%% 清理
clear;
close all;

%% 运行参数设置
% doFindpeaksTest_findpeaks=0;
% doFindFirstpeakSampleTest_findpeaks=0;
% doFindFirstpeakTest_findpeaks=0;
doShowXYs=0;
doShowTargetLabel=0;
doShowHeatMapsBefore=0;
doShowHeatMapsAfter=1;

%% 加载/提取数据、参数
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mat'

yLoCut=log2array(logsout,'yLoCutSim');
heatMap=log2array(logsout,'heatMapSim');
coorPolRaw=log2array(logsout,'coorPolRawSim');
coorPolFil=log2array(logsout,'coorPolFilSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));
% tsRamp=(0:size(yLoCut,1)-1)/fS*fftDownFac;

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

%% 坐标处理
dsPol=single(interp1(ds,shiftdim(single(coorPolFil(:,1,:)))));
angsPol=single(-interp1(angs,shiftdim(single(coorPolFil(:,2,:)))));
dsPol(isnan(dsPol))=0;
angsPol(isnan(angsPol))=0;
xs=dsPol.*sind(angsPol);
ys=dsPol.*cosd(angsPol);
xs(isnan(xs))=0;
ys(isnan(ys))=0;
if doShowXYs
    hCor=figure('name','目标点坐标');
    plot(ts,xs,ts,ys);
    hold on;
end
xs=medfilt1(xs,16,[],1);
ys=medfilt1(ys,16,[],1);
if doShowXYs
    figure(hCor);
    plot(ts,xs,ts,ys);
    title('目标点坐标');
    legend('x滤波前','y滤波前','x滤波后','y滤波后');
    xlabel('t(s)');
    ylabel('(m)');
    hold off;
    pause(0.1);
end

%% 水平xy方向2DFFT
heatMaps=fft2(yLoReshape,lFft,nAng);
heatMaps=heatMaps(isD,:,:,:);

heatMaps=circshift(heatMaps,ceil(size(heatMaps,2)/2),2);
heatMaps=flip(heatMaps,2);
%% 背景消除
heatMapsB=filter(0.2,[1,-0.8],heatMaps,0,4);
heatMapsF=abs(heatMaps-heatMapsB);
heatMapsF=permute(prod(heatMapsF,3),[1,2,4,3]);

if doShowHeatMapsBefore
    %% 显示功率分布
    hHea=figure('name','空间热度图');
    for iFrame=1:size(heatMapsF,3)
        figure(hHea);
        heatMap=heatMapsF(:,:,iFrame);
        heatMap=heatMap./max(max(heatMap));
%         if doShowTargetLabel
%             heatMap=insertShape(heatMap, ...
%                 'circle',[length(angs)-coorPolFil(:,2,iFrame) coorPolFil(:,1,iFrame) 3], ...
%                 'LineWidth',2,'Color','blue');
%         end
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
    ysCoor=single(dMi:0.2:dMa);
    
    [xsMesh,ysMesh]=meshgrid(xsCoor,ysCoor);
    heatMapsCarF=zeros(length(ysCoor),length(xsCoor),length(ts),'single');
    
    % 计算坐标映射矩阵
    dsPo2Car=sqrt(xsMesh.^2+ysMesh.^2);
    angsPo2Car=atand(xsMesh./ysMesh);
    angsPo2Car(isnan(angsPo2Car))=0;
    
    for iFrame=1:length(ts)
        heatMapsCarF(:,:,iFrame)=interp2(angs,dsC,heatMapsF(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
    end
    
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

