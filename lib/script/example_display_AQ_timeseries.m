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
% ��ȡ���ݲο�example_read_AQ_data.m

%% data visualization

% PM10����ʱ������
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw');

% PM10����ʱ�����У�������ͼƬ
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'imgFile', imgFile);

% PM10����ʱ�����У�����ʾͼ�δ��ڣ�����ͼƬ
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'visible', 'off', 'imgFile', imgFile);

% PM10����ʱ�����У�������ͼ����
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'outputDataFile', outputTxtFile1);

% PM10�·�ƽ��ʱ�����У�������ͼ����
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'monthly', 'outputDataFile', outputTxtFile2);

% PM10��ƽ��ʱ�����У�������ͼ����
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'annual', 'outputDataFile', outputTxtFile3);

% PM10����ƽ��ʱ�����У�������ͼ����
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'seasonal', 'outputDataFile', outputTxtFile4);

% PM10����ƽ���仯ʱ�����У�������ͼ����
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'diurnal', 'outputDataFile', outputTxtFile5);

% PM10��ƽ���仯ʱ�����У�������ͼ����
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'daily', 'outputDataFile', outputTxtFile6);

% AQI�ֲ��ı�ͼ���趨���������ݵ�ͳ�ƽ������������ͼ����
displayAQTimeseries(matFilename, tRange, 'AQtype', 'AQI', 'averageType', 'aqi-pie', 'outputDataFile', outputTxtFile6);