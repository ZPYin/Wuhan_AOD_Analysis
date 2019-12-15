clc; close all;
projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectDir, 'include', 'export_fig'));
addpath(fullfile(projectDir, 'include'));

%% set character encoding
currentCharacterEncoding = slCharacterEncoding();
slCharacterEncoding('UTF-8');

%% Parameter initialization
AQI_DataFolder = 'D:\Data\全国空气质量';
city = '武汉';
station_city_lookup_file = '站点列表-2019.08.01起.csv';
matFilename = 'wuhan_air_quality_data.mat';

%% read data
% read the station-city link table
station_city_lookup_table = readtable(fullfile(AQI_DataFolder, station_city_lookup_file), 'Delimiter', ',', 'ReadVariableNames', 0, 'Headerlines', 1);

% change table variable names
station_city_lookup_table.Properties.VariableNames{'Var1'} = 'Station_ID';
station_city_lookup_table.Properties.VariableNames{'Var2'} = 'Station_Name';
station_city_lookup_table.Properties.VariableNames{'Var3'} = 'City';
station_city_lookup_table.Properties.VariableNames{'Var4'} = 'Station_lon';
station_city_lookup_table.Properties.VariableNames{'Var5'} = 'Station_lat';

% list air quality data filenames of different city
city_AQ_files = {};
city_AQ_folders = listdir(AQI_DataFolder, '城市_\w{8}-\w{8}');

for iFolder = 1:length(city_AQ_folders)
    files = listfile(city_AQ_folders{iFolder}, 'china_cities_\w{8}.*csv');
    city_AQ_files = cat(2, city_AQ_files, files);
end

% list air quality data filenames of different stations
station_AQ_files = {};
station_AQ_folders = listdir(AQI_DataFolder, '站点_\w{8}-\w{8}');

for iFolder = 1:length(station_AQ_folders)
    files = listfile(station_AQ_folders{iFolder}, 'china_sites_\w{8}.*csv');
    station_AQ_files = cat(2, station_AQ_files, files);
end

% read data from the pre-defined city
city_AQ_data = struct('time', NaN(1, 1e5), 'AQI', NaN(1, 1e5), 'PM2p5', NaN(1, 1e5), 'PM2p5_24h', NaN(1, 1e5), 'PM10', NaN(1, 1e5), 'PM10_24h', NaN(1, 1e5), 'SO2', NaN(1, 1e5), 'SO2_24h', NaN(1, 1e5), 'NO2', NaN(1, 1e5), 'NO2_24h', NaN(1, 1e5), 'O3', NaN(1, 1e5), 'O3_24h', NaN(1, 1e5), 'O3_8h', NaN(1, 1e5), 'O3_8h_24h', NaN(1, 1e5), 'CO', NaN(1, 1e5), 'CO_24h', NaN(1, 1e5));

dataCounter = 0;
for iFile = 1:length(city_AQ_files)
    fprintf('Finished %5.2f%%: Reading cities -> %s\n', (iFile / length(city_AQ_files)) * 100, city_AQ_files{iFile});

    city_AQ_daily_table = readtable(city_AQ_files{iFile}, 'Delimiter', ',', 'ReadVariableNames', 0, 'Headerlines', 1);

    % read the first line
    fid = fopen(city_AQ_files{iFile}, 'r');
    headers = fgetl(fid);
    fclose(fid);

    % search the column of the predefined city
    columnNames = strsplit(headers, ',');
    thisColumnIndx = NaN;
    for iColumn = 1:length(columnNames)
        if strcmp(columnNames{iColumn}, city)
            thisColumnIndx = iColumn;
            continue;
        end
    end

    % output the data
    indx = 1:int32(size(city_AQ_daily_table, 1) / 15);
    for iTime = 1:length(indx)
        if isnan(thisColumnIndx)
            continue;
        end

        dataCounter = dataCounter + 1;

        city_AQ_data.time(dataCounter) = datenum([num2str(city_AQ_daily_table{(iTime - 1) * 15 + 1, 1}), sprintf('%02d', city_AQ_daily_table{(iTime - 1) * 15 + 1, 2})], 'yyyymmddHH');
        city_AQ_data.AQI(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 1, thisColumnIndx};
        city_AQ_data.PM2p5(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 2, thisColumnIndx};
        city_AQ_data.PM2p5_24h(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 3, thisColumnIndx};
        city_AQ_data.PM10(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 4, thisColumnIndx};
        city_AQ_data.PM10_24h(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 5, thisColumnIndx};
        city_AQ_data.SO2(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 1, thisColumnIndx};
        city_AQ_data.SO2_24h(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 6, thisColumnIndx};
        city_AQ_data.NO2(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 7, thisColumnIndx};
        city_AQ_data.NO2_24h(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 8, thisColumnIndx};
        city_AQ_data.O3(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 9, thisColumnIndx};
        city_AQ_data.O3_24h(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 10, thisColumnIndx};
        city_AQ_data.O3_8h(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 11, thisColumnIndx};
        city_AQ_data.O3_8h_24h(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 12, thisColumnIndx};
        city_AQ_data.CO(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 13, thisColumnIndx};
        city_AQ_data.CO_24h(dataCounter) = city_AQ_daily_table{(iTime - 1)*15 + 1, thisColumnIndx};

    end
