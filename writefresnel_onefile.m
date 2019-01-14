function writefresnel_onefile(fid, PRN, az, el,data,freq,Altitude)
%function writefresnel_onefile(fid, PRN, az, el,data,freq,Altitude)
%    appends the FFZ Google Earth coordinates (data)
%      to the KLM file with identifier(fid)
%----------------------------------------------------------
% INPUT
%      fid: KML filename
%        (satellite info)  
%      PRN: satellite number
%      el: satellite elevation angle (degrees)
%      az:  satellite azimuth angle (degrees [0-360])
%      data: FFZ ellipse in Google Earth coordinates [lat lon]
%      freq: (1, 2, or 5):  L-band frequency 
%      Altitude: ellipsoidal height, meters 
% OUTPUT
%      appends the FFZ Google Earth coordinates to the KML file
%
% REMARK: 
%      The FFZ ellipse complete specifications
%       are in googlefresnel_onefile.m
%----------------------------------------------------------------
% function called by googlefresnel_onefile.m
%---------------------------------------------------------------
% author: Kristine M. Larson and Carolyn Roesler
%---------------------------------------------------------------


fprintf(fid,'<Placemark>\n');
fprintf(fid,'<name>SV %2.0f %3f %2f', PRN, az, el); %SV ## AZd Eld
fprintf(fid,'</name>\n');
fprintf(fid,'<visibility>1</visibility>\n');

fprintf(fid,'<Style>\n');
fprintf(fid,'<geomColor>');
print_colorExt(fid, PRN,1);
fprintf(fid, '</geomColor>\n');

fprintf(fid,'<geomScale>2</geomScale>\n');
fprintf(fid,'</Style>\n');
% not sure i need these
%ch = '<altitudeMode>absolute</altitudeMode>\n';
%ch = '<altitudeMode>relativeToGround</altitudeMode>\n';
%fprintf(fid, ch);
ch = '<altitudeMode>clampToGround</altitudeMode>\n';
%ch='<tessellate>1</tessellate>';
fprintf(fid, ch);

fprintf(fid, '<LineString>\n');
fprintf(fid,'<coordinates>\n');
% write out the file  
% Google Earth does not like spaces between coordinates
[nr,nc]=size(data);
% I do not think you need Altitude, but It is here if you want
% to change the code.
calt = num2str(Altitude);
for i=1:nc
    % southern hemisphere
  if data(2,i) < 0
    if data(2,i) <= -10
      fprintf(fid, '%14.10f,%14.10f\n', data(1,i), data(2,i));
    else
      fprintf(fid, '%14.10f,%13.10f\n', data(1,i), data(2,i));
    end
  else
      % northern hemisphere
    if data(2,i) < 10
      fprintf(fid, '%14.10f,%12.10f\n', data(1,i), data(2,i));
    else
      fprintf(fid, '%14.10f,%13.10f\n', data(1,i), data(2,i));
    end
  end
end
fprintf(fid,'</coordinates>\n');
fprintf(fid,'</LineString>\n');
fprintf(fid,'</Placemark>\n');

end
