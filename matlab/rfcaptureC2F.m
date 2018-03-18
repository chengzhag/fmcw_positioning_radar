%% rfcapture coarse to fine 函数。由粗到细计算功率分布
function [psF,xsF,ysF,zsF]=rfcaptureC2F(psWcen,psWcoor,psBcoor,psB, ...
    C2Fratio,tShowPsProject,hPs, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)
% 初始化
for i=1:length(psWcoor)
    psWcoor(i).xs=psWcoor(i).xs+psWcen(1);
    psWcoor(i).ys=psWcoor(i).ys+psWcen(2);
    psWcoor(i).zs=psWcoor(i).zs+psWcen(3);
    psWcoor(i).xss=psWcoor(i).xss+psWcen(1);
    psWcoor(i).yss=psWcoor(i).yss+psWcen(2);
    psWcoor(i).zss=psWcoor(i).zss+psWcen(3);
    psWcoor(i).coor=psWcoor(i).coor+psWcen;
end

% 最粗一级
psHcoor=psWcoor(1).coor;

for i=1:length(psWcoor)
    % 抽取背景点
    isPsB=zeros(size(psHcoor,1),1);
    for j=1:size(psHcoor,1)
        isPsB(j)=find(all(abs(psBcoor-psHcoor(j,:))<0.001,2),1);
    end
    psBH=psB(isPsB);

    % 硬算选取点
    fTsrampRTZ=rfcaptureCo2F(psHcoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,useGPU)-psBH);
    if i==1
        psF=reshape(psH,size(psWcoor(1).xss));
    else
        psF(isHLog)=psH;
    end
    
    % 显示功率分布
    if tShowPsProject
        showProjectedHeatmaps(hPs,psF,psWcoor(i).xs,psWcoor(i).ys,psWcoor(i).zs);
        pause(tShowPsProject);
    end
    
    if i>=length(psWcoor)
        break;
    end
    
    % 扩展psF和isHLog矩阵
    psF=interp3(psWcoor(i).xss,psWcoor(i).yss,psWcoor(i).zss, ...
        psF,psWcoor(i+1).xss,psWcoor(i+1).yss,psWcoor(i+1).zss,'linear',0);
    
    % 根据规则选取精算点
    isHLog=psF>max(psF(:))*(1-C2Fratio);
    psHcoor=psWcoor(i+1).coor(isHLog(:),:);
end
xsF=psWcoor(end).xs;
ysF=psWcoor(end).ys;
zsF=psWcoor(end).zs;

end