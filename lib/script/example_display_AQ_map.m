%% initialization
csvFile = 'D:\Data\全国空气质量\v_202101\城市_20180101-20181231\china_cities_20180107.csv';   % path to city AQ file.
siteLookupFile = 'D:\Data\全国空气质量\v_202101\_站点列表\站点列表-2020.12.06起.csv';   % path to city Lookup file.
imgFile = 'C:\Users\zpyin\Desktop\test_AQ_map.png';   % path for saving results.

%% data visualization
%
% 如果需要保存图片，可以通过设置关键字'imgFile'
% 比如: 
% displayAQMap(csvFile, siteLookupFile, 'type', 'pm2.5', 'hour', 12, 'imgFile', imgFile);
%
% **********************************
% 如果需要导出数据，可以直接返回参数
% 比如：
% [~, lat, lon, AQData] = displayAQMap(csvFile, siteLookupFile, 'type', 'pm2.5', 'hour', 12);
%
displayAQMap(csvFile, siteLookupFile, 'type', 'pm2.5', 'hour', 12);