function fid = googleHeader(station, lat, long, ht, RefHt);
%function fid = googleHeader(station, lat, long, ht);
%-------------------------------------------------------
%  opens a KML file [station '.kml'] and writes a header
%-------------------------------------------------------
% INPUT:
%       station: station  name 
%       lat : station latitude  in degrees [ -90 90 ]
%       long: station longitude in degree  [ -180 180 ]
%       ht : station  height above sea level in meters  
%       Refht: vertical distance to the horizontal reflector (meters)
% OUTPUT
%       fileID for the KML file output
% KL 17dec08, fixed bug  
%------------------------------------------------------------- 
% function called by googleEarthFresnel.m
%--------------------------------------------------------------
% author Kristine M. Larson  and Carolyn Roesler, 2018-Feb-22
%-------------------------------------------------------------

% output goes to this file with this name.
filename = [station '_RefHt_' num2str(RefHt,'%3.0f') 'm.kml'];
% change to west-east longitude
fprintf(1,'Output goes to: %s \n', filename); 
fid = fopen(filename,'w');
fprintf(fid,'<Folder>\n');
fprintf(fid,'<Placemark>\n');
fprintf(fid,'<name>%s</name>\n',upper(station));
fprintf(fid,'<Point>\n');
if long < 180
  fprintf(fid,'<coordinates> %15.10f, %15.10f, %4.0f </coordinates>\n', long, lat, ht);
else
  fprintf(fid,'<coordinates> %15.10f, %15.10f, %4.0f </coordinates>\n', long-360, lat, ht);
end
fprintf(fid,'</Point>\n');
fprintf(fid,'</Placemark>\n');

end

