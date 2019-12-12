function [slope, offset, slope_std, offset_std] = linfit(x, y)
%linfit Linear regression.
%   Example:
%       [slope, offset, slope_std, offset_std] = linfit(x, y)
%   Inputs:
%       x: columnar array
%       y: columnar array
%   Outputs:
%       slope: float
%           slope of the linear regression.
%       offset: float
%           offset of the linear regression.
%       slope_std: float
%           slope uncertainty of the linear regression.
%       offset_std: float
%           offset uncertainty of the linear regression.
%   History:
%       2019-11-11. First Edition by Zhenping
%   Contact:
%       zp.yin@whu.edu.cn

if length(x) ~= length(y)
    error('x and y must have the same length.');
end

flagNaN = isnan(x) | isnan(y);

x = x(~ flagNaN);
y = y(~ flagNaN);

if isempty(x) || isempty(y)
    error('x or y is empty or without non-NaN values.');
end

cf = fit(x, y, 'poly1');

cf_coeff = coeffvalues(cf);
cf_confint = confint(cf);

slope = cf_coeff(1);
offset = cf_coeff(2);

slope_std = (cf_confint(2, 1) - cf_confint(1, 1)) / 2;
offset_std = (cf_confint(2, 2) - cf_confint(1, 2)) / 2;

end