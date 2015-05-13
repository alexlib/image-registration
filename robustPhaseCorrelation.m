function spectralRPC = robustPhaseCorrelation(A, B, RPCDIAMETER)
% robustPhaseCorrelation performs robust phase correlation of two 
% 2-D signals and returns the output in the spectral domain. 
% 
% INPUTS
%   A = First signal to be correlated. This signal remains stationary during the correlaiton. 
%   B = Second signal to be correlated. This signal is shifted during the correlation. 
% 
% OUTPUTS
%   spectralRPC = Robust phase correlation of A and B in the spectral domain.
% 
% SEE ALSO
%   crossCorrelation, phaseCorrelation, spectralEnergyFilter, fftshift,

% Calculate size of domain (pixeld)
[yregion xregion] = size(A);

% Phase-only-filtered cross correlation in the spectral domain
spectralPhaseCorr = phaseCorrelation(A, B);

% Shift quadrants of spectral phase correlation in preparation for convolution
spectralPhaseCorr_shift = fftshift(spectralPhaseCorr);

% Generate spectral energy filter
spectralFilter = spectralEnergyFilter(xregion,yregion, RPCDIAMETER);

% Convolve spectral energy filter with spectral phase correlation
spectralRPC = spectralPhaseCorr_shift .* spectralFilter;

end
