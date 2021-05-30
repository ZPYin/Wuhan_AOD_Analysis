function [flag] = convertAQData(dataPath, siteLookupFile, site, flagCity, dateRange, matFilename, varargin)
% CONVERTAQDATA convert air pollutant data to mat file.
% USAGE:
%    [flag] = convertAQData(dataPath, siteLookupFile, site, flagCity, matFilename)
% INPUTS:
%    dataPath: char
%        root path of air pollutant data.
%    siteLookupFile: char
%        absolute path of site lookup file.
%    site: cell
%        site list.
%    flagCity: logical
%        city flag.
%    dateRange: 2-element array
%        date range for air pollutant data.
%    matFilename: char
%        absolute path of mat file to be exported to.
% OUTPUTS:
%    flag: logical
%        flag to determine the converting process.
% EXAMPLE:
% HISTORY:
%    2021-05-06: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'dataPath', @ischar);
addRequired(p, 'siteLookupFile', @ischar);
addRequired(p, 'site', @iscell);
addRequired(p, 'flagCity', @islogical);
addRequired(p, 'dateRange', @isnumeric);
addRequired(p, 'matFilename', @ischar);

parse(p, dataPath, siteLookupFile, site, flagCity, dateRange, matFilename, varargin{:});

%% search data files
if flagCity
    % list air quality data filenames of different city
    cityAQFiles = {};
    cityAQFolders = listdir(dataPath, '³ÇÊÐ_\w{8}-\w{8}');

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
        fprintf('Finished %6.2f%%: reading %s\n', ...
            (iFile - 1)/length(cityAQFiles) * 100, ...
            basename(cityAQFiles{iFile}));

        [cityDataTmp, cityLookupTab] = readCityAQ(cityAQFiles{iFile}, ...
            'siteLookupFile', siteLookupFile, 'cityList', site);
        cityData{iFile} = cityDataTmp;
    end

    if ~ isempty(cityAQFiles)
        %% save data
        save(matFilename, 'cityData', 'cityLookupTab', '-v7.3');
        flag = true;
    else
        warning('No data files were found.');
    end

else
    % list air quality data filenames of different stations
    siteAQFiles = {};
    siteAQFolders = listdir(dataPath, 'Õ¾µã_\w{8}-\w{8}');

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
        fprintf('Finished %6.2f%%: reading %s\n', ...
            (iFile - 1)/length(siteAQFiles) * 100, ...
            basename(siteAQFiles{iFile}));

        [siteDataTmp, siteLookupTab] = readSiteAQ(siteAQFiles{iFile}, ...
            'siteLookupFile', siteLookupFile, 'siteList', site);
        siteData{iFile} = siteDataTmp;
    end

    if ~ isempty(siteAQFiles)
        %% save data
        save(matFilename, 'siteData', 'siteLookupTab', '-v7.3');
        flag = true;
    else
        warning('No data files were found.');
    end

end