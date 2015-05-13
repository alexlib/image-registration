function batchRunImageRegistration()

% Specify some job options. This is user-editable.
color_channel = 1; % Color channel to use for template registration
rpc_diameter = 6; % RPC Diameter
corner_detection_threshold = 1000; % Corner Detection Threshold
show_tracking = 1; % Show tracking during processing?
show_registration = 0; % Show image registration during processing?
save_plots = 0; % Save residual plots?
window_size = [64 64]; % Template Window Size (pixels);
window_scale = 0.5; % Ratio of effective window resolution to actual window resolution of tracked images;
max_points = 50; % Max number of points to track
plot_every = 1; % Plotting increment (i.e., show every 5th image)
register_every = 1; % Registration increment (i.e., register every 5th image). This option is only valid for serial processing because parfor loops must increment by increasing consecutive integers.
num_processors = 1; % Number of processors to use for registering images

% Directory containing the raw images
raw_image_dir = '~/Desktop/sample_data/raw';

% Output directory
output_image_dir = fullfile(raw_image_dir, '..', 'reg');

% Base name of the raw images
raw_image_base_name = 'im_gray_';

% Number of digits in the raw image names
raw_image_number_format = '%04d'; 

% First image to register
start_image = 200;

% Last image to register
end_image = 299;

% Image increment
image_step = 5;

% Load template locations?
load_template_locations =0;

% Load control points?
load_control_points = 0;

% Do tracking?
do_tracking = 1;

% Do registration?
do_registration = 1;

% Registration scheme
% Enter 'sso' for similarity, 'sao' for affine
registration_scheme = 'sso';

%%%%%%%%%%%%%%%%%%%%%
% % % % END OF USER INPUTS % % %
%%%%%%%%%%%%%%%%%%%%%
% % % % % % You shouldn't need to change anything down here unless something is broken.

% Specify file format stuff
raw_image_extension = '.tif'; % Image extension
file_trailer = ''; % Image trailer (text that comes after numbers but before the extension)

% % % % % % BUILD DATA STRUCTURE
%  ---------------------------------------
% Build Registration Input Data Structure
Registration.Inputs.RawImageDir = raw_image_dir; % Base directory
Registration.Inputs.OutputImageDir = output_image_dir;
Registration.Inputs.BaseName = raw_image_base_name; % Base name
Registration.Inputs.NumberFormat = raw_image_number_format; % Number format of image files
Registration.Inputs.FileExtension = raw_image_extension; % Image extension
Registration.Inputs.StartImage = start_image; % Starting image
Registration.Inputs.StopImage = end_image; % Ending image
Registration.Inputs.ImageStep = image_step; % Image step
Registration.Inputs.StartStabilize = start_image; % First image to stabilize
Registration.Inputs.ColorChannel = color_channel; % Color channel
Registration.Inputs.FileTrailer = file_trailer; % Filename trailer
Registration.Inputs.WindowSize = window_size; % Template window size
Registration.Inputs.WindowScale = window_scale; % Window Scaling Factor
Registration.Inputs.RPCDiameter = rpc_diameter; % RPC Diameter
Registration.Inputs.MaxPoints = max_points; % Maximum number of points to track
Registration.Inputs.CornerDetectionThreshold = corner_detection_threshold; % Corner-detection threshold
Registration.Inputs.RegistrationScheme = registration_scheme; % Registration Scheme
Registration.Options.nProcessors = num_processors; % Number of processors
Registration.Options.ShowTracking = show_tracking; % Display tracked images?
Registration.Options.PlotEvery = plot_every; % Plotting increment
Registration.Options.RegisterEvery = register_every; % Registration increment
Registration.Options.ShowRegistration = show_registration; % Display registered images?
Registration.Options.LoadTemplateLocations = load_template_locations; %Save or load initial template locations within images?
Registration.Options.LoadControlPoints = load_control_points; % Load registration points from file?
Registration.Options.SavePlots = save_plots; % Save residual plots?
Registration.Options.DoTracking = do_tracking; % Perform tracking after object selection?
Registration.Options.DoRegistration = do_registration; % Perform registration?

% Run the image registration
imageRegistration(Registration);

end



