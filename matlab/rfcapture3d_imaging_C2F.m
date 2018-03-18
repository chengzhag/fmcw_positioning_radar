%% 清理
clear;
close all;

%% 运行参数设置
doShowHeatmaps=0;
doShowTarcoor=0;
doShowPsBProject=1;
tShowPsProject=0.2;
doSavePsBProject=1;
doShowPsZsum=1;
lBlock=1000;
useGPU=1;

%% 加载/提取数据、参数
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest_circle_reflector.mat'

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

if exist('iTVal','var')
    % iTVal=ts>5 & ts<16;
    ts=ts(iTVal);
    yLoReshape=yLoReshape(:,:,:,iTVal);
end

% 背景参数设置
xMi=-3;
xMa=3;
yMi=1;
yMa=5;
zMi=-1.5;
zMa=1.5;
dxC=0.5;
dyC=0.5;
dzC=0.5;

lSampleB=50;

C2Ffac=3;
nC2F=2;
C2Fratio=0.5;

preciFac=C2Ffac.^(nC2F-1);
xsB=single(xMi:dxC/preciFac:xMa);
ysB=single(yMi:dyC/preciFac:yMa);
zsB=single(zMi:dzC/preciFac:zMa);

xs2D=xsB;
ys2D=ysB;
[xss2D,yss2D]=meshgrid(xs2D,ys2D);

%% fft2d测试
heatMapsFft=fft2(yLoReshape,lFftDis,lFftAng);
heatMapsFft=heatMapsFft(isDval,:,:,:);

heatMapsFft=circshift(heatMapsFft,floor(size(heatMapsFft,2)/2)+1,2);
heatMapsFft=flip(heatMapsFft,2);

% 背景消除
heatMapsBFft=filter(0.2,[1,-0.8],heatMapsFft,0,4);
heatMapsFFft=abs(heatMapsFft-heatMapsBFft);
heatMapsFFft=permute(prod(heatMapsFFft,3),[1,2,4,3]);

% 极坐标转换
heatMapsCarFFft=zeros(length(ys2D),length(xs2D),length(ts),'single');

% 计算坐标映射矩阵
dsPo2Car=sqrt(xss2D.^2+yss2D.^2);
angsPo2Car=atand(xss2D./yss2D);
angsPo2Car(isnan(angsPo2Car))=0;

