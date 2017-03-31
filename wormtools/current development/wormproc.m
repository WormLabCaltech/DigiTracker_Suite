function [] = wormproc()
%WORMPROC    Master worm processing function
% 
%   Function to automate running PREORIENT and MANPROC functions
%     - Prompts for a "worm*" directory (which contains a file named
%         "points" and a series of corresponding image files).
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
%   C. J. Cronin 10-26-01
%   Revised 10-28-04 CJC.
%   $Revision: 1.11 $  $Date: 2004/10/28 xx:xx:xx $
% 

% r1.11: Changes 'save' method according to Matlab version & desire for 
%   compatibility with pre-version7.0 Matlab environments. (i.e. allows
%   forcing data into compatibility with version 6.5.)
%   Dated 10-28-04 x:xxPM.
% 
% r1.10: Generalizes the fingerprint.mat load call to look for the
%   first fingerprint.mat file on the Matlab search path (which should
%   be in the same directory as the wormproc function called).  (Allows 
%   us to change the WORMTOOLS folder name - e.g. adding release 
%   number - without having to hard-code the new path.)
%   Dated 8-11-04 11:37PM.
% 
% r1.09: Adds timestamp vector 'timeV' to data file.  Updates calls to 
%   PREORIENT to check for and return timestamp vector.  Replaces '\' 
%   with filesep for portability to non-Windows platforms.
%   Dated 7-23-04 10:44AM.
% 
% r1.08: Part of AUTOPROC ---> PREORIENT philosophy change:
%   No longer using AUTOPROC to Manually orient worms; now
%   using PREORIENT to orient worms automatically.
%   Adds call to PREORIENT; eliminates AUTOPROC call.  Updates help 
%   information adding PREORIENT references.
%   Dated 7-21-03 3:29PM.
% 
% r1.07: Loads *fingerprint* file from 'WormTools' directory; 
%   saves fingerprint along with 'data' file.
%   Dated 11-22-02 1:39PM.
% 
% r1.06: Adds wormproc_fingerprint to 'data' file.
%   Dated 11-13-02 4:35PM.
% 
% r1.05: Revises help information.  Fills in revision history.
%   Dated 9-03-02 6:22PM.
% 
% r1.04: Makes directory name a global variable (allowing access
%   by MANPROC* for window title display).  Dated 6-10-02 1:59AM.
% 
% r1.03: Calls AUTOPROC3 (adds effective interpolation across single
%   missing frames) and MANPROC3 (updates GUI, adds playback speed
%   control, corrects length calculation).  Dated 3-06-02 3:24PM.
% 
% r1.02: Calls AUTOPROC2 - revises table motion correction based on
%   email correspondence with Saleem.  Dated 2-15-02 4:29PM.


% Lock .m file in memory and create persistent variable for folder query.
mlock;
persistent lastDir;

% Variable Declarations
global directory;


% Prevent interp1:NaN in Y warnings:
originalwarningstate = warning('off', 'MATLAB:interp1:NaNinY');   
% 'originalwarningstate' contains previous state...


% Establish whether we Want to Definitely save for Matlab v6.x readability:
FORCE_to_v6 = 1;   % 1 = true, we want to save for v6 readability.
% Check for Matlab version
matlabversion = getmatlabversion;

% Start of function
if isempty(lastDir)
    directory = uigetdir('', 'Select Folder to Process');
else
    directory = uigetdir(lastDir, 'Select Folder to Process');
end

if directory == 0
    return
end

lastDir = directory;

% Display folder name
fprintf(1, '\nProcessing: %s\n', directory);

[x,y, timeV] = preorient2(directory);  % Production version

[x,y] = manproc3(x,y);  % Production version

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

clear PLAYPAUSE cx cy directory fingerprint lookupvalue lookupvaluestring
clear slider_pause_ slider_value_ 

% Restore original warning state:
warning(originalwarningstate)

return