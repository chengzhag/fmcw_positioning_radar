%% 直接使用模型进行判别
clear
%% 读取数据，计算数据
% filename='../data/yLoCut_200kHz_800rps_1rpf_4t12r_psZsum.mat';
% filename='../data/psZsum_200kHz_800rps_1rpf_4t12r_ztest_stand_squat_circle.mat';
% filename='../data//psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';
filename='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';

load(filename)

psZsum=permute(log2array(logsout,'psZsumSim'),[1,3,2]);
psZsum=psZsum./repmat(max(psZsum),length(zsF),1);

%% 绘制背景z功率图
 
imagesc(flipud(psZsum));
% imshow(flipud(psZsum));

%% 数据转换为表格+状态判别
oritable=array2table(psZsum');  %原始数据转换为表格
load('classifier_by_frame.mat')       %载入模型

result=trainedMod_stand_fall.predictFcn(oritable); %进行状态判别，输出结果到result中

%% 绘制整体情况+数据滤波处理
% figure(2)
hold on
plot(result'*(2)+13,'k-p');
result2=smooth(result,5,'rlowess');%使用rlowess滤波器对结果进行平滑

plot(result2'*(2)+13,'r-p');
title('0 代表站着，-1代表蹲着,-2代表摔,1代表无人');