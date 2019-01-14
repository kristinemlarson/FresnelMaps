clear
close all
% Median Average Nyquist examples
% please note that this code will go relatively slowly for 5 second
% sampling.  It will go really really slowly if you use 1 second.
% Also note that this is a fairly linear calculation. If 10 second
% receiver sampling yields a median average Nyquist 
% of 50 meters, then 5 second receiver sampling will yield 100 meters.


% RH = 68 meters is the approximate reflector height 
% value for GPS site AC12 because
% that is the vertical distance between AC12 and sea level
sampI = 5; % sampling interval of the GPS receiver in seconds
eangles = [5 12]; % min and max elevation angles

median_avg_nyquist('ac12',  54.830970, 200.410460,83.8, sampI,eangles)
% output
%----------------------------------------------------------------------
%Station ac12 Median Average Nyquist using   5 sec receiver sampling:   88.3 (m) 
%----------------------------------------------------------------------
% This means 5 second receiver sampling will meet the Nyquist requirements 
 
sampI = 15; % seconds
eangles = [5 25]; % desired RH is 2 meters
median_avg_nyquist('p041',39.949492,254.805734,1728.80,sampI,eangles)
% this is for L1 frequency
% output
%----------------------------------------------------------------------
%Station p041 Median Average Nyquist using  15 sec receiver sampling:   30.9 (m) 
%----------------------------------------------------------------------

% This means that 5 seconds will be a sufficient sampling interval
% to achieve the needed value of 2 meters.

% example of a sampling scenario that fails
sampI = 30;
eangles = [5 15]; % Let's say the desired RH is 15 meters
median_avg_nyquist('p041',39.949492,254.805734,1728.80,sampI,eangles)
% this is for L1 frequency
% output
%----------------------------------------------------------------------
%Station p041 Median Average Nyquist using  30 sec receiver sampling:   16.0 (m) 
%----------------------------------------------------------------------
% This Nyquist is too close to your target of 15.

% google Earth map examples
%In this example we input reflector height of 2 meters and L1 frequency
% only use two elevation angles, 5 and 10 degrees.
% all azimuths, [0 360];
f =1 ;
RH = 2;
googleEarthFresnel('p041',39.949492,254.805734,1728.80, [5 10],[0 360],f,RH)
% screen output.....
%   Station: p041 
%   Latitude      39.9495 
%   Longitude     254.8057 
%   Ellipsoidal Ht   1728.80 
%   Above Sea Level  1744.65 
%   Override the sea level reflector height
%   Using a reflector height of   2.00 (m)
%   Output goes to: p041_RefHt_2m.kml 



% In this example we use sea level as the reflector. l1 frequency 
f = 1; % all azimuiths [0 360] and three elevation angles [5 10 15]
googleEarthFresnel('ac12',54.830970,200.410460,83.8, [5 10 15],[0 360], f)
% screen output......
%   Station: ac12 
%   Latitude      54.8310 
%   Longitude     200.4105 
%   Ellipsoidal Ht     83.80 
%   Above Sea Level    67.55 
%   Use sea level reflector height
%   Output goes to: ac12_RefHt_68m.kml 

% if you have a file of satellite azimuths in the file ssss.txt, it will
% use those. Otherwise, googleEarthFresnel.m,  will compute them for your coordinates and 
% a sample day (code: do_azims.m) 

%---------------------------------------------------------------------------
% you need to have a list of the rising and setting satellite arcs
% here they are stored in the file p041.txt, where the first column
% is satellite number and second column is the approximate azimuth.
% if you do not have that file, you can create it using do_azims.m

% flat map view plots - here I am using L1, reflector height of 2 meters.
% it expects the rising and setting azimuths to be in a file called
% p041.txt.
mapview_fresnel_toolbox('p041',[5 10 15 20 25], 'p041.txt',1,2)
% output goes to p041_mapview_2m.png

% flat map view plots - here I am using L1, reflector height of 10 meters.
mapview_fresnel_toolbox('p041',[5 10 15 20 25], 'p041.txt',1,10)
% output goes to p041_mapview_10m.png


% ac12, use 67 meters (from screen output given by googleEarthFresnel )
mapview_fresnel_toolbox('ac12',[5 7 10], 'ac12.txt',1, 68)
%output goes to ac12_mapview_68m.png
