global WAOD_ENVS;

set(0,'defaultAxesFontName', 'simkai');   % �������ʾ���ģ�������Ҫ����֧�����ĵ����壨�磺����Ŀ��壩
                                          % ע��matlabĬ������ΪHelvetica������֧������
                                          % ������������������壬���Բο���������
                                          % https://blog.csdn.net/m0_37052320/article/details/80296951

%% initialization
matFile = 'Beijing_AQ_data_before_20210119.mat';
tRange = [datenum(2014, 3, 1), datenum(2020, 12, 31)];
stationName = '��������';
analysis_year_list = 2015:2020;
AQILevel = [0, 51, 101, 151, 201, 301];   % �ο��ҹ���׼��https://web.archive.org/web/20190713234941/http://kjs.mee.gov.cn/hjbhbz/bzwb/jcffbz/201203/W020120410332725219541.pdf
AQILevel_label = {'��', '��', '�����Ⱦ', '�ж���Ⱦ', '�ض���Ⱦ', '������Ⱦ'};   % ÿ��AQI����ζ�Ӧ�Ľ����ȼ�
AQILevel_color = [[0, 228, 0]/255;
                    [255, 255, 0]/255;
                    [255, 126, 0]/255;
                    [255, 0, 0]/255;
                    [153, 0, 76]/255;
                    [126, 0, 35]/255];
nAQILevel = length(AQILevel);
nPollutant = 7;
pieAQIOrder = [1, 5, 2, 6, 3, 4];   % ����Ӧ��״ͼԪ�ط�����ʾ����ֹ�ص���

%% load data
load(fullfile(WAOD_ENVS.RootPath, 'data', matFile));

%% load station data
try
    station_ID = station_city_lookup_table.Station_ID{strcmp(station_city_lookup_table.Station_Name, stationName)};
catch errMsg
    error('%s was not a supported station name.', stationName);
end
time = stations_AQ_data.(station_ID).time;
AQI = stations_AQ_data.(station_ID).AQI;
SO2 = stations_AQ_data.(station_ID).SO2;
PM2p5 = stations_AQ_data.(station_ID).PM2p5;
PM10 = stations_AQ_data.(station_ID).PM10;
NO2 = stations_AQ_data.(station_ID).NO2;
O3 = stations_AQ_data.(station_ID).O3;
CO = stations_AQ_data.(station_ID).CO;

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
diurnalDataMean = NaN(nPollutant, length(diurnalTime));
diurnalDataStd = NaN(nPollutant, length(diurnalTime));
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
seasonalDataMean = NaN(nPollutant, 4);
seasonalDataStd = NaN(nPollutant, 4);
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
yearlyTime = datenum(analysis_year_list, nPollutant, 1);
yearlyDataMean = NaN(nPollutant, length(yearlyTime));
yearlyDataStd = NaN(nPollutant, length(yearlyTime));
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

% yearly AQI level
yearlyTime = datenum(analysis_year_list, 7, 1);
yearlyAQILevel = NaN(nAQILevel, length(yearlyTime));
for iYear = 1:length(yearlyTime)
    [yearList, ~, ~] = datevec(time);
    [thisYear, ~, ~] = datevec(yearlyTime(iYear));
    flag = (yearList == thisYear);
    yearlyAQILevel(:, iYear) = histc(AQI(flag), AQILevel);
end

% seasonal-diurnal variations
diurnalTime = datenum(0, 1, 0, 0:23, 30, 0);
seasonalMonths = [3, 4, 5; 6, 7, 8; 9, 10, 11; 12, 1, 2];   % 4 * 3
seasonalDiurnalDataMean = NaN(nPollutant, 4, length(diurnalTime));
seasonalDiurnalDataStd = NaN(nPollutant, 4, length(diurnalTime));
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
figure('Position', [0, 20, 700, 600], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 3, 2);

