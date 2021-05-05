clc; close all;
projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectDir, 'include')));
addpath(genpath(fullfile(projectDir, 'lib')));

% set character encoding
slCharacterEncoding('UTF-8');

%% initialization
dataPath = 'D:\Data\全国空气质量\v_202101';
siteLookupFile = 'D:\Data\全国空气质量\v_202101\_站点列表\站点列表-2020.12.06起.csv';
dateRange = [datenum(2019, 1, 1), datenum(2019, 2, 1)];
matFilename = 'D:\Data\test.mat';
site = {'武汉'};
flagCity = true;

%% search data files
if flagCity
    % list air quality data filenames of different city
    cityAQFiles = {};
    cityAQFolders = listdir(dataPath, '城市_\w{8}-\w{8}');

    for iFolder = 1:length(cityAQFolders)
        files = listfile(cityAQFolders{iFolder}, 'china_cities_\w{8}.*csv');
        cityAQFiles = cat(2, cityAQFiles, files);
    end

    % filter files
    cityAQFilesTmp = cell(0);
    for iFile = 1:length(cityAQFiles)
        thisDate = datenum(cityAQFiles{iFile}((end-11):(end-4)), 'yyyymmdd');

        if (thisDate >= dateRange(1)) && (thisDate <= dateRange(2))
            cityAQFilesTmp = cat(2, cityAQFilesTmp, cityAQFiles(iFile));
        end
    end
    cityAQFiles = cityAQFilesTmp;

    % read city data
    cityData = cell(1, length(cityAQFiles));
    for iFile = 1:length(cityAQFiles)
        fprintf('Finished %6.2f%%: reading %s\n', (iFile - 1)/length(cityAQFiles) * 100, basename(cityAQFiles{iFile}));

        [cityDataTmp, cityLookupTab] = readCityAQ(cityAQFiles{iFile}, 'siteLookupFile', siteLookupFile, 'cityList', site);
        cityData{iFile} = cityDataTmp;
    end

    %% save data
    save(matFilename, 'cityData', 'cityLookupTab', '-v7.3');

else
    % list air quality data filenames of different stations
    siteAQFiles = {};
    siteAQFolders = listdir(dataPath, '站点_\w{8}-\w{8}');

    for iFolder = 1:length(siteAQFolders)
        files = listfile(siteAQFolders{iFolder}, 'china_sites_\w{8}.*csv');
        siteAQFiles = cat(2, siteAQFiles, files);
    end

    siteAQFilesTmp = cell(0);
    for iFile = 1:length(siteAQFiles)
        thisDate = datenum(siteAQFiles{iFile}((end-11):(end-4)), 'yyyymmdd');

        if (thisDate >= dateRange(1)) && (thisDate <= dateRange(2))
            siteAQFilesTmp = cat(2, siteAQFilesTmp, siteAQFiles(iFile));
        end
    end
    siteAQFiles = siteAQFilesTmp;

    % read site data
    siteData = cell(1, length(siteAQFiles));
    for iFile = 1:length(siteAQFiles)
        fprintf('Finished %6.2f%%: reading %s\n', (iFile - 1)/length(siteAQFiles) * 100, basename(siteAQFiles{iFile}));

        [siteDataTmp, siteLookupTab] = readSiteAQ(siteAQFiles{iFile}, 'siteLookupFile', siteLookupFile, 'siteList', site);
        siteData{iFile} = siteDataTmp;
    end

    %% save data
    save(matFilename, 'siteData', 'siteLookupTab', '-v7.3');

end