clc; close all;
projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectDir, 'include', 'export_fig'));
addpath(fullfile(projectDir, 'include'));

%% Parameter initialization
AQI_DataFolder = 'D:\Data\北京空气质量';
matFilename = 'Beijing_AQ_data_before_20210119.mat';   % New station or station names were used after 20210119

% station-city lookup table
load(fullfile(projectDir, 'data', 'Beijing_city_station_lookup_table.mat'));
station_city_lookup_table = Beijing_city_station_lookup_table;

% list air quality data filenames of different stations
station_AQ_files = {};
station_AQ_folders = listdir(AQI_DataFolder, 'beijing_\w{8}-\w{8}');

for iFolder = 1:length(station_AQ_folders)
    files = listfile(station_AQ_folders{iFolder}, 'beijing_all_\w{8}.*csv');
    station_AQ_files = cat(2, station_AQ_files, files);
end

% read data from the national ground stations
station_AQ_data = struct('time', NaN(1, 1e5), 'AQI', NaN(1, 1e5), 'PM2p5', NaN(1, 1e5), 'PM2p5_24h', NaN(1, 1e5), 'PM10', NaN(1, 1e5), 'PM10_24h', NaN(1, 1e5), 'SO2', NaN(1, 1e5), 'SO2_24h', NaN(1, 1e5), 'NO2', NaN(1, 1e5), 'NO2_24h', NaN(1, 1e5), 'O3', NaN(1, 1e5), 'O3_24h', NaN(1, 1e5), 'O3_8h', NaN(1, 1e5), 'O3_8h_24h', NaN(1, 1e5), 'CO', NaN(1, 1e5), 'CO_24h', NaN(1, 1e5));
station_IDs = station_city_lookup_table.Station_ID(strcmp(station_city_lookup_table.City, '北京'));

stations_AQ_data = struct();
for indx = 1:length(station_IDs)
    ID = station_IDs{indx};
    stations_AQ_data.(ID) = station_AQ_data;
end

dataCounter = 0;
for iFile = 1:length(station_AQ_files)
    fprintf('Finished %5.2f%%: Reading stations -> %s\n', (iFile / length(station_AQ_files)) * 100, station_AQ_files{iFile});
    try
        % read beijing_all_********.csv
        station_all_table = readtable(station_AQ_files{iFile}, 'Delimiter', ',', 'ReadVariableNames', 0, 'Headerlines', 1, 'encoding', 'utf-8');
    catch errMsg
        warning('Error in reading %s', station_AQ_files{iFile});
        continue;
    end

    try
        if exist(strrep(station_AQ_files{iFile}, 'all', 'extra'), 'file') == 2
            % read beijing_extra_********.csv
            station_extra_table = readtable(strrep(station_AQ_files{iFile}, 'all', 'extra'), 'Delimiter', ',', 'ReadVariableNames', 0, 'Headerlines', 1, 'encoding', 'utf-8');
        end
    catch errMsg
        warning('Error in reading %s', strrep(station_AQ_files{iFile}, 'all', 'extra'));
        continue;
    end

    % read the first line
    fid = fopen(station_AQ_files{iFile}, 'r', 'n', 'UTF-8');
    headers = fgetl(fid);
    fclose(fid);

    columnNames = strsplit(headers, ',');
    
    % search the column index of the given station ID
    stationNames = station_city_lookup_table.Station_Name;
    for indx = 1:length(stationNames)
        stationName = stationNames{indx};
        thisColumnIndx = find(strcmp(columnNames, stationName));
        if isempty(thisColumnIndx)
            continue;
        end

        ID = station_city_lookup_table.Station_ID{thisColumnIndx - 3};

        thisDataCounter = dataCounter;

        % output the data
        indx_all_data = 1:int32(size(station_all_table, 1) / 5);
        % indx_extra_data = 1:int32(size(station_extra_table, 1) / 8);
        for iTime = 1:length(indx_all_data)

            thisDataCounter = thisDataCounter + 1;
            if iscell(station_all_table{(iTime - 1)*5 + 5, thisColumnIndx})
                continue;
            end

            thisTime = datenum([num2str(station_all_table{(iTime - 1) * 5 + 1, 1}), sprintf('%02d', station_all_table{(iTime - 1) * 5 + 1, 2})], 'yyyymmddHH');
            stations_AQ_data.(ID).('time')(thisDataCounter) = thisTime;
            stations_AQ_data.(ID).('AQI')(thisDataCounter) = station_all_table{(iTime - 1)*5 + 5, thisColumnIndx};
            stations_AQ_data.(ID).('PM2p5')(thisDataCounter) = station_all_table{(iTime - 1)*5 + 1, thisColumnIndx};
            stations_AQ_data.(ID).('PM2p5_24h')(thisDataCounter) = station_all_table{(iTime - 1)*5 + 2, thisColumnIndx};
            stations_AQ_data.(ID).('PM10')(thisDataCounter) = station_all_table{(iTime - 1)*5 + 3, thisColumnIndx};
            stations_AQ_data.(ID).('PM10_24h')(thisDataCounter) = station_all_table{(iTime - 1)*5 + 4, thisColumnIndx};

            if (exist(strrep(station_AQ_files{iFile}, 'all', 'extra'), 'file') == 2) && (thisTime >= datenum(2014, 4, 29)) && (~ iscell(station_extra_table{(iTime - 1)*8 + 1, thisColumnIndx}))
                stations_AQ_data.(ID).('SO2')(thisDataCounter) = station_extra_table{(iTime - 1)*8 + 1, thisColumnIndx};
                stations_AQ_data.(ID).('SO2_24h')(thisDataCounter) = station_extra_table{(iTime - 1)*8 + 2, thisColumnIndx};
                stations_AQ_data.(ID).('NO2')(thisDataCounter) = station_extra_table{(iTime - 1)*8 + 3, thisColumnIndx};
                stations_AQ_data.(ID).('NO2_24h')(thisDataCounter) = station_extra_table{(iTime - 1)*8 + 4, thisColumnIndx};
                stations_AQ_data.(ID).('O3')(thisDataCounter) = station_extra_table{(iTime - 1)*8 + 5, thisColumnIndx};
                stations_AQ_data.(ID).('O3_24h')(thisDataCounter) = station_extra_table{(iTime - 1)*8 + 6, thisColumnIndx};
                stations_AQ_data.(ID).('CO')(thisDataCounter) = station_extra_table{(iTime - 1)*8 + 7, thisColumnIndx};
                stations_AQ_data.(ID).('CO_24h')(thisDataCounter) = station_extra_table{(iTime - 1)*8 + 8, thisColumnIndx};
            else
                stations_AQ_data.(ID).('SO2')(thisDataCounter) = NaN;
                stations_AQ_data.(ID).('SO2_24h')(thisDataCounter) = NaN;
                stations_AQ_data.(ID).('NO2')(thisDataCounter) = NaN;
                stations_AQ_data.(ID).('NO2_24h')(thisDataCounter) = NaN;
                stations_AQ_data.(ID).('O3')(thisDataCounter) = NaN;
                stations_AQ_data.(ID).('O3_24h')(thisDataCounter) = NaN;
                stations_AQ_data.(ID).('CO')(thisDataCounter) = NaN;
                stations_AQ_data.(ID).('CO_24h')(thisDataCounter) = NaN;
            end
        end
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
        tmp = tmp(~ isnan(station_AQ_data.time));
        station_AQ_data.(fields{iField}) = tmp;
    end

    stations_AQ_data.(IDs{iID}) = station_AQ_data;
end

save(fullfile(projectDir, 'data', matFilename), 'station_city_lookup_table', 'stations_AQ_data');