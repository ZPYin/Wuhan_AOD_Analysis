function [fh, mTimeAvg, AQDataAvg] = displayAQTimeseries(matFilename, tRange, varargin)
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
%    ylabel: char
%        label of y-axis (default: 'Concentration (\mug/m^3)').
%    flagCity: logical
%        city flag to determine the type of input site. (default: true)
%    site: char
%        site (default: '武汉').
%    AQType: char
%        air pollutant type. (default: pm10)
%    averageType: char
%        average type. (default: 'raw')
%        'raw': raw data points
%        'monthly': monthly means
%        'annual': annual means
%        'seansonal': seansonal means
%        'diurnal': diurnal variations
%        'daily': daily means
%        'AQI-Pie': pie plot of AQI
%    imgFile: char
%        absolute path of file to export the figure.
%    visible: char
%        figure visibility, specified as 'on' (default) or 'off'. 
%    outputDataFile: char
%        absolute path of file to export the data. (default: '')
% OUTPUTS:
%    fh: figure handle
%    mTimeAvg: array
%        measurement time for each data point.
%    AQDataAvg: array
%        air pollutant concentration after averaging.
% EXAMPLE:
% HISTORY:
%    2021-05-05: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

%% initialization
p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'matFilename', @ischar);
addRequired(p, 'tRange', @isnumeric);
addParameter(p, 'yRange', [0, 200], @isnumeric);
addParameter(p, 'ylabel', 'Concentration (\mug/m^3)', @ischar);
addParameter(p, 'flagCity', true, @islogical);
addParameter(p, 'site', '武汉', @ischar);
addParameter(p, 'AQType', 'pm10', @ischar);
addParameter(p, 'averageType', 'raw', @ischar);
addParameter(p, 'imgFile', '', @ischar);
addParameter(p, 'visible', 'on', @ischar);
addParameter(p, 'outputDataFile', '', @ischar);

parse(p, matFilename, tRange, varargin{:});

[mTime, AQData] = extractAQData(matFilename, tRange, p.Results.flagCity, p.Results.site, p.Results.AQType);

