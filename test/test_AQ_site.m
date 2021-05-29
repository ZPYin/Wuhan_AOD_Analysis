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
AQRootFolder = 'D:\Data\全国空气质量\v_202101';   % 污染物含量数据主目录
siteLookupFile = 'D:\Data\全国空气质量\v_202101\_站点列表\站点列表-2020.12.06起.csv';   % z站点列表（如果站点没在站点列表内，则不能读取），有的站点在站点没在站点列表内，但是在数据文件中有，也不会读取，且运行程序时，会有warning；有的多个站点用同一个站点号，也会有warning
site = {'官园'};   % 需要读取站点的列表；如果需要读取多个站点/城市，可以直接用cell array的形式，如：{'武汉', '北京'}
flagCity = false;   % 城市标志位；否则表示单个站点
tRange = [datenum(2020, 1, 1), datenum(2020, 1, 15)];   % 需要读取数据的时间范围（目前读取速度较慢，读取多年数据可能需要较长时间）
matFilename = fullfile(projectDir, 'data', 'test_read_site.mat');   % 转换的mat文件路径

%% read and convert data
convertAQData(AQRootFolder, siteLookupFile, site, flagCity, tRange, matFilename);
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'flagCity', flagCity, 'site', site{1});