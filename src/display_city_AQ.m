clc; close all;
projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectDir, 'include', 'export_fig'));
addpath(fullfile(projectDir, 'include'));

%% set character encoding
currentCharacterEncoding = slCharacterEncoding();
slCharacterEncoding('UTF-8');

%% initialization
matFile = 'wuhan_air_quality_data.mat';
tRange = [datenum(2014, 2, 1), datenum(2019, 12, 30)];

%% load data
load(fullfile(projectDir, 'data', matFile));

%% data analysis
time = city_AQ_data.time;
AQI = city_AQ_data.AQI;
SO2 = city_AQ_data.SO2;
PM2p5 = city_AQ_data.PM2p5;
PM10 = city_AQ_data.PM10;
NO2 = city_AQ_data.NO2;
O3 = city_AQ_data.O3;
CO = city_AQ_data.CO;

% generate datenum array with interval of 2 months
dates6Months = [];
nMonths = months(time(1), time(end)) + 4;
[thisYear, ~, ~] = datevec(time(1));
for iMonth = 1:1:(nMonths/4)
    if datenum(thisYear, 1 + (iMonth - 1) * 6, 1) <= time(end)
        dates6Months = [dates6Months, datenum(thisYear, 1 + (iMonth - 1) * 6, 1)];
    end
end

% diurnal trend
diurnalTime = datenum(0, 1, 0, 0:23, 30, 0);
diurnalDataMean = NaN(7, length(diurnalTime));
diurnalDataStd = NaN(7, length(diurnalTime));
for iTime = 1:length(diurnalTime)
    flag = (mod(time, 1) >= (diurnalTime(iTime) - datenum(0, 1, 0, 0, 60, 0))) & (mod(time, 1) < diurnalTime(iTime));
    diurnalDataMean(:, iTime) = [nanmean(AQI(flag)); ...
                             nanmean(SO2(flag)); ...
                             nanmean(PM2p5(flag)); ...
                             nanmean(PM10(flag)); ...
                             nanmean(NO2(flag)); ...
                             nanmean(O3(flag)); ...
                             nanmean(CO(flag))];
    diurnalDataStd(:, iTime) = [nanstd(AQI(flag)); ...
                                nanstd(SO2(flag)); ...
                                nanstd(PM2p5(flag)); ...
                                nanstd(PM10(flag)); ...
                                nanstd(NO2(flag)); ...
                                nanstd(O3(flag)); ...
                                nanstd(CO(flag))];
end

% seasonal trend
seasonalTime = 1:4;   % [MAM, JJA, SON, DJF]
seasonalMonths = [3, 4, 5; 6, 7, 8; 9, 10, 11; 12, 1, 2];   % 4 * 3
seasonalDataMean = NaN(7, 4);
seasonalDataStd = NaN(7, 4);
for iSeason = 1:length(seasonalTime)
    [~, monthList, ~] = datevec(time);
    flag = (monthList == seasonalMonths(iSeason, 1)) | (monthList == seasonalMonths(iSeason, 2)) | (monthList == seasonalMonths(iSeason, 3));
    seasonalDataMean(:, iSeason) = [nanmean(AQI(flag)); ...
                                nanmean(SO2(flag)); ...
                                nanmean(PM2p5(flag)); ...
                                nanmean(PM10(flag)); ...
                                nanmean(NO2(flag)); ...
                                nanmean(O3(flag)); ...
                                nanmean(CO(flag))];
    seasonalDataStd(:, iSeason) = [nanstd(AQI(flag)); ...
                                nanstd(SO2(flag)); ...
                                nanstd(PM2p5(flag)); ...
                                nanstd(PM10(flag)); ...
                                nanstd(NO2(flag)); ...
                                nanstd(O3(flag)); ...
                                nanstd(CO(flag))];
end

% yearly trend
yearlyTime = datenum(2015:2019, 7, 1);
yearlyDataMean = NaN(7, length(yearlyTime));
yearlyDataStd = NaN(7, length(yearlyTime));
for iYear = 1:length(yearlyTime)
    [yearList, ~, ~] = datevec(time);
    [thisYear, ~, ~] = datevec(yearlyTime(iYear));
    flag = (yearList == thisYear);
    yearlyDataMean(:, iYear) = [nanmean(AQI(flag)); ...
                                nanmean(SO2(flag)); ...
                                nanmean(PM2p5(flag)); ...
                                nanmean(PM10(flag)); ...
                                nanmean(NO2(flag)); ...
                                nanmean(O3(flag)); ...
                                nanmean(CO(flag))];
    yearlyDataStd(:, iYear) = [nanstd(AQI(flag)); ...
                                nanstd(SO2(flag)); ...
                                nanstd(PM2p5(flag)); ...
                                nanstd(PM10(flag)); ...
                                nanstd(NO2(flag)); ...
                                nanstd(O3(flag)); ...
                                nanstd(CO(flag))];
