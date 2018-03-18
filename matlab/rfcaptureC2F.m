%% rfcapture coarse to fine 函数。由粗到细计算功率分布
function [psF,xsF,ysF,zsF]=rfcaptureC2F(dxC,dyC,dzC,xsC,ysC,zsC,psBcoor,psB, ...
    nC2F,C2Fratio,C2Ffac,tShowPsProject,hPs, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)

% 最粗一级
[xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
psWcoor=[xssC(:),yssC(:),zssC(:)];

if useGPU
    psF=zeros(size(xssC),'single','gpuArray');
else
    psF=zeros(size(xssC),'single');
end

for i=1:nC2F
    % 抽取背景点
    isPsB=zeros(size(psWcoor,1),1);
    for j=1:size(psWcoor,1)
        isPsB(j)=find(all(abs(psWcoor(j,:)-psBcoor)<0.001,2));
    end
    psBH=psB(isPsB);
    
    % 硬算选取点
    % TODO: 根据计算分辨率抽取天线和时域信号，减少计算量
    fTsrampRTZ=rfcaptureCo2F(psWcoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,useGPU)-psBH);
    if i==1
        psF(:)=psH;
    else
        psF(isHLog)=psH;
    end
    
    % 显示功率分布
    if tShowPsProject
        showProjectedHeatmaps(hPs,psF,xsC,ysC,zsC);
        pause(tShowPsProject);
    end
    
    if i>=nC2F
        break;
    end
    
    % 扩展psF和isHLog矩阵
    [xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
    
    preciFac=C2Ffac^i;
    xsC=xsC(1):dxC/preciFac:xsC(end);
    ysC=ysC(1):dyC/preciFac:ysC(end);
    zsC=zsC(1):dzC/preciFac:zsC(end);
    [xssF,yssF,zssF]=meshgrid(xsC,ysC,zsC);
    psWcoor=[xssF(:),yssF(:),zssF(:)];
    
    psF=interp3(xssC,yssC,zssC, ...
        psF,xssF,yssF,zssF,'linear',0);
    
    % 根据规则选取精算点
    isHLog=psF>max(max(max(psF)))*(1-C2Fratio);
    psWcoor=psWcoor(isHLog(:),:);
end
xsF=xsC;
ysF=ysC;
zsF=zsC;

end