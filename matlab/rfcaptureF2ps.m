%% 根据rfcapture论文的硬算公式计算指定坐标上的功率大小
% ps: 对应点功率，复数
% fTsrampRTZ: 硬算公式的中间值f(n,m,zs,ts,tsRamp)，（ts为长时间,tsRamp为短时间）
% yLoCut: 中频信号, 大小[lFrame,nRx,nTx]
function ps=rfcaptureF2ps(fTsrampRTZ,yLoReshape,useGPU)
if useGPU
    yLoReshape=gpuArray(yLoReshape);
end
ps=shiftdim(sum(sum(sum(fTsrampRTZ.*repmat(yLoReshape,1,1,1,size(fTsrampRTZ,4)),1),2),3));
    
end