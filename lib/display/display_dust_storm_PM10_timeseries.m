global WAOD_ENVS;

%% initialization
matFilename = fullfile(WAOD_ENVS.RootPath, 'data', 'wuhan_AQData.mat');
tRange = [datenum(2014, 12, 28), datenum(2014, 12, 31)];

[~, time_PM25, PM25] = displayAQTimeseries(matFilename, tRange, 'AQType', 'pm2.5', 'averageType', 'raw', 'visible', 'off');
[~, time_PM10, PM10] = displayAQTimeseries(matFilename, tRange, 'AQType', 'pm10', 'averageType', 'raw', 'visible', 'off');
close all;

%% data visualization
figure('Position', [0, 10, 650, 300], 'Units', 'Pixels', 'color', 'w');

p1 = plot(time_PM25, PM25, '-.k', 'LineWidth', 1, 'DisplayName', 'PM_{2.5}'); hold on;
p2 = plot(time_PM10, PM10, '-k', 'LineWidth', 1, 'DisplayName', 'PM_{10}'); hold on;

xlabel('Date (mm-dd)');
ylabel(['Concentration/' char(181) 'g\cdotm^{-3}']);
title('Timeseries of pollutant mass concentration over Wuhan', 'FontSize', 14);

xlim(tRange);
ylim([0, 200]);

set(gca, 'XTick', (tRange(1) + 1):3:tRange(2), 'XMinorTick', 'on', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 1, 'Layer', 'top', 'FontSize', 12);
ax = gca;
ax.XAxis.MinorTickValues = (floor(tRange(1))):datenum(0,1,1,0,0,0):floor(tRange(2));

datetick(gca, 'x', 'mm-dd', 'keeplimits', 'keepticks');

legend([p1, p2], 'location', 'northwest');

export_fig(gcf, 'D:\Research\Mongolian_dust\results\dust_timeseries.png', '-r300');