end

% squeeze the array
fields = fieldnames(city_AQ_data);
for iField = 1:length(fields)
    field = fields{iField};
    tmp = city_AQ_data.(field);
    tmp = tmp(1:dataCounter);
    city_AQ_data.(field) =  tmp;
end

% read data from the national ground stations
station_AQ_data = struct('time', NaN(1, 1e5), 'AQI', NaN(1, 1e5), 'PM2p5', NaN(1, 1e5), 'PM2p5_24h', NaN(1, 1e5), 'PM10', NaN(1, 1e5), 'PM10_24h', NaN(1, 1e5), 'SO2', NaN(1, 1e5), 'SO2_24h', NaN(1, 1e5), 'NO2', NaN(1, 1e5), 'NO2_24h', NaN(1, 1e5), 'O3', NaN(1, 1e5), 'O3_24h', NaN(1, 1e5), 'O3_8h', NaN(1, 1e5), 'O3_8h_24h', NaN(1, 1e5), 'CO', NaN(1, 1e5), 'CO_24h', NaN(1, 1e5));
station_IDs = station_city_lookup_table.Station_ID(strcmp(station_city_lookup_table.City, city));

stations_AQ_data = struct();
for indx = 1:length(station_IDs)
    ID = station_IDs{indx};
    stations_AQ_data.(['pd_', ID]) = station_AQ_data;
end

dataCounter = 0;
for iFile = 1:length(station_AQ_files)
    fprintf('Finished %5.2f%%: Reading stations -> %s\n', (iFile / length(station_AQ_files)) * 100, station_AQ_files{iFile});

    station_AQ_daily_table = readtable(station_AQ_files{iFile}, 'Delimiter', ',', 'ReadVariableNames', 0, 'Headerlines', 1);

    % read the first line
    fid = fopen(station_AQ_files{iFile}, 'r');
    headers = fgetl(fid);
    fclose(fid);

    columnNames = strsplit(headers, ',');
    
    % search the column index of the given station ID
    IDs = fieldnames(stations_AQ_data);
    for indx = 1:length(IDs)
        thisColumnIndx = NaN;
        ID = IDs{indx};
        tmp_station_AQ_data = stations_AQ_data.(ID);

        thisDataCounter = dataCounter;

        for iColumn = 1:length(columnNames)
            if strcmp(['pd_', columnNames{iColumn}], ID)
                thisColumnIndx = iColumn;
                continue;
            end
        end

        % output the data
        indx = 1:int32(size(station_AQ_daily_table, 1) / 15);
        for iTime = 1:length(indx)
            if isnan(thisColumnIndx)
                continue;
            end

            thisDataCounter = thisDataCounter + 1;

            tmp_station_AQ_data.('time')(thisDataCounter) = datenum([num2str(station_AQ_daily_table{(iTime - 1) * 15 + 1, 1}), sprintf('%02d', station_AQ_daily_table{(iTime - 1) * 15 + 1, 2})], 'yyyymmddHH');
            tmp_station_AQ_data.('AQI')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 1, thisColumnIndx};
            tmp_station_AQ_data.('PM2p5')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 2, thisColumnIndx};
            tmp_station_AQ_data.('PM2p5_24h')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 3, thisColumnIndx};
            tmp_station_AQ_data.('PM10')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 4, thisColumnIndx};
            tmp_station_AQ_data.('PM10_24h')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 5, thisColumnIndx};
            tmp_station_AQ_data.('SO2')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 1, thisColumnIndx};
            tmp_station_AQ_data.('SO2_24h')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 6, thisColumnIndx};
            tmp_station_AQ_data.('NO2')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 7, thisColumnIndx};
            tmp_station_AQ_data.('NO2_24h')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 8, thisColumnIndx};
            tmp_station_AQ_data.('O3')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 9, thisColumnIndx};
            tmp_station_AQ_data.('O3_24h')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 10, thisColumnIndx};
            tmp_station_AQ_data.('O3_8h')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 11, thisColumnIndx};
            tmp_station_AQ_data.('O3_8h_24h')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 12, thisColumnIndx};
            tmp_station_AQ_data.('CO')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 13, thisColumnIndx};
            tmp_station_AQ_data.('CO_24h')(thisDataCounter) = station_AQ_daily_table{(iTime - 1)*15 + 1, thisColumnIndx};

        end

        stations_AQ_data.(ID) = tmp_station_AQ_data;
    end

    dataCounter = thisDataCounter;
end

% squeeze the data
IDs = fieldnames(stations_AQ_data);
for iID = 1:length(IDs)

    station_AQ_data = stations_AQ_data.(IDs{iID});
    fields = fieldnames(station_AQ_data);

    for iField = 1:length(fields)
        tmp = station_AQ_data.(fields{iField});
        tmp = tmp(1:dataCounter);
        station_AQ_data.(fields{iField}) = tmp;
    end

    stations_AQ_data.(IDs{iID}) = station_AQ_data;
end

save(fullfile(projectDir, 'data', matFilename), 'city_AQ_data', 'station_city_lookup_table', 'stations_AQ_data');