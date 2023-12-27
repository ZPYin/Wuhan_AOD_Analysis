function [aodFile] = convert_MODIS_AOD_2_mat(TerraAODFile, AquaAODFile, savePath, varargin)
% CONVERT_MODIS_AOD_2_MAT convert Giovanno platform output to matlab MAT file format.
%
% USAGE:
%    aodFile = convert_MODIS_AOD_2_mat(TerraAODFile, AquaAODFile, savePath)
%
% INPUTS:
%    TerraAODFile: char
%        absolute path of Terra AOD file.
%    AquaAODFile: char
%        absolute path of Aqua AOD file.
%    savePath: char
%        saving path.
%
% OUTPUTS:
%    aodFile: char
%        absolute path of the output aod file.
%
% HISTORY:
%    2023-12-27: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'TerraAODFile', @ischar);
addRequired(p, 'AquaAODFile', @ischar);
addRequired(p, 'savePath', @ischar);
addParameter(p, 'debug', false, @islogical);

parse(p, TerraAODFile, AquaAODFile, savePath, varargin{:});

%% read data
fid = fopen(TerraAODFile, 'r');
TerraDataRec = textscan(fid, '%s %f', 'Headerlines', 9, 'Delimiter', ',');
fclose(fid);
fid = fopen(AquaAODFile, 'r');
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
aodFile = fullfile(savePath, 'Giovanni_MODIS_AOD.mat');
save(aodFile, 'TerraAOD', 'TerraTime', 'AquaAOD', 'AquaTime');

end