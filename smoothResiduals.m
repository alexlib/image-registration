function OUTPUTS = smoothResiduals(INPUTS)
% Smooths residual plots

OUTPUTS = INPUTS.Outputs; % Initialize Outputs

affineResidualsX = INPUTS.Outputs.RegistrationResiduals.AffineResidualsX; % Affine residuals (X)
affineResidualsY = INPUTS.Outputs.RegistrationResiduals.AffineResidualsY; % Affine residuals (Y)

projectiveResidualsX = INPUTS.Outputs.RegistrationResiduals.ProjectiveResidualsX; % Projective residuals (X)
projectiveResidualsY = INPUTS.Outputs.RegistrationResiduals.ProjectiveResidualsY; % Projective residuals (Y)

smoothingWindow = INPUTS.Options.SmoothingWindow; % Smoothing window
savePlots = INPUTS.Options.SavePlots; % Save plots?
registeredImageDirectory = INPUTS.Inputs.RegisteredImageDirectory; % Directory containing registered images
nPoints = size(affineResidualsX, 2); % Number of control points

for k = 1:nPoints
    affineResidualsXSmoothed(:, k) = smooth(affineResidualsX(:, k), smoothingWindow); % Smooth affine residuals (X)
    affineResidualsYSmoothed(:, k) = smooth(affineResidualsY(:, k), smoothingWindow); % Smooth affine residuals (Y)
    projectiveResidualsXSmoothed(:, k) = smooth(projectiveResidualsX(:, k), smoothingWindow); % Smooth projective residuals (X)
    projectiveResidualsYSmoothed(:, k) = smooth(projectiveResidualsY(:, k), smoothingWindow); % Smooth projective residuals (Y)
end

if savePlots == 1;
    nicePlot(affineResidualsXSmoothed, [registeredImageDirectory 'affineResidualsXSmoothed.tiff'], 'Frame Number', 'Residual (Pixels)', 'Affine Transformation Residual (X)'); % Plot affine residuals (X)
    nicePlot(affineResidualsYSmoothed, [registeredImageDirectory 'affineResidualsYSmoothed.tiff'], 'Frame Number', 'Residual (Pixels)', 'Affine Transformation Residual (Y)'); % Plot affine residuals (Y)
    nicePlot(projectiveResidualsXSmoothed, [registeredImageDirectory 'projectiveResidualsXSmoothed.tiff'], 'Frame Number', 'Residual (Pixels)', 'Projective Transformation Residual (X)'); % Plot projective residuals (X)
    nicePlot(projectiveResidualsYSmoothed, [registeredImageDirectory 'projectiveResidualsYSmoothed.tiff'], 'Frame Number', 'Residual (Pixels)', 'Projective Transformation Residual (Y)'); % Plot projective residuals (Y)
end

OUTPUTS.RegistrationResiduals.AffineResidualsXSmoothed = affineResidualsXSmoothed; % Save smoothed affine residuals (X)
OUTPUTS.RegistrationResiduals.AffineResidualsYSmoothed = affineResidualsYSmoothed; % Save smoothed affine residuals (Y)

OUTPUTS.RegistrationResiduals.ProjectiveResidualsXSmoothed = projectiveResidualsXSmoothed; % Save smoothed projective residuals (X)
OUTPUTS.RegistrationResiduals.ProjectiveResidualsYSmoothed = projectiveResidualsYSmoothed; % Save smoothed projective residuals (Y)

end