%% 清理
clear;
close all;

%% 加载/提取数据、参数
sFileData='../data/heatMap_200kHz_2000rps_4rpf_4t12r_two_targets.mat';
load(sFileData)

heatMapPo=log2array(logsout,'heatMapPoSim');
ts=linspace(0,size(heatMapPo,3)/fF,size(heatMapPo,3));

%% 显示功率分布
hHea=figure('name','二维功率分布图');
for iFrame=1:length(ts)
    figure(hHea);
    
    heatMap=heatMapPo(:,:,iFrame);
    [iDTar,iATar]=iMax2d(heatMap);
    heatMapShape=sum(insertShape(heatMap,'circle', ...
        [iATar iDTar 5],'LineWidth',1, ...
        'Color',repmat(max(heatMap(:)),1,3)),3);
    
    subplot(1,2,1);
    imagesc(angs,dsVal,heatMapShape);
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['第' num2str(ts(iFrame)) 's 的二维功率分布图']);
    xlabel('angle(°)');
    ylabel('dis(m)');
    
    subplot(1,2,2);
    imagesc(angs,dsVal,log(heatMapShape));
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['第' num2str(ts(iFrame)) 's 的二维功率分布图']);
    xlabel('angle(°)');
    ylabel('dis(m)');

    drawnow
end


