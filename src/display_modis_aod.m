clc; close all;

%% initialization
projectDir = fileparts(fileparts(mfilename('fullpath')));
modis_aod_file = 'Giovanni_MODIS_AOD.mat';
addpath(fullfile(projectDir, 'src', 'export_fig'));

%% load data
load(fullfile(projectDir, 'data', modis_aod_file));

%% data analysis
% Monthly mean
nMonthsTerra = months(TerraTime(1), TerraTime(end), 1);
nMonthsAqua = months(AquaTime(1), AquaTime(end), 1);
TerraMonthlyAOD = NaN(1, nMonthsTerra);
TerraMonthlyTime = NaN(1, nMonthsTerra);
AquaMonthlyAOD = NaN(1, nMonthsAqua);
AquaMonthlyTime = NaN(1, nMonthsAqua);

for iMonth = 1:nMonthsTerra
    [thisYear, thisMonth, thisDay] = datevec(TerraTime(1));
    TerraMonthlyTime(iMonth) = datenum(thisYear, thisMonth + iMonth, thisDay) - datenum(0, 0, 15);   % Move the time to the mid of the current month
    flagInMonth = (TerraTime < datenum(thisYear, thisMonth + iMonth, thisDay)) & (TerraTime >= datenum(thisYear, thisMonth + iMonth - 1, thisDay));
    TerraMonthlyAOD(iMonth) = nanmean(TerraAOD(flagInMonth));
end

for iMonth = 1:nMonthsAqua
    [thisYear, thisMonth, thisDay] = datevec(AquaTime(1));
    AquaMonthlyTime(iMonth) = datenum(thisYear, thisMonth + iMonth, thisDay) - datenum(0, 0, 15);   % Move the time to the mid of the current month
    flagInMonth = (AquaTime < datenum(thisYear, thisMonth + iMonth, thisDay)) & (AquaTime >= datenum(thisYear, thisMonth + iMonth - 1, thisDay));
    AquaMonthlyAOD(iMonth) = nanmean(AquaAOD(flagInMonth));
end

% Yearly mean
nYearsTerra = 2019 - 2002 + 1;
nYearsAqua = 2019 -2002 + 1;
TerraYearlyAOD = NaN(1, nYearsTerra);
TerraYearlyAODStd = NaN(1, nYearsTerra);
TerraYearlyTime = NaN(1, nYearsTerra);
AquaYearlyAOD = NaN(1, nYearsAqua);
AquaYearlyAODStd = NaN(1, nYearsAqua);
AquaYearlyTime = NaN(1, nYearsAqua);

for iYear = 1:nYearsTerra
    [thisYear, thisMonth, thisDay] = datevec(TerraTime(1));
    TerraYearlyTime(iYear) = datenum(thisYear + iYear - 1, 7, 1);   % Move the time to the mid of the current month
    flagInYear = (TerraTime < datenum(thisYear + iYear, thisMonth, thisDay)) & (TerraTime >= datenum(thisYear + iYear - 1, thisMonth, thisDay));
    TerraYearlyAOD(iYear) = nanmean(TerraAOD(flagInYear));
    TerraYearlyAODStd(iYear) = nanstd(TerraAOD(flagInYear));
end

for iYear = 1:nYearsAqua
    [thisYear, thisMonth, thisDay] = datevec(AquaTime(1));
    AquaYearlyTime(iYear) = datenum(thisYear + iYear - 1, 7, 1);   % Move the time to the mid of the current month
    flagInYear = (AquaTime < datenum(thisYear + iYear, thisMonth, thisDay)) & (AquaTime >= datenum(thisYear + iYear - 1, thisMonth, thisDay));
    AquaYearlyAOD(iYear) = nanmean(AquaAOD(flagInYear));
    AquaYearlyAODStd(iYear) = nanstd(AquaAOD(flagInYear));
end

% mean AOD before 2011-07-01
flagBefore2011 = (TerraYearlyTime <= datenum(2011, 7, 1));
TerraMeanAODBefore2011 = nanmean(TerraYearlyAOD(flagBefore2011));
flagBefore2011 = (AquaYearlyTime <= datenum(2011, 7, 1));
AquaMeanAODBefore2011 = nanmean(AquaYearlyAOD(flagBefore2011));

meanAODBefore2011 = nanmean([TerraMeanAODBefore2011, AquaMeanAODBefore2011]);
stdAODBefore2011 = nanstd(nanmean([TerraYearlyAOD(flagBefore2011); AquaYearlyAOD(flagBefore2011)], 1));

