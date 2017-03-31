function [vel, theta, mode, velc] = translation3Cheryl(x, y, mmpp, spf, fpt)

%TRANSLATION2    Calculate velocity from xy coordinate data.
%   FORMAT: [vel, theta, mode, velc] = translation3Cheryl(x, y, mmpp, spf, fpt)
%      where 
%      - "x" and "y" are matrices of x and y coordinates.  (Rows are 
%         time, columns are data points along a worm's "spine" from
%         head to tail).
%      - "mmpp" is the ratio "millimeters per pixel" which is 
%         a function of microscope and camera optics.  For the
%         Sternberg Lab's worm tracking rig in Kerckhoff 221:
%             Magnification    mmpp (mm/pixel)
%             -------------    ---------------
%                  6x               0.017
%                 12x               0.0085
%                 25x               0.0041
%                 50x               0.0020
%      - "spf" (seconds per frame) is the time in seconds between
%         successive frames
%      - "fpt" (literally "frames per timeblock") is the 
%         number of frames to group together for the velocity 
%         calculation.  That is, velocity is calculated by 
%         sampling worm position every N'th frame, where N = fpt.
%      - "vel" is a vector of instantaneous velocities every N'th
%         frame (where N = fpt).  The velocities are the mean 
%         of point velocities of the rear ~2/3 of the worm 
%         (points 5 to the tail end).  
%      - "theta" is the angle (in radians) of movement
%      - "mode" is a flag indicating forward (1) or backward (-1)
%         movement.
%      - "velc" is a vector of instantaneous velocities of the CENTROID of
%         the rear 2/3 of the worm (mean position of points 5 to tail end). 

%   C. J. Cronin 7-24-02
%   Revised 
%   $Revision: 3.01 $  $Date: 2004/07/14 xx:xx:xx $
% 
% r3.01: Adds 'velc' calculation: speed of the CENTROID (mean position) 
%   of points [5:end].  Adds 'velc' to function output and help section.
%   Clarified help text to recognize that 'vel' is the mean of point 
%   5:end point velocities.
% 
% r2.03: Changes variable 'dir' to 'theta' to differentiate from
%   built-in function 'dir'.  Corrects angle (theta) calculation 
%   to reflect direction of travel instead of angle from (0,0) point.  
%   Dated 11-13-02 4:35 PM.
%
% r2.02: Adds help information.  Fills in revision history.
%   Dated 9-03-02 5:22 PM.
%
% r2.01: Calculates velocity by sampling change in position 
%   every N'th frame (where N = fpt).  Dated 6-07-02 5:27PM.




% If only two input arguments, do not scale velocity units
if nargin == 2
   mmpp = 1;
   spf = 1;
   fpt = 1;
end

% Establish "abriged" versions of x and y, sampled at every N'th frame:
xa = x(1:fpt:end, :);       % xa = "x-abridged" 
ya = y(1:fpt:end, :);

% Compute velocity 
xp = xa(:,5:end);           % Matrices of rear-2/3 coordinates
yp = ya(:,5:end);
vel = mean(sqrt(diff(xp).^2 + diff(yp).^2)');   % Vector of velocities. 
                                                % (units: pixels/frame)

% Compute (REAR) CENTROID velocity 
xm = mean(xp')';            % Vector of mean rear-2/3 coordinates
ym = mean(yp')';
velc = sqrt(  diff(xm).^2 + diff(ym).^2  )';   % Vector of REAR CENTROID velocities. 
                                                % (units: pixels/frame)

% Determine mode (forward/backward movement)
xp = xa(1:end-1,:);     % Positions at first time ("t1")
yp = ya(1:end-1,:);
xc = xa(2:end,:);       % Positions at second time ("t2")
yc = ya(2:end,:);

d1 = sqrt( (xp(:,4:end-2)-xc(:,5:end-1)).^2 ... % "Is the back of the 
         + (yp(:,4:end-2)-yc(:,5:end-1)).^2 );  % worm moving closer to 
d1 = mean(d1');                                 % the front of the worm?"

d2 = sqrt( (xp(:,6:end)-xc(:,5:end-1)).^2 ...   % "Is the front of the 
         + (yp(:,6:end)-yc(:,5:end-1)).^2 );    % worm moving closer to 
d2 = mean(d2');                                 % the rear of the worm?"

mode = 2*((d1 < d2)-0.5);   % Forward motion: small d1, large d2
                            % Backward motion: Large d1, small d2
vel  = vel  .* mode;      % Correcting to Positive or Negative velocity.
velc = velc .* mode;      % Correcting to Positive or Negative CENTROID velocity.

% do unit conversion from pixels/timeblock  to  mm/sec
vel  = vel  * mmpp / (spf * fpt);
velc = velc * mmpp / (spf * fpt);

% compute direction
cx = diff(mean(xa(:,5:end)'));  % Vectors of mean position coordinates
cy = diff(mean(ya(:,5:end)'));  %   for rear ~2/3 of worm.
theta = atan2(cy, cx);      % Angle from reference to mean positions.

thetap = diff(theta);       % Change in angle
thetap(thetap>+pi) = thetap(thetap>+pi) - 2*pi; % If necessary, 
thetap(thetap<-pi) = thetap(thetap<-pi) + 2*pi; % re-express as
                                                % in +/- pi range.
% dir = thetap;   % NEED TO CHANGE BECAUSE NEED BUILT-IN dir FUNCTION

return;
