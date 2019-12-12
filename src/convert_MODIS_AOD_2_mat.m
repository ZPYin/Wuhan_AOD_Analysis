clc; close all;

%% initialization
projectDir = fileparts(fileparts(mfilename('fullpath')));
TerraAODFile = 'g4.areaAvgTimeSeries.MOD08_D3_6_1_AOD_550_Dark_Target_Deep_Blue_Combined_Mean.20020101-20181231.114E_30N_115E_31N.csv';
AquaAODFile = 'g4.areaAvgTimeSeries.MYD08_D3_6_1_AOD_550_Dark_Target_Deep_Blue_Combined_Mean.20020101-20181231.114E_30N_115E_31N.csv';

%% read data
fid = fopen(fullfile(projectDir, 'data', TerraAODFile), 'r');
TerraDataRec = textscan(fid, '%s %f', 'Headerlines', 9, 'Delimiter', ',');
fclose(fid);
fid = fopen(fullfile(projectDir, 'data', AquaAODFile), 'r');
AquaDataRec = textscan(fid, '%s %f', 'Headerlines', 9, 'Delimiter', ',');
fclose(fid);

% extract the data
TerraTime = NaN(1, length(TerraDataRec{1}));
TerraAOD = NaN(1, length(TerraDataRec{1}));
AquaTime = NaN(1, length(AquaDataRec{1}));
AquaAOD = NaN(1, length(AquaDataRec{1}));

for iRow = 1:length(TerraDataRec{1})
    TerraTime(iRow) = datenum(TerraDataRec{1}{iRow}, 'yyyy-mm-dd');
    if (TerraDataRec{2}(iRow) >= 0) && (TerraDataRec{2}(iRow) <= 4)
        TerraAOD(iRow) = TerraDataRec{2}(iRow);
    end
end

for iRow = 1:length(AquaDataRec{1})
    AquaTime(iRow) = datenum(AquaDataRec{1}{iRow}, 'yyyy-mm-dd');
    if (AquaDataRec{2}(iRow) >= 0) && (AquaDataRec{2}(iRow) <= 4)
        AquaAOD(iRow) = AquaDataRec{2}(iRow);
    end
end

%% convert to h5 file
save(fullfile(projectDir, 'data', 'Giovanni_MODIS_AOD.mat'), 'TerraAOD', 'TerraTime', 'AquaAOD', 'AquaTime');