for iFrame=1:length(ts)
    heatMapsCarFFft(:,:,iFrame)=interp2(angs,dsVal,heatMapsFFft(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
end
heatMapsFFft=heatMapsCarFFft;

%% 比较目标坐标
[isYTarFft,isXTarFft]=iMax2d(heatMapsCarFFft);

isXTarFft=gather(isXTarFft);
isYTarFft=gather(isYTarFft);

xsTarFft=xs2D(isXTarFft);
ysTarFft=ys2D(isYTarFft);


if doShowTarcoor
    hCoor=figure('name','比较两种方法所得目标坐标');
    subplot(1,2,1);
    plot(ts,xsTarFft);
    legend('xsTarFft');
    title('FFT2D所得目标x坐标');
    xlabel('t(s)');
    ylabel('x(m)');
    
    subplot(1,2,2);
    plot(ts,ysTarFft);
    legend('ysTarFft');
    title('FFT2D所得目标y坐标');
    xlabel('t(s)');
    ylabel('y(m)');
    
    pause(0.2);
end

%% 显示功率分布
if doShowHeatmaps
    hHea=figure('name','空间热度图');
    for iFrame=1:length(ts)
        figure(hHea);

        heatMapsFFftScaled=heatMapsFFft(:,:,iFrame)/max(max(heatMapsFFft(:,:,iFrame)));
        heatMapsFFftTar=insertShape(gather(heatMapsFFftScaled),'circle',[isXTarFft(iFrame) isYTarFft(iFrame) 5],'LineWidth',2);
        imagesc(xs2D,ys2D,heatMapsFFftTar);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['第' num2str(ts(iFrame)) 's 的fft2d空间热度图']);
        xlabel('x(m)');
        ylabel('y(m)');
        
        pause(0.5);
    end
end

%% 计算背景
if ~exist('psB','var')
    [xssB,yssB,zssB]=meshgrid(xsB,ysB,zsB);
    
    pointCoor=[xssB(:),yssB(:),zssB(:)];
    
    
    psB=zeros(size(pointCoor,1),1,'single','gpuArray');
    isS=1:lBlock:size(pointCoor,1);
    tic;
    for iFrame=1:lSampleB
        for iS=isS
            iBlock=(iS-1)/lBlock+1;
            if iS+lBlock-1<size(pointCoor,1)
                isBlock=iS:iS+lBlock-1;
            else
                isBlock=iS:size(pointCoor,1);
            end
            fTsrampRTZ=rfcaptureCo2F(pointCoor(isBlock,:),rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
            psB(isBlock,1)=psB(isBlock,1)+rfcaptureF2ps(fTsrampRTZ,yLoReshape(:,:,:,iFrame),useGPU);
        end
        if mod(iFrame,1)==0
            disp(['第' num2str(iFrame) '帧' num2str(iFrame/lSampleB*100,'%.1f') ...
                '% 用时' num2str(toc/60,'%.2f') 'min ' ...
                '剩余' num2str(toc/iFrame*(lSampleB-iFrame)/60,'%.2f') 'min']);
        end
    end
    
    psB=reshape(psB,size(xssB))/lSampleB;
else
    psB=gpuArray(psB);
end

%% 显示背景的功率分布投影图
if doShowPsBProject
    hPs=figure('name','psB的投影图');
    showProjectedHeatmaps(hPs,log(abs(psB)),xsB,ysB,zsB);
    pause(0.5);
end

%% 计算立方窗口
% 要保证d和l的搭配能在-lxW/2:dxW:lxW/2中产生0，y同理
dxW=dxC;
dyW=dyC;
dzW=dzC;
lxW=1;
lyW=1;
lzW=3;
szW=-1.5;

xsTarFftMean=mean(xsTarFft);
ysTarFftMean=mean(ysTarFft);

[~,iXTar]=min(abs(xsB-xsTarFftMean));
[~,iYTar]=min(abs(ysB-ysTarFftMean));
xsTarFftMean=xsB(iXTar);
ysTarFftMean=ysB(iYTar);

xsWin=single(-lxW/2:dxW:lxW/2)+xsTarFftMean;
ysWin=single(-lyW/2:dyW:lyW/2)+ysTarFftMean;
zsWin=single(szW:dxW:szW+lzW);

%% 利用rfcaptureC2F计算窗口前景
xsC=xsWin;
ysC=ysWin;
zsC=zsWin;

tic;
for iFrame=1:length(ts)
    [psF,xsF,ysF,zsF]=rfcaptureC2F(xsC,ysC,zsC,xssB,yssB,zssB,psB, ...
        nC2F,C2Fratio,C2Ffac,0,hPs, ...
        yLoReshape(:,:,:,iFrame),rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    if iFrame==1
        psFo=zeros([size(psF),length(ts)],'single','gpuArray');
    end
    psFo(:,:,:,iFrame)=psF;
    
    if mod(iFrame,10)==0
        disp(['第' num2str(iFrame) '帧' num2str(iFrame/length(ts)*100,'%.1f') ...
            '% 用时' num2str(toc/60,'%.2f') 'min ' ...
            '剩余' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end


%% 显示窗口投影
if tShowPsProject
    hPs=figure('name','psF的投影图');
    if doSavePsBProject
        writerObj=VideoWriter('../../xzProject.mp4','MPEG-4');  %// 定义一个视频文件用来存动画
        writerObj.FrameRate=fF;
        open(writerObj);                    %// 打开该视频文件
    end
    for iFrame=1:length(ts)
        showProjectedHeatmaps(hPs,psFo(:,:,:,iFrame),xsF,ysF,zsF);
        if doSavePsBProject
            writeVideo(writerObj,getframe(gcf));
        end
        pause(tShowPsProject);
    end
    if doSavePsBProject
        close(writerObj); %// 关闭视频文件句柄
    end
end


%% 尝试解算z轴功率分布
if doShowPsZsum
    psZsum=permute(sum(sum(psFo,1),2),[3,4,2,1]);
    psZsum=psZsum./repmat(max(psZsum),length(zsF),1);
    hpsZ=figure('name','目标点 z方向上各点的功率随时间变化关系图');
    imagesc(ts,zsF,psZsum);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('目标点 z方向上各点的功率随时间变化关系图');
    xlabel('t(s)');
end
ylabel('z(m)');