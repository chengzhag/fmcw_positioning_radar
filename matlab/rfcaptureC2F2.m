%% rfcapture coarse to fine 2d 函数。由粗到细计算功率分布

% psF: 精算功率分布, 实数

% psWcen: 窗口属性，结构体数组，包含xyz坐标、meshgrid、坐标
% psWcoor: 窗口中心坐标
% psBcoor: 背景坐标
% psB; 复数背景
% C2Fratio: coarse to fine 比例，选取C2Fratio*maxPower的点进行迭代
% tShowPsProject: 显示各精度投影图的间隔时间，为0时不显示
% hPs: 显示投影图的目标窗口句柄
% yLoReshape: 中频信号大小[length(tsRamp),nRx,nTx]
% rxCoor: 接收天线坐标
% txCoor: 发射天线座标
% nRx: 接收天线数量
% nTx: 发射天线数量
% dCa: 应减去的多余天线线缆距离
% tsRamp: 一个斜坡内的时间坐标
% fBw: 扫频带宽
% fRamp: 斜坡频率
% dLambda: 波长
% useGPU: 是否使用GPU

function psF=rfcaptureC2F2(psWcen,psWl,psWdC, ...
    xssB,yssB,zssB,psB,C2Fratio,C2Fw,C2Fn,tShowPsProject,hPs, ...
    yLoReshape,rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)

% 最粗一级
xsC=single(-psWl(1)/2+psWcen(1):psWdC(1):psWl(1)/2+psWcen(1));
zsC=single(-psWl(3)/2+psWcen(3):psWdC(3):psWl(3)/2+psWcen(3));

[xssC,zssC]=meshgrid(xsC,zsC);
psHcoor=[xssC(:),repmat(psWcen(2),numel(xssC),1),zssC(:)];

for i=1:C2Fn

    % 抽取背景点
%     isPsB=zeros(size(psHcoor,1),1);
%     for j=1:size(psHcoor,1)
%         isPsB(j)=find(all(abs(psBcoor-psHcoor(j,:))<0.001,2),1);
%     end
%     psBH=psB(isPsB);
    psBH=interp3(xssB,yssB,zssB,psB,psHcoor(:,1),psHcoor(:,2),psHcoor(:,3),'nearest');

    % 硬算选取点
    fTsrampRTZ=rfcaptureCo2F(psHcoor,rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,useGPU)-psBH);
    if i==1
        psF=reshape(psH,size(xssC));
    else
        psF(isHLog)=psH;
    end
    
    % 显示功率分布
    if tShowPsProject
        hPs=figure(hPs);

        imagesc(xsC,zsC,psF);
        axis equal;
        axis([min(xsC), max(xsC), min(zsC), max(zsC)]);
        set(gca, 'XDir','normal', 'YDir','normal');
        title('ps的xz投影图');
        xlabel('x(m)');
        ylabel('z(m)');

        pause(tShowPsProject);
    end
    
    if i>=C2Fn
        break;
    end
    
    % 计算下一次迭代坐标
    xsF=single(-psWl(1)/2+psWcen(1):psWdC(1)/(C2Fw^i):psWl(1)/2+psWcen(1));
    zsF=single(-psWl(3)/2+psWcen(3):psWdC(3)/(C2Fw^i):psWl(3)/2+psWcen(3));
    
    [xssF,zssF]=meshgrid(xsF,zsF);
    coorF=[xssF(:),repmat(psWcen(2),numel(xssF),1),zssF(:)];
    
    % 扩展psF和isHLog矩阵
    psF=interp2(xssC,zssC, ...
        psF,xssF,zssF,'linear',0);
    
    % 根据规则选取精算点
    isHLog=psF>max(psF(:))*(1-C2Fratio);
    psHcoor=coorF(isHLog(:),:);
    
    xssC=xssF;
    zssC=zssF;
end

end