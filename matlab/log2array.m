% 读取simulink导出logsout变量中特定名称的信号并转换为矩阵
function array=log2array(logsout,name)
array=get(logsout,name);
array=array.Values;

array=getdatasamples(array,1:length(array.time));
end