end

% seasonal-diurnal variations
diurnalTime = datenum(0, 1, 0, 0:23, 30, 0);
seasonalMonths = [3, 4, 5; 6, 7, 8; 9, 10, 11; 12, 1, 2];   % 4 * 3
seasonalDiurnalDataMean = NaN(7, 4, length(diurnalTime));
seasonalDiurnalDataStd = NaN(7, 4, length(diurnalTime));
for iTime = 1:length(diurnalTime)
    for iSeason = 1:length(seasonalMonths)
        flagTime = (mod(time, 1) >= (diurnalTime(iTime) - datenum(0, 1, 0, 0, 60, 0))) & (mod(time, 1) < diurnalTime(iTime));
        [~, monthList, ~] = datevec(time);
        flagSeason = (monthList == seasonalMonths(iSeason, 1)) | (monthList == seasonalMonths(iSeason, 2)) | (monthList == seasonalMonths(iSeason, 3));
        seasonalDiurnalDataMean(:, iSeason, iTime) = [nanmean(AQI(flagTime & flagSeason)); ...
                                nanmean(SO2(flagTime & flagSeason)); ...
                                nanmean(PM2p5(flagTime & flagSeason)); ...
                                nanmean(PM10(flagTime & flagSeason)); ...
                                nanmean(NO2(flagTime & flagSeason)); ...
                                nanmean(O3(flagTime & flagSeason)); ...
                                nanmean(CO(flagTime & flagSeason))];
        seasonalDiurnalDataStd(:, iSeason, iTime) = [nanstd(AQI(flagTime & flagSeason)); ...
                                    nanstd(SO2(flagTime & flagSeason)); ...
                                    nanstd(PM2p5(flagTime & flagSeason)); ...
                                    nanstd(PM10(flagTime & flagSeason)); ...
                                    nanstd(NO2(flagTime & flagSeason)); ...
                                    nanstd(O3(flagTime & flagSeason)); ...
                                    nanstd(CO(flagTime & flagSeason))];
    end
end

%% data visualization 

% stations map (by jupyter)

%% time series of different components
figure('Position', [0, 20, 700, 600], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 3, 2);

