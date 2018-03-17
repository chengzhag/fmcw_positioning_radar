%% rfcapture coarse to fine 函数。由粗到细计算功率分布
function [psF,xsF,ysF,zsF]=rfcaptureC2F(xsC,ysC,zsC,nC2F,C2Fratio,C2Ffac,doShowPsProject, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)
% 最粗一级
% 初始化
[xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
xsCv=reshape(xssC,numel(xssC),1);
ysCv=reshape(yssC,numel(yssC),1);
zsCv=reshape(zssC,numel(zssC),1);
pointCoor=[xsCv,ysCv,zsCv];

fTsrampRTZ=rfcaptureCo2F(pointCoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,1));
psF=reshape(psH,size(xssC));
isHLog=true(size(xssC));

if doShowPsProject
    hPs=figure('name','ps的xy投影图');
    showProjectedHeatmaps(hPs,psF,xsC,ysC,zsC);
    pause(0.5);
end

for i=1:nC2F
    [xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
    
    isXc=0:C2Ffac:(length(xsC)-1)*C2Ffac;
    isYc=0:C2Ffac:(length(ysC)-1)*C2Ffac;
    isZc=0:C2Ffac:(length(zsC)-1)*C2Ffac;
    isXf=0:(length(xsC)-1)*C2Ffac;
    isYf=0:(length(ysC)-1)*C2Ffac;
    isZf=0:(length(zsC)-1)*C2Ffac;
    
    xsC=interp1(isXc,xsC,isXf,'linear','extrap');
    ysC=interp1(isYc,ysC,isYf,'linear','extrap');
    zsC=interp1(isZc,zsC,isZf,'linear','extrap');
    [xssF,yssF,zssF]=meshgrid(xsC,ysC,zsC);
    xsFv=reshape(xssF,numel(xssF),1);
    ysFv=reshape(yssF,numel(yssF),1);
    zsFv=reshape(zssF,numel(zssF),1);
    pointCoor=[xsFv,ysFv,zsFv];
    
    
    psF=interp3(xssC,yssC,zssC, ...
        psF,xssF,yssF,zssF,'linear',0);
    isHLog=interp3(xssC,yssC,zssC, ...
        isHLog,xssF,yssF,zssF,'nearest',0);
    
    % 根据规则选取精算点
    psHold=psF(isHLog);
    [~,isHnum]=sort(psHold,'descend');
    isHnum=isHnum(1:floor(numel(psHold)*C2Fratio));
    isHLog=false(size(isHLog));
    isHLog(isHnum)=1;
    
    % 硬算选取点
    fTsrampRTZ=rfcaptureCo2F(pointCoor(isHLog(:),:),rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,1));
    psF(isHLog)=psH;
    
    % 显示功率分布
    if doShowPsProject
        showProjectedHeatmaps(hPs,psF,xsC,ysC,zsC);
        pause(0.5);
    end
    
end
xsF=xsC;
ysF=ysC;
zsF=zsC;

end