% left-top (PM2.5 PM10)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
s1 = scatter(time, PM2p5, 3, 'Marker', 's', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'DisplayName', 'PM2.5'); hold on;
s2 = scatter(time, PM10', 1, 'Marker', 'o', 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'DisplayName', 'PM10'); hold on;

xlim(tRange);
ylim([0, 400]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', dates6Months, 'YTick', 100:100:300, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
xlim(tRange);

legend([s1, s2], 'Location', 'NorthEast');

% right-top (AQI)
subplot('Position', figPos(2, :), 'Units', 'Normalized');
s1 = scatter(time, AQI, 2.5, 'Marker', 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'DisplayName', 'AQI'); hold on;

xlim(tRange);
ylim([0, 300]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI');
ylim([0, 300]);

set(gca, 'XTick', dates6Months, 'YTick', 50:50:250, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
xlim(tRange);

legend([s1], 'Location', 'NorthEast');

% mid-left (SO2)
subplot('Position', figPos(3, :), 'Units', 'Normalized');
s1 = scatter(time, SO2, 3, 'Marker', 's', 'MarkerEdgeColor', 'y', 'MarkerFaceColor', 'y', 'DisplayName', 'SO2'); hold on;

xlim(tRange);
ylim([0, 300]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', dates6Months, 'YTick', 50:50:250, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
xlim(tRange);

legend([s1], 'Location', 'NorthEast');

% mid-right (NO2)
subplot('Position', figPos(4, :), 'Units', 'Normalized');
s1 = scatter(time, NO2, 2.5, 'Marker', 's', 'MarkerEdgeColor', 'm', 'MarkerFaceColor', 'm', 'DisplayName', 'NO2'); hold on;

xlim(tRange);
ylim([0, 150]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 150]);

set(gca, 'XTick', dates6Months, 'YTick', 30:30:120, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
xlim(tRange);

legend([s1], 'Location', 'NorthEast');

% bottom-left (O3)
subplot('Position', figPos(5, :), 'Units', 'Normalized');
s1 = scatter(time, O3, 3, 'Marker', 's', 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g', 'DisplayName', 'O3'); hold on;

xlim(tRange);
ylim([0, 250]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', dates6Months, 'YTick', 0:50:200, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy-mm', 'keepticks', 'keeplimits');
xlim(tRange);
xtickangle(45);

legend([s1], 'Location', 'NorthEast');

% bottom-right (CO)
subplot('Position', figPos(6, :), 'Units', 'Normalized');
s1 = scatter(time, CO, 2.5, 'Marker', 's', 'MarkerEdgeColor', 'c', 'MarkerFaceColor', 'c', 'DisplayName', 'CO'); hold on;

xlim(tRange);
ylim([0, 5]);
set(gca, 'YTickLabel', '');

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 5]);

set(gca, 'XTick', dates6Months, 'YTick', 1:1:4, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy-mm', 'keepticks', 'keeplimits');
xlim();
xtickangle(45);

legend([s1], 'Location', 'NorthEast');

text(0, 3.1, sprintf('Time series of pollutants in %s', stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('time-series-AQ-%s.png', stationName)), '-r300');
saveas(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('time-series-AQ-%s.fig', stationName)));

%% diurnal trend
figure('Position', [0, 20, 700, 600], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 3, 2);

% left-top (PM2.5 PM10)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime - datenum(0, 1, 0, 0, 10, 0), diurnalDataMean(3, :), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(diurnalTime + datenum(0, 1, 0, 0, 10, 0), diurnalDataMean(4, :), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([0, 1]);
ylim([0, 200]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 50:50:150, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1, b2], 'Location', 'NorthEast');

% right-top (AQI)
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, diurnalDataMean(1, :), 0.5, 'k', 'DisplayName', 'AQI');

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 150]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI');
ylim([0, 150]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1], 'Location', 'NorthEast');

% mid-left (SO2)
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, diurnalDataMean(2, :), 0.5, 'y', 'DisplayName', 'SO2');

xlim([0, 1]);
ylim([0, 60]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 't    ex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 10:10:50, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
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
ylim([0, 150]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1], 'Location', 'NorthEast');

% bottom-right (CO)
subplot('Position', figPos(6, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, diurnalDataMean(7, :), 0.5, 'c', 'DisplayName', 'CO');

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 3]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 3]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 0.5:0.5:2.5, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

legend([b1], 'Location', 'NorthEast');

text(0, 3.1, sprintf('Dirunal variations of pollutants in %s', stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.2, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.2, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('diurnal-AQ-%s.png', stationName)), '-r300');

%% seasonal trend
figure('Position', [0, 20, 700, 600], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 3, 2);

