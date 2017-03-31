%WORMPROCCheryl    Master worm processing script
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

% % ---Autoproc replaced by preorient...---
% % % % % [x,y] = autoproc3_01x(directory); 
% % % % [x,y] = autoproc3(directory);       % Run AUTOPROC* -- generates xy 
% % % %                                     %  data used by MANPROC*.
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Find file(s) named points* in input directory:
% pointsname = dir([directory filesep 'points*']);
% 
% % Take first points* file as our choice:
% pointsname = pointsname(1).name;
% 
% % Load selected directory 
% points = load([directory filesep pointsname]);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% [longcutoff,shortcutoff] = lengthplotCheryl(len, directory)

% [x,y, timeV] = preorient2Cheryl(directory);  % Cheryl's long recordingversion
[x,y, timeV, shortcutoff, longcutoff] = preorient2Cheryl(directory);  % Cheryl's long recordingversion
% [x,y, timeV] = preorient2_01x(directory); % Development version
% [x,y, timev] = d_preorient(directory);    % Run D_PREORIENT for DigiTracker 'points'
% [x,y] = preorient(directory);    % Run PREORIENT


% During wormproc_08 (et al.) development, considered using MANPROC, and later 
% PREORIENT to do subsampling:
% Rejected in favor of using MANPROC for subsampling.

% HANDLE SUBSAMPLING VIA MANPROC GUI:
% % % subsamplerate = input(['\nEnter subsampling rate (e.g. 3 to use every 3rd frame)'...
% % %                        '\n    (enter  1  or leave blank to use all available data)> ']);
% % % if ~isnumeric(subsamplerate) | isempty(subsamplerate)
% % %     subsamplerate = 1;      % Default to no sub-sampling
% % % end
% % % subsamplerate = round(subsamplerate);   % In case user enters non-integer

% % %   [x,y, index] = preorient_01x(directory, subsamplerate);    % Run PREORIENT

[x,y] = manproc3Cheryl(x,y, shortcutoff, longcutoff);  % Production version
% [x,y] = manproc3_10x(x,y);    % Development version


% % Create "fingerprint" of what functions were used for 
% %   current processing job.
% wormproc_fingerprint = what('wormtools');   % <---- Sloppy, and
                                              % not informative

% Load first fingerprint.mat file on the Matlab search path (which SHOULD
% be the file in the same directory as this wormproc function).
load( which('fingerprint.mat'), 'fingerprint');     % loads 
% (was)
% Load fingerprint file from WormTools directory...
% load(fullfile(matlabroot, 'toolbox','WormTools', 'fingerprint.mat'), 'fingerprint');



% %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%     minutes = inputdlg('Enter recording length (in minutes)  (from index.txt file):','Recording length',1, {num2str(240)}, 'on');
%     minutes = minutes{1};
%     minutes = str2num(minutes);
%      
%     mmpp = inputdlg('Enter mm / pixel (mmpp) value:','mmpp value',1, {num2str(0.0041)}, 'off');
%     mmpp = mmpp{1};
%     mmpp = str2num(mmpp);
%     
%     fpt = inputdlg(['Enter ''frames per timeblock'' value:                                  ';...
%                      '  (that is, only consider every  x''th frame for velocity calculation)'],...
%         'fpt value',1, {num2str(1)}, 'off');
%     fpt = fpt{1};
%     fpt = str2num(fpt);
%     
%    
% 
% % Find file(s) named points* in input directory:
% pointsname = dir([directory filesep 'points*']);
% 
% % Take first points* file as our choice:
% pointsname = pointsname(1).name;
% 
% % Load selected directory 
% points = load([directory filesep pointsname]);
% 
% % Calculate spf
% spf = (minutes*60)/(size(points,1)/2);     % seconds / #frames
% 
% [vel, theta, mode, velc] = translation3Cheryl(x, y, mmpp, spf, fpt);
% 
% % time vector
% minV = [  minutes/size(velc,2) : minutes/size(velc,2)   : minutes];
% 
% % plot velc
% figure; plot(minV,velc,'b.'); grid on;
% %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

% Save x and y matrices (& fingerprint) in file "data" 
%   in input directory
if ( FORCE_to_v6 & (matlabversion >= 7.0) )
    save([directory filesep 'data'], 'x', 'y', 'timeV', 'fingerprint' , '-v6');    
%     save([directory filesep 'velc'], 'velc', 'fingerprint' , '-v6');    
else
    save([directory filesep 'data'], 'x', 'y', 'timeV', 'fingerprint');    
%     save([directory filesep 'velc'], 'velc', 'fingerprint');    
end
% save([directory '\data'], 'x', 'y', 'timev', 'fingerprint');    
% save([directory '\data'], 'x', 'y', 'fingerprint');    

fprintf(1, '\n');
% fprintf(1, 'Size of ''x'' = %g\n', size(x,1)); % Moved to manproc3_02x

% And do the velocity calculations
[vel, theta, mode, velc] = velcalcCheryl(directory);


clear PLAYPAUSE cx cy directory fingerprint lookupvalue lookupvaluestring
clear slider_pause_ slider_value_ 
clear FORCE_to_v6 matlabversion