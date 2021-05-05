function [data, siteLookupTab] = readSiteAQ(dataFile, varargin)
% READSITEAQ read air pollutants data of every site.
% USAGE:
%    [data] = readSiteAQ(dataFile)
% INPUTS:
%    dataFile: char
%        path of the air pollutant data file.
% KEYWORDS:
%    siteLookupFile: char
%    siteList: cell
% OUTPUTS:
%    data: table
%        datetime
%        s+siteCode
%        type
% EXAMPLE:
% HISTORY:
%    2021-04-29: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'dataFile', @ischar);
addParameter(p, 'siteLookupFile', '', @ischar);
addParameter(p, 'siteList', {}, @iscell);

parse(p, dataFile, varargin{:});

% set character encoding
slCharacterEncoding('UTF-8');

siteLookupTab = struct();

if exist(dataFile, 'file') ~= 2
    error('File does not exist: %s\n', dataFile);
end

try
    data = readtable(dataFile, 'Delimiter', ',', 'ReadVariableNames', false, 'Headerlines', 1);
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

% read data headers
fid = fopen(dataFile, 'r');
headers = fgetl(fid);
fclose(fid);

colNames = strsplit(headers, ',');

% rename 'data' variable names
for iCol = 4:length(colNames)
    try
        data.Properties.VariableNames{iCol} = ['s', colNames{iCol}];
    catch ErrMsg
        warning(ErrMsg.identifier, '%s', ErrMsg.message);
    end
end

% convert date to datenum 
data.datetime = datenum(floor(data.date/1e4), mod(floor(data.date/1e2), 1e2), mod(data.date, 1e2), data.hour, 0, 0);

% read site lookup table file
if exist(p.Results.siteLookupFile, 'file') == 2

    [~, ~, fileExt] = fileparts(p.Results.siteLookupFile);

    if strcmp(fileExt, '.csv')
        siteLookupTab = readtable(p.Results.siteLookupFile, 'Delimiter', ',', 'ReadVariableNames', false, 'Headerlines', 1);
        siteLookupTab.Properties.VariableNames{1} = 'code';
        siteLookupTab.Properties.VariableNames{2} = 'siteName';
        siteLookupTab.Properties.VariableNames{3} = 'city';
        siteLookupTab.Properties.VariableNames{4} = 'longitude';
        siteLookupTab.Properties.VariableNames{5} = 'latitude';
        siteLookupTab.Properties.VariableNames{6} = 'flagComparison';

        for iRow = 1:length(siteLookupTab.code)
            siteLookupTab.code{iRow} = ['s', siteLookupTab.code{iRow}];
        end
    else
        warning('csv file was expected: %s', p.Results.siteLookupFile);
    end
end

% extract data
dataTmp = table(data.date, data.hour, data.type, data.datetime);
dataTmp.Properties.VariableNames{1} = 'date';
dataTmp.Properties.VariableNames{2} = 'hour';
dataTmp.Properties.VariableNames{3} = 'type';
dataTmp.Properties.VariableNames{4} = 'datetime';
for iSite = 1:length(p.Results.siteList)
    flagSite = strcmp(siteLookupTab.siteName, p.Results.siteList{iSite});

    if (~ any(flagSite)) || (sum(flagSite) > 1)
        error('Wrong site: %s', p.Results.siteList{iSite});
    end

    siteCode = siteLookupTab.code{flagSite};

    dataTmp.(siteCode) = data.(siteCode);
end

if ~ isempty(p.Results.siteList)
    data = dataTmp;
end

end