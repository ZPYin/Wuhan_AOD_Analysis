global WAOD_ENVS;

%% initialization
matFilename = fullfile(WAOD_ENVS.RootPath, 'data', 'wuhan_AQData.mat');
imgFile = 'C:\Users\zpyin\Desktop\test_AQ_timeseries.png';
outputTxtFile1 = 'C:\Users\zpyin\Desktop\PM10_wuhan_raw.txt';
outputTxtFile2 = 'C:\Users\zpyin\Desktop\PM10_wuhan_monthly.txt';
outputTxtFile3 = 'C:\Users\zpyin\Desktop\PM10_wuhan_annual.txt';
outputTxtFile4 = 'C:\Users\zpyin\Desktop\PM10_wuhan_seasonal.txt';
outputTxtFile5 = 'C:\Users\zpyin\Desktop\PM10_wuhan_diurnal.txt';
outputTxtFile6 = 'C:\Users\zpyin\Desktop\PM10_wuhan_daily.txt';
tRange = [datenum(2019, 1, 1), datenum(2019, 4, 1)];

%% data import
% 读取数据参考example_read_AQ_data.m

%% data visualization

% PM10数据时间序列
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw');

% PM10数据时间序列，并保存图片
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'imgFile', imgFile);

% PM10数据时间序列，不显示图形窗口，保存图片
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'visible', 'off', 'imgFile', imgFile);

% PM10数据时间序列，保存作图数据
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'outputDataFile', outputTxtFile1);

% PM10月份平均时间序列，保存作图数据
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'monthly', 'outputDataFile', outputTxtFile2);

% PM10年平均时间序列，保存作图数据
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'annual', 'outputDataFile', outputTxtFile3);

% PM10季节平均时间序列，保存作图数据
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'seasonal', 'outputDataFile', outputTxtFile4);

% PM10周日平均变化时间序列，保存作图数据
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'diurnal', 'outputDataFile', outputTxtFile5);

% PM10日平均变化时间序列，保存作图数据
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'daily', 'outputDataFile', outputTxtFile6);

% AQI分布的饼图（设定日期内数据的统计结果），保存作图数据
displayAQTimeseries(matFilename, tRange, 'AQtype', 'AQI', 'averageType', 'aqi-pie', 'outputDataFile', outputTxtFile6);