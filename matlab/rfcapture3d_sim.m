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
nTx=4;
nRx=12;
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

slope=fBw*fTr;
fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
fs=linspace(0,fS/2-fD,floor(lFft/2));
ds=fs/fPm;

tsRamp=(0:lRamp-1)/fS;

tarCoor=[1,3,0.5];%target coordinate
dx=1;
dy=0.5;
dz=0.15;
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

%% 计算r(n,m)(X(ts),Y(ts),z)，（ts为长时间）
rsCoRT=zeros(length(zsV),nRx,nTx,'single');%r(n,m)(X(ts),Y(ts),z)，（ts为长时间）
for iRx=1:nRx
    for iTx=1:nTx
        rsCoRT(:,iRx,iTx)=sqrt( ...
            (xsV-repmat(single(antCoor(iRx,1)),length(zsV),1)).^2 ...
            + (ysV-repmat(single(antCoor(iRx,2)),length(zsV),1)).^2 ...
            + (zsV-repmat(single(antCoor(iRx,3)),length(zsV),1)).^2 ...
            ) ...
            + sqrt( ...
            (xsV-repmat(single(antCoor(iTx+nRx,1)),length(zsV),1)).^2 ...
            + (ysV-repmat(single(antCoor(iTx+nRx,2)),length(zsV),1)).^2 ...
            + (zsV-repmat(single(antCoor(iTx+nRx,3)),length(zsV),1)).^2 ...
            );
    end
end

%% 计算sumsumsum s(n,m,ts,tsRamp)*f(n,m,zs,ts,tsRamp)，（ts为长时间,tsRamp为短时间）
rsCoRTGPU=gpuArray(rsCoRT);
yLoReshapeGPU=gpuArray(yLoReshape);
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

ps=reshape(gather(abs(psGPU)),size(xss,1),size(xss,2),size(xss,3));
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