%% 在列向量中寻找噪底之上第一个峰的下标
% iFp: 噪底之上第一个峰的下标
% v: 列向量或列向量构成的矩阵，每列为一个通道
function iFp=findFirstPeak(v)
    for i=1:size(v,2);
        findpeaks(v);
    end
end