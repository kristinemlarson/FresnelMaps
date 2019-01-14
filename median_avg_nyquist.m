function median_avg_nyquist(station,lat,long,h,sampI,eangles, varargin)
 %function median_avg_nyquist(station, lat, long, h, samplingInterval, eangles,RH);
% the goal of this code is help you figure out which sampling interval
% to use for your GNSS-IR experiment. It first calculates 
% INPUTS
%     station: 4 character ID
%     lat: latitude, in degrees
%     long: longitude, in degrees
%     h: ellipsoidal height, in meters
%     sampI: receiver sampling interval in seconds
%     eangles: elevation angle limits in degrees, i.e. [5 15] or [5 25]
%
%     variable argument input is frequency (1, 2, or 5). If no input, l1 is
%     used.
% OUTPUTS:
%     printed to the screen. 

% set for GPS only
if length(varargin) == 1
  fc = varargin{1};
  if fc == 2 | fc == 5
    [cf,ic ] = get_waveL(fc);
  end
else
  % Use L1 as the default
   fc = 1;
  [cf,ic ] = get_waveL(fc);
end
    
maxsat = 32; 
desiredPrecision = 0.01; % 1 cm
fprintf(1,'\nStation: %s \nLatitude %12.4f \nLongitude %12.4f \n', station, lat, long);
fprintf(1, 'Ellipsoidal Ht  %8.2f \n',h);
fprintf(1, 'Frequency L%1.0f \n',fc);


% savedata = [prn ang azimuthA time-start_epoch];
% rise are returned setting separately
% use maxElevAngle of 25 for calculating the orbits. We will 
% later window to the limits you asked for.
maxElevAngle = 25; % in degrees
disp('Simulating orbits - this can be a little slow')
[rise,setting,savedata] = predict_ephem(station, lat, long, h,sampI, maxElevAngle);
% combine the rising and setting data
rise = [rise; setting];
 
sd = savedata;
fnsave=  [];
j=1; % originally the code could do multiple sets of 
% elevation angles. Here I set it to just 1 set.
minElevAngle = eangles(j,1);
maxElevAngle = eangles(j,2);
diffEcrit = (maxElevAngle - minElevAngle) -2;
allNy  = [];  
fprintf(1,'Individual Rising and Setting Arc Nyquist values \n');

for sat = 1:maxsat
  i = find(sat == rise(:,1));
  if length(i) > 0
    tmp = rise(i,:);
    for k=1:length(i)
      % store the azimuth and timing information
      azi = tmp(k,2); t = tmp(k,3); riseset =  tmp(k,4);
% pick up the data near this azimuth
      dd = abs(savedata(:,3) - azi );
%      find data within 20 degrees of azimuth and using elevation angle
%      limits
      kk = find(sd(:,1) == sat & dd < 20 & sd(:,2) > minElevAngle & sd(:,2) < maxElevAngle);
      elevAngles= savedata(kk,2);
      sineE = sind(savedata(kk,2));
      diffT = ( max(sineE) - min(sineE) )/cf;
      diffE =  max(elevAngles) - min(elevAngles);
      N = length(elevAngles); % number of obs
%     average nyquist in reflector height space
%     this is what you would have if you had all the data
      AvgNyq = N/(2*diffT)  ;         
      if diffE > diffEcrit
          fprintf(1,'PRN %2.0f Azim. %6.2f  Nyquist %7.2f (m) %s ElevAngles: %3.0f %3.0f \n', ...
              sat, azi, AvgNyq, riseORset(riseset), minElevAngle, maxElevAngle);
          allNy = [allNy; AvgNyq];
      end
    end % multiple arcs
  end % if you found any data for that satellite
end % for satellites
fprintf(1,'----------------------------------------------------------------------\n'); 
fprintf(1,'Station %s Median Average Nyquist using %3.0f sec receiver sampling: %6.1f (m) \n', ...
  station, sampI, median(allNy));
fprintf(1,'----------------------------------------------------------------------\n'); 
end

