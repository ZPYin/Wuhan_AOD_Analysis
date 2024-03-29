global WAOD_ENVS;
%% initialization
AQRootFolder = 'D:\Data\全国空气质量\v_202101';   % 污染物含量数据主目录
siteLookupFile = 'D:\Data\全国空气质量\v_202101\_站点列表\站点列表-2020.12.06起.csv';   % z站点列表（如果站点没在站点列表内，则不能读取），有的站点在站点没在站点列表内，但是在数据文件中有，也不会读取，且运行程序时，会有warning；有的多个站点用同一个站点号，也会有warning
site = {'武汉'};   % 需要读取站点的列表；如果需要读取多个站点/城市，可以直接用cell array的形式，如：{'武汉', '北京'}
flagCity = true;   % 城市标志位；否则表示单个站点
tRange = [datenum(2014, 12, 29), datenum(2014, 12, 31)];   % 需要读取数据的时间范围（目前读取速度较慢，读取多年数据可能需要较长时间）
matFilename = fullfile(WAOD_ENVS.RootPath, 'data', 'test_read_city.mat');   % 转换的mat文件路径

%% read and convert data
convertAQData(AQRootFolder, siteLookupFile, site, flagCity, tRange, matFilename);
displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'flagCity', flagCity, 'site', site{1});