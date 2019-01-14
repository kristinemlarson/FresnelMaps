function [N] = EGM96geoid(lat, lon)

%==========================================================================
%==========================================================================
% [N] = EGM96geoid(lat, lon)
%
% Calculates the geoid height using the EGM96 Geopotential Model. 
%  Geoid heights are interpolated from a 15-minute grid of point values 
%  in the tide-free system, using the to degree and order 360. The geoid 
%  undulations are with respect to the WGS84 ellipsoid.
%
%  This function calculates geoid heights to 0.01 meters. 
% 
%  The spline interpolation scheme is used with the grid wrapping over 
%  the poles to allow for geoid height calculations at and near these 
%  locations.
%
%  NOTE:  EllipsoidalHeight = OrthometricHeight(aka MSL) + GeoidHeight
%
%
% Author: Ben K. Bradley
% date: 06/03/2010
%
%
% INPUTS:            Description                                     Units
%
%  lat         - geocentric latitude from -90 to 90                 degrees
%  lon         - longitude from 0 to 360 or -180 to 180             degrees
%
% 
% OUTPUT:
%
%  height      - geoid height                                        meters
%
%
% Coupling:
%
%  none
%
% References:
%   
%  [1] National Geospatial-Intelligence Agency website:
%       http://earth-info.nga.mil/GandG/wgs84/gravitymod/egm96/egm96.html
%
%  [2] geoidegm96.m from the Aerospace Toolbox v2.4
%
%==========================================================================
%==========================================================================


persistent geoid  %#ok<USENS>          %  


% Load Geoid data grid if not done so already =============================
if isempty(geoid)
    load EGM96geoidDATA
end

% Loads the structure called: geoid  
%
%                       .grid = geoid height (m) in .25deg steps
%                       .lats = row vector of latitudes, deg (-92,92)
%                       .lons = row vector of longitudes, deg (-2,362)


% Make sure longitude is positive =========================================
if (lon < 0)
    lon = lon + 360;
end


% Spline Interpolation ====================================================

% Create grids for the latitudes and longitudes
[X,Y] = meshgrid(geoid.lons, geoid.lats);


% Interpolate
N = interp2(X, Y, geoid.grid, lon, lat, 'spline');

    
% Fix geoid height at hundreth of a meter =================================
N = fix(N*100)*0.01;








