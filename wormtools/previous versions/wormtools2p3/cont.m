function [res] = cont(x, y, disp)

%CONT    Calculate point velocities from xy coordinate data.
%   FORMAT: [res] = cont(x, y, disp)
%      where 
%      - "x" and "y" are matrices of x and y coordinates.  (Rows 
%         are time, columns are data points along a worm's "spine" 
%         from head to tail.)
%      - "disp" is a flag indicating whether to display data 
%         with a MANPROC* style UI.  NOTE: CONT currently always 
%         called (from METRICS) with disp = 0: do not display.
%      - "res" is a matrix of deflection angles at each of
%         the worm's bends (for N bends: N-1 segments, N-2 bends).
%         Calculated via WORM2CONTR.  NOTE: Positive bends are 
%         clockwise/to-right as viewed from worm's head.

%   C. J. Cronin 7-24-02
%   Revised 
%   $Revision: 1.03 $  $Date: 2002/09/03 xx:xx:xx $
% 
% r1.03: Adds help information.  Adds revision history.  Updates
%   comments.
% 
% r1.02: Corrects length calculation (not used for typical cont
%   function).  Dated 3-07-02 9:58PM.


% %%%%%%%%%%%%%%%%%%%%%%%%%%
% argument checking
% %%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin ~= 2) & (nargin ~= 3)
   error('invalid number of input arguments');
end   

if (size(x,1) ~= size(y,1)) | (size(x,2) ~= size(y,2))
	error('size of x and y must agree');   
end

if nargout ~= 1
   error('invalid number of output arguments');	
end

if nargin == 2
	disp = 1;   
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize variables          % ...dreck...
% %%%%%%%%%%%%%%%%%%%%%%%%%%
global action;      % Not used...
global frameno;     % Not used...
action = 2;         % Not used...
frameno = 0;        % Not used...


% Set-up for the meat of the function.
nworms = size(x,1); % Number of frames in data set


% ...more dreck...
len = sum(sqrt(diff(x').^2 + diff(y').^2)); % Corrected...
                                            % BUT, Not used...
% WAS   len = sqrt(sum(diff(x').^2 + diff(y').^2));	
mu = mean(len(~isnan(len)));    % Not used...




% The Meat of the Function:
res = zeros(nworms, size(x,2)-2);   % Initializes output matrix 
                                    % as matrix of zeros. 
for i=1:nworms      % For each time snapshot...
   res(i,:) = worm2contr([x(i,:); y(i,:)]); % ...calculate vector
                                            % of worm bend angles
end     % Therefore creates matrix of worm bend angles.
        % NOTE: Positive bends are clockwise/to-right as viewed
        %   from worm's head.

% %%%%%%%%%%%%%%%%%%%%%%%%%%
% exit if disp is 0         --  Currently disp always = 0.
% %%%%%%%%%%%%%%%%%%%%%%%%%%
if disp == 0
   return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% TYPICAL FUNCTION END POINT %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% THE FOLLOWING TYPICALLY NOT USED %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%
% pop a new figure
% %%%%%%%%%%%%%%%%%%%%%%%%%%
figure

% %%%%%%%%%%%%%%%%%%%%%%%%%%
% now draw the buttons
% %%%%%%%%%%%%%%%%%%%%%%%%%%
aicons =     ['text(.5,.5,''Rewind '',''Horiz'',''center'')'
 				  'text(.5,.5,'' Stop  '',''Horiz'',''center'')'
   			  'text(.5,.5,'' Play  '',''Horiz'',''center'')'
              'text(.5,.5,''Forward'',''Horiz'',''center'')'];
      
acallbacks = ['global action; action = 1;'
              'global action; action = 2;' 
              'global action; action = 3;'
          	  'global action; action = 4;'];
           
btngroup('BevelWidth', 0.025, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupA', ...
         'ButtonID', ['Rewind ';'Stop   ';'Play   ';'Forward'], ... 
		   'Callbacks', acallbacks, ...
         'Position', [.050 .800 .45 .10], ...
         'IconFunctions', aicons, ...
         'GroupSize', [1 4]);
      
bicons =     ['text(.5,.5,''Step-'',''Horiz'',''center'')'
	 			  'text(.5,.5,''Step+'',''Horiz'',''center'')'];
      
bcallbacks = ['global action; action = 5;' 
              'global action; action = 6;'];
           
btngroup('BevelWidth', 0.025, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupB', ...
         'ButtonID', ['Step-';'Step+'], ... 
		   'Callbacks', bcallbacks, ...
         'Position', [.525 .800 .25 .10], ...
         'IconFunctions', bicons, ...
      	'GroupSize', [1 2]);
            
cicons =     ['text(.5,.5,''Quit'',''Horiz'',''center'')'];
      
ccallbacks = ['global action; action = -1;'];
           
btngroup('BevelWidth', 0.025, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupD', ...
       	'ButtonID', ['Quit'], ... 
		   'Callbacks', ccallbacks, ...
         'Position', [.800 .800 .20 .10], ...
         'IconFunctions', cicons, ...
      	'GroupSize', [1 2]);
      
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize the axes
% %%%%%%%%%%%%%%%%%%%%%%%%%%
      
h1 = axes('position', [0.10 0.1 0.35 0.6]);
axis([-2 2 -2 2]); grid; 
t1 = title('');
h2 = axes('position', [0.55 0.1 0.35 0.6]);
h2p = plot([1:11], zeros(1,11), 'EraseMode', 'xor');
axis([1 11 -pi/2 pi/2]); grid; 
t2 = title('');
drawnow;

while action ~= -1
   
   if action == 1
   
   	if frameno > 100
         frameno = frameno - 100;
	   else
         frameno = 1;
   	end
             
	   pause(0.2);
      
   elseif action == 3
      
      if frameno < nworms
         frameno = frameno + 1;
	    	xp = x(frameno,:); yp = y(frameno,:);
   	   xp = (xp - mean(xp))/mu; yp = (yp - mean(yp))/mu;
		   dispworm(h1, xp, yp, 0);
		   dispcontr(h2p, res(frameno,:));	
   	else
      	action = 2;
	   end
    
   elseif action == 4
         
      if frameno <= nworms - 100
         frameno = frameno + 100;
      else
         frameno = nworms;
      end
       
      pause(0.2);
      
   elseif action == 5
      
      if frameno > 1
         frameno = frameno - 1;
	    	xp = x(frameno,:); yp = y(frameno,:);
   	   xp = (xp - mean(xp))/mu; yp = (yp - mean(yp))/mu;
		   dispworm(h1, xp, yp, 0);
		   dispcontr(h2p, res(frameno,:));
      end
      
      action = 2;
      
   elseif action == 6
      
      if frameno < nworms
         frameno = frameno + 1;
	    	xp = x(frameno,:); yp = y(frameno,:);
   	   xp = (xp - mean(xp))/mu; yp = (yp - mean(yp))/mu;
		   dispworm(h1, xp, yp, 0);
		   dispcontr(h2p, res(frameno,:));
      end   
         
      action = 2;
      
   else
      
      pause(0.2);
      
   end
   
   set(t1, 'string', ['Frame No = ' int2str(frameno)]);
   set(t2, 'string', ['Frame No = ' int2str(frameno)]);
   drawnow;
   
end

% close the window
close

%%%%%%%%%%%%%%%%%%%%%%%%%%
% now return
%%%%%%%%%%%%%%%%%%%%%%%%%%
return;