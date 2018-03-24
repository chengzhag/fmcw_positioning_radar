%% 清理
clear;
close all;

%% 运行参数设置
doShow2DHeatmap=0;
doShowTarcoor=1;
doShowPsBProject=0;
doTestC2F=0;
doTestC2F2=0;
tShowPsProject=0.02;
doSavePsProject=1;
doShowPsZsum=1;
lBlock=1000;
useGPU=1;

%% 加载/提取数据、参数
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_track_stand_squat_circle.mat'

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));
coorWcenFilSim=log2array(logsout,'coorWcenFilSim');
coorWcenFilSim=permute(coorWcenFilSim,[3,2,1]);

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

lDelay=10;
yLoReshape=circshift(yLoReshape,lDelay,4);

if exist('iTVal','var')
    % iTVal=ts>5 & ts<16;
    ts=ts(iTVal);
    yLoReshape=yLoReshape(:,:,:,iTVal);
    coorWcenFilSim=coorWcenFilSim(iTVal,:);
end

%% 显示目标坐标
psWcen=zeros(length(coorWcenFilSim),3);
for i=1:length(coorWcenFilSim)
    psWcen(i,:) = getPsWcen(coorWcenFilSim(i,:),xsB,ysB,psWl);
end

if doShowTarcoor
    hCoor=figure('name','显示目标坐标');
    subplot(1,2,1);
    plot(ts,coorWcenFilSim(:,1),ts,psWcen(:,1));
    legend('xsCoorWcenFilSim','xsPsWcen');
    title('目标x坐标');
    xlabel('t(s)');
    ylabel('x(m)');
    
    subplot(1,2,2);
    plot(ts,coorWcenFilSim(:,2),ts,psWcen(:,2));
    legend('ysCoorWcenFilSim','ysPsWcen');
    title('图像映射和极坐标转换所得目标y坐标');
    xlabel('t(s)');
    ylabel('y(m)');
    
    pause(0.2);
end

%% fft2d测试
xsB2=xsB;
ysB2=ysB;
[xssB2,yssB2]=meshgrid(xsB2,ysB2);

heatMapsFft=fft2(yLoReshape,lFftDis,lFftAng);
heatMapsFft=heatMapsFft(isDval,:,:,:);

heatMapsFft=circshift(heatMapsFft,ceil(size(heatMapsFft,2)/2),2);
heatMapsFft=flip(heatMapsFft,2);

% 背景消除
heatMapsBFft=filter(0.2,[1,-0.8],heatMapsFft,0,4);
heatMapsFFft=abs(heatMapsFft-heatMapsBFft);
heatMapsFFft=permute(prod(heatMapsFFft,3),[1,2,4,3]);

% 极坐标转换
heatMapsCarFFft=zeros(length(ysB2),length(xsB2),length(ts),'single');

% 计算坐标映射矩阵
dsPo2Car=sqrt(xssB2.^2+yssB2.^2);
angsPo2Car=atand(xssB2./yssB2);
angsPo2Car(isnan(angsPo2Car))=0;

