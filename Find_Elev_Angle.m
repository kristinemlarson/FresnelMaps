function [angle] = Find_Elev_Angle(up, RecSat)
%  [angle] = Find_Elev_Angle(Up, RecSat)
%  inputs:
%    receiver up unit vector and
%    vector from receiver to satellite in meters
%  outputs the elevation angle in radians
%
% Author: Kristine Larson

ang = acos(dot(RecSat,up) / (norm(RecSat)));
angle = pi/2-ang;
end
