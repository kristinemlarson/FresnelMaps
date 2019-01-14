function googleEarthFresnel(station, lat, long, realHt,elevAngle,azimrange, freq, varargin);
%function googleF(station,lat,long, realHt,elevAngle,azimrange, freq, varargin);
% creates a GooglE Earth KML file to draw the First Fresnel Zone 
%  (FFZ) ellipses 
%     at the selected  L-band frequency;
%     for each satellite elevation angles given in elevAngle.
%     for all the satellite ground tracks 
%         that are in the given azimuth range (azimrange)
%     on a flat surface at sea level (default)
%
% option: to input the Reflector Height (RH)
%     ie FFZ on a flat surface at a height RH below the Antenna
% ---------------------------------------------------------------------------
%
% INPUT : station:  station name 
%         lat : station latitude  in degrees
%         long: station longitude in degrees
%         realHt:  station ellipsoidal height in meters 
%         elevAngle: vector of satellite elevations  in degrees
%                  : ellipses drawn at these elevations 
%         azimrange: [min_azim  max_azim] satellite azimuth range
%                    in degrees [0 360]              
%         frequency: (1, 2, or 5):  L-band 
%
%--------------------------------------------------------------------------        
% DEFAULT: 
%         call: googleEarthFresnel(station, lat, long, realHt,elevAngle,azimrange, freq)
%          computes the FFZ ellipses on a surface at sea level.
%----------------------------------------------------------------------------
% OPTION: 
%    call:googleEarthFresnel(station, lat, long, realHt,elevAngle,azimrange, freq,RH)
%        varargin:  the reflector height (RH) in meters you want to use 
%        REGARDLESS of what the station's height is above sea level.
%        So for inland water bodies, this would be appropriate
%        It computes the FFZ ellipses 
%           on a flat surface at a height RH below the Antenna
%        
%--------------------------------------------------------------------------
% OUTPUT
%      creates a KML file: ssss.kml   (ie station_name.kml)
%      with the First Fresnel Zone ellipses
%--------------------------------------------------------------------------
% this code uses the EGM96 geoid correction to compute
% the  station height above sea level 
% 
% the approximate rising and setting satellite ground-track  azimuths
%    are in the file station.txt 
%    with 2 columns  [satellite_number  azimuth_track(deg)] 
%    if this file does not exist it is created with do_azims.m
%
% 18feb01, change inputs to allow frequency (instead of ArbitHt).  
%-----------------------------------------------------------------------
% AUTHOR: Kristine M. Larson and Carolyn Roesler, 2018-Feb-22                     
%----------------------------------------------------------------------


% check that legal L-bandfrequency is given
if ~ismember(freq, [1 2 5])
    disp(['Illegal frequency type: ' num2str(freq)])
    return
end

% check that azimrange has 2 elements
 
  if length(azimrange) < 2
    disp(' Error: the googleF.m input azimrange should be a 2-element array')
   return
  elseif azimrange(2) <= azimrange(1)
   disp( ' no FFZ, no ouput  ')
   disp( ' the input azimrange(1) should be smaller than azimrange(2)')
   return
  end
 


% use longitude 0-360
if long < 0
  long = long + 360;
end
if long < 0
  disp('Illegal longitude')
  return
end
if lat > 90 | lat < -90
   disp('Illegal latitude')
  return
end

% how many elevation angles will be plotted
nelevs = length(elevAngle);
% calculate geoid correction
geoidC = EGM96geoid(lat,long);
% 
ht = realHt - geoidC ;
fprintf(1,'\nStation: %s \nLatitude %12.4f \nLongitude %12.4f \n', station, lat, long);
fprintf(1, 'Ellipsoidal Ht (m)  %8.2f \n',realHt);
fprintf(1,'Above Sea Level (m) %8.2f \n', ht);
 
if length(varargin) == 1
  fprintf(1,'Override the sea level reflector height\n')
  ht = varargin{1} ;
  fprintf(1,'Using a reflector height of %6.2f (m)\n', ht);
  if ht < 0
   disp(' Error in googleEarthFresnel.m: the reflector height must be positive')
   return
  end 
else
  fprintf(1,'Use sea level reflector height\n')
end
% input azimuth file
azimfile = [station '.txt'];
if ~exist(azimfile)
  disp('no azimuth file, so one will be computed for you')
  do_azims(azimfile,lat, long, ht);
  if ~exist(azimfile)
    disp('Azimuth file was not created properly')
    return
  end
end

aztracks = load([station '.txt']);
[nr,nc]=size(aztracks);
% make header of the KML file
% open the output file and write out a header 
fid = googleHeader(station, lat, long, realHt, ht);
% loop through the elevation angles and azimuth angles
for j=1:nelevs
  for i=1:nr
    az = aztracks(i,2);
    sat = aztracks(i,1);
    if az > azimrange(1) & az < azimrange(2)
      googlefresnel_onefile(lat,long,elevAngle(j),az,sat,...
          station, ht, freq, fid,realHt)
    end
  end
end
fprintf(fid,'</Folder>\n');
% close out the KML file
fclose(fid);

