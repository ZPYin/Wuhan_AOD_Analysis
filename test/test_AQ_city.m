clc; close all;
projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectDir, 'include')));
addpath(genpath(fullfile(projectDir, 'lib')));

%% initialization
AQRootFolder = 'D:\Data\ȫ����������\v_202101';   % ��Ⱦ�ﺬ��������Ŀ¼
siteLookupFile = 'D:\Data\ȫ����������\v_202101\_վ���б�\վ���б�-2020.12.06��.csv';   % zվ���б����վ��û��վ���б��ڣ����ܶ�ȡ�����е�վ����վ��û��վ���б��ڣ������������ļ����У�Ҳ�����ȡ�������г���ʱ������warning���еĶ��վ����ͬһ��վ��ţ�Ҳ����warning
site = {'����'};   % ��Ҫ��ȡվ����б������Ҫ��ȡ���վ��/���У�����ֱ����cell array����ʽ���磺{'�人', '����'}
flagCity = true;   % ���б�־λ�������ʾ����վ��
tRange = [datenum(2020, 1, 1), datenum(2020, 1, 15)];   % ��Ҫ��ȡ���ݵ�ʱ�䷶Χ��Ŀǰ��ȡ�ٶȽ�������ȡ�������ݿ�����Ҫ�ϳ�ʱ�䣩
matFilename = fullfile(projectDir, 'data', 'test_read_city.mat');   % ת����mat�ļ�·��

%% read and convert data
convertAQData(AQRootFolder, siteLookupFile, site, flagCity, tRange, matFilename);
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'flagCity', flagCity, 'site', site{1});