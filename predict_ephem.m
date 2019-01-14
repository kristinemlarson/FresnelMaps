function [rising,setting,savedata ] = predict_ephem( station, lat, long, h, seconds,maxE )
% author: Kristine M. Larson  
% INPUTS:
%     station: 4 character ID
%     lat: latitude, in degrees
%     long: longitude, in degrees
%     h: ellipsoidal height, in meters
%     seconds: time increment
%     max elevation angle being considered for each track (degrees)
% OUTPUTS:
c = 299792458; %speed of light in m/s
maxsat  = 32;
rising=[]; setting = []; savedata = [];
maxElevAngle = maxE;

% use code from Kai Borre to read the navigation message & compute orbits
navfile = 'auto1780.16n';
if exist(navfile)
  disp('read navigation file')
  rinexe(navfile, 'temporary.dat');
else
  disp('nav file does not exist')
  return
end

Eph = get_eph('temporary.dat');

% GPS time of the nav file
[start_week,start_epoch]=GPSweek(2016,6,25,0,0,0);

% calculate XYZ, in meters
rec_pos=wgslla2xyz([lat long h]) ;
% calculate up vector
xo = cosd(lat)*cosd(long); yo = cosd(lat)*sind(long); zo = sind(lat);
up = [xo yo zo];
% calculate azimuth rotation matrix
azelM = [-sind(long)           cosd(long)          0   ;...
       -sind(lat)*cosd(long) -sind(lat)*sind(long) cosd(lat) ];
%  
interv = seconds; 

endTime = start_epoch + 23.95*3600; % 23.9 hours
savedata = [];
% for all 32 satellites
for prn=1:maxsat
    fprintf(1,'Checking satellite %2.0f \n', prn);
% for time 0 to time 23.95 (hours)
  for time = start_epoch:interv:endTime

  % broadcast pick ephemeris, then call algorithm
    column = find_eph(Eph,prn,time);
%   calculate Cartesian position of the satellite
    [sat_pos, ~] = satpos_Borre(time, Eph(:,column));
%   approximate transmission time correction.  
     tau = norm(sat_pos-rec_pos)/c  ;
    [sat_pos, ~] = satpos_Borre(time-tau, Eph(:,column));
   % elevation angle
     ang = rad2deg(Find_Elev_Angle(up, sat_pos-rec_pos));   % in radians i believe
     uik = azelM*(sat_pos - rec_pos);
     azimuthA = 180*atan2(uik(1), uik(2))/pi;
     if azimuthA < 0
         azimuthA = azimuthA + 360;
     end
%    save all the data between 5 and 25 degree elevation angles
     if ang >= 0 & ang <=  maxElevAngle
         savedata = [savedata; prn ang azimuthA time-start_epoch];
     end
  end
end



x=savedata;

if length(savedata)==0
    disp('no data')
    return
end
lowValue = 5;
rising = [];
setting = [];

%  
for sat=1:maxsat
  i=find(x(:,1) == sat);
  if length(i) > 0
    xe = x(i,:);
    xe(:,2) = xe(:,2) -lowValue;
    [nr,nc ] = size(xe) ;

    for j=1:nr-1
      T = xe(j,4); az = xe(j,3); el=xe(j,2);
%       fprintf(1,'%2.0f %8.0f %6.2f %5.1f \n', sat, T, az,el);
      if xe(j,2) < 0 & xe(j+1,2) > 0
       % disp(['rising sat' num2str(sat)]);
        fprintf(1,'%2.0 %2.0f %5.1f %10.0f \n', 1, sat, az, T);
        rising=[rising ; sat az T  1 ];
      elseif xe(j,2) > 0 & xe(j+1,2) < 0
        % disp(['setting sat' num2str(sat)]);
        fprintf(1,'%2.0  %2.0f %5.1f %10.0f \n', -1, sat, az, T);
        setting=[setting; sat az T -1 ];
      end
    end
  end
end
end