% left-top (PM2.5 PM10)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
s1 = scatter(time, PM2p5, 3, 'Marker', 's', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'DisplayName', 'PM2.5'); hold on;
s2 = scatter(time, PM10', 1, 'Marker', 'o', 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'DisplayName', 'PM10'); hold on;

xlim();
ylim([0, 400]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', dates6Months, 'YTick', 100:100:300, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy-mm', 'keepticks', 'keeplimits');
xlim();

legend([s1, s2], 'Location', 'NorthEast');

% right-top (AQI)
subplot('Position', figPos(2, :), 'Units', 'Normalized');
s1 = scatter(time, AQI, 2.5, 'Marker', 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'DisplayName', 'AQI'); hold on;

xlim();
ylim([0, 300]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI');
ylim([0, 300]);

set(gca, 'XTick', dates6Months, 'YTick', 50:50:250, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy-mm', 'keepticks', 'keeplimits');
xlim();

legend([s1], 'Location', 'NorthEast');

% mid-left (SO2)
subplot('Position', figPos(3, :), 'Units', 'Normalized');
s1 = scatter(time, SO2, 3, 'Marker', 's', 'MarkerEdgeColor', 'y', 'MarkerFaceColor', 'y', 'DisplayName', 'SO2'); hold on;

xlim();
ylim([0, 400]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', dates6Months, 'YTick', 100:100:300, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy-mm', 'keepticks', 'keeplimits');
xlim();

legend([s1], 'Location', 'NorthEast');

% mid-right (NO2)
subplot('Position', figPos(4, :), 'Units', 'Normalized');
s1 = scatter(time, NO2, 2.5, 'Marker', 's', 'MarkerEdgeColor', 'm', 'MarkerFaceColor', 'm', 'DisplayName', 'NO2'); hold on;

xlim();
ylim([0, 100]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 100]);

set(gca, 'XTick', dates6Months, 'YTick', 20:20:80, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy-mm', 'keepticks', 'keeplimits');
xlim();

legend([s1], 'Location', 'NorthEast');

% bottom-left (O3)
subplot('Position', figPos(5, :), 'Units', 'Normalized');
s1 = scatter(time, O3, 3, 'Marker', 's', 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g', 'DisplayName', 'O3'); hold on;

xlim();
ylim([0, 200]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', dates6Months, 'YTick', 0:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy-mm', 'keepticks', 'keeplimits');
xlim();
xtickangle(45);

legend([s1], 'Location', 'NorthEast');

% bottom-right (CO)
subplot('Position', figPos(6, :), 'Units', 'Normalized');
s1 = scatter(time, CO, 2.5, 'Marker', 's', 'MarkerEdgeColor', 'c', 'MarkerFaceColor', 'c', 'DisplayName', 'CO'); hold on;

xlim();
ylim([0, 300]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 300]);

set(gca, 'XTick', dates6Months, 'YTick', 0:50:250, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy-mm', 'keepticks', 'keeplimits');
xlim();
xtickangle(45);

legend([s1], 'Location', 'NorthEast');

text(0, 3.1, 'Time series of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'time-series-AQ-wuhan.png'), '-r300');
saveas(gcf, fullfile(projectDir, 'img', 'time-series-AQ-wuhan.fig'));

%% diurnal trend
figure('Position', [0, 20, 700, 600], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 3, 2);

% left-top (PM2.5 PM10)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime - datenum(0, 1, 0, 0, 10, 0), diurnalDataMean(3, :), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(diurnalTime + datenum(0, 1, 0, 0, 10, 0), diurnalDataMean(4, :), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([0, 1]);
ylim([0, 400]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 100:100:300, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1, b2], 'Location', 'NorthEast');

% right-top (AQI)
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, diurnalDataMean(1, :), 0.5, 'k', 'DisplayName', 'AQI');

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 300]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI');
ylim([0, 300]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:250, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1], 'Location', 'NorthEast');

% mid-left (SO2)
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, diurnalDataMean(2, :), 0.5, 'y', 'DisplayName', 'SO2');

xlim([0, 1]);
ylim([0, 400]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 't    ex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 100:100:300, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1], 'Location', 'NorthEast');

% mid-right (NO2)
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, diurnalDataMean(5, :), 0.5, 'm', 'DisplayName', 'NO2');

xlim([0, 1]);
ylim([0, 100]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 100]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 20:20:80, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1], 'Location', 'NorthEast');

% bottom-left (O3)
subplot('Position', figPos(5, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, diurnalDataMean(6, :), 0.5, 'g', 'DisplayName', 'O3');

xlim([0, 1]);
ylim([0, 200]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 0:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1], 'Location', 'NorthEast');

% bottom-right (CO)
subplot('Position', figPos(6, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, diurnalDataMean(7, :), 0.5, 'c', 'DisplayName', 'CO');

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 300]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 300]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 0:50:250, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1], 'Location', 'NorthEast');

