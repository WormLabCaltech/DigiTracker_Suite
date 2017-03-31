%SLIDER_PAUSE    Sets playback pause according to slider position (in MANPROC GUI)
%   SLIDER_PAUSE    
%   Script invoked when playback slider is moved (in MANPROC*).  
%   Sets PLAYPAUSE variable by interpolation according to new 
%   slider position and updates slider display in (MANPROC*).
%
%   Note:  SCRIPT, not a function!!!

%   C. J. Cronin 7-17-02
%   Revised  
%   $Revision: 1.02 $  $Date: 2002/09/03 xx:xx:xx $
%
% r1.02: Adds help information & comments.  Adds revision 
%   history.  


global PLAYPAUSE;       % Playback pause (# seconds per playback cycle)
% global DEFAULTPLAYPAUSE;
global slider_pause_;   % Playback speed control slider POSITION (0-100)
global slider_value_;   % Text equivalent of Playback speed control 
                        %  slider position ('0%' - '100%').

cx = [-1 50 101];       % "cx" is reference slider positions.
cy = [0.5 0.06 0];      % "cy" is corresponding playback pauses 
                        %    (# seconds per playback cycle)
                        % Three pairs of points to define playback 
                        % speed control 'function'.
                        % Used for interpolation below.
                        
lookupvalue = get(slider_pause_, 'value');  % New slider POSITION (0-100)

PLAYPAUSE = interp1(cx, cy, lookupvalue, 'pchip');  %Shape-preserving 
                        % piecewise cubic interpolation, formerly known as
                        % 'cubic'.  Reviewing Matlab release notes found
                        % that 'cubic' method was first deprecated in
                        % R2012a, but silently (no warning).  As of R2013b
                        % Matlab issues a warning. 
                        % New playback pause
                        % interpolated according to the function defined 
                        % by the cx-cy pairs, assumed to be a cubic 
                        % function.

PLAYPAUSE = (floor(1000*abs(PLAYPAUSE)))/1000;
                        
lookupvaluestring = int2str(round(lookupvalue));    % Text-version of
                        % new slider position ('0' - '100')...

set(slider_value_, 'String', [lookupvaluestring '%']);  % String formatted 
                        % for display beside slider ('0%' - '100%')
