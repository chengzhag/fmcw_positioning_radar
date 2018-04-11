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
for iFrame=100:10:length(ts)
    figure(hHea);
    
    heatMap=heatMapPo(:,:,iFrame);
    
    pre=heatMap;
%     pre=filter2(fspecial('average',3),pre);
    pre = medfilt2(pre,[3,3]);
%     pre = wiener2(pre,[5 13]);
%     se = strel('disk',3);
%     pre = imopen(pre,se);
    
    subplot(1,3,1);
    imagesc(angs,dsVal,pre);
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['第' num2str(ts(iFrame)) 's 的二维功率分布图']);
    xlabel('angle(°)');
    ylabel('dis(m)');

    subplot(1,3,2); 
    bw = imbinarize(pre,10*mean(pre(:)));
    imagesc(angs,dsVal,bw);
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['第' num2str(ts(iFrame)) 's 的二维功率分布图']);
    xlabel('angle(°)');
    ylabel('dis(m)');
    
    subplot(1,3,3); 
    stats = regionprops(bw,heatMap,'Area','WeightedCentroid');
    isCen=[stats.WeightedCentroid];
    if ~isempty(isCen)
        isCen=permute(reshape(isCen',2,numel(isCen)/2),[2,1]);
        coorCen=[interp1(1:length(angs),angs,isCen(:,1)) interp1(1:length(dsVal),dsVal,isCen(:,2))];
    else
        coorCen=[];
    end
    
    imagesc(angs,dsVal,heatMap); hold on
    plot(coorCen(:,1),coorCen(:,2),'r+')
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['第' num2str(ts(iFrame)) 's 的二维功率分布图']);
    xlabel('angle(°)');
    ylabel('dis(m)');
    
    drawnow
end