text(0, 3.1, 'Dirunal variations of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.2, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.2, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'diurnal-AQ-wuhan.png'), '-r300');

%% seasonal trend
figure('Position', [0, 20, 700, 600], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 3, 2);

% left-top (PM2.5 PM10)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(seasonalTime - 0.2, seasonalDataMean(3, :), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(seasonalTime + 0.2, seasonalDataMean(4, :), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([0, 5]);
ylim([0, 400]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', seasonalTime, 'YTick', 100:100:300, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 5]);

legend([b1, b2], 'Location', 'NorthEast');

% right-top (AQI)
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(seasonalTime, seasonalDataMean(1, :), 0.5, 'k', 'DisplayName', 'AQI');

xlim([0, 5]);
set(gca, 'YTickLabel', '');
ylim([0, 300]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI');
ylim([0, 300]);

set(gca, 'XTick', seasonalTime, 'YTick', 50:50:250, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 5]);

legend([b1], 'Location', 'NorthEast');

% mid-left (SO2)
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(seasonalTime, seasonalDataMean(2, :), 0.5, 'y', 'DisplayName', 'SO2');

xlim([0, 5]);
ylim([0, 400]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 't    ex');

set(gca, 'XTick', seasonalTime, 'YTick', 100:100:300, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 5]);

legend([b1], 'Location', 'NorthEast');

% mid-right (NO2)
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(seasonalTime, seasonalDataMean(5, :), 0.5, 'm', 'DisplayName', 'NO2');

xlim([0, 5]);
ylim([0, 100]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 100]);

set(gca, 'XTick', seasonalTime, 'YTick', 20:20:80, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 5]);

legend([b1], 'Location', 'NorthEast');

% bottom-left (O3)
subplot('Position', figPos(5, :), 'Units', 'Normalized');
b1 = bar(seasonalTime, seasonalDataMean(6, :), 0.5, 'g', 'DisplayName', 'O3');

xlim([0, 5]);
ylim([0, 200]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', seasonalTime, 'XTickLabel', {'MAM', 'JJA', 'SON', 'DJF'}, 'YTick', 0:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
xlim([0, 5]);

legend([b1], 'Location', 'NorthEast');

% bottom-right (CO)
subplot('Position', figPos(6, :), 'Units', 'Normalized');
b1 = bar(seasonalTime, seasonalDataMean(7, :), 0.5, 'c', 'DisplayName', 'CO');

xlim([0, 5]);
set(gca, 'YTickLabel', '');
ylim([0, 300]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 300]);

set(gca, 'XTick', seasonalTime, 'XTickLabel', {'MAM', 'JJA', 'SON', 'DJF'}, 'YTick', 0:50:250, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
xlim([0, 5]);

legend([b1], 'Location', 'NorthEast');

text(0, 3.1, 'Seasonal variations of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'seasonal-AQ-wuhan.png'), '-r300');

%% yearly trend
figure('Position', [0, 20, 700, 600], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 3, 2);

% left-top (PM2.5 PM10)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(yearlyTime - datenum(0, 3, 0, 0, 0, 0), yearlyDataMean(3, :), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(yearlyTime + datenum(0, 3, 0, 0, 0, 0), yearlyDataMean(4, :), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([floor(time(1)), ceil(time(end)) + 1]);
ylim([0, 400]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', yearlyTime, 'YTick', 100:100:300, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1, b2], 'Location', 'NorthEast');

% right-top (AQI)
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(yearlyTime, yearlyDataMean(1, :), 0.5, 'k', 'DisplayName', 'AQI');

xlim([floor(time(1)), ceil(time(end)) + 1]);
set(gca, 'YTickLabel', '');
ylim([0, 300]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI');
ylim([0, 300]);

set(gca, 'XTick', yearlyTime, 'YTick', 50:50:250, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1], 'Location', 'NorthEast');

% mid-left (SO2)
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(yearlyTime, yearlyDataMean(2, :), 0.5, 'y', 'DisplayName', 'SO2');

xlim([floor(time(1)), ceil(time(end)) + 1]);
ylim([0, 400]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 't    ex');

set(gca, 'XTick', yearlyTime, 'YTick', 100:100:300, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1], 'Location', 'NorthEast');

% mid-right (NO2)
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(yearlyTime, yearlyDataMean(5, :), 0.5, 'm', 'DisplayName', 'NO2');

xlim([floor(time(1)), ceil(time(end)) + 1]);
ylim([0, 100]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 100]);

set(gca, 'XTick', yearlyTime, 'YTick', 20:20:80, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1], 'Location', 'NorthEast');

% bottom-left (O3)
subplot('Position', figPos(5, :), 'Units', 'Normalized');
b1 = bar(yearlyTime, yearlyDataMean(6, :), 0.5, 'g', 'DisplayName', 'O3');

xlim([floor(time(1)), ceil(time(end)) + 1]);
ylim([0, 200]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', yearlyTime, 'YTick', 0:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1], 'Location', 'NorthEast');

% bottom-right (CO)
subplot('Position', figPos(6, :), 'Units', 'Normalized');
b1 = bar(yearlyTime, yearlyDataMean(7, :), 0.5, 'c', 'DisplayName', 'CO');

xlim([floor(time(1)), ceil(time(end)) + 1]);
set(gca, 'YTickLabel', '');
ylim([0, 300]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 300]);

set(gca, 'XTick', yearlyTime, 'YTick', 0:50:250, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1], 'Location', 'NorthEast');

text(0, 3.1, 'Yearly variations of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.2, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.2, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'yearly-AQ-wuhan.png'), '-r300');

%% seasonal-diurnal variations
%% PM2p5 and PM10
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (PM2.5 PM10)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime - datenum(0, 1, 0, 0, 10, 0), squeeze(seasonalDiurnalDataMean(3, 1, :)), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(diurnalTime + datenum(0, 1, 0, 0, 10, 0), squeeze(seasonalDiurnalDataMean(4, 1, :)), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([0, 1]);
ylim([0, 200]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1, b2], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime - datenum(0, 1, 0, 0, 10, 0), squeeze(seasonalDiurnalDataMean(3, 2, :)), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(diurnalTime + datenum(0, 1, 0, 0, 10, 0), squeeze(seasonalDiurnalDataMean(4, 2, :)), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 200]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 200]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime - datenum(0, 1, 0, 0, 10, 0), squeeze(seasonalDiurnalDataMean(3, 3, :)), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(diurnalTime + datenum(0, 1, 0, 0, 10, 0), squeeze(seasonalDiurnalDataMean(4, 3, :)), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([0, 1]);
ylim([0, 200]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime - datenum(0, 1, 0, 0, 10, 0), squeeze(seasonalDiurnalDataMean(3, 4, :)), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(diurnalTime + datenum(0, 1, 0, 0, 10, 0), squeeze(seasonalDiurnalDataMean(4, 4, :)), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 200]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 200]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, 'Dirunal variations of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'seasonal-diurnal-PM-wuhan.png'), '-r300');

%% AQI
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (AQI)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(1, 1, :)), 0.5, 'k', 'DisplayName', 'AQI'); hold on;

xlim([0, 1]);
ylim([0, 200]);

ylabel('AQI', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(1, 2, :)), 0.5, 'k', 'DisplayName', 'AQI'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 200]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI', 'Interpreter', 'tex');
ylim([0, 200]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(1, 3, :)), 0.5, 'k', 'DisplayName', 'AQI'); hold on;

