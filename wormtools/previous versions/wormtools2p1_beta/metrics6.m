function [] = metrics6(mmpp, scnds, fpt, varargin)

%METRICS6    Calculate worm motion metrics.
%   FORMAT: metrics6(mmpp, #seconds, fpt, 'input_directory_name(s)');
%      where 
%      - "mmpp" is the ratio "millimeters per pixel" which is 
%         a function of microscope and camera optics.  For the
%         Sternberg Lab's worm tracking rig in Kerckhoff 221:
%             Magnification    mmpp (mm/pixel)
%             -------------    ---------------
%                  6x               0.017
%                 12x               0.0085
%                 25x               0.0041
%                 50x               0.0020
%      - "#seconds" is the length of the data set in seconds.
%         (e.g. a 4 minute data set will be 240 seconds.)
%      - "fpt" (literally "frames per timeblock") is the 
%         number of frames to group together for the velocity 
%         calculation.  That is, METRICS* calculates 
%         velocity by sampling worm position every N'th 
%         frame, where N = fpt.  (Specify 1 to use all frames.)
%      - "input_directory_name(s)" is the comma-separated
%         list of input directory names containing 
%         subdirectories named worm* (where * is an integer), 
%         which subsequently each contain a file called 'data' 
%         (containing matrices of x & y coordinate data).
%
%   example:  metrics6(0.0041, 240, 1,... 
%              'C:\Jane-AVD\Arsenite\cat4-0-30min',...
%              'C:\Jane-AVD\Arsenite\cat4-1.25-30min');   
%
%       NB: The '...' at the end of the lines allows the user to continue
%       input on the following line.
%
%   Output is a set of files called "metrics.mat" saved one in 
%   each worm* folder.  Metrics.mat files contain the variables:
%   - vel -- vector containing the mean instantaneous speed of 
%               a worm in along its serpentine path, specifically
%               the mean point velocity of points 5 through the 
%               end of the worm (forward and backward) for each 
%               time snapshot (or every N'th frame for fpt=N).
%   - velc - vector containing the mean worm CENTROID speeds (forward  
%               and backward) for each time snapshot (or every N'th 
%               frame for fpt=N).
%   - mode - vector containing flags indicating forward (1) or 
%               backward (-1) movement.
%   - theta - vector containing the instantaneous direction 
%               of movement (in radians).  (Velocity vector angle.)
%   - fre -- matrix containing the instantaneous bending 
%               frequencies for each of the worm's bends
%               at each time-snapshot of the data set.
%   - amp -- matrix containing the maximum bend angle, in radians, 
%               for a window of time-snapshots (using a sliding 
%               window) for each of the worm's bends. 
%   - flex - matrix containing the maximum flex, that is maximum 
%               minus minimum bend angle, in radians, for a window 
%               of time-snapshots (using a sliding window) for each 
%               of the worm's bends. 
%   - phs -- matrix containing the time delay (in seconds) between 
%               successive bends passing through the same angle 
%               at each time-snapshot.
%   - ptvel -- matrix containing the instantaneous velocity
%               of each point along a worm's "spine" at each
%               time-snapshot.
%   - ampt - vector containing the instantaneous wormtrack amplitudes 
%               or, more precisely, at each "time" the width of a 
%               bounding box aligned with the worm's velocity vector 
%               (the direction the rear 2/3 of the worm is traveling 
%               at that moment).
%   - wavelnth - vector contaning the instantaneous wormtrack 
%               wavelengths.  Calculated by: at each time snapshot, 
%               aligning the worm's velocity vector with the x-axis, 
%               performing a spatial (as opposed to temporal) fast 
%               Fourier transform (FFT) for the y-coordinates of the 
%               worm's posture (yielding cycles/pixel), inverting 
%               (to get pixels/cycle), and scaling to the desired units.
%   - len -- vector containing the calculated worm length at each time 
%               snapshot.
%   - metrics_fingerprint - structure array containing a listing of
%               m-files (functions) in directory "wormtools" that
%               are being used to perform the current processing job.
%   - mmpp -- (the milimeters per pixel value from the input section)
%   - dataset_length_in_seconds - (the #seconds value from the input section)
%   - fpt -- (the frames per timeblock value from the input section)
%   - input_directory_list - (list of input directories)
%   - seconds_per_frame - the calculated time between successive time
%               snapshots
%   - contr -- matrix of bend angles (in radians) for all of the worm's
%               bends.  (This is the matrix used to calculate FRE, FLEX
%               and PHS.)
% 
%   Discussion:  
%    FPT: Velocity is calculated by dividing change 
%    in position by time.  Decreasing the amount of 
%    time between position measurements increases the 
%    sensitivity to small changes in velocity, but also 
%    increases the data "noise" in the velocity measurement.  
%    (That is, inaccuracies in position measurement yield 
%    inaccuracies in velocity calculation.)  Increasing fpt
%    damps out the system's sensitivity to small changes in
%    velocity, but also decreases the effect of small 
%    position measurement errors.  Selection of fpt for 
%    a given application should be based on a laboratory's
%    data aquisition system accuracy.
%
%   C. J. Cronin 10-29-01
%   Revised 10-28-04 CJC.
% 

% r6.06: Changes 'save' method according to Matlab version & desire for 
%   compatibility with pre-version7.0 Matlab environments. (i.e. allows
%   forcing data into compatibility with version 6.5 or prior.)  Metrics is
%   currently hard coded to force data into version <=6.5 with the
%   'FORCE_to_v6' flag.
%   Dated 10-28-04 x:xxPM.
% 
% r6.05: Adds MMPP, DATASET_LENGTH_IN_SECONDS, FPT, and the list  
%   of input directories (INPUT_DIRECTORY_LIST) as processing 
%   "fingerprints" in the metrics.mat file.  (Previously there 
%   was no convenient way to determine what inputs were presented 
%   to METRICS for processing.)    Also adds the calculated values 
%   SECONDS_PER_FRAME and CONTR (the matrix of bend angles in 
%   radians) for convenience, particularly since both are already
%   calculated through intermediate steps in METRICS.  Updated help 
%   information to reflect changes and to clarify calling format.
%   Also changes call structure for loading fingerprint.mat to 
%   load the first fingerprint.mat on the search path (which should
%   be in the same directory as this metrics function).  (Allows us
%   to change the WORMTOOLS folder name - e.g. adding release number - 
%   without having to hard-code the new path.)
%   Dated 8-11-04 11:37PM.
%
% r6.04: Adds VELC (Centroid velocity) calculation; VEL is 
%   mean velocity of points 5:end, thus mean velocity of worm
%   in its track.  Changed help section to clarify and add VELC.  
%   Changes '\' to 'filesep' as appropriate for portability to 
%   non-Windows platforms.  Capitalized all x-axis labels; 
%   changed Velocity chart title to clarify 'mean point velocity.'
%   Dated 7-14-03 1:57AM.
% 
% r6.03: Adds LENGTH calculation (len); Adds 'len' to output
%   file 'metrics'.
%   Dated 5-22-03 9:44AM.
%
% r6.02: Loads *fingerprint* file from 'WormTools directory; 
%   saves fingerprint along with metrics file.
%   Dated 11-22-02 1:39PM.
%
% r6.01: Adds call to new function TIMEDELAY (code spun off of 
%   CONTRACTION3); updates call to CONTRACTION4.  Adds call to 
%   TRACKS (metrics of worm track).  Changes variable 'dir' to 
%   'theta' (to differentiate from the built-in function 'dir'.)  
%   Adds 'flex,' 'theta,' 'mode,' and 'metrics_fingerprint' to 
%   output file 'metrics'.  Cleans up processing time commands.
%   Adds 'metrics_fingerprint' to 'metrics' file.
%   Dated 11-13-02 4:35PM.
%
% r5.03: Revises help information.  Fills in revision history.
%   Dated 9-03-02 5:22PM.
%
% r5.02: Adds point velocity calculation (via POINTTRANSLATION).
%   Dated 6-10-02 2:07AM.
%
% r4.01: Calls TRANSLATION2.  Adds 'fpt' (frames per timeblock) 
%   to input: calculates velocity by sampling position every
%   N'th frame, where N = fpt.  Dated 2-27-02 11:14PM.
%   
% r3.01: Calls CONTRACTION3 (No 'offset' in function call.)
%   Dated 1-29-02 11:25PM.
%   
% r2.01: Changes 'spf' (seconds per frame) in function call
%   to 'number of seconds in data set'; adds spf calculation 
%   to METRICS.  Adds processing time output (as a monitor
%   of system performance).  Dated 12-18-01 10:55PM.
% CHANGING NAMES FOR GENERIC FORMAT BY REPLACING \ BY FILESEP
% JAGAN SRINIVASAN 16TH JUNE 2004 


% some error checking
if nargout > 0
	error('FORMAT: metrics5(mmpp, seconds, frames-per-timeblock, directory1, directory2, ....)');   
end

if nargin < 4
	error('FORMAT: metrics5(mmpp, seconds, frames-per-timeblock,  directory1, directory2, ....)');     
end

%----------------------------------------------------------------
% Establish whether we Want to Definitely save for Matlab v6.x readability:
FORCE_to_v6 = 1;   % 1 = true, we want to save for v6 readability.
% Check for Matlab version
matlabversion = ver('MATLAB');
matlabversion = str2num(matlabversion.Version);

%----------------------------------------------------------------
% Progress status display query
InvalidInput = 1;     % Flag to verify valid input
displayprogress = 0;       % Defaults to no chart display
fprintf(1,'\n');
while InvalidInput
    InvalidInput = 0;   % Assume valid input
    resp = input(['Display progress status?  (y)yes (n)no?  '], 's');
    if(( prod(size(resp)) == 1 ) & (xor((resp == 'y') , (resp =='n')))) 
        if resp == 'y'     % Yes, display progress...
            displayprogress = 1;
        end
    elseif isempty(resp)    % placeholder for valid input requiring no action
        
    else                    % Invalid because not [], 'y' or 'n'...
        beep
        fprintf(1, '     ---> Please enter ''y'' or ''n'' only...\n'); % Warning for bad input
        InvalidInput = 1;   % Restores Invalid input
   end
end


%----------------------------------------------------------------
% Coverage statistics query
InvalidInput = 1;     % Flag to verify valid input
displaychart = 0;       % Defaults to no chart display
fprintf(1,'\n');
while InvalidInput
    InvalidInput = 0;   % Assume valid input
    resp = input(['Display coverage statistic charts?  (y)yes (n)no?  '], 's');
    if(( prod(size(resp)) == 1 ) & (xor((resp == 'y') , (resp =='n')))) 
        if resp == 'y'     % Yes, display charts...
            displaychart = 1;
        end
    elseif isempty(resp)    % placeholder for valid input requiring no action
        
    else                    % Invalid because not [], 'y' or 'n'...
        beep
        fprintf(1, '     ---> Please enter ''y'' or ''n'' only...\n'); % Warning for bad input
        InvalidInput = 1;   % Restores Invalid input
   end
end

fprintf(1,'\n');

%-THE SET-UP FOR CALCULATING METRICS----------------------------

% now process data in each directory
for i=1:nargin-3        % because now three non-variable inputs
% for i=1:nargin-2      % Directories containing worm-directories.
   
   % get contents of each directory
   pd = varargin(i);
   pd = pd{1};
   
   d = dir([pd filesep 'worm*']);
   nd = prod(size(d));
   
   % now loop over each item
   for j=1:nd       % worm directories
      
      % get name of directory
      name = d(j).name;
      
      % print out message to stdout
      fprintf(1, 'Processing %s\n', [pd, filesep name]);
      
      % clear variables
      clear x y vel dir mode fre amp off phs ptvel len
      
      % load in the data
      directory = [pd filesep name];
      load([pd filesep name filesep 'data.mat']);
      
      % Calculate seconds per frame coversion factor:
      nframes = prod(size(x(:,1)));
      spf = scnds/nframes;
% CJC 8-9-04: When we fully implement use of time vector (timeV) this is
% probably where we should put the handler.  Perhaps something like:
%   if exist('timeV')
%  ......
      
      
%----------------------------------------------------------------
% NOW BEGIN COMPUTING METRICS 

%-TRANSLATION----------------------------------------------------
      if displayprogress
          fprintf(1, ['      Beginning *translation3* at ' datestr(now,14) '\n']);
      end
      
%       [vel, theta, mode, velc] = translation3_01x(x, y, mmpp, spf, fpt);
      [vel, theta, mode, velc] = translation3(x, y, mmpp, spf, fpt);

      
%-POINTTRANSLATION-----------------------------------------------
      if displayprogress
          fprintf(1, ['      Beginning *pointtranslation* at ' datestr(now,14) '\n']);
      end
      
      [ptvel, ptdir, ptmode] = pointtranslation(x, y, mmpp, spf, fpt);

      clear ptdir ptmode;
     
      
%-CONT-----------------------------------------------------------
      if displayprogress
          fprintf(1, ['      Beginning *cont* at ' datestr(now,14) '\n']);
      end
      
      contr = cont(x, y, 0);
      
      
%-CONTRACTION----------------------------------------------------
      if displayprogress
          fprintf(1, ['      Beginning *contraction4* at ' datestr(now,14) '\n']);
      end
      
      [fre, amp, flex] = contraction4(contr, spf);
      
      
%-TIMEDELAY------------------------------------------------------
      if displayprogress
          fprintf(1, ['      Beginning *timedelay* at ' datestr(now,14) '\n']);
      end
      
      [phs] = timedelay(contr, spf); 
      
      
%-TRACKS---------------------------------------------------------
      if displayprogress
          fprintf(1, ['      Beginning *tracks* at ' datestr(now,14) '\n']);
      end
      
      [ampt, wavelnth] = tracks(x, y, mmpp); 
      
      
%-LENGTH---------------------------------------------------------
      if displayprogress
          fprintf(1, ['      Beginning *length* at ' datestr(now,14) '\n']);
      end
      
      len_pixels = sum( sqrt( diff(   x').^2 + diff(   y').^2 ) );
      len = len_pixels*mmpp;    % Convert length into mm
      
      
%-SAVE RESULTS---------------------------------------------------
      % save the results
      if displayprogress
          fprintf(1, ['      Beginning *save* at ' datestr(now,14) '\n']);
      end
      
%       % Create "fingerprint" of what functions were used for 
%       %   current processing job.
%       metrics_fingerprint = what('wormtools');    % <--- Sloppy, and 
                                                    % not informative

      % Load first fingerprint.mat file on the Matlab search path (which SHOULD
      % be the file in the same directory as this metrics function).
      load( which('fingerprint.mat'), 'fingerprint');     % loads 
      %   (was)
      % Load fingerprint file from WormTools directory...
      % load(fullfile(matlabroot, 'toolbox','WormTools', 'fingerprint.mat'), 'fingerprint');

      input_directory_list = varargin;
      dataset_length_in_seconds = scnds;
      seconds_per_frame = spf;
      
      % Save x and y matrices (& fingerprint) in file "metrics" 
      % in desired format
      if ( FORCE_to_v6 & (matlabversion >= 7.0) )   % Add '-v6' flag to force
          save([pd filesep name filesep 'metrics.mat'], ...
              'vel', 'velc', 'fre', 'theta', 'amp', 'flex', 'phs', 'ptvel', ...
              'mode', 'ampt', 'wavelnth', 'len', 'fingerprint',...
              'mmpp', 'dataset_length_in_seconds', 'fpt','input_directory_list', ... % Inputs as *fingerprints*
              'seconds_per_frame', 'contr', '-v6'); % Additional high-level parameters for convenience.
      else
          save([pd filesep name filesep 'metrics.mat'], ...
              'vel', 'velc', 'fre', 'theta', 'amp', 'flex', 'phs', 'ptvel', ...
              'mode', 'ampt', 'wavelnth', 'len', 'fingerprint',...
              'mmpp', 'dataset_length_in_seconds', 'fpt','input_directory_list', ... % Inputs as *fingerprints*
              'seconds_per_frame', 'contr'); % Additional high-level parameters for convenience.
      end

       
           
           % % %       save([pd filesep name filesep 'metrics.mat'], ...
% % %            'vel', 'velc', 'fre', 'theta', 'amp', 'flex', 'phs', 'ptvel', ...
% % %            'mode', 'ampt', 'wavelnth', 'len', 'fingerprint'); 
% % % % % %       save([pd '\' name '\metrics.mat'], ...
% % % % % %            'vel', 'fre', 'theta', 'amp', 'flex', 'phs', 'ptvel', ...
% % % % % %            'mode', 'ampt', 'wavelnth', 'len', 'fingerprint'); 
      
      
%-COMPLETE-------------------------------------------------------
      if displayprogress
          fprintf(1, ['      Processing complete at ' datestr(now,14) '\n']);
      end
      
%----------------------------------------------------------------
      
      
      if displaychart == 1
          coverageplot(directory, x, vel, fre);
%           coverageplot_03x(directory, x, vel, fre);   % Devlopment version
          fprintf(1,'-----------------------------------------------------------------\n');
      end
%----------------------------------------------------------------

   end  % for j = 1:nd
   
end     % for i=1:nargin-3

return;