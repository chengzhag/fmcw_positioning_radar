%% 运行参数设置
doFindpeaksTest_findpeaks=0;
doFindFirstpeakSampleTest_findpeaks=0;
doFindFirstpeakTest_findpeaks=0;

%% 清理
close all;

%% 加载/提取数据、参数
load '../data/yLoCut_1MHz_400rps_1rpf_1t8r_walking.mat'

nRx=size(antBits,1);
yLoCut=log2array(logsout,'yLoCutSim');
lRamp=fS/fTr;%length ramp
lSp=size(yLoCut,1);
fF=fTr/nRx/nCyclePF;

fBw=2e9;%frequency bandwidth
fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
dPs=fD/fPm;%distance per sample
fs=linspace(0,fD*(lSp/2-1),floor(lSp/2));
ds=fs/fPm;
ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

%% 计算每根天线的参数
% 计算发射天线到各接收天线之间的距离
dsTxRxi=zeros(nRx,1);%暂时只做一根发射天线
for iRx=1:nRx
    dsTxRxi(iRx,:)=pdist([antCoor(iRx,:);antCoor(nRx+1,:)]);
end

%% 截取有效时间
tMi=5;
tMa=38;
valT=ts>=tMi & ts<=tMa;

yLoCut=yLoCut(:,:,valT);
ts=ts(valT);

%% 2DFFT

yLoCut=yLoCut...
    .*repmat(hamming(size(yLoCut,2))',size(yLoCut,1),1,size(yLoCut,3))...
    .*repmat(hamming(size(yLoCut,1)),1,size(yLoCut,2),size(yLoCut,3));
heatMaps=fft2(yLoCut,size(yLoCut,1),2^nextpow2(100));

% 排除线缆长度，截取有效距离
heatMaps=heatMaps(ds>=dCa,:,:);
ds=ds(ds>=dCa)-dCa;

% 截取有效距离范围
dMi=max(dsTxRxi);
dMa=20;
valD=ds>=dMi & ds<=dMa;

heatMaps=heatMaps(valD,:,:);
ds=ds(valD);

heatMaps=flip(heatMaps,2);

% 减去背景
heatMapB=filter(0.05,[1,-0.95],heatMaps,0,3);
heatMaps=abs(heatMaps-heatMapB);

hHea=figure('name','空间热度图');
for iFrame=1:size(heatMaps,3)
    figure(hHea);
    heatMap=heatMaps(:,:,iFrame);
    heatMap=circshift(heatMap,ceil(size(heatMap,2)/2),2);
    imagesc(1:size(heatMap,2),ds,heatMap);
    title(['第' num2str(ts(iFrame)) 's 的空间热度图']);
    pause(0.01);
end
