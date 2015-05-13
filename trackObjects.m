function OUTPUTS = trackObjects(INPUTS)
% trackObjects(INPUTS) tracks the locations of template-specified
% objects in a series of images.
% 
% SYNTAX
%   OUTPUTS = trackObjects(INPUTS)
% 
% INPUTS
%   INPUTS is a data structure containing the following fields.
%   INPUTS.Inputs.FilePaths = Matrix whose row are strings corresponding to the file paths of the images to be registered
%   INPUTS.Inputs.SaveDir = Path to directory in which the registered images will be saved.
%   INPUTS.Options.LoadTemplateLocations =  Binary digit specifying whether load  pre-existing templates (1 = load, 0 = create new / save).
%   INPUTS.Options.LoadControlPoints; % Binary flag specifying whether or not to load the position histories of tracked points
%   INPUTS.Inputs.ColorChannel; % Color channel to use for object tracking (1, 2, or 3)
%   INPUTS.Inputs.WindowSize; % 2 x 1 vector specifying the height and width
%                   (pixels) of the size to make each search template (i.e., [height width] = [64 64])

%   INPUTS.Inputs.WindowScale; % Scaling factor between 0 and 1 to specify the ratio of the
%                 effective to actual window resolutions of the tracked objects after gaussian windowing 
%                  in the spatial domain. for tracked-object gaussian.
%                  WindowScale should be LESS THAN 1 so ensure that the
%                  gaussian window sizing function that Matt wrote doesn't
%                  get stuck in an infinite loop (ask him about this some time).
%   INPUTS.Inputs.maxPoints; % Maximum number of objects to track
%   INPUTS.Inputs.RPCDiameter; % Effective particle diameter used for the Robust Phase Correlation . 
%                   Larger diameters (around 6) seem to work well for non-particle images
%   INPUTS.Options.SmoothingWindow; % Size of the moving-average window (in time-steps) 
%                   with which to smooth the position histories of the tracked objects
%   INPUTS.Options.ShowTracking = Binary digit specifying whether or not to
%                       display images showing the locations of the tracked objects (1 = display images, 0 = suppress images). 
% 
% OUTPUTS
%   OUTPUTS.XPoints = nPoints-by-nImages matrix whose rows specify the horizontal
%                   (i.e., column) coordinates of the control points that were used to register the series of images. 
%                   nPoints is the number of control points that were used to register each image, and nImages is
%                   the number of images that were registered. This field
%                   is under "Outputs" becuase it is assumed to be an
%                   output of another code.
%   OUTPUTS.YPoints = nPoints-by-nImages matrix whose rows specify the vertical 
%                   (i.e., row) coordinates of the control points that were used to register the series of images.
% 
% SEE ALSO
%  registerTemplate, robustPhaseCorrelation, createTemplates, extractPoints, regionSelect

% try

% Suppress warnings
warning off all;
    
% Extract variables from input structure
filePaths = INPUTS.Inputs.FilePaths;      % matrix whose row are strings corresponding to the file paths of the images to be registered
saveDir = INPUTS.Inputs.RegisteredImageDirectory; % Save directory
colorChannel = INPUTS.Inputs.ColorChannel; % Color channel
windowSize = INPUTS.Inputs.WindowSize; % Template window size
windowScale = INPUTS.Inputs.WindowScale; % Scaling factor for tracked-object gaussian windowing filter
maxPoints = INPUTS.Inputs.MaxPoints; % Max points to track
rpcDiameter = INPUTS.Inputs.RPCDiameter; % RPC Diameter
cornerDetectionThreshold = INPUTS.Inputs.CornerDetectionThreshold; % Corner Detection Threshold
smoothingWindow = INPUTS.Options.SmoothingWindow; % Size of the moving-average window with which to smooth the position histories of the tracked objects
LoadTemplateLocations = INPUTS.Options.LoadTemplateLocations; % Save or load initial locations of templates within images?
loadControlPoints = INPUTS.Options.LoadControlPoints; % Binary flag specifying whether or not to load the position histories of tracked points
showTracking = INPUTS.Options.ShowTracking; % Display tracked images?
plotEvery = INPUTS.Options.PlotEvery; % Display every [plotEvery] image (i.e. every 5th image)
doTracking = INPUTS.Options.DoTracking; % Perform object tracking after object selection?

