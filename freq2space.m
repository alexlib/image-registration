function spatialCorr = freq2space(spectralCorr)
% FREQ2SPACE Shifts the zero-frequency component of a correlation in the spectral domain 
% to the center of spectrum, then transforms the correlation into the
% spatial domain.

% Calculate size of correlation matrix
[m n] = size(spectralCorr);

spatialCorr = abs(real(ifftn(spectralCorr, 'symmetric')));

% Shift zero-frequency component of cross-correlation to center of spectrum
xind = [ceil(n/2)+1:n 1:ceil(n/2)];
yind = [ceil(m/2)+1:m 1:ceil(m/2)];
spatialCorr = spatialCorr(yind, xind);

end