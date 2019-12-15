function [rgbColor] = hex2rgb(hexColor)
%hex2rgb Convert hex color string to RGB color array.
%   Example:
%       [rgbColor] = hex2rgb(hexColor)
%   Inputs:
%       hexColor: char
%           hex color.
%   Outputs:
%       rgbColor: normalized r-g-b array
%   History:
%       2019-12-15. First Edition by Zhenping
%   Contact:
%       zp.yin@whu.edu.cn

if ~ ischar(hexColor)
    error('Input must be an hex char array: #000000');
end

if ~ regexp(hexColor, '#\w{6}')
    error('Wrong input format: #000000');
end

rgbColor = sscanf(hexColor(2:end),'%2x%2x%2x',[1 3])/255;

end