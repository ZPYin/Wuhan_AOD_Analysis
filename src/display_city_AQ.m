clc; close all;
projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectDir, 'include', 'export_fig'));
addpath(fullfile(projectDir, 'include'));

%% set character encoding
currentCharacterEncoding = slCharacterEncoding();
slCharacterEncoding('UTF-8');

%% initialization
matFile = 'wuhan_air_quality_data.mat';

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
dates2Months = [];
nMonths = months(time(1), time(end - 1)) + 4;
[thisYear, thisMonth, ~] = datevec(time(1));
for iMonth = 1:1:(nMonths/4)
    if datenum(thisYear, thisMonth + (iMonth - 1) * 4, 1) <= time(end - 1)
        dates2Months = [dates2Months, datenum(thisYear, thisMonth + (iMonth - 1) * 4, 1)];
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
seasonalMonths = [ 12, 1, 2; 3, 4, 5; 6, 7, 8; 9, 10, 11];   % 4 * 3
seasonalDataMean = NaN(7, 4);
seasonalDataStd = NaN(7, 4);
for iSeason = 1:length(seasonalTime)
    [~, monthList, ~] = datevec(time);
    flag = (monthList == seasonalMonths(iSeason, 1)) | (monthList == seasonalMonths(iSeason, 2)) | (monthList == seasonalMonths(iSeason, 3));
    seasonalDataMean(:, iTime) = [nanmean(AQI(flag)); ...
                                nanmean(SO2(flag)); ...
                                nanmean(PM2p5(flag)); ...
                                nanmean(PM10(flag)); ...
                                nanmean(NO2(flag)); ...
                                nanmean(O3(flag)); ...
                                nanmean(CO(flag))];
    seasonalDataStd(:, iTime) = [nanstd(AQI(flag)); ...
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
    yearlyDataMean(:, iTime) = [nanmean(AQI(flag)); ...
                                nanmean(SO2(flag)); ...
                                nanmean(PM2p5(flag)); ...
                                nanmean(PM10(flag)); ...
                                nanmean(NO2(flag)); ...
                                nanmean(O3(flag)); ...
                                nanmean(CO(flag))];
    yearlyDataStd(:, iTime) = [nanstd(AQI(flag)); ...
                                nanstd(SO2(flag)); ...
                                nanstd(PM2p5(flag)); ...
                                nanstd(PM10(flag)); ...
                                nanstd(NO2(flag)); ...
                                nanstd(O3(flag)); ...
                                nanstd(CO(flag))];
end

%% data visualization 

% stations map (by jupyter)

% time series of different components
figure('Position', [0, 20, 700, 600], 'Units', 'Pixels');

figPos = subfigPos([0.07, 0.1, 0.86, 0.88], 3, 2);

subplot('Position', figPos(1, :), 'Units', 'Normalized');
s1 = scatter(time, PM2p5, 3, 'Marker', 's', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'DisplayName', 'PM2.5'); hold on;
s2 = scatter(time, PM10', 2, 'Marker', 'o', 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'DisplayName', 'PM10'); hold on;

xlim([datenum(2014, 2, 1), datenum(2019, 12, 30)]);
ylim([0, 400]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');
datetick(gca, 'x', 'mm', 'keepticks', 'keeplimits');
xlim([datenum(2014, 2, 1), datenum(2019, 12, 30)]);

set(gca, 'XTick', dates2Months, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);

legend([s1, s2], 'Location', 'NorthEast');

subplot('Position', figPos(2, :), 'Units', 'Normalized');
s1 = scatter(time, AQI, 2.5, 'Marker', 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'DisplayName', 'AQI'); hold on;

xlim([datenum(2014, 2, 1), datenum(2019, 12, 30)]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI')
ylim([0, 300]);

datetick(gca, 'x', 'mm', 'keepticks', 'keeplimits');
xlim([datenum(2014, 2, 1), datenum(2019, 12, 30)]);

set(gca, 'XTick', dates2Months, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);

legend([s1], 'Location', 'NorthEast');

subplot('Position', figPos(3, :), 'Units', 'Normalized');
subplot('Position', figPos(4, :), 'Units', 'Normalized');
subplot('Position', figPos(5, :), 'Units', 'Normalized');
subplot('Position', figPos(6, :), 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');

% diurnal trend

% seasonal trend

% yearly trend