# images
系统运行截图和硬件、实验照片

## README.md
对图片内容、时间进行说明

## 斜坡同步信号定义.png
定义一发三收定位系统的接收天线切换同步信号，用于mcu/antenna_switch_mbed项目

## 三根天线瀑布图.jpg
positioning_test.m生成的图像，对foreground_1MHz_400rps_5rpf_1t3r_walking.mat数据绘制得到的三根天线的前景频谱，经过log函数变换以提高显示的动态范围，用于印象笔记插图。

## 寻峰得到的距离_时间曲线.jpg
positioning_test.m生成的图像，从foreground_1MHz_400rps_5rpf_1t3r_walking.mat三根天线的前景频谱中分析得到的距离——时间曲线，可以看到由于固定距离处的频谱抖动，从2/3天线频谱中提取的距离有一部分落到了抖动的峰处。可见该抖动成为影响定位的重大问题。
