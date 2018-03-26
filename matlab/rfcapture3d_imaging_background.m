%% 清理
clear;
close all;

%% 运行参数设置
doShowPsBProject=1;
lBlock=1000;
useGPU=1;

%% 加载/提取数据、参数
filename='../data/yLoCut_200kHz_800rps_1rpf_4t12r_background.mat';
load(filename)

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

%% 截取后lBackCut帧参与建模
lBackCut=50;
if length(ts)>lBackCut
    yLoReshape=yLoReshape(:,:,:,end-lBackCut+1:end);
    ts=ts(end-lBackCut+1:end);
end

%% 计算背景
if ~exist('psB','var')
    preciFac=C2Fw.^(C2Fn-1);
    xsB=single(xMi:dxC/preciFac:xMa);
    ysB=single(yMi:dyC/preciFac:yMa);
    zsB=single(zMi:dzC/preciFac:zMa);
    [xssB,yssB,zssB]=meshgrid(xsB,ysB,zsB);
    psBcoor=[xssB(:),yssB(:),zssB(:)];
    
    if useGPU
        psB=zeros(size(psBcoor,1),1,'single','gpuArray');
    else
        psB=zeros(size(psBcoor,1),1,'single');
    end
    
    isS=1:lBlock:size(psBcoor,1);
    tic;
    for iFrame=1:length(ts)
        for iS=isS
            iBlock=(iS-1)/lBlock+1;
            if iS+lBlock-1<size(psBcoor,1)
                isBlock=iS:iS+lBlock-1;
            else
                isBlock=iS:size(psBcoor,1);
            end
            fTsrampRTZ=rfcaptureCo2F(psBcoor(isBlock,:),rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
            psB(isBlock,1)=psB(isBlock,1)+rfcaptureF2ps(fTsrampRTZ,yLoReshape(:,:,:,iFrame),useGPU);
        end
        if mod(iFrame,1)==0
            disp(['第' num2str(iFrame) '帧' num2str(iFrame/length(ts)*100,'%.1f') ...
                '% 用时' num2str(toc/60,'%.2f') 'min ' ...
                '剩余' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
        end
    end
    
    psB=gather(reshape(psB,size(xssB))/length(ts));
    save(filename,'xsB','ysB','zsB','xssB','yssB','zssB','psBcoor','psB','-append');
end

%% 显示背景的功率分布投影图
if doShowPsBProject
    hPs=figure('name','psB的投影图');
    showProjectedHeatmaps(hPs,log(abs(psB)),xsB,ysB,zsB);
    pause(0.5);
else
    hPs=[];
end
