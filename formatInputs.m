function OUTPUTS = formatInputs(INPUTS)
% FORMATINPUTS formats inputs (verifies the exisitence of fields needed to run a
% registration job; creates output directories; sets inputs to default values if they have not been
% specified in the job file.

try
    
OUTPUTS = INPUTS; % Initialize output structure

% Input image directory
input_dir = INPUTS.RawImageDir;

% Output directory
output_dir = INPUTS.OutputImageDir;

% Base name of the input images
soure_image_base_name = INPUTS.BaseName;
    
% Add 'dot' to extension
fileExtension = INPUTS.FileExtension; % Read field from input structure
if ~strcmp(fileExtension(1), '.'); % Check for 'dot'
    fileExtension(end+1) = '.'; % Add 'dot'
    fileExtension = circshift(fileExtension, [0 1]); % Move 'dot' to first position
end
OUTPUTS.FileExtension = fileExtension; % Update output structure

% Set default (empty) trailer if it is not passed with the input Data structure
if isfield(INPUTS, 'FileTrailer');
   fileTrailer = INPUTS.FileTrailer;
else
   fileTrailer = ''; % Default to empty string
end
OUTPUTS.FileTrailer = fileTrailer;

% Set or initialize STEP 
if isfield(INPUTS, 'ImageStep')
    imageStep = INPUTS.ImageStep;
else
    imageStep = 1; % Default step to 1 (register every image)
end
OUTPUTS.ImageStep = imageStep; % Update data structure

% Set or initialize template windowing function scaling factor
if isfield(INPUTS, 'WindowScale')
    windowScale = INPUTS.WindowScale;
else
    windowScale = 0.5; % Default window scale of 0.5
end
OUTPUTS.WindowScale = windowScale; % Update data structure

% Set or initialize template windowing function scaling factor
if isfield(INPUTS, 'RPCDiameter')
    rpcDiameter = INPUTS.RPCDiameter;
else
    rpcDiameter = 6; % Default RPC Diameter of 6 pixels
end
OUTPUTS.RPCDiameter = rpcDiameter; % Update data structure


% Default to corner detection threshold of 15
if isfield(INPUTS, 'CornerDetectionThreshold');
    cornerDetectionThreshold = INPUTS.CornerDetectionThreshold;
else
    cornerDetectionThreshold = 15; % Default to corner detection threshold of 15
end
OUTPUTS.CornerDetectionThreshold = cornerDetectionThreshold;

% Default to affine transformation scheme
if isfield(INPUTS, 'RegistrationScheme');
    registration_scheme = INPUTS.RegistrationScheme;
else
    registration_scheme = 'sso'; % Default to similarity
end
OUTPUTS.RegistrationScheme = registration_scheme;

% Default to track at most 30 points
if isfield(INPUTS, 'MaxPoints');
    maxPoints = INPUTS.MaxPoints;
else
    maxPoints = 30; % Default to tracking 30 points
end
OUTPUTS.MaxPoints = maxPoints;

% Set transformation type to reflect scheme input % affine or projective)
% The second letter in the "scheme" tag specifies affine ('a') or
% projective ('p');
if strcmp(registration_scheme(2), 'p')
    TRANSFORMATIONTYPE = 'projective'; % Set transformation type to projective
elseif strcmp(registration_scheme(2), 'a') 
    TRANSFORMATIONTYPE = 'affine'; %Default Set transforation type to affine
elseif strcmp(registration_scheme(2), 's')
    TRANSFORMATIONTYPE = 'similarity'; % Set transformation type to similarity 
else
       registration_scheme = 'sso';
       TRANSFORMATIONTYPE = 'similarity'; %Default Set transforation type to affine
      fprintf(1, 'Scheme type not found. Defaulting to similarity transformation.\n \n'); % Throw an error if the scheme type isn't found 
end

OUTPUTS.TransformationType = TRANSFORMATIONTYPE; % Update transformation type in data structure
OUTPUTS.RegistrationScheme = registration_scheme; % Update Scheme in data structure

%Specify directories
OUTPUTS.SourceImageDirectory = input_dir; % Directory containing source (input) images

% Directory to contain registered (output) images
registeredImageDirectory = fullfile(output_dir); 
OUTPUTS.RegisteredImageDirectory = registeredImageDirectory; 

% Create save directory if it doesn't exist yet
if exist(registeredImageDirectory, 'dir') ~= 7; % Check existence
    mkdir(registeredImageDirectory); % Make directory
end

% Base name of the input images
OUTPUTS.SourceImageBaseName = soure_image_base_name; 

% Base names of registered (output) images
OUTPUTS.RegisteredImageBaseName = [soure_image_base_name registration_scheme '_']; 

% Throw a keyboard-error if something goes awry.
catch ER
    fprintf(1, 'Error in formatInputs.m ... \n% s\n', ER.message);
    keyboard
end % End whole-function try-catch wrapper


end