%% data visualization
switch lower(p.Results.averageType)
case {'raw'}

    % raw data points
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w', 'visible', p.Results.visible);

    mTimeAvg = mTime;
    AQDataAvg = AQData;
    AQDataStd = zeros(size(AQDataAvg));
    scatter(mTimeAvg, AQDataAvg, 5, 'marker', 'o', 'markerfacecolor', [230, 171, 2]/255, 'markeredgecolor', [230, 171, 2]/255); hold on;
    xlim(tRange);
    ylim(p.Results.yRange);

    xlabel('Date');
    ylabel(p.Results.ylabel);
    title(sprintf('\\fontname{Arial}%s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', linspace(tRange(1), tRange(2), 6), 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

    datetick(gca, 'x', 'mm-dd', 'Keeplimits', 'KeepTicks');

    % export data
    if ~ isempty(p.Results.outputDataFile)
        fid = fopen(p.Results.outputDataFile, 'w');
        fprintf(fid, '%s %s at %s\n', p.Results.averageType, p.Results.AQType, p.Results.site);
        fprintf(fid, 'Date Time Concentration/AQI\n');

        for iRow = 1:length(mTimeAvg)
            fprintf(fid, '%s %f\n', datestr(mTimeAvg(iRow), 'yyyy-mm-dd HH:MM:SS'), AQDataAvg(iRow));
        end

        fclose(fid);
    end

case {'monthly'}

    % monthly mean
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w', 'visible', p.Results.visible);

    scatter(mTimeAvg, AQDataAvg, 5, 'marker', 'o', 'markerfacecolor', [230, 171, 2]/255, 'markeredgecolor', [230, 171, 2]/255); hold on;
    xlim(tRange);
    ylim(p.Results.yRange);

    xlabel('Date');
    ylabel(p.Results.ylabel);
    title(sprintf('\\fontname{Arial}Monthly %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', linspace(tRange(1), tRange(2), 6), 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

    datetick(gca, 'x', 'mm-dd', 'Keeplimits', 'KeepTicks');

    % export data
    if ~ isempty(p.Results.outputDataFile)
        fid = fopen(p.Results.outputDataFile, 'w');
        fprintf(fid, '%s %s at %s\n', p.Results.averageType, p.Results.AQType, p.Results.site);
        fprintf(fid, 'Date Time Concentration/AQI\n');

        for iRow = 1:length(mTimeAvg)
            fprintf(fid, '%s %f\n', datestr(mTimeAvg(iRow), 'yyyy-mm-dd HH:MM:SS'), AQDataAvg(iRow));
        end

        fclose(fid);
    end

case {'annual'}

    % annual mean
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w', 'visible', p.Results.visible);

    scatter(mTimeAvg, AQDataAvg, 5, 'marker', 'o', 'markerfacecolor', [230, 171, 2]/255, 'markeredgecolor', [230, 171, 2]/255); hold on;
    xlim(tRange);
    ylim(p.Results.yRange);

    xlabel('Date');
    ylabel(p.Results.ylabel);
    title(sprintf('\\fontname{Arial}Annual %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', linspace(tRange(1), tRange(2), 6), 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

    datetick(gca, 'x', 'mm-dd', 'Keeplimits', 'KeepTicks');

    % export data
    if ~ isempty(p.Results.outputDataFile)
        fid = fopen(p.Results.outputDataFile, 'w');
        fprintf(fid, '%s %s at %s\n', p.Results.averageType, p.Results.AQType, p.Results.site);
        fprintf(fid, 'Date Time Concentration/AQI\n');

        for iRow = 1:length(mTimeAvg)
            fprintf(fid, '%s %f\n', datestr(mTimeAvg(iRow), 'yyyy-mm-dd HH:MM:SS'), AQDataAvg(iRow));
        end

        fclose(fid);
    end

case {'season', 'seasonal'}

    % seasonal mean
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    tickLabels = {'Spring', 'Summer', 'Autumn', 'Winter'};
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w', 'visible', p.Results.visible);

    errorbar(mTimeAvg, AQDataAvg, AQDataStd, 's', 'MarkerFaceColor', [230, 171, 2]/255, 'MarkerEdgeColor', [230, 171, 2]/255);
    xlim(tRange);
    xlim([0.2, 4.8]);

    ylabel(p.Results.ylabel);
    title(sprintf('\\fontname{Arial}Daily %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', 1:4, 'XTickLabel', tickLabels, 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

    % export data
    if ~ isempty(p.Results.outputDataFile)
        fid = fopen(p.Results.outputDataFile, 'w');
        fprintf(fid, '%s %s at %s\n', p.Results.averageType, p.Results.AQType, p.Results.site);
        fprintf(fid, 'Season Concentration/AQI\n');

        for iRow = 1:length(mTimeAvg)
            fprintf(fid, '%s %f\n', tickLabels{mTimeAvg(iRow)}, AQDataAvg(iRow));
        end

        fclose(fid);
    end

case {'diurnal'}

    % diurnal variations
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w', 'visible', p.Results.visible);

    errorbar(mTimeAvg, AQDataAvg, AQDataStd, 's', 'MarkerFaceColor', [230, 171, 2]/255, 'MarkerEdgeColor', [230, 171, 2]/255);
    xlim(tRange);
    xlim([0, 24]);

    xlabel('Hour');
    ylabel(p.Results.ylabel);
    title(sprintf('\\fontname{Arial}Diurnal %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', 0:3:24, 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');
    ax = gca;
    ax.XAxis.MinorTickValues = 1:23;

    % export data
    if ~ isempty(p.Results.outputDataFile)
        fid = fopen(p.Results.outputDataFile, 'w');
        fprintf(fid, '%s %s at %s\n', p.Results.averageType, p.Results.AQType, p.Results.site);
        fprintf(fid, 'Hour Concentration/AQI\n');

        for iRow = 1:length(mTimeAvg)
            fprintf(fid, '%s %f\n', datestr(mTimeAvg(iRow), 'yyyy-mm-dd HH:MM:SS'), AQDataAvg(iRow));
        end

        fclose(fid);
    end

case {'daily'}

    % daily mean
    [mTimeAvg, AQDataAvg, AQDataStd] = averaging(mTime, AQData, 'type', p.Results.averageType);
    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w', 'visible', p.Results.visible);

    scatter(mTimeAvg, AQDataAvg, 5, 'marker', 'o', 'markerfacecolor', [230, 171, 2]/255, 'markeredgecolor', [230, 171, 2]/255); hold on;
    xlim(tRange);
    ylim(p.Results.yRange);

    xlabel('Date');
    ylabel(p.Results.ylabel);
    title(sprintf('\\fontname{Arial}Daily %s concentration at \\fontname{Kaiti}%s', p.Results.AQType, p.Results.site));

    set(gca, 'XTick', linspace(tRange(1), tRange(2), 6), 'XMinorTick', 'off', 'YTick', linspace(p.Results.yRange(1), p.Results.yRange(2), 5), 'YMinorTick', 'on', 'Box', 'on', 'linewidth', 2, 'Layer', 'top');

    datetick(gca, 'x', 'mm-dd', 'Keeplimits', 'KeepTicks');

    % export data
    if ~ isempty(p.Results.outputDataFile)
        fid = fopen(p.Results.outputDataFile, 'w');
        fprintf(fid, '%s %s at %s\n', p.Results.averageType, p.Results.AQType, p.Results.site);
        fprintf(fid, 'Date Time Concentration/AQI\n');

        for iRow = 1:length(mTimeAvg)
            fprintf(fid, '%s %f\n', datestr(mTimeAvg(iRow), 'yyyy-mm-dd HH:MM:SS'), AQDataAvg(iRow));
        end

        fclose(fid);
    end

case {'aqi-pie'}

    if ~ strcmpi(p.Results.AQType, 'aqi')
        error('Wrong keyword input for AQType. Only ''AQI'' was expected');
    end

    % pie plot of AQI
    AQILevel = [0, 51, 101, 151, 201, 301];   % 参考我国标准：https://web.archive.org/web/20190713234941/http://kjs.mee.gov.cn/hjbhbz/bzwb/jcffbz/201203/W020120410332725219541.pdf
    AQILevel_label = {'优', '良', '轻度污染', '中度污染', '重度污染', '严重污染'};   % 每个AQI区间段对应的健康等级
    AQILevel_color = [[0, 228, 0]/255;
                        [255, 255, 0]/255;
                        [255, 126, 0]/255;
                        [255, 0, 0]/255;
                        [153, 0, 76]/255;
                        [126, 0, 35]/255];
    AQILevelCounts = histc(AQData, AQILevel);
    mTimeAvg = AQILevel_label;
    AQDataAvg = AQILevelCounts;
    AQDataStd = zeros(size(mTimeAvg));
    flagNonZero = abs(AQILevelCounts) > 1e-5;

    fh = figure('Position', [0, 20, 500, 300], 'Units', 'Pixels', 'Color', 'w', 'visible', p.Results.visible);
    subplot('Position', [0, 0.1, 0.7, 0.7], 'Units', 'Normalized');
    pie(AQILevelCounts(flagNonZero));

    title(sprintf('\\fontname{Arial}Percentage of AQIs at \\fontname{Kaiti}%s', p.Results.site));
    colormap(gca, AQILevel_color(flagNonZero, :));

    ax1 = subplot('Position', [-10, -10, 1, 1], 'Units', 'Normalized');
    pie(ax1, ones(1, length(AQILevel_label)));
    colormap(ax1, AQILevel_color);
    legend(AQILevel_label, 'Position', [0.6, 0.2, 0.3, 0.4], 'Orientation', 'Vertical', 'Units', 'Normalized', 'FontWeight', 'Bold');

    % export data
    if ~ isempty(p.Results.outputDataFile)
        fid = fopen(p.Results.outputDataFile, 'w');
        fprintf(fid, '%s %s at %s\n', p.Results.averageType, p.Results.AQType, p.Results.site);
        fprintf(fid, 'AQI-Label Counts\n');

        for iRow = 1:length(mTimeAvg)
            fprintf(fid, '%s %f\n', AQILevel_label{iRow}, AQDataAvg(iRow));
        end

        fclose(fid);
    end

otherwise
    error('Unknown averaging requirement: %s', p.Results.averageType);
end

% export figure
if ~ isempty(p.Results.imgFile)
    export_fig(gcf, p.Results.imgFile, '-r300');
end

end