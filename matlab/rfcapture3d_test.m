%% 清理
clear;
close all;

%% 运行参数设置
doShowXYs=1;
doShowSamTsRsZ=0;
doShowSamFTsrampRTZ=1;
% useGPU=1;

%% 加载/提取数据、参数
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mat'

yLoCut=log2array(logsout,'yLoCutSim');
heatMap=log2array(logsout,'heatMapSim');
coorPolRaw=log2array(logsout,'coorPolRawSim');
coorPolFil=log2array(logsout,'coorPolFilSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));
tsRamp=(0:size(yLoCut,1)-1)/fS*fftDownFac;

% iTsVal=(ts>5&ts<50);
iTsVal=true(length(ts),1);

%% 为硬算公式准备参数
dsPol=single(interp1(ds,shiftdim(single(coorPolFil(:,1,:)))));
angsPol=single(-interp1(angs,shiftdim(single(coorPolFil(:,2,:)))));
zs=single(-1:0.05:2);
xs=dsPol.*sind(angsPol);
ys=dsPol.*cosd(angsPol);
xs(isnan(xs))=0;
ys(isnan(ys))=0;
if doShowXYs
    plot(ts,xs,ts,ys);
    hold on;
end
% xs=filter(0.1,[1,-0.9],xs,0,1);
% ys=filter(0.1,[1,-0.9],ys,0,1);
xs=medfilt1(xs,16,[],1);
ys=medfilt1(ys,16,[],1);
zsTs=repmat(zs',1,length(ts));
xsTs=repmat(xs',length(zs),1);
ysTs=repmat(ys',length(zs),1);
if doShowXYs
    plot(ts,xs,ts,ys);
    title('目标点坐标');
    legend('x滤波前','y滤波前','x滤波后','y滤波后');
    xlabel('t(s)');
    ylabel('(m)');
    hold off;
end

%% 计算功率
psZGPU=zeros(length(zs),length(ts),'single','gpuArray');
tic;
for iFrame=1:length(ts)
    %% 计算r(n,m)(X(ts),Y(ts),z)，（ts为长时间）
    rsCoRT=zeros(length(zs),nRx,nTx,'single');%r(n,m)(X(ts),Y(ts),z)，（ts为长时间）
    for iRx=1:nRx
        for iTx=1:nTx
            rsCoRT(:,iRx,iTx)=sqrt( ...
                (xsTs(:,iFrame)-repmat(single(antCoor(iRx,1)),length(zs),1)).^2 ...
                + (ysTs(:,iFrame)-repmat(single(antCoor(iRx,2)),length(zs),1)).^2 ...
                + (zsTs(:,iFrame)-repmat(single(antCoor(iRx,3)),length(zs),1)).^2 ...
                ) ...
                + sqrt( ...
                (xsTs(:,iFrame)-repmat(single(antCoor(iTx+nRx,1)),length(zs),1)).^2 ...
                + (ysTs(:,iFrame)-repmat(single(antCoor(iTx+nRx,2)),length(zs),1)).^2 ...
                + (zsTs(:,iFrame)-repmat(single(antCoor(iTx+nRx,3)),length(zs),1)).^2 ...
                );
        end
    end
    
    %% 计算sumsumsum s(n,m,ts,tsRamp)*f(n,m,zs,ts,tsRamp)，（ts为长时间,tsRamp为短时间）
    rsCoRTGPU=gpuArray(rsCoRT);
    yLoReshapeGPU=gpuArray(yLoReshape(:,:,:,iFrame));
    tsRampGPU=gpuArray(tsRamp);
    rsCoRTTsrampGPU=permute(repmat(rsCoRTGPU,1,1,1,length(tsRamp)),[4,2,3,1]);
    tsCoRTTsrampGPU=repmat(tsRampGPU',1,size(rsCoRTTsrampGPU,2),size(rsCoRTTsrampGPU,3),size(rsCoRTTsrampGPU,4));
    % psGPU=zeros(1,length(xss),'single','gpuArray');
    
    fTsrampRTZ=exp( ...
        1i*2*pi*fBw*fTr.*rsCoRTTsrampGPU/3e8 ...
        .*tsCoRTTsrampGPU ...
        ) ...
        .*exp( ...
        1i*2*pi*rsCoRTTsrampGPU/dLambda ...
        );
    psGPU=shiftdim(sum(sum(sum(fTsrampRTZ.*repmat(yLoReshapeGPU,1,1,1,size(fTsrampRTZ,4)),1),2),3));
    
    psZGPU(:,iFrame)=abs(psGPU);
    
    if mod(iFrame,10)==0
    disp(['第' num2str(iFrame) '帧' num2str(iFrame/length(ts)*100,'%.1f') ...
        '% 用时' num2str(toc/60,'%.2f') 'min ' ...
        '剩余' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end
psZ=gather(psZGPU);
psZ(isnan(psZ))=0;

%% 背景消除
psZF=filter(0.2,[1,-0.8],abs(psZ),0,2);
% psZF=psZ-psZB;

%% 绘制目标点 z方向上各点的功率随时间变化关系图
psZAmp=abs(psZF(:,iTsVal));
psZAmp=psZAmp./repmat(max(psZAmp),length(zs),1);
hpsZ=figure('name','目标点 z方向上各点的功率随时间变化关系图');
imagesc(ts(iTsVal),zs,psZAmp);
set(gca, 'XDir','normal', 'YDir','normal');
title('目标点 z方向上各点的功率随时间变化关系图');
xlabel('t(s)');
ylabel('z(m)');

