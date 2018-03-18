%% 根据rfcapture论文的硬算公式计算指定坐标上的功率大小

% fTsrampRTZ: 硬算公式的中间值f(n,m,zs,ts,tsRamp)，（ts为长时间,tsRamp为短时间）

% pointCoor: 指定坐标，n行3列
% rxCoor: 接收天线坐标
% txCoor: 发射天线座标
% nRx: 接收天线数量
% nTx: 发射天线数量
% dCa: 应减去的多余天线线缆距离
% tsRamp: 一个斜坡内的时间坐标
% fBw: 扫频带宽
% fRamp: 斜坡频率
% dLambda: 波长
% useGPU: 是否使用GPU

function fTsrampRTZ=rfcaptureCo2F(pointCoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)
%% 计算r(n,m)(X(ts),Y(ts),z)，（ts为长时间）

nPair=nRx*nTx;
nP=size(pointCoor,1);
[isRx,isTx]=meshgrid(1:nRx,1:nTx);
isRx=permute(isRx,[2,1]);
isTx=permute(isTx,[2,1]);
isRxV=reshape(isRx,1,nPair);
isTxV=reshape(isTx,1,nPair);
rsCoRT=sqrt( ...
    (repmat(pointCoor(:,1),1,nPair)-repmat(rxCoor(isRxV,1)',nP,1)).^2 ...
    + (repmat(pointCoor(:,2),1,nPair)-repmat(rxCoor(isRxV,2)',nP,1)).^2 ...
    + (repmat(pointCoor(:,3),1,nPair)-repmat(rxCoor(isRxV,3)',nP,1)).^2 ...
    ) ...
    + sqrt( ...
    (repmat(pointCoor(:,1),1,nPair)-repmat(txCoor(isTxV,1)',nP,1)).^2 ...
    + (repmat(pointCoor(:,2),1,nPair)-repmat(txCoor(isTxV,2)',nP,1)).^2 ...
    + (repmat(pointCoor(:,3),1,nPair)-repmat(txCoor(isTxV,3)',nP,1)).^2 ...
    ) ...
    + dCa;
rsCoRT=reshape(rsCoRT,nP,nRx,nTx);

%% 计算f(n,m,zs,ts,tsRamp)，（ts为长时间,tsRamp为短时间）
if useGPU
    rsCoRT=gpuArray(rsCoRT);
    tsRamp=gpuArray(tsRamp);
end
rsCoRTTsramp=permute(repmat(rsCoRT,1,1,1,length(tsRamp)),[4,2,3,1]);
% persistent  tsCoRTTsramp;
tsCoRTTsramp=repmat(tsRamp',1,size(rsCoRTTsramp,2),size(rsCoRTTsramp,3),size(rsCoRTTsramp,4));
fTsrampRTZ=exp( ...
    1i*2*pi*fBw*fRamp.*rsCoRTTsramp/3e8 ...
    .*tsCoRTTsramp ...
    ) ...
    .*exp( ...
    1i*2*pi*rsCoRTTsramp/dLambda ...
    );
    
end