function [XPOINTS, YPOINTS] = extractPoints(IMAGE, CHANNEL, MAXPOINTS, CORNERDETECTIONTHRESHOLD)
% Extract salient points from an image using the Rosten & Drummond method.
% Matt needs to learn how this works. 

% Default to 30 points
if nargin < 3
    MAXPOINTS = 30;
end

% Default to the green channel
if nargin < 2;
    CHANNEL = 2;
end

% % Extract Region of interest
imshow(IMAGE); % Show first image
set(gcf, 'color', [0 0 0]); % Set background color to black
title('Select region to track ...', 'FontSize', 20);
h = imrect; % Draw rectangle
pause; % Wait for user input
pos = round(getPosition(h)); % Get rectangle positions
close all; % Close the window

% Determine rectangle position
xminROI = pos(1); yminROI = pos(2); roiWidth = pos(3); roiHeight = pos(4);

% Extract region of interest from the image
ROI = IMAGE(yminROI : yminROI + roiHeight, xminROI : xminROI + roiWidth, :);

% Extract color channel as a double
ROI = double(ROI(:, :, CHANNEL)); 

% Select FAST algorithm by Rosten & Drummond
hcornerdet = vision.CornerDetector('Method','Local intensity comparison (Rosten & Drummond)', 'MaximumCornerCount', MAXPOINTS);

% Identify the salient points
points = step(hcornerdet, ROI);

% % Detect corners using a pixel-neighborhood intensity based method (Rosten
% %& Drummond. References for the method are contained in the help files for
% %fast_corner_detect_12 and fast_nonmax.
% firstPassPoints = fast_corner_detect_12(ROI, CORNERDETECTIONTHRESHOLD);

% % Perform non-maximal suppression of features.
% points = fast_nonmax(ROI, CORNERDETECTIONTHRESHOLD, firstPassPoints, MAXPOINTS);

% Extract X and Y points from salient points matrix
XPOINTS = points(:, 1) + xminROI; 
YPOINTS = points(:, 2) + yminROI;

% Release the corner detector
release(hcornerdet);


end










