%% initialization
dataFile1 = 'D:\Data\全国空气质量\v_202101\城市_20190101-20191231\china_cities_20191028.csv';
dataFile2 = 'D:\Data\全国空气质量\v_202101\城市_20190101-20191231\china_cities_20191029.csv';
dataFile3 = 'D:\Data\全国空气质量\v_202101\城市_20190101-20191231\china_cities_20191101.csv';
dataFile4 = 'D:\Data\全国空气质量\v_202101\城市_20190101-20191231\china_cities_20191103.csv';
imgFile1 = 'D:\Research\Mongolian_dust\docs\production\figures\national_PM10_1.png';
imgFile2 = 'D:\Research\Mongolian_dust\docs\production\figures\national_PM10_2.png';
imgFile3 = 'D:\Research\Mongolian_dust\docs\production\figures\national_PM10_3.png';
imgFile4 = 'D:\Research\Mongolian_dust\docs\production\figures\national_PM10_4.png';
siteLookupFile = 'D:\Data\全国空气质量\v_202101\_站点列表\站点列表-2020.12.06起.csv';

%% data visualization
displayAQMap(dataFile1, siteLookupFile, 'type', 'pm10', 'hour', 0, 'imgFile', imgFile1, 'AQUnit', ['PM_{10}/' char(181) 'g\cdotm^{-3}'], 'cRange', [0, 250], 'latRange', [0,58]);
displayAQMap(dataFile2, siteLookupFile, 'type', 'pm10', 'hour', 12, 'imgFile', imgFile2, 'AQUnit', ['PM_{10}/' char(181) 'g\cdotm^{-3}'], 'cRange', [0, 250], 'latRange', [0,58]);
displayAQMap(dataFile3, siteLookupFile, 'type', 'pm10', 'hour', 12, 'imgFile', imgFile3, 'AQUnit', ['PM_{10}/' char(181) 'g\cdotm^{-3}'], 'cRange', [0, 250], 'latRange', [0,58]);
displayAQMap(dataFile4, siteLookupFile, 'type', 'pm10', 'hour', 18, 'imgFile', imgFile4, 'AQUnit', ['PM_{10}/' char(181) 'g\cdotm^{-3}'], 'cRange', [0, 250], 'latRange', [0,58]);