for iFrame=1:length(ts)
    heatMapsCarFFft(:,:,iFrame)=interp2(angs,dsVal,heatMapsFFft(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
end

%% 显示功率分布
if doShow2DHeatmap
    hHea=figure('name','空间热度图');
    for iFrame=1:length(ts)
        figure(hHea);
        
        heatMapsFFftScaled=heatMapsCarFFft(:,:,iFrame)/max(max(heatMapsCarFFft(:,:,iFrame)));
        iXTar=find(xsB==psWcen(iFrame,1),1);
        iYTar=find(ysB==psWcen(iFrame,2),1);
        lXW=psWl(1)/dxF;
        lYW=psWl(2)/dyF;
        heatMapsFFftTar=insertShape(gather(heatMapsFFftScaled), ...
            'Rectangle',[iXTar-lXW/2 iYTar-lYW/2 lXW lYW],'LineWidth',1);
        imagesc(xsB2,ysB2,heatMapsFFftTar);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['第' num2str(ts(iFrame)) 's 的fft2d空间热度图']);
        xlabel('x(m)');
        ylabel('y(m)');
        
        pause(0.05);
    end
end

%% 利用rfcaptureC2F计算窗口前景
if doTestC2F
    tic;
    for iFrame=1:length(ts)
        psF=rfcaptureC2F(psWcen(iFrame,:),psWl,psWdC, ...
            xssB,yssB,zssB,psB,C2Fratio,C2Fw,C2Fn,0,[], ...
            yLoReshape(:,:,:,iFrame),rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
        if iFrame==1
            if useGPU
                psFo=zeros([size(psF),length(ts)],'single','gpuArray');
            else
                psFo=zeros([size(psF),length(ts)],'single');
            end
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
        if doSavePsProject
            writerObj=VideoWriter('../../xzProject.mp4','MPEG-4');  %// 定义一个视频文件用来存动画
            writerObj.FrameRate=fF;
            open(writerObj);                    %// 打开该视频文件
        end
        for iFrame=1:length(ts)
            showProjectedHeatmaps(hPs,psFo(:,:,:,iFrame), ...
                xsF,ysF,zsF);
            if doSavePsProject
                writeVideo(writerObj,getframe(gcf));
            end
            pause(tShowPsProject);
        end
        if doSavePsProject
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
        ylabel('z(m)');
    end
end

%% 利用rfcaptureC2F2计算窗口前景
if doTestC2F2
    tic;
    for iFrame=1:length(ts)
        psF=rfcaptureC2F2(psWcen(iFrame,:),psWl,psWdC, ...
            xssB,yssB,zssB,psB,C2Fratio,C2Fw,C2Fn,0,[], ...
            yLoReshape(:,:,:,iFrame),rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
        if iFrame==1
            if useGPU
                psFo=zeros([size(psF),length(ts)],'single','gpuArray');
            else
                psFo=zeros([size(psF),length(ts)],'single');
            end
        end
        psFo(:,:,iFrame)=psF;
        
        if mod(iFrame,10)==0
            disp(['第' num2str(iFrame) '帧' num2str(iFrame/length(ts)*100,'%.1f') ...
                '% 用时' num2str(toc/60,'%.2f') 'min ' ...
                '剩余' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
        end
    end
    
    
    %% 显示窗口投影
    if tShowPsProject
        hPs=figure('name','psF的投影图');
        if doSavePsProject
            writerObj=VideoWriter('../../xzProject.mp4','MPEG-4');  %// 定义一个视频文件用来存动画
            writerObj.FrameRate=fF;
            open(writerObj);                    %// 打开该视频文件
        end
        for iFrame=1:length(ts)
            figure(hPs);
            
            imagesc(xsF,zsF,psFo(:,:,iFrame));
            axis equal;
            axis([min(xsF), max(xsF), min(zsF), max(zsF)]);
            set(gca, 'XDir','normal', 'YDir','normal');
            title('ps的xz投影图');
            xlabel('x(m)');
            ylabel('z(m)');
            if doSavePsProject
                writeVideo(writerObj,getframe(gcf));
            end
            pause(tShowPsProject);
        end
        if doSavePsProject
            close(writerObj); %// 关闭视频文件句柄
        end
    end
    
    
    %% 尝试解算z轴功率分布
    if doShowPsZsum
        psZsum=permute(sum(psFo,2),[1,3,2]);
        psZsum=psZsum./repmat(max(psZsum),length(zsF),1);
        hpsZ=figure('name','目标点 z方向上各点的功率随时间变化关系图');
        imagesc(ts,zsF,psZsum);
        set(gca, 'XDir','normal', 'YDir','normal');
        title('目标点 z方向上各点的功率随时间变化关系图');
        xlabel('t(s)');
        ylabel('z(m)');
    end
end
