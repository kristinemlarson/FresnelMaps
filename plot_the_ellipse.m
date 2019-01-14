function  plot_the_ellipse(azimuth,A,B,Ctr,icolor);

% function  plot_the_ellipse(azimuth,A,B,Ctr,icolor);
%
% plots an ellipse  
%
%  INPUT: 
%      azimuth: satellite azimuth direction 
%      A: is the semi-major dimension, axis aligned with the satellite azimuth
%      B: is the semi-minor dimension
%      Ctr: locates the center of the ellispe 
%             on the satellite azimuth direction (theta)
%             and at a distance  Ctr from the origin (x=0 y=0)
%            (Here the base of the antenna is located at the origin)
%      icolor: color to plot the ellipse: a 3 column vector
%---------------------------------------------------------------------
% borrowed code


theta = azimuth; 
 
amaj = A  ;
bmin = B  ;
x=(-amaj):.1:(amaj);
y=bmin*(1-(x).^2/amaj^2).^(.5);
y=[y,fliplr(-y)];
x=[x,fliplr(x)];

geez1 = y;
geez2 = -(x-Ctr)  ;

theta = -theta;
rot=[cosd(theta),sind(theta);-sind(theta),cosd(theta)];
newxy = [geez1' geez2']*rot;
plot(newxy(:,1), newxy(:,2) , '-', 'linewidth',2, 'color', icolor);
hold on;

end

