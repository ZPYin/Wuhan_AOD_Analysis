function [timeOut, dataOut, dataStd] = averaging(timeIn, dataIn, varargin)
% AVERAGING average the input timeseries data.
% USAGE:
%    % Usecase 1: daily averaging
%    [timeList, dataOut, dataStd] = averaging(timeIn, dataIn, 'type', 'daily');
%    % Usecase 2: filter outliers
%    [timeList, dataOut, dataStd] = averaging(timeIn, dataIn, 'data_range', [0, 1]);
%
% INPUTS:
%    timeIn: numeric
%        time in MATLAB datenum.
%    dataIn: numeric
%        measurements at each timestamp.
%
% KEYWORDS:
%    type: averaging scheme
%        - annual
%        - month
%        - day (default)
%        - season | seasonal
%        - diurnal
%    data_range: 2-element array
%        valid data range.
%    min_cases: integer
%        minimum case number for each averaging segment. (default: 1)
%
% OUTPUTS:
%    timeList: numeric
%        timestamp for each averaging period.
%    dataOut: numeric
%        averaged results at each segment.
%    dataStd: numeric
%        uncertainty at each segment.
%
% HISTORY:
%    2020-12-08. First Edition by Zhenping
%
% CONTACT:
%    zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'timeIn', @isnumeric);
addRequired(p, 'dataIn', @isnumeric);
addParameter(p, 'type', 'daily', @ischar);
addParameter(p, 'min_cases', 1, @isnumeric);
addParameter(p, 'data_range', [], @isnumeric);

parse(p, timeIn, dataIn, varargin{:});

% initialize output
timeOut = [];
dataOut = [];
dataStd = [];

if length(timeIn) ~= length(dataIn)
    error('MATLAB:averaging', 'Data dimension is incompatible');
end

% exclude invalid data
if ~ isempty(p.Results.data_range)
    flagInvalid = (dataIn < p.Results.data_range(1)) | ...
                  (dataIn > p.Results.data_range(2));
    timeIn = timeIn(~ flagInvalid);
    dataIn = dataIn(~ flagInvalid);
end

startTime = datetime(min(timeIn), 'convertfrom', 'datenum');
stopTime = datetime(max(timeIn), 'convertfrom', 'datenum');

switch lower(p.Results.type)
case {'yearly', 'annual', 'year'}

    % annual average
    nYear = stopTime.Year - startTime.Year + 1;

    timeOut = NaN(1, nYear);
    dataOut = NaN(1, nYear);
    dataStd = NaN(1, nYear);
    for iYear = 1:nYear
        flagYear = (timeIn >= datenum(startTime.Year + iYear - 1, 1, 1)) & ...
                   (timeIn < datenum(startTime.Year + iYear, 1, 1));
        timeOut(iYear) = datenum(startTime.Year + iYear - 1, 1, 1);

        if sum(flagYear) >= p.Results.min_cases
            dataOut(iYear) = nanmean(dataIn(flagYear));
            dataStd(iYear) = nanstd(dataIn(flagYear));
        end
    end

case {'monthly', 'month'}

    % monthly average
    nMonth = 12 * (stopTime.Year - startTime.Year) + (stopTime.Month - startTime.Month);

    timeOut = NaN(1, nMonth);
    dataOut = NaN(1, nMonth);
    dataStd = NaN(1, nMonth);
    for iMonth = 1:nMonth
        flagMonth = (timeIn >= datenum(startTime.Year, startTime.Month + iMonth - 1, 1)) & ...
                    (timeIn < datenum(startTime.Year, startTime.Month + iMonth, 1));
        timeOut(iMonth) = datenum(startTime.Year, startTime.Month + iMonth - 1, 1);

        if sum(flagMonth) >= p.Results.min_cases
            dataOut(iMonth) = nanmean(dataIn(flagMonth));
            dataStd(iMonth) = nanstd(dataIn(flagMonth));
        end
    end

case {'daily', 'day'}

    % daily average
    nDay = (ceil(max(timeIn)) - ceil(min(timeIn))) + 1;

    timeOut = NaN(1, nDay);
    dataOut = NaN(1, nDay);
    dataStd = NaN(1, nDay);
    for iDay = 1:nDay
        flagDay = (timeIn >= datenum(startTime.Year, startTime.Month, iDay - 1)) & ...
                  (timeIn < datenum(startTime.Year, startTime.Month, iDay));
        timeOut(iDay) = datenum(startTime.Year, startTime.Month, iDay - 1);

        if sum(flagDay) >= p.Results.min_cases
            dataOut(iDay) = nanmean(dataIn(flagDay));
            dataStd(iDay) = nanstd(dataIn(flagDay));
        end
    end

case {'seasonal', 'season'}

    % seasonal average
    nSeason = 4;

    timeOut = NaN(1, nSeason);
    dataOut = NaN(1, nSeason);
    dataStd = NaN(1, nSeason);
    seasonIndx = determine_season(timeIn);

    for iSeason = 1:nSeason
        flagSeason = (seasonIndx == iSeason);
        timeOut(iSeason) = iSeason;

        if sum(flagSeason) >= p.Results.min_cases
            dataOut(iSeason) = nanmean(dataIn(flagSeason));
            dataStd(iSeason) = nanstd(dataIn(flagSeason));
        end
    end

case {'diurnal'}

    % diurnal average
    nHour = 24;

    timeOut = NaN(1, nHour);
    dataOut = NaN(1, nHour);
    dataStd = NaN(1, nHour);

    [~, ~, ~, hourIndx, ~, ~] = datevec(timeIn);
    for iHour = 1:nHour
        flagHour = (hourIndx == (iHour - 1));
        timeOut(iHour) = (iHour - 1);

        if sum(flagHour) >= p.Results.min_cases
            dataOut(iHour) = nanmean(dataIn(flagHour));
            dataStd(iHour) = nanstd(dataIn(flagHour));
        end
    end

%% TODO
% case {'hourly', 'hour'}
% case {'minutely', 'minute'}
% case {'secondly', 'second'}

otherwise
    error('MATLAB:averaging', 'Unknown type of %s', p.Results.type);
end

end