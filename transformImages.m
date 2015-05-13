function transformImages(INPUTS) % Perform to-first registration of a series of color images
% TransformImages(INPUTS)  registers a series of images via the Matlab Computer Vision toolbox
% 
% SYNTAX
%   TransformImages(INPUTS)
% 
% INPUTS
%   INPUTS is a data structure containing the following fields.
%
%   INPUTS.Inputs.StartImage = Number of the first image in the series (integer)
%
%   INPUTS.Inputs.StopImage = Number of the last image in the series (integer)
%
%   INPUTS.Inputs.StartStabilize = Number of the first image to register (integer). 
%                   This does not have to coincide with the field StartImage. 
%
%   INPUTS.Inputs.FilePaths = Matrix whose rows contain the filepaths that point to the images to be registered (strings).
%
%   INPUTS.Inputs.RegisteredImageBaseName = Base name of images to be registered (string)
% 
%   INPUTS.Inputs.RegisteredImageDirectory = Path to directory in which  registered images will be saved (string)
%
%  INPUTS.Inputs.NumberFormat; % Number format for registered images (i.e, '%05.0f')
%
%  INPUTS.Inputs.FileExtension; % File Extension for registered images (string, i.e., '.tif')
%
%   INPUTS.Options.TransformationType = String specifying the type of registration to be performed ('affine' or 'projective')
%
%   INPUTS.Outputs.TrackedPoints.XPoints = nPoints-by-nImages matrix whose rows specify the horizontal
%                   (i.e., column) coordinates of the control points that were used to register the series of images. 
%                   nPoints is the number of control points that were used to register each image, and nImages is
%                   the number of images that were registered. This field
%                   is under "Outputs" becuase it is generated as an
%                   output of another function.
%
%   INPUTS.Outputs.TrackedPoints.YPoints = nPoints-by-nImages matrix whose rows specify the vertical 
%                   (i.e., row) coordinates of the control points that were used to register the series of images.
%
% INPUTS.Options.ShowRegistration = Binary flag specifying whether or not to show
%                   registration as it is performed. This option is only allowed for single-processor jobs. 
%
% INPUTS.Options.nProcessors =  Number of processors to use for registration (integer)
%
% OUTPUTS
%   None; this function saves output images to files.
% 
% SEE ALSO
%  trackObjects

try
    
% Suppress warnings
warning off all;
    
fprintf(1, 'Registering images... \n \n'); % Inform the user

% Parse inputs
startImage = INPUTS.Inputs.StartImage; % First image in series
stopImage = INPUTS.Inputs.StopImage; % Last image in series
startStabilize = INPUTS.Inputs.StartStabilize;  % First image to register
filePaths = INPUTS.Inputs.FilePaths; % File paths to images
registeredImageBaseName = INPUTS.Inputs.RegisteredImageBaseName; % Registered Image Base Name
registeredImageDirectory = INPUTS.Inputs.RegisteredImageDirectory; % Directory to contain saved images
numberFormat = INPUTS.Inputs.NumberFormat; % Number format for registered images
fileExtension = INPUTS.Inputs.FileExtension; % File Extension
transformationType = INPUTS.Inputs.TransformationType; % Transformation type (affine or projective);
xPoints = INPUTS.Outputs.TrackedPoints.XPoints; % X-coordinates of match points
yPoints = INPUTS.Outputs.TrackedPoints.YPoints; % Y-coordinates of match points
showRegistration = INPUTS.Options.ShowRegistration; % Show registered images?
nProcessors = INPUTS.Options.nProcessors; % Number of processors to use
plotEvery = INPUTS.Options.PlotEvery; % Plotting increment
registerEvery = INPUTS.Options.RegisterEvery; % Registration Increment

% % % % TRANSFORM IMAGES % % % % %

close all % Close any open figures

% Don't display image registrations if parallel processing is used.
if nProcessors > 1
    showRegistration = 0;
end

% Read first image to extract size information
destinationImage = imread(filePaths(1, :)); % Load first image 
[imageHeight imageWidth nChannels] = size(destinationImage); % Image dimensions

% Construct transform estimator (i.e. transformation matrix)
if strcmp(transformationType, 'projective')
    geometricTransformEstimator = vision.GeometricTransformEstimator('ExcludeOutliers', false, 'Transform', 'Projective'); % Construct projective transform estimator
elseif strcmp(transformationType, 'affine')
    geometricTransformEstimator = vision.GeometricTransformEstimator('ExcludeOutliers', false, 'Transform', 'Affine'); % Construct affine transform estimator
else
    geometricTransformEstimator = vision.GeometricTransformEstimator('ExcludeOutliers', false, 'Transform', 'Nonreflective similarity'); % Construct similarity transform estimator (default)
