function [data, cityLookupTab] = readCityAQ(dataFile, varargin)
% READCITYAQ read air pollutants data of every city (or given cities).
% USAGE:
%    [data] = readCityAQ(dataFile)
% INPUTS:
%    dataFile: char
%        path of the air pollutant data file.
% KEYWORDS:
%    siteLookupFile: char
%    cityList: cell
% OUTPUTS:
%    data: table
%        datetime
%        s+cityCode
%        type
% EXAMPLE:
% HISTORY:
%    2021-04-29: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'dataFile', @ischar);
addParameter(p, 'siteLookupFile', '', @ischar);
addParameter(p, 'cityList', {}, @iscell);

parse(p, dataFile, varargin{:});

% set character encoding
slCharacterEncoding('UTF-8');

cityLookupTab = struct();

if exist(dataFile, 'file') ~= 2
    error('File does not exist: %s\n', dataFile);
end

try
    data = readtable(dataFile, 'Delimiter', ',', 'ReadVariableNames', false, 'Headerlines', 1, 'EmptyValue', NaN);
catch ErrMsg
    error('Error in reading %s', dataFile);
end

data.Properties.VariableNames{1} = 'date';
data.Properties.VariableNames{2} = 'hour';
data.Properties.VariableNames{3} = 'type';

% replace '' with NaN
if (length(data.date) >= 1)
    if iscell(data{1, end})
        data(:, end) = [];
    end
end

% read site lookup table file
if exist(p.Results.siteLookupFile, 'file') == 2

    [~, ~, fileExt] = fileparts(p.Results.siteLookupFile);

    if strcmp(fileExt, '.csv')
        cityLookupTab = readtable(p.Results.siteLookupFile, 'Delimiter', ',', 'ReadVariableNames', false, 'Headerlines', 1);
        cityLookupTab.Properties.VariableNames{1} = 'code';
        cityLookupTab.Properties.VariableNames{2} = 'siteName';
        cityLookupTab.Properties.VariableNames{3} = 'city';
        cityLookupTab.Properties.VariableNames{4} = 'longitude';
        cityLookupTab.Properties.VariableNames{5} = 'latitude';
        cityLookupTab.Properties.VariableNames{6} = 'flagComparison';

        for iRow = 1:length(cityLookupTab.code)
            cityLookupTab.code{iRow} = ['s', cityLookupTab.code{iRow}];
        end
    else
        warning('csv file was expected: %s', p.Results.siteLookupFile);
    end

    [~, index, ~] = unique(cityLookupTab.city);
    cityLookupTab = cityLookupTab(index, :);
end

% read data headers
fid = fopen(dataFile, 'r');
headers = fgetl(fid);
fclose(fid);

colNames = strsplit(headers, ',');

% rename 'data' variable names
for iCol = 4:length(colNames)
    try
        flagCity = strcmp(cityLookupTab.city, colNames{iCol});
        data.Properties.VariableNames{iCol} = cityLookupTab.code{flagCity};
    catch ErrMsg
        warning(ErrMsg.identifier, '%s: %s', ErrMsg.message, colNames{iCol});
    end
end

% convert date to datenum 
data.datetime = datenum(floor(data.date/1e4), mod(floor(data.date/1e2), 1e2), mod(data.date, 1e2), data.hour, 0, 0);

% extract data
dataTmp = table(data.date, data.hour, data.type, data.datetime);
dataTmp.Properties.VariableNames{1} = 'date';
dataTmp.Properties.VariableNames{2} = 'hour';
dataTmp.Properties.VariableNames{3} = 'type';
dataTmp.Properties.VariableNames{4} = 'datetime';
for iSite = 1:length(p.Results.cityList)
    flagSite = strcmp(cityLookupTab.city, p.Results.cityList{iSite});

    if (~ any(flagSite)) || (sum(flagSite) > 1)
        error('Wrong site: %s', p.Results.cityList{iSite});
    end

    siteCode = cityLookupTab.code{flagSite};

    dataTmp.(siteCode) = data.(siteCode);
end

if ~ isempty(p.Results.cityList)
    data = dataTmp;
end

end