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
%
%   C. J. Cronin 7-24-02
%   Revised 
%   $Revision: 1.04 $  $Date: 2006/07/28 xx:xx:xx $
% 

% r1.04: Changed *zero* bend angle screen to look at whether the dot
%   product of the unit-vectorized segments (which form a bend angle)
%   yields a number greater than 1.  In such case we force a zero angle
%   instead of allowing acos to throw a complex number.
%
% r1.03: Added screen for worms with a *zero* bend angle:  During bend
%   angle calculation, a value for   v1'*v2   is calculated for input to
%   the Matlab function   acos.  From  acos  documentation, calling  acos
%   with a value outside the range [-1 1] yields a complex number for
%   the angle.  On 11-20-04 CJC experienced an event on a worm with a zero
%   bend angle where v1'*v2 should have equalled 1; actual value was 
%   (1 + eps), where eps is the floating-point relative accuracy.
%   Dated 11-21-04 4:44PM.
%
% r1.02: Adds help information.  Adds revision history.  Adds
%   comments.
%   Dated 9-03-02 4:22PM.


% Prevent forceAngleToZero warning for cases where two worm segments happen
% to be perfectly aligned (but because of round-off error would throw an
% imaginary number for the zero angle).
originalwarningstate = warning('off', 'WORMTOOLS:worm2contr:forceAngleToZero');   

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
      
      % 11-21-04: CJC discovered that for a pair of segments that are
      % PERFECTLY aligned (*zero* bend angle), at least one worm had a v1'*v2
      % value greater than 1 -- off by MATLAB's Floating-point relative
      % accuracy!  (The Floating-point relative accuracy can be accessed
      % by calling the MATLAB function 'eps'.  NB: For P4 PC running MATLAB
      % v6.5 eps is 2.2204e-016.)
      %
      % 2-04-05: CJC discovered a case where PERFECTLY aligned segments
      % yielded a v1'*v2 of (1 + 2*eps)!  So, slightly changing philosophy,
      % we'll screen for no difference between the two vectors
      %
      % 7-27-06: Sometimes it is good to drag one's feet before releasing a
      % file for general use, or perhaps better stated as: testing is
      % good...  Discovered yesterday afternoon that sometimes v1 and v2
      % are only ALMOST identical and still yield an imaginary bend angle.
      % SO, instead of looking for an identical v1 and v2, change the
      % *zero* angle screen to look for a dot product of v1 and v2 greater
      % than 1.  (NB: v1 and v2 *should* have been reduced to unit vectors
      % in the previous step.)
      
      
%       if all( (v1-v2) == 0 )    % if v1 and v2 are identical (i.e. no bend), difference will be [0;0]
%           % Force a zero bend
      % Change in concept:
      % Do the dot product and look at whether it is greater than 1 
      % (?? Should we screen for less than -1, too???  No, because worms don't bend that way.)
      if (v1'*v2) > 1    % A dot product of 1 indicates straight.  Greater than 1 yields an imaginary angle value
          contr(i) = 0;
          warning('WORMTOOLS:worm2contr:forceAngleToZero', ['(for reference) Reported angle forced to -0-  (Dot product > 0) --> Over by: '  num2str((v1'*v2)-1) ]);
      else
          % Do the calculation
          contr(i) = acos(v1'*v2);
      end
          
%       if abs(v1'*v2) <= 1     % in the range [-1 1], as would be hoped... 11-21-04 CJC
%           % Do the calculation
%           contr(i) = acos(v1'*v2);
%       elseif v1'*v2 == (1 + eps)        % i.e. POSITIVE    
%           % ...so SUBTRACT the Floating-point accuracy value 
%           contr(i) = acos( (v1'*v2) - eps );
%       elseif v1'*v2 == -1 - eps         % i.e. NEGATIVE
%           % ...so ADD the Floating-point accuracy value 
%           contr(i) = acos( (v1'*v2) + eps );
%       elseif abs(v1'*v2) > 1            % Outside of the expected range
%           % Throw a complex number warning:
%           warning('Potential complex number calculation.  -->Check Bend Angles');
%           %    ...and do the calculation ANYWAY
%           contr(i) = acos(v1'*v2);
%       else                              % e.g. x or y are NaN...
%           contr(i) = acos(v1'*v2);
%       end

      
      if (v1(1)*v2(2) - v2(1)*v1(2)) > 0
         contr(i) = -contr(i);
      end
   end
   
% Restore original warning state:
warning(originalwarningstate)

return;
   