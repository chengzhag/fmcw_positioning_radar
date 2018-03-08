# data
存储记录的用于调试的数据

## README.md
对数据文件的功能、引用代码/框图进行说明

## dataSim_200kHz_400rps_5rpf_1t3r_static.mat 
用usrp_save_raw_data.slx录制的usrp原始数据dataSim，采样率200kHz，每秒400个斜坡，每帧5个斜坡，1发3收，静止背景。 
通过以下几个参数完全描述其信息： 
- fS: 采样率 
- fTr: 帧率 
- nPul: 脉冲/比特总数 
- tPul: 脉冲/比特宽度 
- nRx：接收天线数量，指switch切换周期的通道数 
- antBits：各天线比特电平 

## dataSim_1MHz_400rps_5rpf_1t3r_static.mat 
用usrp_save_raw_data.slx录制的usrp原始数据dataSim，采样率1MHz，每秒400个斜坡，每帧5个斜坡，1发3收，静止背景。同时包括上面几个参数 

## foreground_1MHz_400rps_5rpf_1t3r_walking.mat 
用usrp_1t3r_positioning.slx录制的foreground频谱数据，采样率1MHz，每秒400个斜坡，每天线每帧5个斜坡，1发3收，行人来回走动。 
通过以下几个参数完全描述其信息： 
- fS: 采样率 
- fTr: 帧率 
- nPul: 脉冲/比特总数 
- tPul: 脉冲/比特宽度 
- nRx：接收天线数量，指switch切换周期的通道数 
- antBits：各天线比特电平 
- antCoor：各天线坐标，前size(antBits,1)个坐标对应antBits表示的接收天线，最后一个坐标对应发射天线。暂时只考虑一发多收的情况 
- dCa：线缆长度，认为各接收天线线缆长度相同 
- nCyclePF：每帧的循环数，即平均的斜坡次数 
 
## yLoCut_1MHz_400rps_1rpf_1t8r_walking.mat 
 
用usrp_1t3r_positioning.slx录制的foreground频谱数据，采样率1MHz，每秒400个斜坡，每天线每帧1个斜坡，1发8收，行人来回走动。 
包含参数与foreground_1MHz_400rps_5rpf_1t3r_walking.mat相同 

## yLoCut_200kHz_800rps_1rpf_4t12r_walking.mat
- 用usrp_4t12r_heatmap.slx录制的各收发天线对中频信号。
- 测试动作：前后左右走动。

## yLoCut_200kHz_800rps_1rpf_4t12r_walking.mp4
- 用usrp_4t12r_heatmap.slx录制的功率分布，横坐标为角度，纵坐标为距离。
- 测试动作：前后左右走动。

## yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mat
- 用usrp_4t12r_heatmap.slx录制的各收发天线对中频信号。
- 测试动作：静止站立，站在板凳上，下蹲。来回行走和蹲走。

## yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mp4
- 用usrp_4t12r_heatmap.slx录制的功率分布，横坐标为角度，纵坐标为距离。
- 测试动作：静止站立，站在板凳上，下蹲。来回行走和蹲走。