% left-top (PM2.5 PM10)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(seasonalTime - 0.2, seasonalDataMean(3, :), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(seasonalTime + 0.2, seasonalDataMean(4, :), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([0, 5]);
ylim([0, 200]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', seasonalTime, 'YTick', 50:50:150, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 5]);

legend([b1, b2], 'Location', 'NorthWest');

% right-top (AQI)
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(seasonalTime, seasonalDataMean(1, :), 0.5, 'k', 'DisplayName', 'AQI');

xlim([0, 5]);
set(gca, 'YTickLabel', '');
ylim([0, 150]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI');
ylim([0, 150]);

set(gca, 'XTick', seasonalTime, 'YTick', 30:30:120, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 5]);

legend([b1], 'Location', 'NorthWest');

% mid-left (SO2)
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(seasonalTime, seasonalDataMean(2, :), 0.5, 'y', 'DisplayName', 'SO2');

xlim([0, 5]);
ylim([0, 30]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 't    ex');

set(gca, 'XTick', seasonalTime, 'YTick', 5:5:25, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 5]);

legend([b1], 'Location', 'NorthWest');

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

set(gca, 'XTick', seasonalTime, 'YTick', 20:20:100, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 5]);

legend([b1], 'Location', 'NorthWest');

% bottom-left (O3)
subplot('Position', figPos(5, :), 'Units', 'Normalized');
b1 = bar(seasonalTime, seasonalDataMean(6, :), 0.5, 'g', 'DisplayName', 'O3');

xlim([0, 5]);
ylim([0, 150]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', seasonalTime, 'XTickLabel', {'MAM', 'JJA', 'SON', 'DJF'}, 'YTick', 30:30:120, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
xlim([0, 5]);

legend([b1], 'Location', 'NorthWest');

% bottom-right (CO)
subplot('Position', figPos(6, :), 'Units', 'Normalized');
b1 = bar(seasonalTime, seasonalDataMean(7, :), 0.5, 'c', 'DisplayName', 'CO');

xlim([0, 5]);
set(gca, 'YTickLabel', '');
ylim([0, 3]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 3]);

set(gca, 'XTick', seasonalTime, 'XTickLabel', {'MAM', 'JJA', 'SON', 'DJF'}, 'YTick', 0.5:0.5:2.5, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
xlim([0, 5]);

legend([b1], 'Location', 'NorthWest');

text(0, 3.1, sprintf('Seasonal variations of pollutants in %s', stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('seasonal-AQ-%s.png', stationName)), '-r300');

%% yearly trend
figure('Position', [0, 20, 700, 600], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 3, 2);

% left-top (PM2.5 PM10)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(yearlyTime - datenum(0, 3, 0, 0, 0, 0), yearlyDataMean(3, :), 0.3, 'r', 'DisplayName', 'PM2.5'); hold on;
b2 = bar(yearlyTime + datenum(0, 3, 0, 0, 0, 0), yearlyDataMean(4, :), 0.3, 'b', 'DisplayName', 'PM10'); hold on;

xlim([floor(time(1)), ceil(time(end)) + 1]);
ylim([0, 200]);

ylabel('PM (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', yearlyTime, 'YTick', 50:50:150, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1, b2], 'Location', 'NorthWest');

% right-top (AQI)
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(yearlyTime, yearlyDataMean(1, :), 0.5, 'k', 'DisplayName', 'AQI');

xlim([floor(time(1)), ceil(time(end)) + 1]);
set(gca, 'YTickLabel', '');
ylim([0, 150]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI');
ylim([0, 150]);

set(gca, 'XTick', yearlyTime, 'YTick', 30:30:120, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1], 'Location', 'NorthWest');

% mid-left (SO2)
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(yearlyTime, yearlyDataMean(2, :), 0.5, 'y', 'DisplayName', 'SO2');

xlim([floor(time(1)), ceil(time(end)) + 1]);
ylim([0, 30]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 't    ex');

set(gca, 'XTick', yearlyTime, 'YTick', 5:5:25, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1], 'Location', 'NorthWest');

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

legend([b1], 'Location', 'NorthWest');

% bottom-left (O3)
subplot('Position', figPos(5, :), 'Units', 'Normalized');
b1 = bar(yearlyTime, yearlyDataMean(6, :), 0.5, 'g', 'DisplayName', 'O3');

xlim([floor(time(1)), ceil(time(end)) + 1]);
ylim([0, 150]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', yearlyTime, 'YTick', 30:30:120, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1], 'Location', 'NorthWest');

% bottom-right (CO)
subplot('Position', figPos(6, :), 'Units', 'Normalized');
b1 = bar(yearlyTime, yearlyDataMean(7, :), 0.5, 'c', 'DisplayName', 'CO');

xlim([floor(time(1)), ceil(time(end)) + 1]);
set(gca, 'YTickLabel', '');
ylim([0, 3]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 3]);

set(gca, 'XTick', yearlyTime, 'YTick', 0.5:0.5:2.5, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'yyyy', 'keepticks', 'keeplimits');
xlim([floor(time(1)), ceil(time(end)) + 1]);

