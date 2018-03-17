%% 清理
clear;
close all;

%% 运行参数设置
doShowLo=0;
doShowPsProject=1;
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

tarCoor=[2,4,0.5];%target coordinate

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
dxIn=1;
dyIn=1;
dzIn=1;
C2Ffac=3;
nC2F=2;
C2Fratio=0.1;

xs=single(-3:dxIn:3);
ys=single(1:dyIn:5);
zs=single(-1.5:dzIn:1.5);

[psF,xsF,ysF,zsF]=rfcaptureC2F(xs,ys,zs,nC2F,C2Fratio,C2Ffac,doShowPsProject, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);

