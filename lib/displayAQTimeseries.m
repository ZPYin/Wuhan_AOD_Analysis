function [fh, mTime, AQData] = displayAQTimeseries(matFilename, tRange, varargin)
% DISPLAYAQTIMESERIES display timeseries plot of air pollutant.
% USAGE:
%    [fh, mTime, AQData] = displayAQTimeseries(matFilename, tRange)
% INPUTS:
%    matFilename: char
%        absolute path of mat data file.
%    tRange: 2-element array
%        temporal range of data to be exported.
% KEYWORDS:
%    yRange: 2-element array
%        y-axis range.
%    flagCity: logical
%        city flag to determine the type of input site. (default: true)
%    AQType: char
%        air pollutant type. (default: pm10)
%    averageType: char
%        average type. (default: 'raw')
%    imgFile: char
%        absolute path of file to export the figure.
% OUTPUTS:
%    fh: figure handle
%    mTime: array
%        measurement time.
%    AQData: array
%        air pollutant concentration.
% EXAMPLE:
% HISTORY:
%    2021-05-05: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

% set character encoding
slCharacterEncoding('UTF-8');

%% initialization
p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'matFilename', @ischar);
addRequired(p, 'tRange', @isnumeric);
addParameter(p, 'yRange', [0, 200], @isnumeric);
addParameter(p, 'flagCity', true, @islogical);
addParameter(p, 'site', '武汉', @ischar);
addParameter(p, 'AQType', 'pm10', @ischar);
addParameter(p, 'averageType', 'raw', @ischar);
addParameter(p, 'imgFile', '', @ischar);

parse(p, matFilename, tRange, varargin{:});

[mTime, AQData] = extractAQData(matFilename, tRange, p.Results.flagCity, p.Results.site, p.Results.AQType);

%% data visualization
switch lower(p.Results.averageType)
case {'raw'}
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w');

    scatter(mTime, AQData, 5, 'marker', 'o', 'markerfacecolor', [230, 171, 2]/255, 'markeredgecolor', [230, 171, 2]/255); hold on;
    xlim(tRange);
    ylim(p.Results.yRange);

    xlabel('Date');
    ylabel('Concentration (\mug/m^3)');
    title(sprintf('\\fontname{Arial}%s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', linspace(tRange(1), tRange(2), 6), 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

    datetick(gca, 'x', 'mm-dd', 'Keeplimits', 'KeepTicks');
case {'monthly'}
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w');

    scatter(mTimeAvg, AQDataAvg, 5, 'marker', 'o', 'markerfacecolor', [230, 171, 2]/255, 'markeredgecolor', [230, 171, 2]/255); hold on;
    xlim(tRange);
    ylim(p.Results.yRange);

    xlabel('Date');
    ylabel('Concentration (\mug/m^3)');
    title(sprintf('\\fontname{Arial}Monthly %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', linspace(tRange(1), tRange(2), 6), 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

    datetick(gca, 'x', 'mm-dd', 'Keeplimits', 'KeepTicks');
case {'annual'}
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w');

    scatter(mTimeAvg, AQDataAvg, 5, 'marker', 'o', 'markerfacecolor', [230, 171, 2]/255, 'markeredgecolor', [230, 171, 2]/255); hold on;
    xlim(tRange);
    ylim(p.Results.yRange);

    xlabel('Date');
    ylabel('Concentration (\mug/m^3)');
    title(sprintf('\\fontname{Arial}Annual %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', linspace(tRange(1), tRange(2), 6), 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

    datetick(gca, 'x', 'mm-dd', 'Keeplimits', 'KeepTicks');
case {'seasonal'}
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w');

    errorbar(mTimeAvg, AQDataAvg, AQDataStd, 's', 'MarkerFaceColor', [230, 171, 2]/255, 'MarkerEdgeColor', [230, 171, 2]/255);
    xlim(tRange);
    xlim([0.2, 4.8]);

    ylabel('Concentration (\mug/m^3)');
    title(sprintf('\\fontname{Arial}Daily %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', 1:4, 'XTickLabel', {'Spring', 'Summer', 'Autumn', 'Winter'}, 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

case {'diurnal'}
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w');

    errorbar(mTimeAvg, AQDataAvg, AQDataStd, 's', 'MarkerFaceColor', [230, 171, 2]/255, 'MarkerEdgeColor', [230, 171, 2]/255);
    xlim(tRange);
    xlim([0, 24]);

    xlabel('Hour');
    ylabel('Concentration (\mug/m^3)');
    title(sprintf('\\fontname{Arial}Diurnal %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', 0:3:24, 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');
    ax = gca;
    ax.XAxis.MinorTickValues = 1:23;

case {'daily'}
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w');

    scatter(mTimeAvg, AQDataAvg, 5, 'marker', 'o', 'markerfacecolor', [230, 171, 2]/255, 'markeredgecolor', [230, 171, 2]/255); hold on;
    xlim(tRange);
    ylim(p.Results.yRange);

    xlabel('Date');
    ylabel('Concentration (\mug/m^3)');
    title(sprintf('\\fontname{Arial}Daily %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', linspace(tRange(1), tRange(2), 6), 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

    datetick(gca, 'x', 'mm-dd', 'Keeplimits', 'KeepTicks');
otherwise
    error('Unknown averaging requirement: %s', p.Results.averageType);
end

% export figure
if ~ isempty(p.Results.imgFile)
    export_fig(gcf, p.Results.imgFile, '-r300');
end

end