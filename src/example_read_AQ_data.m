clc; close all;
projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectDir, 'include')));
addpath(genpath(fullfile(projectDir, 'lib')));

%% initialization
AQRootFolder = 'D:\Data\ȫ����������\v_202101';   % ��Ⱦ�ﺬ��������Ŀ¼
siteLookupFile = 'D:\Data\ȫ����������\v_202101\_վ���б�\վ���б�-2020.12.06��.csv';   % zվ���б����վ��û��վ���б��ڣ����ܶ�ȡ�����е�վ����վ��û��վ���б��ڣ������������ļ����У�Ҳ�����ȡ�������г���ʱ������warning���еĶ��վ����ͬһ��վ��ţ�Ҳ����warning
site = {'�人'};   % ��Ҫ��ȡվ����б������Ҫ��ȡ���վ��/���У�����ֱ����cell array����ʽ���磺{'�人', '����'}
flagCity = true;   % ���б�־λ�������ʾ����վ��
tRange = [datenum(2018, 1, 1), datenum(2019, 12, 31)];   % ��Ҫ��ȡ���ݵ�ʱ�䷶Χ��Ŀǰ��ȡ�ٶȽ�������ȡ�������ݿ�����Ҫ�ϳ�ʱ�䣩
matFilename = fullfile(projectDir, 'data', 'test_data.mat');   % ת����mat�ļ�·��

%% read and convert data
convertAQData(AQRootFolder, siteLookupFile, site, flagCity, tRange, matFilename);