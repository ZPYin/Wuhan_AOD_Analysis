function [seasonIndex, seasonLabel, seasonMonthLabel] = determine_season(mDate)
% DETERMINE_SEASON determine the season of the input date.
% USAGE:
%    [seasonIndex] = determine_season(mDate)
%
% INPUTS:
%    mDate: datenum
%        measurement date.
%
% OUTPUTS:
%    seasonIndex: numeric
%        season index.
%        1: Spring; 2: Summer; 3: Autumn; 4: Winter;
%    seasonLabel: cell
%        season labels. {'Spring', 'Summer', 'Autumn', 'Winter'}
%    seasonMonthLabel: cell
%        month abbreviation of each season.
%        'Spring': 'MAM' (March, April, May)
%        'Summer': 'JJA' (June, July, August)
%        'Autumn': 'SON' (September, October, November)
%        'Winter': 'DJF' (December, January, February)
%
% HISTORY:
%    2020-04-06. First Edition by Zhenping
%
% CONTACT:
%    zp.yin@whu.edu.cn

seasonIndexTable = [4, 4, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4];
seasonLabelTable = {'Spring', 'Summer', 'Autumn', 'Winter'};
seasonMonthLabelTable = {'MAM', 'JJA', 'SON', 'DJF'};

dateArr = datevec(mDate);

seasonIndex = NaN(size(mDate));
seasonLabel = cell(size(mDate));
seasonMonthLabel = cell(size(mDate));

flagValid = ~ isnan(dateArr(:, 1));
seasonIndex(flagValid) = seasonIndexTable(dateArr(flagValid, 2));
seasonLabel(flagValid) = seasonLabelTable(seasonIndex(flagValid));
seasonMonthLabel(flagValid) = seasonMonthLabelTable(seasonIndex(flagValid));

end