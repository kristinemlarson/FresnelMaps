function do_azims(azimfile, lat, long, h);
%function do_azims(azimfile, lat, long, h);
%
% purpose: find approximate azimuth of rising and setting 
%          arcs for GPS satellites
% REMARK:
%         satellites are hardwired to their values 
%         on doy 178 in the year 2016.
%--------------------------------------------------------
% INPUT: 
%     azimfile: name of the output file
%     GPS receiver station coordinates:
%        lat: station latitude, in degrees [-90 , 90]
%        long: station longitude, in degrees [-180 ,180]
%        h: station ellipsoidal height, in meters
%--------------------------------------------------------
% OUTPUT:
%        creates the file azimfile
%        with 2 columns:  col1: GPS satellite number 
%                         col2: approximate  azimuth of rising 
%                               and setting arcs 
%    (a GPS satellite has a maximum of 2 rising and 2 setting arcs)
%-----------------------------------------------------
%  AUTHOR: Kristine M. Larson and Carolyn Roesler, 2018-Feb-22
%  We thank Kai Borre for publishing his GPS navigation code,
%  which is described here: 
%  GPS Solutions, Volume 7, Number 1, 2003, pp 47-51, 
% "The Easy Suite - Matlab code for the GPS newcomer"  
% 
%-----------------------------------------------------
if lat > 90 | lat < -90
    disp('Latitude must be between -90 and 90')
    return
end
if long > 360 | long < -180
    disp('Longitude must be [0 360] or [-180 180]')
    return
end
% for now set maximum number of GPS satellites to 32
maxsat  = 32;  

% navigation file on doy 178 in the year 2016
navigation_file = 'auto1780.16n';
disp('read navigation file')
rinexe(navigation_file, 'temporary.dat');
Eph = get_eph('temporary.dat');
 
% GPS time for the nav file
[start_week,start_epoch]=GPSweek(2016,6,25,0,0,0);
 
% calculate XYZ, in meters
rec_pos=wgslla2xyz([lat long h]) ;
% calculate up vector
xo = cosd(lat)*cosd(long); yo = cosd(lat)*sind(long); zo = sind(lat);
up = [xo yo zo];
% calculate azimuth rotation matrix
azelM = [-sind(long)           cosd(long)          0   ;...
       -sind(lat)*cosd(long) -sind(lat)*sind(long) cosd(lat) ];

% timestep :  every 3 minutes    
interv = 60*3; % 3 minutes
endTime = start_epoch + 23.9*3600; % 23.9 hours
savedata = [];

% for all  satellites
for prn=1:maxsat
% for time 0 to time 23.9 (hours) 
  for time = start_epoch:interv:endTime
 
  % broadcast pick ephemeris, then call algorithm
    column = find_eph(Eph,prn,time);  
%   calculate Cartesian position of the satellite
    [sat_pos, ~] = satpos_Borre(time, Eph(:,column));
   
     ang = rad2deg(Find_Elev_Angle(up, sat_pos-rec_pos)); %CR missing CODE    
     uik = azelM*(sat_pos - rec_pos);
     azimuthA = 180*atan2(uik(1), uik(2))/pi;
     if azimuthA < 0
         azimuthA = azimuthA + 360;
     end
%    save all the data between 0 and 15 degree elevation angles
     if ang > 0 & ang < 15
         savedata = [savedata; prn ang azimuthA time-start_epoch];
     end
  end
end



x=savedata;
 
if length(savedata)==0
    disp('no data')
    return
end
lowValue = 5; % degrees 
rising = [];
setting = [];

% open the output file

fid2=fopen(azimfile, 'w'); 
for sat=1:maxsat
  i=find(x(:,1) == sat);
  if length(i) > 0
    xe = x(i,:);
%  when the satellite elevation angle crosses lowValue (5 degrees)
%   if the time series changes from negative to positive: arc rising
%   and vice versa: arc setting

    xe(:,2) = xe(:,2) -lowValue;
    [nr,nc ] = size(xe);
      
    for j=1:nr-1
      T = xe(j,4)/3600;
      az = xe(j,3);
      if xe(j,2) < 0 & xe(j+1,2) > 0
        fprintf(1,'Rise %2.0f azim %5.1f Time %5.1f UTC\n', ...
               sat, xe(j,3),xe(j,4)/3600);
        fprintf(fid2,'%2.0f %6.1f  \n', sat, az);
          rising=[rising ; sat az T ];
      elseif xe(j,2) > 0 & xe(j+1,2) < 0
         fprintf(1,'Set  %2.0f azim %5.1f Time %5.1f UTC\n', ...
               sat, az, T);
        fprintf(fid2,'%2.0f %6.1f \n', sat, az);
         setting=[setting; sat az T ];
      end
    end
  end
end
fclose(fid2);
fprintf(1,'OUTPUT went to: %s \n', azimfile);
fprintf(1,'Input Lat and Long: %8.3f %8.3f \n', lat, long);
end
