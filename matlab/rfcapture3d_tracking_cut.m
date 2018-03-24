%% 清理
clear;
close all;

%% 加载/提取数据、参数
filename='../data/yLoCut_200kHz_800rps_1rpf_4t12r_track_stand_squat_circle.mat';
load(filename)


yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));
coorWcenFilSim=log2array(logsout,'coorWcenFilSim');
coorWcenFilSim=permute(coorWcenFilSim,[3,2,1]);

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

%% 显示目标坐标
psWcen=zeros(length(coorWcenFilSim),3);
for i=1:length(coorWcenFilSim)
    psWcen(i,:) = getPsWcen(coorWcenFilSim(i,:),xsB,ysB,psWl);
end


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


%% 询问截取区间
if ~exist('iTVal','var')
    tMi=input('输入起始时间(s)：');
    tMa=input('输入终止时间(s)：');
    if tMi>=tMa
        error('起始时间必须小于终止时间');
    end
    iTVal=ts>tMi & ts<tMa;
    save(filename,'iTVal','-append');
end