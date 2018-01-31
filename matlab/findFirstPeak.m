%% 在列向量中寻找噪底之上第一个峰的下标
% iFp: 噪底之上第一个峰的下标
% v: 列向量或列向量构成的矩阵，每列为一个通道
% thres: 噪底阈值，相对最大的数据
function isFp=findFirstPeak(v,thres)
isFp=zeros(1,size(v,2));
for i=1:size(v,2);
    [~,ip]=findpeaks(v(:,i),'MinPeakHeight',max(v(:,i))*thres,'NPeaks',1);
    if isempty(ip)
        isFp(i)=nan;
    else
        isFp(i)=ip;
    end
    
end
end