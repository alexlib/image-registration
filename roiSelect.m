function [XMIN YMIN WIDTH HEIGHT XMAX YMAX TEMPLATEIMAGE] = roiSelect(IM)
% ROISELECT selects a rectangular region of interest within an image IM. 

imshow(IM);     % Display image
title('Select ROI that contains template');
% Select region of interest
h = imrect;
pause; 
pos = getPosition(h);
% Position, width, and height of ROI
XMIN = round( pos(1) );    % Min x position of ROI
YMIN = round( pos(2) );    % Min y position of ROI
WIDTH = round( pos(3) ) ;  % Width of ROI
HEIGHT = round( pos(4) );  % Height of ROI
XMAX = XMIN + WIDTH;    % Max x position of ROI
YMAX = YMIN + HEIGHT;   % Max y position of ROI
TEMPLATEIMAGE = IM(YMIN:YMAX, XMIN:XMAX);
WIDTH = size(TEMPLATEIMAGE, 2);
HEIGHT = size(TEMPLATEIMAGE, 1);

end