# matlab
.m代码和.mlx代码。

## README.md
对matlab代码功能、目的进行说明

## log2array_example.m
读取simulink log生成的dataset数据类型示例程序，log2array函数例程

## log2array.m
读取simulink导出logsout变量中特定名称的信号并转换为矩阵

## function_test.m
测试各系统函数。

### firstRampTime测试
- 测试了firstRampTime函数可能可能带来的相位抖动，并以图形的方式展示了检测到的样本帧的触发沿。
- 通过循环位移样本帧模拟了长时间运行时可能触发的边界条件，保证程序的稳定运行。

## firstRampTime.m
用于提取第一个同步斜坡信号起始时间，返回所有斜坡信号起始时间点，精确到采样时间之下，以第一个采样点为参考时间0。