legend([b1], 'Location', 'NorthWest');

text(0, 3.1, sprintf('Annual variations of pollutants in %s', stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.2, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.2, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('yearly-AQ-%s.png', stationName)), '-r300');

%% seasonal-diurnal variations
%% PM2p5 and PM10
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels', 'color', 'w');

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

text(0, 2.1, sprintf('Dirunal variations of pollutants in %s',stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('seasonal-diurnal-PM-%s.png', stationName)), '-r300');

%% AQI
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (AQI)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(1, 1, :)), 0.5, 'k', 'DisplayName', 'AQI'); hold on;

xlim([0, 1]);
ylim([0, 150]);

ylabel('AQI', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(1, 2, :)), 0.5, 'k', 'DisplayName', 'AQI'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 150]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI', 'Interpreter', 'tex');
ylim([0, 150]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(1, 3, :)), 0.5, 'k', 'DisplayName', 'AQI'); hold on;

xlim([0, 1]);
ylim([0, 150]);

ylabel('AQI', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(1, 4, :)), 0.5, 'k', 'DisplayName', 'AQI'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 150]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('AQI', 'Interpreter', 'tex');
ylim([0, 150]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.9, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, sprintf('Dirunal variations of pollutants in %s', stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('seasonal-diurnal-AQI-%s.png', stationName)), '-r300');

%% SO2
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (SO2)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(2, 1, :)), 0.5, 'y', 'DisplayName', 'SO2'); hold on;

xlim([0, 1]);
ylim([0, 70]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 10:10:60, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(2, 2, :)), 0.5, 'y', 'DisplayName', 'SO2'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 70]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 70]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 10:10:60, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(2, 3, :)), 0.5, 'y', 'DisplayName', 'SO2'); hold on;

xlim([0, 1]);
ylim([0, 70]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 10:10:60, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(2, 4, :)), 0.5, 'y', 'DisplayName', 'SO2'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 70]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 70]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 10:10:60, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, sprintf('Dirunal variations of pollutants in %s', stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('seasonal-diurnal-SO2-%s.png', stationName)), '-r300');

%% NO2
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (NO2)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(5, 1, :)), 0.5, 'm', 'DisplayName', 'NO2'); hold on;

xlim([0, 1]);
ylim([0, 100]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 10:20:90, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(5, 2, :)), 0.5, 'm', 'DisplayName', 'NO2'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 100]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 100]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 10:20:90, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(5, 3, :)), 0.5, 'm', 'DisplayName', 'NO2'); hold on;

xlim([0, 1]);
ylim([0, 100]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 10:20:90, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(5, 4, :)), 0.5, 'm', 'DisplayName', 'NO2'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 100]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 100]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 10:20:90, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, sprintf('Dirunal variations of pollutants in %s', stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('seasonal-diurnal-NO2-%s.png', stationName)), '-r300');

%% O3
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (O3)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(6, 1, :)), 0.5, 'g', 'DisplayName', 'O3'); hold on;

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
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(6, 2, :)), 0.5, 'g', 'DisplayName', 'O3'); hold on;

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
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(6, 3, :)), 0.5, 'g', 'DisplayName', 'O3'); hold on;

xlim([0, 1]);
ylim([0, 150]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 30:30:120, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(6, 4, :)), 0.5, 'g', 'DisplayName', 'O3'); hold on;

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

text(0, 2.1, sprintf('Dirunal variations of pollutants in %s', stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('seasonal-diurnal-O3-%s.png', stationName)), '-r300');

%% CO
figure('Position', [0, 20, 700, 500], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.07, 0.1, 0.85, 0.83], 2, 2);

% left-top (CO)
subplot('Position', figPos(1, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(7, 1, :)), 0.5, 'c', 'DisplayName', 'CO'); hold on;

xlim([0, 1]);
ylim([0, 3]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 0.5:0.5:2.5, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Spring', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

legend([b1], 'Location', 'NorthEast');

% right-top
subplot('Position', figPos(2, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(7, 2, :)), 0.5, 'c', 'DisplayName', 'CO'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 3]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 3]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 0.5:0.5:2.5, 'XTickLabel', '', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Summer', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-left
subplot('Position', figPos(3, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(7, 3, :)), 0.5, 'c', 'DisplayName', 'CO'); hold on;

xlim([0, 1]);
ylim([0, 3]);

ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 0.5:0.5:2.5, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Autumn', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