% linear regression for AOD after 2011-07-01
flagAfter2011 = (TerraYearlyTime >= datenum(2011, 7, 1));
TerraMeanAODAfter2011 = TerraYearlyAOD(flagAfter2011);
flagAfter2011 = (AquaYearlyTime >= datenum(2011, 7, 1));
AquaMeanAODAfter2011 = AquaYearlyAOD(flagAfter2011);

meanAODAfter2011 = nanmean([TerraMeanAODAfter2011; AquaMeanAODAfter2011], 1);
meanAODTimeAfter2011 = AquaYearlyTime(flagAfter2011);

[slope, offset, slopeStd, offsetStd] = linfit(meanAODTimeAfter2011', meanAODAfter2011');

%% data visualization
figure('Position', [0, 20, 750, 400], 'Units', 'Pixels');

p1 = scatter(TerraTime, TerraAOD, 3, 'Marker', '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'MarkerEdgeAlpha', 0.3, 'MarkerFaceAlpha', 0.3, 'DisplayName', 'Terra Daily Mean'); hold on;
p2 = scatter(AquaTime, AquaAOD, 3, 'Marker', 's', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'MarkerEdgeAlpha', 0.3, 'MarkerFaceAlpha', 0.3, 'DisplayName', 'Aqua Daily Mean'); hold on;
p3 = plot(TerraYearlyTime, TerraYearlyAOD, '-r', 'Marker', '^', 'MarkerSize', 6, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'LineWidth', 3, 'DisplayName', 'Terra Yearly Mean');
e1 = errorbar(TerraYearlyTime, TerraYearlyAOD, TerraYearlyAODStd, 'LineStyle', 'None', 'LineWidth', 1, 'Color', 'r');
p4 = plot(AquaYearlyTime, AquaYearlyAOD, '-b', 'Marker', 's', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'LineWidth', 3, 'DisplayName', 'Aqua Yearly Mean');
e2 = errorbar(AquaYearlyTime, AquaYearlyAOD, AquaYearlyAODStd, 'LineStyle', 'None', 'LineWidth', 1, 'Color', 'b');

l = plot([datenum(2011, 7, 1), datenum(2011, 7, 1)], [0, 10], '--k', 'LineWidth', 3);
l.Color(4) = 0.7;

l1 = plot([TerraTime(1), datenum(2011, 7, 1)], [mean([TerraMeanAODBefore2011, AquaMeanAODBefore2011]), mean([TerraMeanAODBefore2011, AquaMeanAODBefore2011])], '-g', 'LineWidth', 5);
l1.Color(4) = 0.75;

t1 = text(datenum(2004, 1, 1), 1.7, sprintf('Polluted period: AOD=%4.2f\\pm%4.2f', meanAODBefore2011, stdAODBefore2011), 'FontWeight', 'Bold', 'Interpreter', 'tex');

l2 = plot(meanAODTimeAfter2011, offset + slope * meanAODTimeAfter2011, '-g', 'LineWidth', 5);
l2.Color(4) = 0.75;
t2 = text(datenum(2012, 1, 1), 1.3, sprintf('Cleansing period: %4.2f\\pm%4.2f Yr^{-1}', slope * 365, slopeStd * 365), 'FontWeight', 'Bold', 'Interpreter', 'tex');

% rectangle
r = rectangle('Position', [datenum(2001, 10, 1),  0, (datenum(2019, 3, 1) - datenum(2001, 10, 1)), 0.2], 'FaceColor', [166, 130, 31]/255, 'EdgeColor', [166, 130, 31]/255,...
          'LineWidth', 3);
r.FaceColor(4) = 0.5;
t3 = text(datenum(2008, 1, 1), 0.1, sprintf('AOD level in Tibetan Plateau'), 'Color', [150, 112, 6]/255, 'FontWeight', 'Bold', 'Interpreter', 'tex');

xlim([datenum(2002, 1, 1), datenum(2019, 1, 1)]);
ylim([0, 2]);

xlabel('Date (yyyy)');
ylabel('AOD at 550 nm');
title('AOD trend from 2002-2018 at Wuhan');

set(gca, 'XTick', datenum(2002:2:2019, 1, 1), ...
'YMinorTick', 'On', ...
'Box', 'on', 'LineWidth', 1.5)

datetick(gca, 'x', 'yyyy', 'Keepticks', 'keeplimits');
xlim([datenum(2001, 10, 1), datenum(2019, 3, 1)]);

legend([p1, p3, p2, p4], 'Location', 'NorthEast');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
set(findall(gcf, '-Property', 'FontSize'), 'FontSize', 12);

export_fig(gcf, fullfile(projectDir, 'img', 'MODIS_AOD_2002-2018.png'), '-r300');