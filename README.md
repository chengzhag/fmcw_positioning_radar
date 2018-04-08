# fmcw_positioning_radar
基于FMCW雷达的多天线定位系统。

2018年英特尔杯嵌入式邀请赛作品。电子科技大学本科2015级：章程、许浩、管紫菁。

# 文件结构
- ad4159：ad4159评估板配置文件。
- data：存储记录的用于调试的数据。
- documents：文档和说明。
- images：系统运行截图和硬件、实验照片。
- matlab：.m代码和.mlx代码。
- mcu：单片机工程文件。
- simlink：simulink框图.slx文件。

## ad4159
- ADF4159官方软件的参数设置。
- 命名方式：ADF4159_settings_A_B_C.txt，如ADF4159_settings_2000Hz_2800MHz_3800MHz.txt。
    - A：斜坡频率
    - B：扫频起始频率
    - C：扫频结束频率

## data
- 存储记录的用于调试的数据。
- 命名方式：A_B_C_D_E_F，如psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall。
    - A：重要变量
    - B：降采样后中频信号频率
    - C：斜坡频率
    - D：平均帧数
    - E：n发m收天线
    - F：测试过程关键词

## documents
文档、说明、参考资料。

## images
文档所需图片或截图。

## matlab
.m代码或函数。

## mcu
单片机工程文件。

## simulink
simulink框图.slx文件。

# release note
## 2.0.0
直接运行usrp_4t12r_heatmap.slx呈现二维成像效果。
- 删除z轴成像功能。
- 删除z轴成像数据。
- 调整降采样因子由5到2，并增加距离至10m。
## 2.1.0
- 更改4根发射天线排布，由竖直排列个改为交叉排列试图用左右分布的发射天线消除水平方向的多径效应。
