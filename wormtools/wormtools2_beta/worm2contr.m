function [contr] = worm2contr(worm)

%WORM2CONTR    Calculate bend angles from xy coordinate data.
%   FORMAT: [contr] = worm2contr(worm)
%      where 
%      - "worm" is a two-row matrix of worm position coordinates,
%         with row 1 as the x-coordinates, row 2 as the y-coordinates 
%         at a moment in time.
%      - "contr" is a vector of deflection angles (from straight) 
%         at each of the worm's bends (for N bends: N-1 segments, 
%         N-2 bends).  NOTE: Positive bends are clockwise/to-right 
%         as viewed from worm's head.

%   C. J. Cronin 7-24-02
%   Revised 
%   $Revision: 1.02 $  $Date: 2002/09/03 xx:xx:xx $
% 
% r1.02: Adds help information.  Adds revision history.  Adds
%   comments.


   xp = worm(1,:);      % Vector of x-coordinates
   yp = worm(2,:);      % Vector of y-coordinates
   
   npoints = prod(size(xp));    % Number of points along worm
   nsegments = npoints - 1;     % Number of segments between points
   
   vx = xp(2:end) - xp(1:end-1);    % Differences in position, x&y
   vy = yp(2:end) - yp(1:end-1);
   
   contr = zeros(1, nsegments-1);   % Place holder vector of zeros,


% Bend angle computation, based on 
%   V1.V2 = |V1|*|V2|*cos(theta)
% where
%   V1.V2 = V1x*V2x + V1y*V2y
% so,
%   cos(theta) = (V1x*V2x + V1y*V2y) / (|V1|*|V2|)
% or restated,
%   theta = acos[(V1x*V2x + V1y*V2y) / (|V1|*|V2|)]
%   
% where
%   V1 = first segment vector
%   V2 = second segment vector
%       (from CJC notes, 1/9/02)
   for i=1:nsegments-1
      v1 = [vx(i); vy(i)];
      v2 = [vx(i+1); vy(i+1)];
      
      v1 = v1 / sqrt(v1'*v1);
      v2 = v2 / sqrt(v2'*v2);
      
      contr(i) = acos(v1'*v2);
      
      if (v1(1)*v2(2) - v2(1)*v1(2)) > 0
         contr(i) = -contr(i);
      end
   end
   
return;
   