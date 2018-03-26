%% 清理
clear;
close all;

%% 运行参数设置
doLabel=1;

%% 加载/提取数据、参数
sFileData='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';
sFileTime='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.txt';
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

if doLabel
    %% 读取label
    idFileTime=fopen(sFileTime);
    
    % 计算时间
    contentFileTime=textscan(idFileTime,'%f %f %f');
    tsLabel=cumsum(contentFileTime{2}*60+contentFileTime{3});
    tFirstLabel=input('输入z方向上功率分布图中第一个动作点的时间(s)：');
    tsLabel=tsLabel-tsLabel(1)+tFirstLabel;
    
    % 计算标签
    lb=input('输入动作点的标签：');
    lbsChange=zeros(length(tsLabel),2);
    lbsChange(:,1)=lb;
    lbsChange(:,2)=tsLabel;
    
    fclose(idFileTime);
    
    %% 保存标签和标签时间
    save(sFileData,'lbsChange','-append');
end
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



