%% initialization
csvFile = 'D:\Data\ȫ����������\v_202101\����_20180101-20181231\china_cities_20180107.csv';   % path to city AQ file.
siteLookupFile = 'D:\Data\ȫ����������\v_202101\_վ���б�\վ���б�-2020.12.06��.csv';   % path to city Lookup file.
imgFile = 'C:\Users\zpyin\Desktop\test_AQ_map.png';   % path for saving results.

%% data visualization
%
% �����Ҫ����ͼƬ������ͨ�����ùؼ���'imgFile'
% ����: 
% displayAQMap(csvFile, siteLookupFile, 'type', 'pm2.5', 'hour', 12, 'imgFile', imgFile);
%
% **********************************
% �����Ҫ�������ݣ�����ֱ�ӷ��ز���
% ���磺
% [~, lat, lon, AQData] = displayAQMap(csvFile, siteLookupFile, 'type', 'pm2.5', 'hour', 12);
%
displayAQMap(csvFile, siteLookupFile, 'type', 'pm2.5', 'hour', 12);