function FILE_PATHS = makeFilepaths(IMAGEDIRECTORY, ...
    IMAGE_BASE_NAME, NUMBER_FORMAT, FILE_EXTENSION, ...
    STARTFILE, STOP_FILE, FILE_TRAILER, IMAGE_STEP)
%  MAKEILEPATHS creates a vector whose rows contain the file-paths to
%  sequentially-numbered files

% File numbers
file_nums = STARTFILE : IMAGE_STEP : STOP_FILE;

% Number of files
nFiles = length(file_nums);

% Create array of strings containing paths to
for k = 1 : nFiles
    
   % File name
   file_name = [IMAGE_BASE_NAME num2str(file_nums(k), NUMBER_FORMAT) ...
       FILE_TRAILER FILE_EXTENSION];
    
   FILE_PATHS(k, :) = fullfile(IMAGEDIRECTORY, ...
       file_name);
end

end