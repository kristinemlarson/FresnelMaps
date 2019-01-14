function mapview_fresnel_toolbox(station,mapeangles,filename,freq, RH,varargin)
%---------------------------------------------------------------------
%function mapview_fresnel_toolbox(station,mapeangles,filename,freq, RH,varargin)
%  Draws First Fresnel Zone ellipses 
%  at the selected  L-band frequency;
%  on a flat surface at a height RH below the Antenna;
%  for each satellite tracks (aproximate azimuths) given in filename; 
%  and for each elevation angles given in mapeangles. 
%--------------------------------------------------------------------
%
% INPUT
%      station: station name 'ssss' 4 letter ID 
%      mapeangles : elevation angle vector: (degrees)
%                 : ellipses drawn at these elevations 
%      filename:  file  with the azimuths of the 
%        rising and setting GPS satellite tracks. format of the file: 
%        column1: sat_Number  (PRN)
%        column2: approx. azimuth (degrees)  
%      freq:  1, 2 or 5 : for L-band frequency (L1,L2, or L5) 
%      RH: reflector heights in meters
%
%  varargin: is the  x-axis limit Xlim, in meters 
%            map extends to [-Xlim Xlim]  in both directions 
%                                        
%-----------------------------------------------------------------------
% OUTPUT
%         plot goes to ssss_mapview.png
%------------------------------------------------------------------------
% REMARK
%       If an azimuth file does not exist you can create it with do_azims.m 
%-----------------------------------------------------------------------
% Author : Kristine M. Larson and Carolyn Roesler 2018-Feb-22 
%-----------------------------------------------------------------------

% FontSize for the plot
FS = 12;

% check that legal L-bandfrequency is given
if ~ismember(freq, [1 2 5])
    disp(['Illegal frequency type: ' num2str(freq)])
    return
end
% check that RH is positive
if RH < 0
   disp([' Error in mapview_fresnel_toolbox.m : ',...
         'the reflector height RH must be positive'])
   return
end 

name1=[station '_mapview_' num2str(RH) 'm.png'];
disp(['output goes to ' name1]);
if exist(filename)
  ntracks=load(filename);
  % number of satellite tracks
  N=length(ntracks);
  if N==0
    disp('No data in your satellite track file');
    return
  end
else
  disp(['The satellite track file ' filename ' does not exist']);
  disp(['Use do_azims.m to create one.'])
  return
end

% number of elevation angles
nr = length(mapeangles);
if length(nr) < 1 
    disp('no positive elevation angles were provided')
    return
end
figure
set(gcf,'defaultaxesfontsize',FS);
% colors for different elevation angles
cc = varycolor(nr);
for i=1:N
  for k=1:nr
    icolor=cc(k,:);
    az = ntracks(i,2); % azimuth
    % get the size and center of the ellipse
    xx= FresnelZone(freq, mapeangles(k), RH, az);
    % restore the values
    A = xx(1); B = xx(2); Ctr = xx(3);   
    plot_the_ellipse(az,A,B,Ctr, icolor);    
  end
end
% make a simple legend for the elevation angles
leg = [];
for k=1:nr
  leg = [leg ; sprintf('%02d', mapeangles(k) )];
end
legend(leg);
% the GPS antenna is at the center of the plot and marked by the plus
% symbol
plot(0,0,'k+');
xlabel('meters'); ylabel('meters')
title(['Mapview ' station '- Fresnel zones -ReflHt. ' ...
    num2str(RH) 'm - L' num2str(freq) 'Freq'],'Fontweight','Normal');
% set the y and x limits, if desired
if length(varargin) == 1
  xl=  varargin{1};
  ylim([-xl xl]); xlim([-xl xl]);
end
grid on
axis equal
% save the plot to a png file
print('-dpng',name1)
