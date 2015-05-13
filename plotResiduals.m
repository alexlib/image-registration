fSize = 14;

plot(xResiduals);
set(gcf, 'color', [1 1 1]);

xlim( [ 0 60 ] );
ylim([ 0 16 ] );

xlabel('Frame Number', 'FontSize', fSize);
ylabel('Horiziontal Residuals (Pixels)', 'FontSize', fSize);
title({'Difference between original and registered' ; 'features (residuals), horizontal component'}, 'FontSize', fSize)
set(gca, 'FontSize', fSize);

