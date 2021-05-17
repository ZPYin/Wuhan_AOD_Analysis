clc; close all;
projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectDir, 'include')));
addpath(genpath(fullfile(projectDir, 'lib')));

%% set character encoding
currentCharacterEncoding = slCharacterEncoding();
slCharacterEncoding('UTF-8');   % 编码格式设置成UTF-8，跟我的原始保存格式一致。
                                % 如果你当前的编码格式不是采用的UTF-8，则代码中文会显示乱码，但是运行依然会正常显示
                                % 可是如果你使用的是不同的编码格式进行保存（matlab编辑器默认的是GBK，或者ISO-8859-1），那么当前中文内容将会永远乱码。
                                % 建议阅读：https://iloveocean.top/index.php/archives/486/#:~:text=matlab%20%E8%8B%B1%E6%96%87%E7%8E%AF%E5%A2%83%E4%B8%8B%E9%BB%98%E8%AE%A4,utf%2D8%20%E6%A0%BC%E5%BC%8F%E8%BF%9B%E8%A1%8C%E7%BC%96%E7%A0%81%E3%80%82

%% initialization
matFilename = fullfile(projectDir, 'data', 'wuhan_AQData.mat');
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