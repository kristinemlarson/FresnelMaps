function [firstF] = FresnelZone(freq, e, h, theta)
%------------------------------------------------------------------
% function [firstF] = FreneslZone(freq, e, h, theta)
%   This function gets the size and center of the First Fresnel Zone ellipse
%     at the selected  L-band frequency  (freq)
%     for an Antenna height (h) above the flat reflecting surface
%     for a satellite elevation angle (e) and azimuth direction (theta)
%
%      (this code assumes a horizontal, untilted reflecting surface)   
%-------------------------------------------------------------------
% input
%       freq:  1 2 or 5 :  for L-band frequency (L1,L2, or L5)      
%       e:  elevation angle in degrees
%       h: antenna height in meters, above the flat reflecting surface
%       theta: azimuth angle in degrees 
%
% output
%      firstF: [a, b, R ] in meters where:
%              a is the semi-major axis, aligned with the satellite azimuth 
%              b is the semi-minor axis
%              R locates the center of the ellispe 
%                   on the satellite azimuth direction (theta)
%                   and R meters away from the base of the Antenna.
%     
%     The ellipse is located on a flat horizontal surface h meters below
%     the receiver.                  
%-------------------------------------------------------------------------
% author:    Kristine Larson and Carolyn Roesler
% thank you to Felipe Nievinski and Andria Bilich
%------------------------------------------------------------------------

%SOME GPSCONSTANTS	
CLIGHT = 299792458;             % speed of light, m/sec
FREQ = [1575.42e6; 1227.6e6; 0; 0; 1176.45e6];   % GPS frequencies, Hz
                                                 % [ L1 L2  0 0 L5]
CYCLE = CLIGHT./FREQ;           % wavelength per cycle (m/cycle)
RAD2M = CYCLE/2/pi;             % (m)


%initialisation
firstF=[];

% check that legal L-bandfrequency is given
if ~ismember(freq, [1 2 5])
    disp(['Illegal frequency type: ' num2str(freq)])
    return
end


% ------------------
% delta = locus of points corresponding to a fixed delay;
% typically the first Fresnel zone is is the 
% "zone for which the differential phase change across
% the surface is constrained to lambda/2" (i.e. 1/2 the wavelength)
delta = CYCLE(freq)/2; 	% [meters]


% semi-major and semi-minor dimension
% from the appendix of Larson and Nievinski, 2013
sin_elev = sind(e);
d = delta; 
B = sqrt( (2 * d * h / sin_elev) + (d / sin_elev)^2 ) ; % [meters]
A = B / sin_elev ;                                      % [meters]


% determine distance to ellipse center 
center = (h + delta/sind(e))/tand(e) ;  	% [meters]

[firstF]=[A,B,center];

end
