%% 清理
clear;
close all;

%% 运行参数设置
doShowLo=0;
doShowPsYZ=0;
doShowPsXY=0;
doShowPsYZsum=1;
doShowPsXYsum=1;

%% 加载/提取数据、参数
nTx=8;
nRx=8;
antCoor=[ ...
    [linspace(-0.053*(nRx/2-0.5),0.053*(nRx/2-0.5),nRx)',zeros(nRx,2)]; ...
    [zeros(nTx,2),linspace(-0.138-0.053*(nTx-1),-0.138,nTx)'] ...
    ];
fCen=3.2e9;
fBw=1e9;
fS=200e3;
fTr=800;
lRamp=fS/fTr;
lFft=lRamp;
dLambda=3e8/fCen;
dMa=10;
dMi=1;

fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
fs=linspace(0,fS/2-fD,floor(lFft/2));
ds=fs/fPm;

tsRamp=(0:lRamp-1)/fS;

tarCoor=[1,3,0.5];%target coordinate
dx=0.05;
dy=0.05;
dz=0.05;

lBlock=1000;

%% 计算坐标
xs=single(-2:dx:2);
ys=single(0:dy:5);
zs=single(-1:dz:2);
[xss,yss,zss]=meshgrid(xs,ys,zs);
xss=permute(xss,[2,1,3]);
yss=permute(yss,[2,1,3]);
zss=permute(zss,[2,1,3]);
xsV=reshape(xss,numel(xss),1);
ysV=reshape(yss,numel(yss),1);
zsV=reshape(zss,numel(zss),1);
pointCoor=[xsV,ysV,zsV];

%% 计算目标点反射回波下变频的中频信号
% 计算目标到各天线间的距离
dsRT=zeros(nRx,nTx);
for iTx=1:nTx
    for iRx=1:nRx
        dsRT(iRx,iTx)=pdist([tarCoor;antCoor(iRx,:)])+pdist([tarCoor;antCoor(iTx+nRx,:)]);
    end
end

yLoReshape=zeros(lRamp,nRx,nTx);
for iTx=1:nTx
    for iRx=1:nRx
        yLoReshape(:,iRx,iTx)=cos(2*pi*fPm*dsRT(iRx,iTx)*tsRamp+2*pi*dsRT(iRx,iTx)/dLambda);
    end
end
if doShowLo
    figure('name','yLo');
    yLo=reshape(yLoReshape,lRamp,nRx*nTx);
    imagesc(1:nRx*nTx,tsRamp*1e6,yLo);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('yLo');
    xlabel('天线编号');
    ylabel('tsRamp(us)');
end

%% 根据rfcapture论文的硬算公式计算指定坐标上的功率大小
ps=zeros(size(pointCoor,1),1,'gpuArray');
isS=1:lBlock:size(pointCoor,1);
tic;
for iS=isS
    iBlock=(iS-1)/lBlock+1;
    if iS+lBlock-1<size(pointCoor,1)
        isBlock=iS:iS+lBlock-1;
    else
        isBlock=iS:size(pointCoor,1);
    end
    fTsrampRTZ=rfcaptureCo2F(pointCoor(isBlock,:),antCoor,nRx,nTx,0,tsRamp,fBw,fTr,dLambda,1);
    ps(isBlock,1)=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,1));
    if mod(iBlock,10)==0
    disp(['第' num2str(iBlock) '分块' num2str(iBlock/length(isS)*100,'%.1f') ...
        '% 用时' num2str(toc/60,'%.2f') 'min ' ...
        '剩余' num2str(toc/iBlock*(length(isS)-iBlock)/60,'%.2f') 'min']);
    end
end
ps=reshape(ps,size(xss,1),size(xss,2),size(xss,3));

%% 绘制ps的yz剖面图
if doShowPsYZ
    hPs=figure('name','ps的yz剖面图');
    for ix=1:size(ps,1)
        psYZ=permute(ps(ix,:,:),[2,3,1]);
        figure(hPs);
        imagesc(zs,ys,psYZ);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['ps的x=' num2str(xs(ix)) '剖面图']);
        xlabel('z(m)');
        ylabel('y(m)');
        pause(0.2);
    end
end

%% 绘制ps的xy剖面图
if doShowPsXY
    hPs=figure('name','ps的xy剖面图');
    for iz=1:size(ps,3)
        psXY=permute(ps(:,:,iz),[2,1]);
        figure(hPs);
        imagesc(xs,ys,psXY);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['ps的z=' num2str(zs(iz)) '剖面图']);
        xlabel('x(m)');
        ylabel('y(m)');
        pause(0.2);
    end
end

%% 绘制ps的yz投影图
if doShowPsYZsum
    hPs=figure('name','ps的yz投影图');
    psYZsum=permute(sum(ps,1),[2,3,1]);
    figure(hPs);
    imagesc(zs,ys,psYZsum);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('ps的yz投影图');
    xlabel('z(m)');
    ylabel('y(m)');
    disp(['z方向上的3dB分辨率为' ...
        num2str(dz*max(sum(psYZsum>max(max(psYZsum))/2,2))) ...
        'm'])
end

%% 绘制ps的xy投影图
if doShowPsXYsum
    hPs=figure('name','ps的xy投影图');
    psXYsum=permute(sum(ps,3),[2,1]);
    figure(hPs);
    imagesc(xs,ys,psXYsum);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('ps的xy投影图');
    xlabel('x(m)');
    ylabel('y(m)');
    disp(['x方向上的3dB分辨率为' ...
        num2str(dx*max(sum(psXYsum>max(max(psXYsum))/2,2))) ...
        'm'])
end