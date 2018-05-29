close all;
sSavePath='../images';
sLoadPath='../../fmcw_positioning_radar_large';
if ~exist('angs','var')
    load(fullfile(sLoadPath,'params.mat'));
end
%% 图片功率补偿系数
currFig=figure('Name','功率补偿系数');
imagesc(angs,ds,facD);
colorbar
title('功率补偿系数');
xlabel('角度(°)');
ylabel('距离(m)');
set(currFig, 'position', [0 0 800 600]);
set(gca,'FontSize',20,'FontName','黑体')
imWrite=getframe(currFig);
imWrite=frame2im(imWrite);
imwrite(imWrite,fullfile(sSavePath,'facD.jpg'),'jpg');
close(currFig);


%% 图片极坐标转换
currFig=figure('Name','极坐标转换角度');

subplot(1,2,1)
imagesc(xs,ys,angsPo2Car);
c=colorbar;
c.Label.String='极坐标系下的角度ang(°)';
title('极坐标转换角度映射矩阵');
xlabel('x(m)');
ylabel('y(m)');
set(gca,'FontSize',20,'FontName','黑体')

subplot(1,2,2)
imagesc(xs,ys,dsPo2Car);
c=colorbar;
c.Label.String='极坐标系下的距离d(m)';
title('极坐标转换距离映射矩阵');
xlabel('x(m)');
ylabel('y(m)');
set(gca,'FontSize',20,'FontName','黑体')

set(currFig, 'position', [0 0 1600 600]);
imWrite=getframe(currFig);
imWrite=frame2im(imWrite);
imwrite(imWrite,fullfile(sSavePath,'angsPo2Car.jpg'),'jpg');
close(currFig);

%% gif
tBegin=70;
tLength=8;
tEnd=tBegin+tLength;

%% gif基带信号
cutShowSave(fullfile(sLoadPath,'yLoCut.avi'),tBegin,tEnd, ...
    [],tsRamp, ...
    '基带信号','天线对','时间(s)', ...
    0,fullfile(sSavePath,'yLoCut.gif'));

%% gif原始热度图
cutShowSave(fullfile(sLoadPath,'heatMapPoAll.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '原始热度图','角度(°)','距离(m)', ...
    1,fullfile(sSavePath,'heatMapPoAll.gif'));

%% gif热度图背景
cutShowSave(fullfile(sLoadPath,'heatMapPoBac.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '热度图背景','角度(°)','距离(m)', ...
    1,fullfile(sSavePath,'heatMapPoBac.gif'));

%% gif热度图前景
cutShowSave(fullfile(sLoadPath,'heatMapPoFor.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '热度图前景','角度(°)','距离(m)', ...
    1,fullfile(sSavePath,'heatMapPoFor.gif'));

%% gif时域低通滤波后的热度图
cutShowSave(fullfile(sLoadPath,'heatMapPoMultiRemove.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '时域低通滤波后的热度图','角度(°)','距离(m)', ...
    1,fullfile(sSavePath,'heatMapPoMultiRemove.gif'));

%% gif空域中值滤波后的热度图
cutShowSave(fullfile(sLoadPath,'heatMapPoFil.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '空域中值滤波后的热度图','角度(°)','距离(m)', ...
    1,fullfile(sSavePath,'heatMapPoFil.gif'));

%% gif二值化后的热度图
cutShowSave(fullfile(sLoadPath,'heatMapPoBw.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '二值化后的热度图','角度(°)','距离(m)', ...
    1,fullfile(sSavePath,'heatMapPoBw.gif'));

%% gif热度图目标检测
cutShowSave(fullfile(sLoadPath,'heatMapTarget.avi'),tBegin+40,tEnd+40, ...
    angs,ds, ...
    '热度图目标检测','角度(°)','距离(m)', ...
    1,fullfile(sSavePath,'heatMapTarget.gif'));

%% gif函数
function cutShowSave(sFile,tBegin,tEnd, ...
    xs,ys, ...
    sTitle,sXlabel,sYlabel, ...
    doSc,sSave)
v=VideoReader(sFile);
v.CurrentTime=tBegin;

currFig=figure('Name',sTitle);
iFrame=0;
while v.CurrentTime<tEnd
    iFrame=iFrame+1;
    for j=1:3
        frameRead=readFrame(v);
    end
    if doSc
        frameRead=rgb2gray(frameRead);
    end
    figure(currFig);
    imagesc(xs,ys,frameRead);
%     if doSc
%         colorbar
%     end
    %     imshow(frame, 'Parent', currAxes);
    
    %     set(gca, 'XDir','normal', 'YDir','normal');
%     axis image;

    set(currFig, 'position', [0 0 800 600]);
    title(sTitle);
    xlabel(sXlabel);
    ylabel(sYlabel);
    set(gca,'FontSize',20,'FontName','黑体')
    pause(0);
    
    framwWrite=getframe(currFig);
    framwWrite = frame2im(framwWrite); 
    [I,map]=rgb2ind(framwWrite,256);
    if iFrame == 1
    imwrite(I,map,sSave,'gif','Loopcount',inf,'DelayTime',1/v.FrameRate);
    else
    imwrite(I,map,sSave,'gif','WriteMode','append','DelayTime',1/v.FrameRate);
    end
end
close(currFig);
end