% Attempt to load control points
if(loadControlPoints && exist(fullfile(saveDir, 'TrackedPoints.mat'), 'file'));
            fprintf(1, 'Loading tracked points from %s ... \n \n', saveDir); %Inform the user
            load(fullfile(saveDir, 'TrackedPoints.mat')); % Load control points from file
% Save tracked points to output structure
            OUTPUTS.XPoints = XPoints;
            OUTPUTS.YPoints = YPoints;
else

    fprintf(1, 'Tracking control points... \n \n'); % Inform the user

    nImages = size(filePaths, 1); % Number of images
    firstImage = imread(filePaths(1, :)); % Read first image
    [ImageHeight ImageWidth] = size(firstImage);    % Size of images

    close all; %Close any open figures

% Determine whether to save or load data
    if(LoadTemplateLocations == 1 && exist(fullfile(saveDir, 'templates.mat'), 'file') == 2) ;
            load(fullfile(saveDir, 'templates')); % Load initial search region data from save directory
    else

    xPoints = 0; % Initialize the X points
    yPoints = 0; % Initialize the Y points
        
% Initialize the flag to select additional regions
        selectMoreRegions = 1;

%   Loop through regions to select until the user says "stop selecting regions"
        while selectMoreRegions == 1;

% Initialize flag to select search region   
            selectObjects = 0; 

% Select search region
            while selectObjects == 0; 
                fprintf(1, 'Select search region for templates, then press "enter" \n');  % Inform the user
                [xPointsTemp yPointsTemp] = extractPoints(firstImage, colorChannel, maxPoints, cornerDetectionThreshold);    % Select ROI from first image           
            
% Show the first image with the salient points identified   
                imshow(firstImage); 
                set(gcf, 'color', [0 0 0]);
                hold on; 
                plot(xPointsTemp, yPointsTemp, 'ob', 'MarkerSize', 5, 'LineWidth', 3); 
                title('Accept this search region? (press "enter" for yes,  0 to select a different region)?', 'FontSize', 14);
                replyAccept = input('Accept this search region? (press "enter" for yes,  0 to select a different region)? \n'); % Prompt the user to accept this search region
                if isempty(replyAccept) % If the user doesn't input a response....
                    replyAccept = 1; % Default to 'select a different region'
                end
                selectObjects = replyAccept; % Set the loop flag to the response of the user to the screen prompt
            end
        
% Add x and y points to the x - y points vector
            xPoints = cat(1, xPoints, xPointsTemp);
            yPoints = cat(1, yPoints, yPointsTemp);
        
            replyAnother = input('Select an additional region? (press "enter" for no, 1 to select an additional region) \n'); % prompt the user to select an additional region
            if isempty(replyAnother) % If the user doesn't input a response....
                replyAnother = 0; % Default to 'select a different region'
            end
            selectMoreRegions = replyAnother; % Set the loop flag to the response of the user to the screen prompt
        
        end
        
% Put the original zero (left over from variable initialization) at the end of the position vectors
        xPoints = circshift(xPoints, [-1 0]);
        yPoints = circshift(yPoints, [-1 0]);
        
% Ignore the initial zeros
        xPoints = xPoints(1: end - 1);
        yPoints = yPoints(1 : end - 1);
        
% Extract templates from image
        [xmin ymin width height xmax ymax Templates] = createTemplates(firstImage, xPoints, yPoints, windowSize);
        
% Save the initial search windows into the output directory.
        save(fullfile(saveDir, 'templates.mat'), 'xmin', 'ymin', 'width', 'height', 'xmax', 'ymax', 'Templates');
        fprintf(1, 'Saved template images and locations to %s \n', fullfile(saveDir, 'templates.mat')); %Inform the user of the save location
    end % End 'save or load templates' if-statement
    
    % Perform tracking if it was requested
    if doTracking == 1
        
        nObjects = numel(Templates); % Determine number of objects tracked
    
        fclose all; % Close any open figures 
    
% Make a new figure if object tracking will be plotted in real-time
        if showTracking == 1;
            figure(1) 
        end
    
% Perform template - image correlations
        XPoints = zeros(nImages, nObjects);    % Initialize matrix to hold x-center positions
        YPoints = zeros(nImages, nObjects);    % Initialize matrix to hold y-center positions
      
