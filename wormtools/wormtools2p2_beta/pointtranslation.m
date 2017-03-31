function [ptvel, ptdir, ptmode] = pointtranslation(x, y, mmpp, spf, fpt)

%POINTTRANSLATION    Calculate point velocities from xy coordinate data.
%   FORMAT: [ptvel, ptdir, ptmode] = pointtranslation(x, y, mmpp, spf, fpt)
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
%      NOTE: POINTTRANSLATION CURRENTLY DISREGARDS THE INPUTTED
%       FPT AND DEFAULTS TO FPT = 1!!!!!!
%      - "ptvel" is a matrix of velocities for each point along
%         a worm's "spine" at each time snapshot.  
%      - "ptdir" is a matrix of angles (in radians) of movement.
%      - "ptmode" is a matrix of flags indicating forward (1) or 
%         backward (-1) movement.
%   NOTE: POINTTRANSLATION is based upon TRANSLATION2_01x

%   C. J. Cronin 7-24-02
%   Revised 
%   $Revision: 1.02 $  $Date: 2002/09/03 xx:xx:xx $
% 
% r1.02: Adds help information.  Adds revision history.  Updates
%   comments.



% If only two input arguments, do not scale velocity units
if nargin == 2
   mmpp = 1;
   spf = 1;
   fpt = 1;
end

% FORCE CALCULATION OF VELOCITY FROM FULL DATA SET
fpt = 1;    % i.e. One frame per timeblock


% Establish "abriged" versions of x and y, sampled at every N'th frame:
xa = x(1:fpt:end, :);       % xa = "x-abridged" 
ya = y(1:fpt:end, :);

% Deleted because considering entire length of worm...
% xp = xa(:,5:end);     % because calculating entire worm's point velocities
% yp = ya(:,5:end);
% vel = mean(sqrt(diff(xp).^2 + diff(yp).^2)');

% Calculate matrix of point velocities
ptvel = sqrt(diff(xa).^2 + diff(ya).^2);    

% Start of Mode (positive or negative velocity)calculation
xp = xa(1:end-1,:);     % Positions at first time ("t1")
yp = ya(1:end-1,:);
xc = xa(2:end,:);       % Positions at second time ("t2")
yc = ya(2:end,:);
%- - - - - - - - - - - - - - - - - - - - -
d1 = sqrt( (xp(:,4:end-2)-xc(:,5:end-1)).^2 ... % "Is the back of the 
         + (yp(:,4:end-2)-yc(:,5:end-1)).^2 );  % worm moving closer to 
d1 = mean(d1');                                 % the front of the worm?"

d2 = sqrt( (xp(:,6:end)-xc(:,5:end-1)).^2 ...   % "Is the front of the 
         + (yp(:,6:end)-yc(:,5:end-1)).^2 );    % worm moving closer to 
d2 = mean(d2');                                 % the rear of the worm?"

ptmode = 2*((d1 < d2)-0.5); % Forward motion: small d1, large d2
                            % Backward motion: Large d1, small d2
ptmodematrix = ptmode'*ones(1,prod(size(xa,2)));
                            % Matrix with "ptmode" as each column.

ptvel = ptvel .* ptmodematrix;  % Correcting to Positive or Negative velocity.

% do unit conversion from pixels/timeblock  to  mm/sec
ptvel = ptvel * mmpp / (spf * fpt);

% compute direction
ptdir = atan2(diff(ya), diff(xa));


%much simpler (and more accurate) than:
% % % cx = mean(xa');
% % % cy = mean(ya');
% % % theta = atan2(cy, cx);
% % % thetap = diff(theta);
% % % thetap(thetap>+pi) = thetap(thetap>+pi) - 2*pi;
% % % thetap(thetap<-pi) = thetap(thetap<-pi) + 2*pi;
% % % dir = thetap;

return;
