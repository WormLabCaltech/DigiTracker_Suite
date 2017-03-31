function [] = dispworm(h, xp, yp, flip, valid)

%DISPWORM    Plot worm "skeleton."
%   DISPWORM(h, xp, yp, flip, valid)
%      where 
%      - "h" is handle to the current axis.  (Can be manually
%         determined via   h = gca;   )
%      - "xp" and "yp" are vectors of x & y coordinates for display.
%      - "flip" is a binary flag indicating whether "xp" and "yp" 
%         coordinates are to be displayed in reverse order.
%      - "valid" is a binary flag indicating whether "xp" and "yp"
%         represent invalid data, and therefore should be "X'ed" out
%
%   Displays blue spine with red data points.  Worm's head is 
%   depicted with a large red circle.  Invalid data is overplotted 
%   with a large red "X".

%   C. J. Cronin 10-29-01
%   Revised 7-18-02 CJC.
%   $Revision: 1.03 $  $Date: 2002/09/03 xx:xx:xx $
%
% r1.03: Updates help information & comments.  Fills in revision 
%   history.  
%
% r1.02:  Adds validity flag to call.  (Should have been r2.01
%   because of I/O change.)  Dated 9-24-02 7:05AM.


axes(h);                             % Establish axis location at "h"
cla
hold on 

plot(xp, yp, 'EraseMode','Xor');         % Blue spine
plot(xp, yp, 'r.', 'EraseMode','Xor');   % Red vertices

if flip == 0                             % If data does not need 
   plot(xp(1), yp(1), 'ro',  ...         % reversed, plot large Red 
       'MarkerSize', 8,     ...          % circle at head end.
       'LineWidth',  4,      ...
       'EraseMode','Xor');
else 
   if flip == 1                          % If data needs reversed, plot
       plot(xp(end), yp(end), 'ro',  ...     % large Red circle at corrected
           'MarkerSize', 8,     ...          % head end.
           'LineWidth',  4,      ...
           'EraseMode','Xor');
   end
end
   
if ~valid                                    % If NOT valid worm, 
    plot(0, 0, 'rx',         ...             %  overplot Large Red X
        'MarkerSize', 72,    ...
        'LineWidth', 8,     ...
        'EraseMode','Xor');
end
drawnow;
hold off
 
return;