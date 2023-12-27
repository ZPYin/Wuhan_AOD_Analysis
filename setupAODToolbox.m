global WAOD_ENVS;

WAOD_ENVS.RootPath = fileparts(mfilename('fullpath'));
WAOD_ENVS.Author = 'Zhenping Yin';
WAOD_ENVS.Email = 'zp.yin@whu.edu.cn';
WAOD_ENVS.UpdateTime = '2023-12-27';
WAOD_ENVS.Version = '0.1';

addpath(genpath(fullfile(WAOD_ENVS.RootPath, 'include')));
addpath(genpath(fullfile(WAOD_ENVS.RootPath, 'lib')));