% bottom-right
subplot('Position', figPos(4, :), 'Units', 'Normalized');
b1 = bar(diurnalTime, squeeze(seasonalDiurnalDataMean(7, 4, :)), 0.5, 'c', 'DisplayName', 'CO'); hold on;

xlim([0, 1]);
set(gca, 'YTickLabel', '');
ylim([0, 3]);

yyaxis right
ax = gca;
ax.YColor = 'k';
ylabel('Conc. (\mug/m^3)', 'Interpreter', 'tex');
ylim([0, 3]);

set(gca, 'XTick', diurnalTime(1:2:end), 'YTick', 0.5:0.5:2.5, 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLen', [0.01, 0.01]);
datetick(gca, 'x', 'HH', 'keepticks', 'keeplimits');
xlim([0, 1]);

text(0.1, 0.8, 'Winter', 'FontSize', 12, 'FontWeight', 'Bold', 'Units', 'Normalized');

text(0, 2.1, sprintf('Dirunal variations of pollutants in %s', stationName), 'FontSize', 12, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(-0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');
text(0.5, -0.13, 'Time (LT: hour)', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Units', 'Normalized');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('seasonal-diurnal-CO-%s.png', stationName)), '-r300');

%% yearly AQI level
figure('Position', [0, 30, 500, 700], 'Units', 'Pixels', 'color', 'w');

figPos = subfigPos([0.02, 0.03, 0.95, 0.90], 3, 2, 0, 0.07);

ax1 = subplot('Position', figPos(1, :), 'Units', 'Normalized');

yearlyAQILevel_organize = yearlyAQILevel(pieAQIOrder, :);
AQILevel_color_organize = AQILevel_color(pieAQIOrder, :);

flagNonZero = abs(yearlyAQILevel_organize(:, 1)) > 1e-5;
p1 = pie(ax1, yearlyAQILevel_organize(flagNonZero, 1));   % ����Ӧ��״ͼԪ�ط�����ʾ����ֹ�ص���
title('2015', 'FontSize', 14);
colormap(ax1, AQILevel_color_organize(flagNonZero, :));

ax2 = subplot('Position', figPos(2, :), 'Units', 'Normalized');

flagNonZero = abs(yearlyAQILevel_organize(:, 2)) > 1e-5;
p2 = pie(ax2, yearlyAQILevel_organize(flagNonZero, 2));   % ����Ӧ��״ͼԪ�ط�����ʾ����ֹ�ص���
title('2016', 'FontSize', 14);
colormap(ax2, AQILevel_color_organize(flagNonZero, :));

ax3 = subplot('Position', figPos(3, :), 'Units', 'Normalized');

flagNonZero = abs(yearlyAQILevel_organize(:, 3)) > 1e-5;
p3 = pie(ax3, yearlyAQILevel_organize(flagNonZero, 3));   % ����Ӧ��״ͼԪ�ط�����ʾ����ֹ�ص���
title('2017', 'FontSize', 14);
colormap(ax3, AQILevel_color_organize(flagNonZero, :));

ax4 = subplot('Position', figPos(4, :), 'Units', 'Normalized');

flagNonZero = abs(yearlyAQILevel_organize(:, 4)) > 1e-5;
p4 = pie(ax4, yearlyAQILevel_organize(flagNonZero, 4));   % ����Ӧ��״ͼԪ�ط�����ʾ����ֹ�ص���
title('2018', 'FontSize', 14);

colormap(ax4, AQILevel_color_organize(flagNonZero, :));

ax5 = subplot('Position', figPos(5, :), 'Units', 'Normalized');

flagNonZero = abs(yearlyAQILevel_organize(:, 5)) > 1e-5;
p5 = pie(ax5, yearlyAQILevel_organize(flagNonZero, 5));   % ����Ӧ��״ͼԪ�ط�����ʾ����ֹ�ص���
title('2019', 'FontSize', 14);

colormap(ax5, AQILevel_color_organize(flagNonZero, :));

ax6 = subplot('Position', [-10, -10, 1, 1], 'Units', 'Normalized');
p6 = pie(ax6, ones(1, nAQILevel));
colormap(ax6, AQILevel_color);
legend(AQILevel_label, 'Position', [0.6, 0.06, 0.25, 0.23], 'Orientation', 'Vertical', 'Units', 'Normalized', 'FontWeight', 'Bold');

export_fig(gcf, fullfile(WAOD_ENVS.RootPath, 'img', sprintf('AQI-level-%s.png', stationName)), '-r300');