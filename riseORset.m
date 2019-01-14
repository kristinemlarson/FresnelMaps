function [cRS ] = riseORset( a )
%function [cRS ] = riseORset( a )
% translate 1/-1 values into Rise or Set
% for output to screen
if a == 1
    cRS = 'Rise';
else
    cRS = 'Set ';
end

