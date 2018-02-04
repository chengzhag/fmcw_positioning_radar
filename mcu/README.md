# mcu
单片机工程文件

## README.md
对单片机各项目的功能、目的进行说明

## antenna_switch_mbed
基于mbed的天线切换控制。

* 以AD4159MUXOUT脚输出的扫频结束脉冲作为触发信号，通过单片机轮流切换switch输入端口
* 根据switchADRF5040的datasheet，RF1/2/3分别对应V1/2电平为00/10/01
* 由于MUXOUT输出脉冲无法表示天线的编号，因此将天线编号的发送交给单片机
* 定义斜坡同步信号格式为：
![斜坡同步信号定义](https://github.com/pidan1231239/fmcw_positioning_radar/blob/master/images/%E6%96%9C%E5%9D%A1%E5%90%8C%E6%AD%A5%E4%BF%A1%E5%8F%B7%E5%AE%9A%E4%B9%89.jpg)
* 来自AD4159的下降沿信号触发单片机的中断，单片机待下降沿结束将信号拉低w时间，然后发送n比特天线编号
* n位比特与当前天线编号相同，从高到地位发送
* 优化后的触发信号，利用了ad4159triger的下降沿，单片机只通过拉低电平发送天线编号，保证了相位精度。改进后，相位抖动与单片机无关，只受运放影响。
* 改进后的程序：利用vector实现了同一个控制位多个IO控制，方便接线；利用bitset实现了任意多天线的控制







