function imageRegistration(INPUTS)
%  imageRegistration(INPUTS) performs image registration based on a jobfile
%  that defines INPUTS. Information regarding each function herein is available in that function's help file. 

% Flag specifying whether or not to perform registration after object tracking
doRegistration = INPUTS.Options.DoRegistration;

% Check and format inputs (directory names, extensions)
INPUTS.Inputs = formatInputs(INPUTS.Inputs);

% Check and set default options
INPUTS.Options = defaultOptions(INPUTS.Options);

% Generate File paths
INPUTS.Inputs.FilePaths = makeRawImageFilepaths(INPUTS); 

%  Track Object Centroids 
INPUTS.Outputs.TrackedPoints  = trackObjects(INPUTS); % Track centroids of objects in series of images

%  Transform (register) images
if doRegistration
    transformImages(INPUTS);
end

end