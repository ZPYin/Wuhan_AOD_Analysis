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
csvFile = 'D:\Data\全国空气质量\v_202101\城市_20180101-20181231\china_cities_20180107.csv';
siteLookupFile = 'D:\Data\全国空气质量\v_202101\_站点列表\站点列表-2020.12.06起.csv';
imgFile = 'C:\Users\zpyin\Desktop\test_AQ_map.png';

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