% Loop through images
        for n = 1:nImages; 
            fprintf(1, 'Tracking objects in image %06d ... \n', n); % Inform the user of the frame number being tracked
             Image = imread(filePaths(n,:)); % Load image

             if(showTracking == 1 && rem(n, plotEvery) == 0); % Make plots?
                hold off; 
                 set(gcf, 'Color', [0 ,0, 0]); % Set background color to black
                 set(gcf, 'InvertHardCopy', 'off'); % Set figures to not invert frame colors on export
                 imshow(Image); axis off    % Display image
                 hold on;
             end
         
% Initialize subregion search positions 
             xCorner = zeros(nObjects, 1);  
             yCorner = zeros(nObjects, 1);
             xCenter = zeros(nObjects, 1);
             yCenter = zeros(nObjects, 1);
         
% Loop through tracked features
            for k = 1:nObjects 
            
% Extract image subregion
            subRegion = Image(ymin(k) : ymax(k), xmin(k) : xmax(k), :); 
      
% Extract color channel from template
            Template = Templates{k}(:, :, colorChannel); 
            
% Extract channel from subregion
           subRegion =  double(subRegion(:, :, colorChannel)); 
  
% Find the location of the template within image using Robust Phase Correlation
           [xCorner(k) yCorner(k) xCenter(k) yCenter(k)] = registerTemplate(subRegion, Template, width(k), height(k), xmin(k), ymin(k), 'RPC', rpcDiameter, windowScale); 

% Update search region
            xminNew = xCorner(k);    % Left edge of the search window in the next image
            yminNew = yCorner(k);   % Top edge of the search window in the next image
            xmin(k) = round(min(xminNew, ImageWidth - width(k))); % Update variable for loop. If search window would exceed image dimensions, set search window edge as image edge.
            ymin(k) = round(min(yminNew, ImageHeight - height(k))); % Update variable for loop. If search window would exceed image dimensions, set search window edge as image edge.
            xmax(k) = xmin(k) + width(k) - 1; % Update max x position
            ymax(k) = ymin(k) + height(k) - 1; % Update max y position
            XPoints(n, k) = xCenter(k);  % x- Location of center of template within image
            YPoints(n, k) = yCenter(k);  % y- Location of center of template within image    
        
% Make plots if requested
             if(showTracking == 1 && rem(n, plotEvery) == 0); % Make plots?
                plot(xCenter(k), yCenter(k), 'ob', 'MarkerSize', 5, 'LineWidth', 3); % Mark thecenter of the template
            end

            end

% If making plots, pause briefly so that image sequence "plays" as a movie
            if showTracking == 1; % Make plots?
                drawnow
            end

        end
    
% initialize vector to hold smoothed X- and Y- positions of tracked points
        XPointsSmoothed = zeros(size(XPoints)); 
        YPointsSmoothed = zeros(size(YPoints));

% Smooth the X- and Y- position histories of each tracked object
        for k = 1:nObjects
            XPointsSmoothed(:, k) = smooth(XPoints(:, k), smoothingWindow); % Smooth x points with a moving average window of 5
            YPointsSmoothed(:, k) = smooth(YPoints(:, k), smoothingWindow); % Smooth y points with a moving average window of 5
        end

% Update x- and y- tracked points. Overwriting the raw track points might
% be a bad idea in case we ever want to go back and smooth them with some
% other type of filter. This should be fixed in a later revision.
        XPoints = XPointsSmoothed; 
        YPoints = YPointsSmoothed;
    
% Inform the user
        fprintf(1, '\n Saving tracked points to %s \n \n', fullfile(saveDir, 'TrackedPoints.mat')); 

% Save tracked points to output structure
        OUTPUTS.XPoints = XPoints;
        OUTPUTS.YPoints = YPoints;

% Save tracked points to file
        save(fullfile(saveDir, 'TrackedPoints.mat'), 'XPoints', 'YPoints'); 

        fprintf(1, 'Tracking Completed. \n \n'); % Inform the user that tracking has completed

    else % If tracking wasn't specified, set 'OUTPUTS' to an empty value
 
        OUTPUTS = [];
        
    end % End 'if doTracking is specified' if-statement 
 
end % End load-or-save tracked points loop

% Unsuppress warnings
warning on all;

% Throw a keyboard error if something goes haywire.
% catch ER
%     fprintf(1, 'Error in trackObjects.m ... \n%s\n', ER.message);
%     keyboard
% end % End whole-function try-catch wrapper

end

%%%%%%%%%%%%%%%%%
%%% END OF FUNCTION %%%
%%%%%%%%%%%%%%%%%



