function print_colorExt(fid, PRN,varargin)
% function print_color(fid, PRN,varargin)
%    Each satellite is color coded
%    converts matlab color format to Google Earth color format
% Googgle use : [blue green red]  whereas matlab uses [red green blue]
%---------------------------------------------------------------------
% INPUT:
%        fid: KML file identifier 
%        PRN: satellite number
%        varargin: hardwired to 1: 
%                 uses the color palette varycolor(33)
% OUPUT
%      the matlab satellite color varycolor(PRN)  
%      is converted to Google Eart color format
%      and is written in the KML file   
%--------------------------------------------------------
% called by google earth code : writefresnel_onefile.m
%
% REMARK
% no one bothered to provide a link for this - maybe this will help
% http://msdn.microsoft.com/en-us/library/system.drawing.color.aspx
%--------------------------------------------------------------------
% default value for color vector
col3 = [];

if length(varargin)==1 
% use 33 colors because max GPS satellites are 32
  cc = varycolor(33);
  col3 = cc(PRN,:);
end

if sum(col3) == 0
  disp('no color was set - so will use red')
  newval = ge_color([1 0 0]);
  fprintf(fid,['FF' newval]);   
else
  newval = ge_color(col3);
  fprintf(fid,['FF' newval]);
end
end
