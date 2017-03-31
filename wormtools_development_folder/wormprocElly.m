%WORMPROCElly    Master worm processing script
% 
%   Script to automate running PREORIENT and MANPROC functions
%     - Prompts for directory containing "worm1", "worm2"... folders
%         (each containing a file named "points" and a series of
%         corresponding image files).
%     - Runs PREORIENT*
%     - Runs MANPROC*
%     - Saves x and y matrices in a Matlab file called "data" 
%     - Saves x-y data timestamps, if available, in "data"
%     - Saves list of current functions used for wormproc
%
%   Note: x and y matrices will be ~1400 rows long (for a 4 minute 
%   worm recording) by (typically) 13 columns wide.  Each column 
%   represents a point along the "spine" (or centerline) of the worm, 
%   column 1 at the head, column 13 at the tail, the rest distributed 
%   evenly along the worm.  Rows are essentially snapshots of the 
%   worm's position over time with row 1 as the worm's first position, 
%   row 2 its next position,...  Each successive row is ~1/5 second 
%   later than the previous.  (The calculation for actual time delay 
%   between successive rows is calculated  by METRICS* and is used to 
%   scale the data to determine the worm's   velocity and frequency.  
%
%   Note:  SCRIPT, not a function!!!
%
%   C. J. Cronin 10-26-01
%   Revised 10-28-04 CJC.
%   $Revision: 1.11 $  $Date: 2004/10/28 xx:xx:xx $
% 




% Variable Declarations
% global x;
% global y;
% global timeV;
global directory;


% Establish whether we Want to Definitely save for Matlab v6.x readability:
FORCE_to_v6 = 1;   % 1 = true, we want to save for v6 readability.
% Check for Matlab version
matlabversion = ver('MATLAB');
matlabversion = str2num(matlabversion.Version);


% Start of script
directory = input('Enter Directory name> ','s');


[x,y, timeV, shortcutoff, longcutoff] = preorient2Cheryl(directory);  % Cheryl's long recordingversion


[x,y] = manproc3Cheryl(x,y, shortcutoff, longcutoff);  % Production version


% Load first fingerprint.mat file on the Matlab search path (which SHOULD
% be the file in the same directory as this wormproc function).
load( which('fingerprint.mat'), 'fingerprint');     % loads 



% Save x and y matrices (& fingerprint) in file "data" 
%   in input directory
if ( FORCE_to_v6 & (matlabversion >= 7.0) )
    save([directory filesep 'data'], 'x', 'y', 'timeV', 'fingerprint' , '-v6');    
else
    save([directory filesep 'data'], 'x', 'y', 'timeV', 'fingerprint');    
end


fprintf(1, '\n');


% And do the velocity calculations
[vel, theta, mode, velc] = velcalcElly(directory);


clear PLAYPAUSE cx cy directory fingerprint lookupvalue lookupvaluestring
clear slider_pause_ slider_value_ 
clear FORCE_to_v6 matlabversion