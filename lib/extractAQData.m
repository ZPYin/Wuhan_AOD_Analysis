function [mTime, AQData] = extractAQData(matFilename, tRange, flagCity, site, AQType)
% EXTRACTAQDATA extract air pollutant data from mat file.
% USAGE:
%    [mTime, AQData] = extractAQData(matFilename, tRange, flagCity, site, AQType)
% INPUTS:
%    matFilename: char
%        absolute path of mat data file.
%    tRange: 2-element array
%        temporal range of data to be exported.
%    flagCity: logical
%        whether to export air pollutant data averaged to city scale.
%    site: char
%        site.
%    AQType: char
%        air pollutant label.
% OUTPUTS:
%    mTime: array
%        measurement time for each data entry.
%    AQData: array
%        air pollutant concentration.
% EXAMPLE:
% HISTORY:
%    2021-05-05: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

%% load data
data = load(matFilename);

%% extract data
mTime = [];
AQData = [];
if flagCity
    % extract city data
    for iDay = 1:length(data.cityData)
        cityDailyData = data.cityData{iDay};

        cityCode = data.cityLookupTab.code{strcmp(data.cityLookupTab.city, site)};
        if isempty(cityCode)
            warning('No measurements at %s', site);
            return;
        end

        rowInd = strcmpi(cityDailyData.type, AQType);
        colInd = strcmp(cityDailyData.Properties.VariableNames, cityCode);

        mTimeTmp = cityDailyData.datetime(rowInd);
        AQDataTmp = cityDailyData{rowInd, colInd};
        flagTime = (mTimeTmp >= tRange(1)) & (mTimeTmp <= tRange(2));

        mTime = cat(1, mTime, mTimeTmp(flagTime));
        AQData = cat(1, AQData, AQDataTmp(flagTime));
    end
else
    % extract site data
    for iDay = 1:length(data.siteData)
        siteDailyData = data.siteData{iDay};

        siteCode = data.siteLookupTab.code{strcmp(data.siteLookupTab.site, site)};
        if isempty(siteCode)
            warning('No measurements at %s', site);
            return;
        end

        rowInd = strcmpi(siteDailyData.type, AQType);
        colInd = strcmp(siteDailyData.Properties.VariableNames, siteCode);

        mTimeTmp = siteDailyData.datetime(rowInd);
        AQDataTmp = siteDailyData{rowInd, colInd};
        flagTime = (mTimeTmp >= tRange(1)) & (mTimeTmp <= tRange(2));

        mTime = cat(1, mTime, mTimeTmp(flagTime));
        AQData = cat(1, AQData, AQDataTmp(flagTime));
    end
end

end