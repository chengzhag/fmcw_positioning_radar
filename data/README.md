# data
存储记录的用于调试的数据

## README.md
对数据文件的功能、引用代码/框图进行说明

## dataSim_200kHz_400rps_5rpf_1t3r_static.mat
用usrp_save_raw_data.slx录制的usrp原始数据dataSim，采样率200kHz，每秒400个斜坡，每帧5个斜坡，1发3收，静止背景
通过fS、fTr、nPul、tPul、nRx五个参数完全描述其信息：
- fS: 采样率
- fTr: 帧率
- nPul: 脉冲/比特总数
- tPul: 脉冲/比特宽度
- nRx：接收天线数量，指switch切换周期的通道数

## dataSim_1MHz_400rps_5rpf_1t3r_static.mat
用usrp_save_raw_data.slx录制的usrp原始数据dataSim，采样率1MHz，每秒400个斜坡，每帧5个斜坡，1发3收，静止背景
通过fS、fTr、nPul、tPul、nRx五个参数完全描述其信息：
- fS: 采样率
- fTr: 帧率
- nPul: 脉冲/比特总数
- tPul: 脉冲/比特宽度
- nRx：接收天线数量，指switch切换周期的通道数

