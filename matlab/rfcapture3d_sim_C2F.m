%% 清理
clear;
close all;

%% 运行参数设置
doShowLo=0;
doShowPsYZsum=0;
doShowPsXYsum=1;
useGPU=1;

%% 加载/提取数据、参数
nTx=4;
nRx=12;
rxCoor=[linspace(-0.053*(nRx/2-0.5),0.053*(nRx/2-0.5),nRx)',zeros(nRx,2)];
txCoor=[zeros(nTx,2),linspace(-0.138-0.053*(nTx-1),-0.138,nTx)'];
fCen=3.2e9;
fBw=1e9;
fSDown=200e3;
fRamp=800;
lRampDown=fSDown/fRamp;
lFft=512;
dLambda=3e8/fCen;
dMa=10;
dMi=1;
dCa=0;

fPm=fBw*fRamp/3e8;%frequency per meter

tsRamp=(0:lRampDown-1)/fSDown;

tarCoor=[1,3,0.5];%target coordinate

%% 计算目标点反射回波下变频的中频信号
% 计算目标到各天线间的距离
dsRT=zeros(nRx,nTx);
for iTx=1:nTx
    for iRx=1:nRx
        dsRT(iRx,iTx)=pdist([tarCoor;rxCoor(iRx,:)])+pdist([tarCoor;txCoor(iTx,:)]);
    end
end

yLoReshape=zeros(lRampDown,nRx,nTx);
for iTx=1:nTx
    for iRx=1:nRx
        yLoReshape(:,iRx,iTx)=cos(2*pi*fPm*dsRT(iRx,iTx)*tsRamp+2*pi*dsRT(iRx,iTx)/dLambda);
    end
end
if doShowLo
    figure('name','yLo');
    yLo=reshape(yLoReshape,lRampDown,nRx*nTx);
    imagesc(1:nRx*nTx,tsRamp*1e6,yLo);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('yLo');
    xlabel('天线编号');
    ylabel('tsRamp(us)');
end

%% 由粗到细算法
dxIn=2;
dyIn=2;
dzIn=2;
C2Ffac=3;
nC2F=2;
C2Fratio=0.1;

% 最粗一级
% 初始化
xs=single(-3:dxIn:3);
ys=single(1:dyIn:5);
zs=single(-1.5:dzIn:1.5);
[xss,yss,zss]=meshgrid(xs,ys,zs);
xsV=reshape(xss,numel(xss),1);
ysV=reshape(yss,numel(yss),1);
zsV=reshape(zss,numel(zss),1);
pointCoor=[xsV,ysV,zsV];

fTsrampRTZ=rfcaptureCo2F(pointCoor,rxCoor,txCoor,nRx,nTx,0,tsRamp,fBw,fRamp,dLambda,1);
ps=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,1));
ps=reshape(ps,size(xss));

hPs=figure('name','ps的xy投影图');
psYXsum=sum(ps,3);
figure(hPs);
imagesc(xs,ys,psYXsum);
set(gca, 'XDir','normal', 'YDir','normal');
title('ps的xy投影图');
xlabel('x(m)');
ylabel('y(m)');
pause(1);

for i=1:nC2F
    [ps,xs,ys,zs]=getFine(ps,xs,ys,zs,C2Ffac,C2Fratio, ...
        yLoReshape,rxCoor,txCoor,nRx,nTx,0,tsRamp, ...
        fBw,fRamp,dLambda,1);
    
    figure(hPs);
    psYXsum=sum(ps,3);
    figure(hPs);
    imagesc(xs,ys,psYXsum);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('ps的xy投影图');
    xlabel('x(m)');
    ylabel('y(m)');
    
    pause(1);
    
end

%% 精算公式
function [psF,xsF,ysF,zsF]=getFine(psC,xsC,ysC,zsC,C2Ffac,C2Fratio, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)

[xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
isXc=ceil(C2Ffac/2):C2Ffac:length(xsC)*C2Ffac-floor(C2Ffac/2);
isYc=ceil(C2Ffac/2):C2Ffac:length(ysC)*C2Ffac-floor(C2Ffac/2);
isZc=ceil(C2Ffac/2):C2Ffac:length(zsC)*C2Ffac-floor(C2Ffac/2);
isXf=1:length(xsC)*C2Ffac;
isYf=1:length(ysC)*C2Ffac;
isZf=1:length(zsC)*C2Ffac;
xsF=interp1(isXc,xsC,isXf,'linear','extrap');
ysF=interp1(isYc,ysC,isYf,'linear','extrap');
zsF=interp1(isZc,zsC,isZf,'linear','extrap');
[xssF,yssF,zssF]=meshgrid(xsF,ysF,zsF);
xsFv=reshape(xssF,numel(xssF),1);
ysFv=reshape(yssF,numel(yssF),1);
zsFv=reshape(zssF,numel(zssF),1);
pointCoor=[xsFv,ysFv,zsFv];


psF=interp3(xssC,yssC,zssC, ...
    psC,xssF,yssF,zssF,'linear',0);

% 根据规则选取精算点
psV=reshape(psF,numel(psF),1);
[~,isH]=sort(psV,'descend');
isH=isH(1:floor(length(isH)*C2Fratio));

% 硬算选取点
fTsrampRTZ=rfcaptureCo2F(pointCoor(isH,:),rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,1));
psF(isH)=psH;
end
