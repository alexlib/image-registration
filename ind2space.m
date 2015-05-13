function [xspace yspace] = ind2space(rPos, cPos, yregion, xregion)
%  [xspace yspace] = ind2space(rPos, cPos, yregion, xregion) shifts the position of data from its matrix-index position to its spatial position
% 
% INPUTS
%   cPos = Column position of data (index);
%   rPos = Row position of data (index); 
%   xregion = Width of each interrogation region (pixels)
%   yregion = Height of each interrogation region (pixels)
% 
% OUTPUTS
%   xspace = Horizontal spatial position of data
%   yspace = Vertical spatial position of data
% 
  
yspace = rPos - ceil(yregion / 2) - (1 - rem(yregion, 2) ) ;
xspace = cPos - ceil(xregion / 2) - (1 - rem(xregion, 2) );

end
