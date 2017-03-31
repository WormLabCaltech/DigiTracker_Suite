function [res] = flip(x1, y1, x2, y2)

%FLIP    Determine whether worm orientation should be "flipped" (reversed)
%   [res] = FLIP(x1, y1, x2, y2)
%      where 
%      - "x1" and "y1" are vectors of x and y coordinates at a particular
%         time (the "set in question") for comparison with "x2" and "y2".
%      - "x2" and "y2" are reference vectors of x and y coordinates at an 
%         adjacent time. 
%      - "res" is a Boolean 1 (true) or 0 (false) result indicating 
%         whether the set in question needs to be flipped (1/true) or 
%         not flipped (0/false).
%
%   Essentially finds the displacement of the set in question with 
%   respect to the reference set, and also with respect to the reference 
%   set with its points in reversed order.
%   - Compares the sizes of the effective displacements.  Outputs 1 
%     (true) if the smaller effective displacement is with respect 
%     to the reversed reference set.

%   C. J. Cronin 10-29-01
%   Revised 7-17-02 CJC.
%   $Revision: 1.02 $  $Date: 2002/09/03 xx:xx:xx $
%
% r1.02: Revises help information.  Adds revision history.


err1 = sum((x1 - x2).^2 + ...   %Subtracts the reference set (x2/y2) 
           (y1 - y2).^2);       % positions from the set in question 
                                % (x1/y1), point-wise.  Squares the 
                                % displacements, then sums them.
                                        
err2 = sum((x1 - x2(end:-1:1)).^2 + ... % Same calculation, but with the 
   	     (y1 - y2(end:-1:1)).^2);       % reference set in reversed order.
        
res = (err2 < err1);                    % Yields 1 (true) if comparison 
                                        % with reversed-order reference set
                                        % is smaller.
                                        
return;