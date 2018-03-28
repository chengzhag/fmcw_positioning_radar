%% 清理
clear;
close all;

%% 运行参数设置
doShowSam=0;

%% 加载/提取数据、参数
sFileData='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';
sFileSample='../data/inoutputs_200kHz_2000rps_4rpf_4t12r_walk_fall.mat';
load(sFileData)

psZsum=permute(log2array(logsout,'psZsumSim'),[1,3,2]);

ts=linspace(0,size(psZsum,2)/fF,size(psZsum,2));

%% 显示z轴功率分布

psZsumAj=psZsum./repmat(max(psZsum),length(zsF),1);
hpsZ=figure('name','目标点 z方向上各点的功率随时间变化关系图');
imagesc(ts,zsF,psZsumAj);
set(gca, 'XDir','normal', 'YDir','normal');
title('目标点 z方向上各点的功率随时间变化关系图');
xlabel('t(s)');
ylabel('z(m)');

%% 展示标签
[~,isZMax]=max(psZsum);
zsMax=zsF(isZMax);
figure('name','展示标签');
plot(ts,zsMax);
hold on;
isLbsChange=interp1(ts,1:length(ts),lbsChange(:,2),'nearst');
plot(lbsChange(:,2),zsMax(isLbsChange),'o');
text(lbsChange(:,2),double(zsMax(isLbsChange))+0.03,num2str(lbsChange(:,1)));
hold off;

%% 切割样本
isSamW=-round(tSam*fF/2):round(tSam*fF/2);
tsSamW=isSamW/fF;
psZsumSam=zeros(size(psZsum,1),length(isSamW),length(size(lbsChange,1)));

for i=1:size(lbsChange,1)
    tSamCen=lbsChange(i,2);
    iSamCen=interp1(ts,1:length(ts),tSamCen,'nearst');
    psZsumSam(:,:,i)=psZsum(:,iSamCen+isSamW);
end

%% 显示样本
if doShowSam
    hSam=figure('name','显示样本');
    for i=1:size(psZsumSam,3)
        figure(hSam);
        psZsumSamAj=psZsumSam(:,:,i)./repmat(max(psZsumSam(:,:,i)),length(zsF),1);
        imagesc(tsSamW+lbsChange(i,2),zsF,psZsumSamAj);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['样本' num2str(i) '/' num2str(size(psZsumSam,3))]);
        xlabel('t(s)');
        ylabel('z(m)');
        pause(0.5);
    end
end

%% 分类器输入前预处理
psZReshapeSam=permute(reshape(psZsumSam,size(psZsumSam,1)*size(psZsumSam,2),size(psZsumSam,3)),[2,1]);
% 归一化
psZReshapeSam=psZReshapeSam./repmat(max(psZReshapeSam,[],2),1,size(psZReshapeSam,2));

%% 添加到数据
doAdd2Sample=input('是否要添加到训练样本？(1/0)：');
if doAdd2Sample
    load(sFileSample)
    inputs=[inputs;psZReshapeSam];
    targets=[targets;lbsChange(:,1)];
    samples=[targets,inputs];
    save(sFileSample,'inputs','targets','samples');
end