end

hgt = vision.GeometricTransformer('InterpolationMethod', 'Bicubic'); %Construct geometric transformer

% Mapping points in destination image (map TO these)
destinationPointsX = xPoints(startStabilize - startImage + 1, :); % X-points in destination image
destinationPointsY = yPoints(startStabilize - startImage + 1, :); % Y-points in destination image
destinationPoints = [destinationPointsX; destinationPointsY]'; % Mapping points in destination image

% Register series of images

% % Close any open matlab pools
% if matlabpool('size') > 1
%     matlabpool close
% end
  
% Check the specified number of processors
if nProcessors > 1
    if matlabpool('size') < 1
     matlabpool(nProcessors); % Start a parallel processing pool if multiple processors have been specified
    end
% Begin parallel processing image registration
   parfor k = startStabilize - startImage + 1 : stopImage - startImage+ 1;
        try
            fprintf(1, 'Registering image %6.0f ... \n', k); % Print status 
            SourceImage = imread(filePaths(k, :)); % Image to deform

% Mapping points in source image (map FROM these)
            sourcePointsX = xPoints(k, :); % X-points in source image
            sourcePointsY = yPoints(k, :); % Y-points in source image
            sourcePoints = [sourcePointsX; sourcePointsY]'; % Mapping points in source image
            transformedImage = zeros(imageHeight, imageWidth, nChannels); % Initialize transformed image
            transformationMatrix = step(geometricTransformEstimator, sourcePoints, destinationPoints); % Construct projective transformation matrix

% Transform each color channel
          for n = 1:nChannels; 
            transformedImage(:, :, n) = step(hgt, double(SourceImage(:, :, n)), transformationMatrix); % Populate transformed image
          end
      
% Convert transaformed image to uint8 format
        transformedImage = uint8(transformedImage); 
      
% Save transformed image
         imwrite(transformedImage, fullfile(registeredImageDirectory,  [registeredImageBaseName num2str(k + startImage - 1, numberFormat) fileExtension])); 
        catch ER % Catch registration errors
            fprintf(1, 'Registration error: image %06.0f \n%s\n', k + startImage - 1, ER.message); % Inform user of error

        end % End parallel processing try-catch loop

   end % End parallel processing registration for-loop
   
%    matlabpool close; % Close the parallel processing pool
   
else % Begin single-processor image registration
      for k = startStabilize - startImage + 1 : registerEvery : stopImage - startImage+ 1;
        try
            fprintf(1, 'Registering image %6.0f ... \n', k); % Print status 
            SourceImage = imread(filePaths(k, :)); % Image to deform

% Mapping points in source image (map FROM these)
            sourcePointsX = xPoints(k, :); % X-points in source image
            sourcePointsY = yPoints(k, :); % Y-points in source image
            sourcePoints = [sourcePointsX; sourcePointsY]'; % Mapping points in source image
            transformedImage = zeros(imageHeight, imageWidth, nChannels); % Initialize transformed image
            transformationMatrix = step(geometricTransformEstimator, sourcePoints, destinationPoints); % Construct projective transformation matrix
%             Taugmented = transformationMatrix;
%             Taugmented(:, 3) = [ 0 0 1];

          for n = 1:nChannels; % Transform each color channel
            transformedImage(:, :, n) = step(hgt, double(SourceImage(:, :, n)), transformationMatrix); % Populate transformed image
          end

         transformedImage = uint8(transformedImage); % Convert transaformed image to uint8 format
         
% Show registered images
          if(showRegistration &&  rem(k, plotEvery) == 0) ; 
              close all % Close any open windows
              
% Make an overlaid plot of registered and original images
              cvexShowMatches(transformedImage(:, :, 1), destinationImage(:, :, 1)); 
              pause(1/100); % Pause to allow the images to plot
          end
      
% Save transformed image
      imwrite(transformedImage, fullfile(registeredImageDirectory,  [registeredImageBaseName num2str(k + startImage - 1, numberFormat) fileExtension]));

        catch ER% Catch registration errors
            fprintf(1, 'Registration error: image %06.0f \n%s\n', k + startImage - 1, ER.message); % Inform user of error

        end % End serial processing try-catch loop

      end % End serial processing registration for-loop
   
end
    
fprintf(1, 'Registrations complete. \n\n'); % Inform the user that the registration job has completed


% Unsuppress warnings
warning on all;

% Throw a keyboard error if something goes nuts.
catch ER
    fprintf(1, 'Error in transformImages.m ... \n%s\n', ER.message);
    keyboard;
end % End of whole-function try-catch loop

% Calculate the 


end % End of function

%%%%%%%%%%%%%%%%%%
%%%% END OF FUNCTION %%%
%%%%%%%%%%%%%%%%%%




