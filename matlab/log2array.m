function array=log2array(logsout,name)
array=get(logsout,name);
array=array.Values;

array=getdatasamples(array,1:length(array.time));
end