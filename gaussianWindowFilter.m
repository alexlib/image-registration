function WINDOW = gaussianWindowFilter(DIMENSIONS, STD)
% gaussianwindowFilter applies a centered gaussian filter to a 2-D signal.
% INPUTS
%   sigRaw = Raw signal (Double precision format)
%   sx = Standard deviation in the x-direction of the 2-D gaussian function (pixels)
%   sy = Standard deviation in the y-direction of the 2-D gaussian function (pixels)
% 
% OUTPUTS
%   sigFiltered = Gaussian-filtered signal (Double precision format)
% 
% SEE ALSO
%   findwidth

% Signal height and width
height = DIMENSIONS(1);
width = DIMENSIONS(2);

% Standard deviations
sy = STD(1);
sx = STD(2);

% Calculate center of signal
xo = round(width/2);
yo = round(height/2);

% Create grid of x,y positions to hold gaussian filter data
[x,y] = meshgrid(1:width, 1:height);

% Don't window in X direction if Sx = 0
if sx == 0
    WindowX = 1;
else
    WindowX = exp( - ((x - xo).^2 / (2 * sx^2)));
end

% Don't window in Y direction if Sy = 0;
if sy == 0
    WindowY = ones(height, width);
else
    WindowY = exp( - ((y - yo).^2 / (2 * sy^2)));
end

% 2-D Gaussian Distribution
WINDOW = WindowX .* WindowY;

end