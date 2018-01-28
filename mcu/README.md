# mcu
单片机工程文件

## README.md
对单片机各项目的功能、目的进行说明

## antenna_switch_mbed
基于mbed的天线切换控制。

* 以AD4159MUXOUT脚输出的扫频结束脉冲作为触发信号，通过单片机轮流切换switch输入端口
* 根据switchADRF5040的datasheet，RF1/2/3分别对应V1/2电平为00/10/01
* 由于MUXOUT输出脉冲无法表示天线的编号，因此将帧同步信号的任务交给单片机
* 定义斜坡同步信号格式为：
![斜坡同步信号定义](https://github.com/pidan1231239/fmcw_positioning_radar/blob/master/images/%E6%96%9C%E5%9D%A1%E5%90%8C%E6%AD%A5%E4%BF%A1%E5%8F%B7%E5%AE%9A%E4%B9%89.png)
* 来自AD4159的下降沿信号触发单片机的中断，单片机立即将输出IO拉高，给USRP一个上升沿信号并切换天线，脉冲持续w1，然后发送两比特天线编号，数据位宽度w1=w2=w3
* 两位比特与当前switch的控制信号V1/2相同





