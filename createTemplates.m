function [XMINS YMINS WIDTHS HEIGHTS XMAXS YMAXS TEMPLATEIMAGE] = createTemplates(IMAGE, XPOINTS, YPOINTS, WINDOWSIZE)
% Extract templates (centered at XPOINTS, YPOINTS) from an image. 

% Default to square windows
if length(WINDOWSIZE) < 2;
    WINDOWSIZE = repmat(WINDOWSIZE, 1, 2);
end

% X- and Y- window sizes
windowSizeY = WINDOWSIZE(1);
windowSizeX = WINDOWSIZE(2);

% Determine minimum and maximum X-coordinates of templates within image 
XMINS = XPOINTS - round(windowSizeX / 2);
XMAXS = XMINS + windowSizeX - 1;

% Determine minimum and maximum Y-coordinates of templates within image 
YMINS = YPOINTS - round(windowSizeY / 2);
YMAXS = YMINS + windowSizeY - 1;

% Number of tracked points
nPoints = length(XPOINTS);

% Extract the templates. Store as a structure array. 
for k = 1:nPoints
    TEMPLATEIMAGE{k} = IMAGE(YMINS(k):YMAXS(k), XMINS(k):XMAXS(k), :);
end

% Save window widths and heights to variables
WIDTHS = ones(nPoints, 1) * windowSizeX;
HEIGHTS = ones(nPoints, 1) * windowSizeY;

end