function eph = get_eph(ephemeridesfile)
%GET_EPH  The ephemerides contained in ephemeridesfile
%         are reshaped into a matrix with 21 rows and
%         as many columns as there are ephemerides.
% 
%         Typical call eph = get_eph('rinex_n.dat')

%Kai Borre 10-10-96
%Copyright (c) by Kai Borre
%$Revision: 1.0 $  $Date: 1997/09/26  $

fide = fopen(ephemeridesfile);
[eph, count] = fread(fide, Inf, 'double');
noeph = count/21;
eph = reshape(eph, 21, noeph);
%%%%%%%% end get_eph.m %%%%%%%%%%%%%%%%%%%%%

