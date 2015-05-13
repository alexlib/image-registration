function [XCORNER YCORNER XCENTER YCENTER] = registerTemplate(SEARCH, TEMPLATE, TX, TY, XMIN, YMIN,Corr,RPC_diam,RPC_weight)
% REGISTERTEMPLATE determines the position of a signal TEMPLATE within a
% subregion SEARCH of a larger signal.

%% Convert images to double precision
dSub = double(SEARCH);     % Convert subregion to double
dTemp = double(TEMPLATE);   % Convert template to double

%% Determine the dimensions of the template image
y=size(TEMPLATE,1); % y size of the template
x=size(TEMPLATE,2); % x size of the template
    
%% SCC
if strcmp(Corr,'SCC')
    subFilt = dSub - mean(dSub(:));     % Apply zero-mean filter to subregion
    tempFilt = dTemp - mean(dTemp(:));  % Apply zero-mean filter to template
    spatialCorr = xcorr2(subFilt, tempFilt);   % Spatial cross correlation
        
    %% Prana subplixel implmentation
    [xdisp,ydisp,~,~]=subpixel(spatialCorr,x*2-1,y*2-1,ones(size(spatialCorr)),3,0); % Subpixel peak location
    
    %% RPC
elseif strcmp(Corr,'RPC')
    [sx sy] = findGaussianWidth(x, y, RPC_weight*x, RPC_weight*y); % determine standard deviations for gaussian window
    windowFilter = gaussianWindowFilter([y x], [sx sy]); % Create windowing filter
    subWindow = windowFilter .* dSub; % Apply window to subregion
    tempWindow = windowFilter .* dTemp; % Apply window to template
    spectralRPC = robustPhaseCorrelation(subWindow,tempWindow,RPC_diam); % Phase correlation of the windowed images
    spatialCorr=freq2space(spectralRPC); % Convert spectral information back into the spatial domain
    
%     %% Matt's subpixle estimator function
%     [rowPeak columnPeak] = SubPixelEstimator(spatialCorr, subWindow,tempWindow); % Matt's function for subpixel estimation
%     xdisp=xpeak-x-.5;
%     ydisp=ypeak-y-.5;
    
    %% Prana subplixel implmentation
    [xdisp,ydisp,~,~]=subpixel(spatialCorr,x,y,ones(size(spatialCorr)),3,0); % Subpixel peak location
end

%% Update subregion information
XCORNER = XMIN + xdisp;    % x-Location of the top-left corner of the template within the image
YCORNER = YMIN + ydisp;    % y-Location of the top-left corner of the template within the image

XCENTER = XCORNER + TX / 2;    % x-location of center of template within the image
YCENTER = YCORNER + TY / 2;    % y-location of center of template within image

end