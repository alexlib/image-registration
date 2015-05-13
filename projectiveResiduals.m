function [projectiveTransformationResidualsX projectiveTransformationResidualsY] = projectiveResiduals(sourcePoints, destinationPoints, projectiveTransformationMatrix)

tForm = projectiveTransformationMatrix; %projective transformation matrix

sourcePointsX = sourcePoints(1, :);
sourcePointsY = sourcePoints(2, :);

nPoints = size(sourcePointsX, 2); % Number of control points

destinationPointsX = destinationPoints(1, :);
destinationPointsY = destinationPoints(2, :);

% transformedPointsX = ( tForm(1, 1) * sourcePointsX + tForm(1, 2) * sourcePointsY + tForm(1, 3) ) ./  ( tForm(3, 1) * sourcePointsX + tForm(3, 2) * sourcePointsY + 1);
% 
% transformedPointsY = ( tForm(2, 1) * sourcePointsX + tForm(2, 2) * sourcePointsY + tForm(2, 3) ) ./ ( tForm(3, 1) * sourcePointsX + tForm(3, 2) * sourcePointsY + 1 );
% 
% projectiveTransformationResidualsX = abs(destinationPointsX - transformedPointsX); % Calculate the horizontal (x) residual between the destination points and the transformed source points
% projectiveTransformationResidualsY = abs(destinationPointsY - transformedPointsY); % Calculate the vertical (y) residual between the destination points and the transformed source points
% 


transformed_homo = tForm * [sourcePointsX; sourcePointsY; ones(1, nPoints)]; %Transformed  coordinates (homogeneous)
w = repmat(transformed_homo(3, :), 3, 1); % Replicate third row of transformed  coordinates (homogeneous)
transformed_cart = transformed_homo ./ w; %Transformed  coordinates (cartesian)
transformedPointsX = transformed_cart(1, :); % Deformed x-coordinates (cartesian)
transformedPointsY = transformed_cart(2, :); % Deformed y-coordinates (cartesian)

projectiveTransformationResidualsX = abs(destinationPointsX - transformedPointsX);
projectiveTransformationResidualsY = abs(destinationPointsY - transformedPointsY);

end