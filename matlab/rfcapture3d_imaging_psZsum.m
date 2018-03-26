%% 清理
clear;
close all;

%% 运行参数设置
doShowPsZsum=1;

%% 加载/提取数据、参数
filename='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';
load(filename)

psZsum=permute(log2array(logsout,'psZsumSim'),[1,3,2]);

ts=linspace(0,size(psZsum,2)/fF,size(psZsum,2));

%% 显示z轴功率分布
if doShowPsZsum
    psZsumAj=psZsum./repmat(max(psZsum),length(zsF),1);
    hpsZ=figure('name','目标点 z方向上各点的功率随时间变化关系图');
    imagesc(ts,zsF,psZsumAj);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('目标点 z方向上各点的功率随时间变化关系图');
    xlabel('t(s)');
    ylabel('z(m)');
end
