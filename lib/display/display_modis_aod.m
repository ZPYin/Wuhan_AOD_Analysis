function [fh] = display_modis_aod(modis_aod_file, varargin)
% DISPLAY_MODIS_AOD description
%
% USAGE:
%    [fh] = display_modis_aod(modis_aod_file, imgFile)
%
% INPUTS:
%    modis_aod_file, imgFile
%
% OUTPUTS:
%    fh
%
% EXAMPLE:
%
% HISTORY:
%    2023-12-27: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'modis_aod_file', @ischar);
addParameter(p, 'visible', 'on', @ischar);
addParameter(p, 'xlim', [], @isnumeric);
addParameter(p, 'linePos', datenum(2011, 7, 1), @isnumeric);
addParameter(p, 'imageFile', '', @ischar);

parse(p, modis_aod_file, varargin{:});

%% load data
modisAOD = load(modis_aod_file);

if isempty(p.Results.xlim)
    xRange = [min(modisAOD.TerraTime, modisAOD.AquaTime), max([modisAOD.TerraTime, modisAOD.AquaTime])];
else
    xRange = p.Results.xlim;
end

%% data analysis
% Monthly mean
nMonthsTerra = months(modisAOD.TerraTime(1), modisAOD.TerraTime(end), 1);
nMonthsAqua = months(modisAOD.AquaTime(1), modisAOD.AquaTime(end), 1);
TerraMonthlyAOD = NaN(1, nMonthsTerra);
TerraMonthlyTime = NaN(1, nMonthsTerra);
AquaMonthlyAOD = NaN(1, nMonthsAqua);
AquaMonthlyTime = NaN(1, nMonthsAqua);

for iMonth = 1:nMonthsTerra
    [thisYear, thisMonth, thisDay] = datevec(modisAOD.TerraTime(1));
    TerraMonthlyTime(iMonth) = datenum(thisYear, thisMonth + iMonth, thisDay) - datenum(0, 0, 15);   % Move the time to the mid of the current month
    flagInMonth = (modisAOD.TerraTime < datenum(thisYear, thisMonth + iMonth, thisDay)) & (modisAOD.TerraTime >= datenum(thisYear, thisMonth + iMonth - 1, thisDay));
    TerraMonthlyAOD(iMonth) = nanmean(modisAOD.TerraAOD(flagInMonth));
end

for iMonth = 1:nMonthsAqua
    [thisYear, thisMonth, thisDay] = datevec(modisAOD.AquaTime(1));
    AquaMonthlyTime(iMonth) = datenum(thisYear, thisMonth + iMonth, thisDay) - datenum(0, 0, 15);   % Move the time to the mid of the current month
    flagInMonth = (modisAOD.AquaTime < datenum(thisYear, thisMonth + iMonth, thisDay)) & (modisAOD.AquaTime >= datenum(thisYear, thisMonth + iMonth - 1, thisDay));
    AquaMonthlyAOD(iMonth) = nanmean(modisAOD.AquaAOD(flagInMonth));
end

% Yearly mean
[endYear, ~, ~] = datevec(max([modisAOD.AquaTime, modisAOD.TerraTime]));
[startYear, ~, ~] = datevec(min([modisAOD.AquaTime, modisAOD.TerraTime]));
nYearsTerra = endYear - startYear + 1;
nYearsAqua = endYear -startYear + 1;
TerraYearlyAOD = NaN(1, nYearsTerra);
TerraYearlyAODStd = NaN(1, nYearsTerra);
TerraYearlyTime = NaN(1, nYearsTerra);
AquaYearlyAOD = NaN(1, nYearsAqua);
AquaYearlyAODStd = NaN(1, nYearsAqua);
AquaYearlyTime = NaN(1, nYearsAqua);

for iYear = 1:nYearsTerra
    [thisYear, thisMonth, thisDay] = datevec(modisAOD.TerraTime(1));
    TerraYearlyTime(iYear) = datenum(thisYear + iYear - 1, 7, 1);   % Move the time to the mid of the current month
    flagInYear = (modisAOD.TerraTime < datenum(thisYear + iYear, thisMonth, thisDay)) & (modisAOD.TerraTime >= datenum(thisYear + iYear - 1, thisMonth, thisDay));
    TerraYearlyAOD(iYear) = nanmean(modisAOD.TerraAOD(flagInYear));
    TerraYearlyAODStd(iYear) = nanstd(modisAOD.TerraAOD(flagInYear));
end

for iYear = 1:nYearsAqua
    [thisYear, thisMonth, thisDay] = datevec(modisAOD.AquaTime(1));
    AquaYearlyTime(iYear) = datenum(thisYear + iYear - 1, 7, 1);   % Move the time to the mid of the current month
    flagInYear = (modisAOD.AquaTime < datenum(thisYear + iYear, thisMonth, thisDay)) & (modisAOD.AquaTime >= datenum(thisYear + iYear - 1, thisMonth, thisDay));
    AquaYearlyAOD(iYear) = nanmean(modisAOD.AquaAOD(flagInYear));
    AquaYearlyAODStd(iYear) = nanstd(modisAOD.AquaAOD(flagInYear));
end