xlim([0, 1]);
ylim([0, 200]);

ylabel('AQI', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(1, 4, :)), 0.5, 'k', 'DisplayName', 'AQI'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 200]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI', 'Interpreter', 'tex');
ylim([0, 200]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, 'Dirunal variations of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'seasonal-diurnal-AQI-wuhan.png'), '-r300');

%% SO2
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (SO2)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(2, 1, :)), 0.5, 'y', 'DisplayName', 'SO2'); hold on;

xlim([0, 1]);
ylim([0, 200]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(2, 2, :)), 0.5, 'y', 'DisplayName', 'SO2'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 200]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 200]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(2, 3, :)), 0.5, 'y', 'DisplayName', 'SO2'); hold on;

xlim([0, 1]);
ylim([0, 200]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(2, 4, :)), 0.5, 'y', 'DisplayName', 'SO2'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 200]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 200]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, 'Dirunal variations of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'seasonal-diurnal-SO2-wuhan.png'), '-r300');

%% NO2
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (NO2)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(5, 1, :)), 0.5, 'm', 'DisplayName', 'NO2'); hold on;

xlim([0, 1]);
ylim([0, 30]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 5:5:25, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(5, 2, :)), 0.5, 'm', 'DisplayName', 'NO2'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 30]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 30]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 5:5:25, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(5, 3, :)), 0.5, 'm', 'DisplayName', 'NO2'); hold on;

xlim([0, 1]);
ylim([0, 30]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 5:5:25, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(5, 4, :)), 0.5, 'm', 'DisplayName', 'NO2'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 30]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 30]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 5:5:25, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, 'Dirunal variations of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'seasonal-diurnal-NO2-wuhan.png'), '-r300');

%% O3
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (O3)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(6, 1, :)), 0.5, 'g', 'DisplayName', 'O3'); hold on;

xlim([0, 1]);
ylim([0, 100]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 20:20:80, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(6, 2, :)), 0.5, 'g', 'DisplayName', 'O3'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 100]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 100]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 20:20:80, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(6, 3, :)), 0.5, 'g', 'DisplayName', 'O3'); hold on;

xlim([0, 1]);
ylim([0, 100]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 20:20:80, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(6, 4, :)), 0.5, 'g', 'DisplayName', 'O3'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 100]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 100]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 20:20:80, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, 'Dirunal variations of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'seasonal-diurnal-O3-wuhan.png'), '-r300');

%% CO
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (CO)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(7, 1, :)), 0.5, 'c', 'DisplayName', 'CO'); hold on;

xlim([0, 1]);
ylim([0, 150]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(7, 2, :)), 0.5, 'c', 'DisplayName', 'CO'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 150]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 150]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(7, 3, :)), 0.5, 'c', 'DisplayName', 'CO'); hold on;

xlim([0, 1]);
ylim([0, 150]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(7, 4, :)), 0.5, 'c', 'DisplayName', 'CO'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 150]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 150]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, 'Dirunal variations of pollutants in Wuhan', 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(projectDir, 'img', 'seasonal-diurnal-CO-wuhan.png'), '-r300');