%% rfcapture coarse to fine 函数。由粗到细计算功率分布
function [psF,xsF,ysF,zsF]=rfcaptureC2F(dxC,dyC,dzC,xsC,ysC,zsC,psBcoor,psB, ...
    nC2F,C2Fratio,C2Ffac,tShowPsProject,hPs, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)
% % 初始化
% tCutCen=floor(length(tsRamp)/2);

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
    
    
    % 根据计算分辨率抽取天线和时域信号，减少计算量
%     % 根据y方向分辨率计算截取时域信号长度
%     lYLoCut=min(fSdown/fPm/dxC,length(tsRamp));
%     isYLoCut=1:length(tsRamp)<=lYLoCut;
%     % 硬算选取点
%     fTsrampRTZ=rfcaptureCo2F(psWcoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp(isYLoCut),fBw,fRamp,dLambda,useGPU);
%     psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape(isYLoCut,:,:),useGPU)-psBH);
    % 经分析：在添加时域信号截取后，性能反而降低。
    % 角度分辨率上，由于实际使用中不需要计算比目前能达到分辨率更低的分辨率，因此不需要抽取天线数量

    % 硬算选取点
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
    
    dxC=dxC/C2Ffac;
    dyC=dyC/C2Ffac;
    dzC=dzC/C2Ffac;
    xsC=xsC(1):dxC:xsC(end);
    ysC=ysC(1):dyC:ysC(end);
    zsC=zsC(1):dzC:zsC(end);
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