% mean AOD before 2011-07-01
flagBefore2011 = (TerraYearlyTime <= p.Results.linePos);
TerraMeanAODBefore2011 = nanmean(TerraYearlyAOD(flagBefore2011));
flagBefore2011 = (AquaYearlyTime <= p.Results.linePos);
AquaMeanAODBefore2011 = nanmean(AquaYearlyAOD(flagBefore2011));

meanAODBefore2011 = nanmean([TerraMeanAODBefore2011, AquaMeanAODBefore2011]);
stdAODBefore2011 = nanstd(nanmean([TerraYearlyAOD(flagBefore2011); AquaYearlyAOD(flagBefore2011)], 1));

% linear regression for AOD after 2011-07-01
flagAfter2011 = (TerraYearlyTime >= p.Results.linePos);
TerraMeanAODAfter2011 = TerraYearlyAOD(flagAfter2011);
flagAfter2011 = (AquaYearlyTime >= p.Results.linePos);
AquaMeanAODAfter2011 = AquaYearlyAOD(flagAfter2011);

meanAODAfter2011 = nanmean([TerraMeanAODAfter2011; AquaMeanAODAfter2011], 1);
meanAODTimeAfter2011 = AquaYearlyTime(flagAfter2011);

[slope, offset, slopeStd, ~] = linfit(meanAODTimeAfter2011', meanAODAfter2011');

%% data visualization
figure('Position', [0, 20, 750, 400], 'Units', 'Pixels', 'Color', 'w', 'visible', p.Results.visible);

p1 = scatter(modisAOD.TerraTime, modisAOD.TerraAOD, 3, 'Marker', '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'MarkerEdgeAlpha', 0.3, 'MarkerFaceAlpha', 0.3, 'DisplayName', 'Terra Daily Mean'); hold on;
p2 = scatter(modisAOD.AquaTime, modisAOD.AquaAOD, 3, 'Marker', 's', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'MarkerEdgeAlpha', 0.3, 'MarkerFaceAlpha', 0.3, 'DisplayName', 'Aqua Daily Mean'); hold on;
p3 = plot(TerraYearlyTime, TerraYearlyAOD, '-r', 'Marker', '^', 'MarkerSize', 6, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'LineWidth', 3, 'DisplayName', 'Terra Yearly Mean');
errorbar(TerraYearlyTime, TerraYearlyAOD, TerraYearlyAODStd, 'LineStyle', 'None', 'LineWidth', 1, 'Color', 'r');
p4 = plot(AquaYearlyTime, AquaYearlyAOD, '-b', 'Marker', 's', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'LineWidth', 3, 'DisplayName', 'Aqua Yearly Mean');
errorbar(AquaYearlyTime, AquaYearlyAOD, AquaYearlyAODStd, 'LineStyle', 'None', 'LineWidth', 1, 'Color', 'b');

if ~ isempty(p.Results.linePos)
    l = plot([p.Results.linePos, p.Results.linePos], [0, 10], '--k', 'LineWidth', 3);
    l.Color(4) = 0.7;
end

l1 = plot([modisAOD.TerraTime(1), p.Results.linePos], [mean([TerraMeanAODBefore2011, AquaMeanAODBefore2011]), mean([TerraMeanAODBefore2011, AquaMeanAODBefore2011])], '-g', 'LineWidth', 5);
l1.Color(4) = 0.75;

text(0.03, 0.8, sprintf('Polluted: AOD=%4.2f\\pm%4.2f', meanAODBefore2011, stdAODBefore2011), 'FontWeight', 'Bold', 'Interpreter', 'tex', 'Units', 'Normalized');

l2 = plot(meanAODTimeAfter2011, offset + slope * meanAODTimeAfter2011, '-g', 'LineWidth', 5);
l2.Color(4) = 0.75;
text(0.6, 0.6, sprintf('Cleansing: %4.2f\\pm%4.2f Yr^{-1}', slope * 365, slopeStd * 365), 'FontWeight', 'Bold', 'Interpreter', 'tex', 'Units', 'Normalized');

% rectangle
r = rectangle('Position', [xRange(1),  0, (xRange(2) - xRange(1)), 0.2], 'FaceColor', [166, 130, 31]/255, 'EdgeColor', [166, 130, 31]/255,...
          'LineWidth', 3);
r.FaceColor(4) = 0.1;
text(mean(xRange), 0.1, sprintf('AOD level in Tibetan Plateau'), 'Color', [150, 112, 6]/255, 'FontWeight', 'Bold', 'Interpreter', 'tex', 'HorizontalALignment', 'center');

xlim(xRange);
ylim([0, 2]);

xlabel('Date (yyyy)');
ylabel('AOD at 550 nm');
title(sprintf('AOD trend from %04d-%-04d at Wuhan', startYear, endYear));

set(gca, 'XTick', datenum(startYear:2:endYear, 1, 1), ...
    'YMinorTick', 'On', ...
    'Box', 'on', 'LineWidth', 1.5)

datetick(gca, 'x', 'yyyy', 'Keepticks', 'keeplimits');
xlim([xRange(1), xRange(2)]);

legend([p1, p3, p2, p4], 'Location', 'NorthEast');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
set(findall(gcf, '-Property', 'FontSize'), 'FontSize', 12);

if ~ isempty(p.Results.imageFile)
    export_fig(gcf, p.Results.imageFile, '-r300');
end

end