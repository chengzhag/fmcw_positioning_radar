% 读取simulink log生成的dataset数据类型示例程序，log2array函数例程

%% 清理
close all;
%% 加载数据、参数
load '../data/dataSim_200kHz_7500pf_1t3r_static.mat'

ys=log2array(logsout,'dataSim');

%% 提取两路信号
iSam=3;
ysLo=real(ys);
ysTr=imag(ys);
ts=0:1/fS:1/fS*(size(ysLo,2)-1);
figure;
plot(ts,ysLo(iSam,:));
hold on
plot(ts,ysTr(iSam,:));
hold off

%% 绘制信号帧
figure;
subplot(1,2,1);
imshow(ysLo,[]);
subplot(1,2,2);
imshow(ysTr,[]);
