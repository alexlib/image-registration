function OUTPUTS = makeRawImageFilepaths(INPUTS)

try
    
% Read variables from structure
sourceImageDirectory = INPUTS.Inputs.SourceImageDirectory;  % Directory containing raw images
sourceImageBaseName = INPUTS.Inputs.SourceImageBaseName; % Basename of raw images
numberFormat = INPUTS.Inputs.NumberFormat; % Number format
fileExtension = INPUTS.Inputs.FileExtension; % Extension
startFile = INPUTS.Inputs.StartImage; % First image
stopFile= INPUTS.Inputs.StopImage;  % Last image
fileTrailer = INPUTS.Inputs.FileTrailer; % Text trailing the file number but preceeding the extension
imageStep = INPUTS.Inputs.ImageStep; % Step between images

% Make file paths
OUTPUTS = makeFilepaths(sourceImageDirectory, ...
    sourceImageBaseName, numberFormat, fileExtension, ...
    startFile, stopFile, fileTrailer, imageStep);

% Throw a keyboard error if something goes nutty
catch ER
    fprintf(1, 'Error in makeRawImageFilepaths.m ... \n%s\n', ER.message);
    keyboard
end

end