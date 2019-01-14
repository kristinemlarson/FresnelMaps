function googlefresnel_onefile(lat,lon,el,az,PRN,station, ht, freq,fid,Altitude)
%function googlefresnel_onefile(lat,lon,el,az,PRN,station, ht, freq,fid)
%    converts First Fresnel Zone (FFZ) local coordinates to Google Earth format
%    and appends them to the KML file with identifier(fid)
%---------------------------------------------------------------------
%    uses the FFZ ellipse:  for station;
%        at the selected  L-band frequency;
%        for satellite PNR with elevation angle (el) and azimuth (az);
%        on a flat surface at a height (ht) below the antenna
% 
%--------------------------------------------------------------------  
% INPUT:
%            (station info)
%        station:  a 4 character ID
%        lat: station latitude (degrees)
%        lon: station longitude (degrees)
%            (satellite info)   
%        PRN: satellite number
%        el: satellite elevation angle (degrees)
%        az:  satellite azimuth angle (degrees [0-360])
%
%        ht: antenna height ( meters)
%        freq: (1, 2, or 5):  L-band frequency 
%        fid: is the  file id for output
%        Altitude: ellipsoidal height (meters)
%
% OUTPUT
%      appends the FFZ coordinates in Google Earth format
%      to the KML file with identifier(fid)
%----------------------------------------------------------------
%  function called by googleF.m
%           uses writefresnel_onefile.m
%---------------------------------------------------------------
% author: Kristine M. Larson  and Carolyn Roesler, 2018-Feb-22
%---------------------------------------------------------------


%Radius of Earth, average
R=6378.14; %km

% use Felipe Nievinski's calculation for first Fresnel Zone
if ht < 0
   disp([' Error in googlefresnel_onefile.m: ',...
         'the reflector height must be positive'])
   return
end 

F = FresnelZone(freq, el, ht, az);
if isempty(F)
 disp(' no FFZ zone')
 return
end
% ellipse size
a=F(1); 
b=F(2) ;
center=F(3) ;
%Calculate the relative x and y positions for points along the Fresnel
%ellipse.  
%Convert az to proper angle for use in ellipse. azimuth is typically
%measured clockwise with north as zero, ellipse is a cartesian system which
%is counter-clockwise and east is zero.

azcart=360-az+90;
if azcart>360
    azcart=azcart-360;
end
%convert aznew to radians
azcart=azcart*pi/180;
% number of points in the ellipse
Nb = 150;
% put the ellipse into Google Earth coordinates
[x y]=ellipseGE(a,b,azcart,center*cos(azcart),center*sin(azcart),'b',Nb) ;
%for i=1:length(x)
%  fprintf(1,'%15.10f %15.10f \n', x(i), y(i));
%end

%for each of the x-y coordinates, calculate the distance from the antenna,
%the bearing angle relative to the antenna in order to solve for the
%latitude and longitude of each point.


d=sqrt(x.^2+y.^2); %meters ; 
d=d./1000; %km

%Calculate bearing angle. This is reference similiarly as azimuth i.e.
%clockwise from north.

theta=atan2(x,y);
k=find(theta<0);
theta(k)=theta(k)+2*pi;
theta=theta*180/pi;

%new lat and lon
latnew=asin(sind(lat).*cos(d./R)+cosd(lat).*sin(d./R).*cosd(theta));
lonnew=lon+180./pi.*(atan2(sind(theta).*sin(d./R).*cosd(lat),cos(d./R)-sind(lat).*sin(latnew)));
latnew=latnew.*180./pi;
data=[lonnew;latnew];

azd=azcart*180/pi;
% write out the Fresnel zone coordinates to Google Earth format.
writefresnel_onefile(fid, PRN, az, el,data,freq,Altitude)

end
