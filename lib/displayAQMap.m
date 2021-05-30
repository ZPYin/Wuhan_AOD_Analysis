function [fh, lat, lon, AQData] = displayAQMap(dataFile, siteLookupFile, varargin)
% DISPLAYAQMAP display map of air pollutants.
% USAGE:
%    [fh, lat, lon, AQData] = displayAQMap(dataFile, siteLookupFile, varargin)
% INPUTS:
%    dataFile: char
%        absolute path of the csv data file for cities. (e.g., 'china_cities_20200101.csv')
%    siteLookupFile: char
%        absolute path of the csv site lookup file. (e.g., '站点列表-2020.12.06起.csv')
% KEYWORDS:
%    latRange: 2-element array
%        latitude range. (degree)
%    lonRange: 2-element array
%        longitude range. (degree)
%    cRange: 2-element array
%        color range.
%    type: char
%        pollutant type. (PM2.5, PM10, O3, NO2, SO2, CO)
%    hour: numeric
%        hour of measurement.
%    AQUnit: char
%        unit to be displayed on top of the colorbar.
%    imgFile: char
%        absolute path of file to export the figure.
% OUTPUTS:
%    fh: figure handle
%    lat: numeric
%    lon: numeric
%    AQData: numeric
% EXAMPLE:
% HISTORY:
%    2021-04-30: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'dataFile', @ischar);
addRequired(p, 'siteLookupFile', @ischar);
addParameter(p, 'latRange', [18, 58], @isnumeric);
addParameter(p, 'lonRange', [70, 140], @isnumeric);
addParameter(p, 'cRange', [0, 200], @isnumeric);
addParameter(p, 'type', 'PM10', @ischar);
addParameter(p, 'AQUnit', '\mug/m^3', @ischar);
addParameter(p, 'hour', 0, @isnumeric);
addParameter(p, 'imgFile', '', @ischar);

parse(p, dataFile, siteLookupFile, varargin{:});

%% read data
[data, cityLookupTab] = readCityAQ(dataFile, 'siteLookupFile', siteLookupFile);

%% extract data
lat = [];
lon = [];
AQData = [];
mDate = data.datetime(1);
typeInd = find(strcmpi(data.type, p.Results.type));
thisDatetime = mDate + datenum(0, 1, 0, p.Results.hour, 0, 0);
[~, hourInd] = min(abs(data.datetime(strcmpi(data.type, p.Results.type)) - thisDatetime));
rowInd = typeInd(hourInd);
for iCol = 4:(length(data.Properties.VariableNames) - 1)
    cityCode = data.Properties.VariableNames{iCol};

    flagCity = strcmp(cityLookupTab.code, cityCode);

    if sum(flagCity) == 1
        lat = cat(2, lat, str2double(cityLookupTab.latitude{flagCity}));
        lon = cat(2, lon, str2double(cityLookupTab.longitude{flagCity}));
        AQData = cat(2, AQData, data{rowInd, iCol});
    end
end

%% data visualization
fh = figure('Color', 'w', 'Position', [20, 40, 500, 400], 'Units', 'Pixels');

ax1 = axes('Position', [-0.17, 0, 1.3, 1.1], 'Units', 'Normalized');
axes(ax1);

axesm('MapProjection', 'lambertstd', 'MLabelParallel', 'South', ...
             'Frame', 'off', 'MeridianLabel', 'on', ...
             'MapLatLimit', p.Results.latRange, 'MapLonLimit', p.Results.lonRange);

text(0.5, 0.91, ...
    sprintf('Distribution of %s at %s (LT)', ...
        p.Results.type, datestr(mDate, 'yyyy-mm-dd HH')), ...
    'FontSize', 14, 'FontWeight', 'Bold', 'FontSize', 16, ...
    'Units', 'Normalized', 'HorizontalALignment', 'center');

scatterm(lat, lon, 10, AQData, 'filled');

colormap('jet');
hold on;

shpChinaProv = load('china.province.mat');
plotm(shpChinaProv.lat, shpChinaProv.long, 'color', 'k', 'LineWidth', 0.5);

caxis(p.Results.cRange);
mlabel off; plabel off; gridm off;
set(gca, 'box', 'off', 'visible', 'off');

cb = colorbar('Position', [0.85, 0.25, 0.02, 0.6], 'Units', 'Normalized');
titleHandle = get(cb, 'Title');
set(titleHandle, 'String', p.Results.AQUnit);

tightmap;

% export figure
if ~ isempty(p.Results.imgFile)
    export_fig(gcf, p.Results.imgFile, '-r300');
end

end