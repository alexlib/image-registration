function OUTPUTS = defaultOptions(INPUTS)
% DEFAULTOPTIONS(INPUTS) sets default options for an image-registration
% job and ensures that all the necessary job-fields exist.

try

OUTPUTS = INPUTS; % Initialize output structure

% % Check Inputs and set defaults
% Set or initialize LOAD (1 or 0)
if isfield(INPUTS, 'LoadTemplateLocations')
    loadTemplateLocations = INPUTS.LoadTemplateLocations;
else
    loadTemplateLocations = 0;
end
OUTPUTS.LoadTemplateLocations = loadTemplateLocations; % Update data structure

% Set or initialize ShowTracking (1 or 0)
if isfield(INPUTS, 'ShowTracking');
    showTracking = INPUTS.ShowTracking;
else
    showTracking = 0;
end
OUTPUTS.ShowTracking = showTracking; % Update data structure

% Set or initialize ShowRegistration (1 or 0)
if isfield(INPUTS, 'ShowRegistration');
    showRegistration = INPUTS.ShowRegistration;
else
    showRegistration = 0;
end
OUTPUTS.ShowRegistration = showRegistration; % Update data structure

% Set or initialize SavePlots (1 or 0)
if isfield(INPUTS, 'SavePlots');
    savePlots = INPUTS.SavePlots;
else
    savePlots = 0;
end
OUTPUTS.SavePlots = savePlots; % Update data structure

%  Set or initialize Smoothing Window
if isfield(INPUTS, 'SmoothingWindow');
    smoothingWindow = INPUTS.SmoothingWindow;
else
    smoothingWindow = 5;
end
OUTPUTS.SmoothingWindow = smoothingWindow; % Update data structure

% Set or initialize whether to load previously tracked points
if isfield(INPUTS, 'LoadControlPoints');
        loadControlPoints = INPUTS.LoadControlPoints;
else
        loadControlPoints = 0;
end
OUTPUTS.LoadControlPoints = loadControlPoints; % Update data structure
% 
% % Set or initialize transformation type 
% if isfield(INPUTS, 'TransformationType')
%     transformationType = INPUTS.TransformationType;
% else
%     transformationType = 'affine'; % Default affine transformation
% end
% OUTPUTS.TransformationType = transformationType; % Update data structure

% Default to plotting every image during tracking and registration
if isfield(INPUTS, 'PlotEvery');
    plotEvery = INPUTS.PlotEvery;
else
    plotEvery = 1;
end
OUTPUTS.PlotEvery = plotEvery;

% Default to registering every image 
if isfield(INPUTS, 'RegisterEvery');
    registerEvery = INPUTS.RegisterEvery;
else
    registerEvery = 1;
end
OUTPUTS.RegisterEvery = registerEvery;

% Default to perform object tracking
if isfield(INPUTS, 'DoTracking');
    doTracking = INPUTS.DoTracking;
else
    doTracking = 1;
end
OUTPUTS.DoTracking = doTracking;



% Throw a keyboard error if something goes  haywire
catch ER
    fprintf(1, 'Error in defaultOptions.m ... \n%s\n', ER.message);
    keyboard; 
end % End whole-function try-catch wrapper

end