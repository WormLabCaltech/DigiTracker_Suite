function [resx, resy] = manproc3(x, y, index)

%MANPROC3    Manually screen and orient worm data
%   [resx, resy] = MANPROC3(x, y)
%   [resx, resy] = MANPROC3(x, y, index)
%      where 
%      - "x" and "y" are matrices of x and y coordinates.  (Rows are 
%         time, columns are data points along a worm's "spine" from
%         head to tail).
%      - "resx" and "resy" are the same x and y coordinate matrices 
%         "cleaned up" by the user.  "resx" and "resy" are passed 
%         back in computer memory, not saved to disk.
%   Note: MANPROC expects that coordinate data has been 
%   preprocessed (oriented and screened) by function AUTOPROC.  
%         
%   MANPROC* allows user to manually screen and edit worm position 
%   data by viewing data set as a "movie."  Individual "frames" can 
%   be deleted or reincluded as desired.  User can flip the worm 
%   head-to-tail as required to correct for mistakes made (by 
%   computer or human) in function AUTOPROC*.
%         
%   Graphical user interface (GUI) consists of buttons resembling  
%   those of a videotape editor, with the addition of "accept/reject" 
%   and "flip" toggle buttons.
%         
%   IMPORTANT:  "Accept/Reject" TOGGLES the valid flag for ALL frames 
%   from the current frame through the end of the data set; that is, 
%   valids become invalids, and vice versa.  This allows the user to 
%   efficiently invalidate a range of data while maintaining any other
%   editing performed on the movie.  (The user should toggle the data 
%   to invalid at the beginning of the range, then toggle again AFTER 
%   the end of the invalid range.)
%       Example: For a range of data:
%                       Frame   Valid/Invalid
%                       -----   -------------
%                         1        Valid
%                         2       Invalid
%                         3        Valid
%                         4        Valid
%       Toggling "Accpt/Rejct" while on Frame 1 yields
%                       Frame   Valid/Invalid
%                       -----   -------------
%                         1       Invalid
%                         2        Valid
%                         3       Invalid
%                         4       Invalid
%
%   NOTE:  "Flip" works the same as "Accept", but in this case "flip" 
%   TOGGLES the worm's head position; that is, heads become tails, 
%   and vice versa, for ALL frames from the current frame through 
%   the end of the data set.
%
%   An additional button labeled "Un-Reject All" removes all "reject"
%   editing perfomed on the movie (except, missing worms are still
%   left "rejected").
% 
%   C. J. Cronin 10-29-01
%   Revised 10-28-04 CJC.
%   $Revision: 3.10 $  $Date: 2004/10/28 xx:xx:xx $
%

% This might be handy later:    -CJC  7-21-03
%      - "sub-sampling_rate" [default is 1] provides a means
%         reducing the effective data sampling frequency.  For
%         example, if data was originally sampled at 6Hz, 
%         calling this function with a subsampling rate of 3 
%         would return x and y coordinates with only every
%         third data point from the original data set 
%         represented-- that is, with a sampling rate of 2Hz!
%         (Obviously, a subsampling rate of 1 would return all
%         data from the original data set
%

% r3.10: Changed main GUI font sizes for proper rendering under 
%   Matlab v7.0.  Speeds execution of data sets with no images
%   by querying existance of 'any' images only once, then painting 
%   the missing-image screen only once.  Modifies calls to dispworm
%   (optional) 'axis_scale' parameter to prevent editor window's 
%   gridlines from wandering with successive draws.  ('axis_scale' 
%   contains the 'xlims' and 'ylims' for the editor window.)
%   Dated 10-28-04 x:xxPM.
%
% r3.09: Replaced '\' with filesep as appropriate for portability 
%   to non-Windows platforms.  Cleaned up length diagnostic chart 
%   to leave holes where rejected data occurs.
%   Dated 7-23-04 10:44AM.
%
% r3.08: Changes to tolerate missing images (or a single image). 
%   Dated 11-11-03 3:43PM.
%
% r3.07: Streamlined program for faster processing: Changed to 
%   load all images into an array (in RAM) at start of processing.  
%   Image for display is read from RAM (from array) rather than
%   reading from disk.
%   Dated 8-26-03 4:17PM.
%
% r3.06: Part of AUTOPROC ---> PREORIENT philosophy change:
%   No longer using AUTOPROC to Manually orient worms; now
%   using PREORIENT to orient worms automatically.
%   Adds second window displaying worm images for aid in 
%   orienting worms.  Adds capability of subsampling data, but 
%   subsample rate must be set IN THE SOURCE CODE.  (Provides for
%   future expansion--  "TO DO" item.)  Subsampling rate display 
%   added to GUI, but only as a semi-functional placeholder (mostly  
%   for display.)
%   Dated 7-21-03 3:29PM.
%
% r3.05: Removes forced warning beeps (allows user to silence
%   program).  Adds random salutation to exit question dialog box.
%   Dated 2-12-03 12:16PM.
%
% r3.04: Changes auto-rejection of "too short" and "too long" worms
%   to use percent of MOST COMMON worm length instead of mean length.
%   (Most common length is the maximum peak on the a length histogram.)
%   Adds an "Un-Reject All" button to clear all auto-rejected worms. 
%   (Exception: Missing worms are still auto-rejected).  Re-labeled 
%   "OK / NG" button to "Accpt/Rejct" for clarity, and added "Toggle" 
%   label above as a memory aid.
%   Dated 11-20-02 1:01PM.
%
% r3.03: Updates help information & comments.  Fills in revision 
%   history.  Modifies directory name definition to allow MANPROC 
%   call without directory name specified.  Dated 9-03-02 5:22PM.
% 
% r3.02: Interpolates over single NaN frames to increase data 
%   coverage.  GUI: moves FFwd & FRew away from Play & Stop buttons.
%   Dated 6-7-02 5:05PM.
% 
% r3.01: Updates GUI, adds playback speed control.  Corrects length 
%   calculation.  Dated 3-08-02 2:45PM.
% 
% r2.01: Adds auto-rejection of "too short" and "too long" worms based
%   on percent of mean length; sizes windows to fit any screen; 
%   eliminates standard deviation diagnostic chart at end.  Dated
%   3-06-02 9:49PM.
% 
% r1.03: Adds standard deviation to movie; displays diagnostic charts
%   (worm length standard deviation & % mean length vs frame) at end.
%   Dated 11-26-01 6:17PM.
% 
% r1.02: Calls DISPWORM2.  Dated 11-14-01 2:55PM.



% Commented version of MANPROC3_02 dated 6-7-02 5:05PM
%
% Based on MANPROC3_01x  dated  3-08-02  2:45PM
% - Adds interpolation code to end (based on Autoproc code)
%   to fill in single NaN frames (to improve amp, fre, and phs
%   coverage)
% - Modifies GUI to move FFwd and FRew away from Play and Stop
%
% Based on MANPROC  dated 11/26/01  6:17PM
% Changed to automatically invalidate worms that are shorter than 90% of 
% the mean worm length or longer than 110% of the mean worm length.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%
% argument checking
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 2
   error('invalid number of input arguments');
end   

if nargin < 3
    index = [1:size(x,1)]';
end
    
if (size(x,1) ~= size(y,1)) | (size(x,2) ~= size(y,2))
	error('size of x and y must agree');   
end

if nargout ~= 2
   error('invalid number of output arguments');	
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global frameno;
global action;
global PLAYPAUSE;       % Playback pause (# seconds per playback cycle)
global slider_pause_;   % Playback speed control slider POSITION (0-100)
global slider_value_;   % Text equivalent of Playback speed control 
                        %  slider position ('0%' - '100%').
global directory;       % Directory name (for window title display)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frameinterval = median(diff(index));
% frameno = 1;        
frameno = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Eliminate next line and eliminate call with INDEX
% subsamplerate = 6;   % FOR 6-12-03 PROCESSING...
subsamplerate = 1;  % TO DO:  Add user input capability to set
                    % subsampling rate...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


action = 2;         % Set initial action condition to "Stop"
PLAYPAUSE = 0.06;   % Number of seconds to pause during playback.  
                    % Can be reset during playback by slider.
% beep on;    % Forces warning tones


nworms = size(x,1);
flipflag = zeros(nworms,1);     % Initialize "flip" flags to 0's 
                                %(i.e. "don't flip")
validflag = ~isnan(x(:,1));     % Initialize valid flags to 1's (i.e. 
                                %   "yes, valid" for coordinates with 
                                %   numeric data; set to 0's (i.e. 
                                %   "invalid" for coordinates without data.
                                
len = sum(sqrt(diff(x').^2 + diff(y').^2)); % Corrected...
% len = sqrt(sum(diff(x').^2 + diff(y').^2));     % Vector of worm length at 
                                                %   each time snapshot.

                                                
%--AUTOSCREEN---------------------------------------------------------
%--Select most common worm length (closest integer number of pixels)--
%----as the "mean" length for autoscreen------------------------------
%----(WAS)--------------------
% mu = mean(len(~isnan(len)));                    % Mean worm length -- used 
%                                                 %   to scale axes for user 
%                                                 %   interface display and 
%                                                 %   set auto-trim lengths
%----(IS)-------------
lengths = [1:1:1000];   % Reference vector (wormlengths to 1000 pixels)
h = hist(len,lengths);  % Actual wormlengths into ref vector bins

indx = find( h == max(h) );     % Most common worm length(s)
indx = indx(1);             % The first (shortest), most common length
                            %   (to handle the rare case when there are
                            %   two or more most common lengths)-- (if
                            %   the first is not the correct choice, the
                            %   user will need to manually screen the 
                            %   data, or will need to modify this code.
                            
mu = lengths(indx);         % MU (formerly the mean) now the MOST
%                           %   COMMON WORM LENGTH, in pixels
% 
%---------------------------------------------------------------------
%---------------------------------------------------------------------

fastinterval = 500;             % Interval for FastFwd and FastRew
fastinterval = round( (fastinterval/frameinterval)/50 ) * 50;  % Scale for subsampled worms & round to nearest 50
% fastinterval = round( fastinterval/frameinterval );  % Scale for subsampled worms

% Parse bottom two directory names from directory string for figure title
if ~exist(directory)
    directory = ' ';
end

delimiter_positions = findstr(filesep, directory);
if size(delimiter_positions, 2) > 2
    figure_name = ['...' directory(delimiter_positions(end-2):end)];
else
    figure_name = directory;
end


%%%%%%%%%%%%%%%%%%DEVELOPMENT-CJC%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                    %
mu = mu;                                                            %
meanlength = mean(len(~isnan(len)));                                %
stddevlen = std(len(~isnan(len)));                                  %
                                                                    %
% Print to screen                                                   %                                                                    
fprintf(1, 'Most-common worm length = %5.1f pixels\n', mu);         %
fprintf(1, 'Mean worm length = %5.1f pixels\n', meanlength);        %
fprintf(1, 'Standard deviation (length) = %5.4f\n\n', stddevlen);   %
                                                                    %
fprintf(1, 'Number of input frames = %g\n', size(x,1));             %
                                                                    %
                                                                    %
deltalength = len - mu;                                             %
                                                                    %
numsigmas = deltalength/stddevlen;                                  %
                                                                    %
%%%%%%%%%%%%%%%%%%DEVELOPMENT-CJC%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


stddev = std(len(~isnan(len)));                 % Standard deviation of 
                                                %   worm length  --  used 
                                                %   trim off shrunken worms
                                                
% trimlength = mu - (2*stddev);                 % Mean - 2sigma
shortlength = 0.89*mu;                          % 89% of mean length
longlength = 1.12*mu;                           % 112% of mean length

validflag = validflag & ((len' >= shortlength) & (len' <= longlength));   
                                                % (Also) Invalidates worms
                                                %   more than +/- 10% of
                                                %   mean length
% (WAS)
% validflag = validflag & (len' >= trimlength);   % (Also) Invalidates worms
%                                                 %   more than 2 std.dev'ns
%                                                 %   below mean length.
%                                                 %  Data still visible, but
%                                                 %  Will be x'ed out.



%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pop a new figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%
scrnsz = get(0,'ScreenSize');
figwidth = 560;
figheight = 421;
% figure('position', ...
%     [scrnsz(3)-figwidth-10 , scrnsz(4)-figheight-80, figwidth, figheight]);
fig = figure('Name', figure_name, 'position', ...
    [scrnsz(3)-figwidth-10 , scrnsz(4)-figheight-80, figwidth, figheight]);
                                                % Locate new GUI window in 
                                                %  upper right corner of 
                                                %  screen 
% figure('position', [460  275  560  420]);       % Locate new GUI window in 
%                                                 %  upper right corner of 
%                                                 %  screen (assuming 1024 x 
%                                                 %  764 screen resolution)
set(fig,'DefaultUIControlUnits','Normalized')
set(fig,'DoubleBuffer','on')        % For flicker-free movie
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------
%------------------------------------------------------------------------

bckgrnd = get(fig, 'Color');

text_slider_label_ = uicontrol(fig, ...     % Slider Title
    'Style',        'Text',...
    'String',       'Playback Speed: ',...
    'Position',     [0.265 0.005 0.18 0.04],...
    'BackgroundColor', bckgrnd,...
    'HorizontalAlignment',  'Center');

text_slider_slow_ = uicontrol(fig, ...      % Slider low-end title
    'Style',        'Text',...
    'String',       'Slow',...
    'Position',     [0.445 0.005 0.05 0.04],...
    'BackgroundColor', bckgrnd,...
    'HorizontalAlignment',  'Right');

text_slider_fast_ = uicontrol(fig, ...      % Slider high-end title
    'Style',        'Text',...
    'String',       'Fast',...
    'Position',     [0.705 0.005 0.05 0.04],...
    'BackgroundColor', bckgrnd,...
    'HorizontalAlignment',  'Left');
     
slider_value_ = uicontrol(fig, ...          % Slider value (percent)
    'Style',        'Text',...
    'String',       '50%',...
    'Position',     [0.755 0.005 0.05 0.04],...
    'BackgroundColor', bckgrnd,...
    'HorizontalAlignment',  'Right');
     
slider_pause_ = uicontrol(fig,  ...           % Controls value of  
               'Style',    'Slider',   ...    %  PLAYPAUSE using 
               'Min',      0,          ...    %  slider control
               'Max',      100,        ...
               'Value',    50,        ...
               'Position', [0.5  0.01  0.2  0.04], ...
               'Callback', 'slider_pause');     % Calls slider_pause script
                                                % when slider is moved.
%                'Callback', 'slider_pause_01x'); % when slider is moved.

%------------------------------------------------------------------------
%------------------------------------------------------------------------

un_reject_text_ = uicontrol(fig, ...
            'Style',    'Text',   ...
            'String',   'Un-Reject All',    ...
                            ...
            'Position', [0.750 0.955  0.200  0.040],   ...
            'BackgroundColor', bckgrnd,...
            'HorizontalAlignment',     'Right',  ...
            'FontSize',     8,  ...
            'FontWeight', 'Light');
        

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% To do...  (6/12/03)
subsample_ = uicontrol(fig, ...
            'Style',    'Edit',   ...
            'String',   int2str(subsamplerate),    ...
            ...  NOT NECESSARY?????  'Value',    6,   ...
                            ...
            'Position', [0.925 0.045 0.05 0.04],   ...
            ... was 'Position', [0.925 0.005 0.05 0.04],   ...
            ...  'BackgroundColor', [1 1 1],...
            'BackgroundColor', bckgrnd,...
            'HorizontalAlignment',     'Right',  ...
            'FontSize',     8, ...          was 4,  ...
            'FontWeight', 'Light');
% FILL THIS IN...        
%             'Callback', TBD,
%             );
        
subsample_text_ = uicontrol(fig, ...
            'Style',    'Text',   ...
            'String',   'Subsample',    ...
                            ...
            'Position', [0.9 0.005 0.18 0.04],   ...
            ... was 'Position', [0.9 0.045 0.18 0.04],   ...
            'BackgroundColor', bckgrnd,...
            'HorizontalAlignment',     'Left',  ...
            'FontSize',     8, ...          was 2,  ...
            'FontWeight', 'normal');
        
%------------------------------------------------------------------------
%------------------------------------------------------------------------

toggle_text_ = uicontrol(fig, ...
            'Style',    'Text',   ...
            'String',   '---- Toggle ----',    ...
                            ...
            'Position', [0.035 0.370  0.180  0.035],   ...
            'BackgroundColor', bckgrnd,...
            'HorizontalAlignment',     'Center',  ...
            'FontSize',     8,...           was 4,  ...
            'FontAngle',    'italic',   ...
            'FontWeight', 'Light');
        
%------------------------------------------------------------------------
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function    Action  %
%   --------    ------  %
% Button group "A"      %
%     Stop    =   2     %
%     Play    =   3     %
%                       %
% Button group "B"      %
%     Step-   =   5     %
%     Step+   =   6     %
%                       %
% Button group "C"      %
%     Accept  =   7     %
%     Flip    =   8     %
%                       %
% Button group "D"      %
%     Done    =  -1     %
%                       %
% Button group "E"      %
%     Rew     =   1     %
%     FastRew =   9     %
%                       %
% Button group "F"      %
%     Fwd     =   4     %
%     FastFwd =  10     %
%                       %
% Button group "G"      %
%     Un-Reject = 11    %
%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% draw the buttons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aicons =     ['text(.5,.5,'' Stop  '',''Horiz'',''center'')'
              'text(.5,.5,'' Play >'',''Horiz'',''center'')'];
      
acallbacks = ['global action; action = 2;'
              'global action; action = 3;'];

btngroup('BevelWidth', 0.025, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupA', ...
         'ButtonID', ['Stop';'Play'], ... 
		   'Callbacks', acallbacks, ...
         'Position', [.050 .615 .15 .13], ...
         'IconFunctions', aicons);
     
%------------------------------------------------------------------------

bicons =     ['text(.5,.5,''< Step   '',''Horiz'',''center'')'
	 		  'text(.5,.5,''   Step >'',''Horiz'',''center'')'];
      
bcallbacks = ['global action; action = 5;' 
              'global action; action = 6;'];
           
btngroup('BevelWidth', 0.025, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupB', ...
         'ButtonID', ['Step-';'Step+'], ... 
		   'Callbacks', bcallbacks, ...
         'Position', [.050 .435 .15 .130], ...
         'IconFunctions', bicons);

%------------------------------------------------------------------------

      
% cicons =     ['text(.5,.5,''OK / NG'',''Horiz'',''center'')'
cicons =     ['text(.5,.5,''Accpt/Rejct'',''Horiz'',''center'')'
	 		  'text(.5,.5,''    Flip   '',''Horiz'',''center'')'];
      
ccallbacks = ['global action; action = 7;' 
              'global action; action = 8;'];
           
btngroup('BevelWidth', 0.025, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupC', ...
         'ButtonID', ['Accept';' Flip '], ... 
		   'Callbacks', ccallbacks, ...
         'Position', [.050 .240 .15 .130], ...
...         'Position', [.050 .255 .15 .130], ...
         'IconFunctions', cicons);
      
%------------------------------------------------------------------------

dicons =     ['text(.5,.5,''Done'',''Horiz'',''center'')'];
      
% dcallbacks = ['global action; action = -1;'];
dcallbacks = ['global action; action = 12;'];
           
btngroup('BevelWidth', 0.035, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupD', ...
       	 'ButtonID', ['Done'], ... 
		   'Callbacks', dcallbacks, ...
         'Position', [.050 .040 .15 .130], ...
         'IconFunctions', dicons);
     
%        	'ButtonID', ['Quit'], ... 
%------------------------------------------------------------------------
% upper left
eicons =     ['text(.5,.5,''<<<'',''Horiz'',''center'')'
              'text(.5,.5,'' <<'',''Horiz'',''center'')'];
      
ecallbacks = ['global action; action = 9;'
              'global action; action = 1;'];
           
btngroup('BevelWidth', 0.025, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupE', ...
       	 'ButtonID', ['FRew';'Rew '], ... 
		   'Callbacks', ecallbacks, ...
         'Position', [.015 .770 .110 .130], ...
         'IconFunctions', eicons);
     
%------------------------------------------------------------------------
% upper right
ficons =     ['text(.5,.5,''>>>'',''Horiz'',''center'')'
              'text(.5,.5,''>> '',''Horiz'',''center'')'];
      
fcallbacks = ['global action; action = 10;'
              'global action; action =  4;'];
           
btngroup('BevelWidth', 0.025, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupF', ...
       	 'ButtonID', ['FFwd';'Fwd '], ... 
		   'Callbacks', fcallbacks, ...
         'Position', [.125 .770 .110 .130], ...
         'IconFunctions', ficons);
     
%------------------------------------------------------------------------
% UN-REJECT ALL
gicons =     ['text(.5,.5,''x'',''Horiz'',''center'')'];
      
gcallbacks = ['global action; action = 11;'];
           
btngroup('BevelWidth', 0.135, ...
         'PressType', 'flash', ...
         'GroupID', 'GroupG', ...
       	 'ButtonID', ['Un_Reject'], ... 
		   'Callbacks', gcallbacks, ...
         'Position', [0.96 0.970  0.02  0.02], ...
         'IconFunctions', '');
     
%------------------------------------------------------------------------
%------------------------------------------------------------------------

% %%%%%%%%%%%%%%%%%%%%%%%%%%
% draw the axis and worms
% %%%%%%%%%%%%%%%%%%%%%%%%%%
h = axes('position', [0.3 0.1 0.6 0.8]);        % Using Normalized (default)
                                                %  coordinates in figure
% axis(mu * [-2 2 -2 2]);         % Scale axes to +/- 2x mean worm length
axis_scale = mu * [-0.58 0.58 -0.58 0.58];     % Setup to scale axes to +/- 0.58x most common worm length
% axis(mu * [-0.58 0.58 -0.58 0.58]);     % Scale axes to +/- 0.55x mean worm length
axis(axis_scale);     % Scale axes 
axis equal;                     % Makes axes square
axis ij;                        % Axis in Matrix mode (origin at upper 
                                %   left corner
grid on;                        % Turn on grid
drawnow;


%99999999999999999999999999999999999999999999999999999
%99999999999999999999999999999999999999999999999999999
%
% generate Second Figure to display worm images
fig2 = figure('Name', 'Worm Images', ...
              'Position', [13 313 432 318]);
set(fig2,'DoubleBuffer','on')        % For flicker-free movie

% % % h3 = axes;
% % % im = imread('C:\Jane-AVD\Shawn\WetVelocityDecay_5-22-03_SUBSAMPLING\trp-2\worm11\File.201.bmp');
% % % h2 = imagesc(im);
% % % axis image;
% % % % axis ij;
% % % colormap gray;
% % % 
% % % %----------
% % % trans = 0;
% % % up = 1;
% % % tx1 = 'Hello';
% % % %----------
%
%99999999999999999999999999999999999999999999999999999
%99999999999999999999999999999999999999999999999999999



%99999999999999999999999999999999999999999999999999999
%99999999999999999999999999999999999999999999999999999
%
% % % imagenumber = [];
% % % for i = 1:nworms
% % %     imagename = [directory '\File.' int2str(frameno) '.bmp'];
% % %     if exist(imagename, 'file') == 2
% % %         imagenumber = [imagenumber frameno];
% % %     end
% % % end
% % % 

% imagedir = dir([directory '\file.*']);
% imagedir = dir([directory filesep 'file.*']);   % replace '\' with 'filesep' for portability

% Look for .jpg images first, then for .bmp images
imagedir = dir([directory filesep 'file.*.jpg']);   % index of .jpg images
imagefmt = '.jpg';
if size(imagedir,1) == 0        %... otherwise check for .bmp images
    imagedir = dir([directory filesep 'file.*.bmp']);   % index of .bmp images
    imagefmt = '.bmp';
end


imagelist = [];
for i = 1:size(imagedir,1)
    temp_image_name = imagedir(i).name;
    temp_image_name = temp_image_name(6:end-4);
    imagelist = [imagelist; str2num(temp_image_name)];
end
imagelist = sort(imagelist);
imagespacing = median(diff(imagelist));     % Typical image spacing 
current_image = 0;      % Placeholder for image number-- ensures that image 1 displays

images_available = any(imagelist);          % Flag indicating presence of images

% GUI placeholder for worm without images:
if ~images_available                % In case no images
    displayImageNotAvail    % ...local function to plot 'Image Not Avail'
    current_image = 1;      % Placeholder
    appropriate_image = 1;  % Placeholder
end

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\    
% Populate image_array in RAM with all data set's images:
for i = 1:size(imagedir,1)
%     image_array{i} = imread([directory '\file.' int2str(imagelist(i)) '.bmp']);
    image_array{i} = imread([directory filesep 'file.' int2str(imagelist(i)) imagefmt]);
end
    
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\    
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\    
%
%99999999999999999999999999999999999999999999999999999
%99999999999999999999999999999999999999999999999999999

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop controlled by on-screen buttons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while action ~= -1              % While not "quit"

%99999999999999999999999999999999999999999999999999999
%99999999999999999999999999999999999999999999999999999
%
% % % cla;
% % % h2 = imagesc(im);
% % % 
% % % if up == 1
% % %     if trans <1
% % %         trans = trans+0.05;
% % %         set(h2, 'alphadata', trans);
% % % %         alpha(h2, trans);
% % %     else
% % %         up = 0;
% % %         trans = trans - 0.05;
% % %         alpha(h2, trans);
% % %     end
% % % else
% % %     if trans >0
% % %         trans = trans-0.05;
% % %         alpha(h2, trans);
% % %     else
% % %         up = 1;
% % %         trans = trans + 0.05;
% % %         alpha(h2, trans);
% % %     end
% % %     
% % % end
% % % % delete(tx1);
% % % tx1 = text(400, 50, num2str(trans));
%
%99999999999999999999999999999999999999999999999999999
%99999999999999999999999999999999999999999999999999999

    
    
    
%-FastRewind-----------------------------------------      
   if action == 9       %FastRewind

       if frameno > fastinterval
         frameno = frameno - fastinterval;    % Rewinds many frames at a time
% % %        if frameno > fastinterval * frameinterval
% % %          frameno = frameno - fastinterval * frameinterval;    % Rewinds many frames at a time
      else
         frameno = 1;   %  
         action = 2;    % Stops rewind.
      end
	  xp = x(frameno,:);    % Current frame, all columns
      yp = y(frameno,:);
      
      xp = (xp - mean(xp));     % Centers data about mean position
      yp = (yp - mean(yp));     %   of that frame
%       dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));
      dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);
%       dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%           axis_scale);
             
      pause(0.2);       % 0.2 second pause in rewind 
%-end of FastRewind-----------------------------------------      
      
%-Rewind-----------------------------------------      
   elseif action == 1       %Rewind
         
      if frameno > 10
         frameno = frameno - 10;    % Rewinds 10 frames at a time
% % %       if frameno > 10*frameinterval
% % %          frameno = frameno - 10*frameinterval;    % Rewinds 10 frames intervals at a time
      else
         frameno = 1;   % When 10[*frameinterval] or less frames remaining, 
         action = 2;    % stops rewind.
      end
	  xp = x(frameno,:);    % Current frame, all columns
      yp = y(frameno,:);
      
      xp = (xp - mean(xp));     % Centers data about mean position
      yp = (yp - mean(yp));     %   of that frame
%       dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));
      dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);
%       dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%           axis_scale);
             
      pause(PLAYPAUSE*3.3);       % Rewind 3x faster than play 
%       pause(0.2);       % 0.2 second pause in rewind 
%-end of Rewind-----------------------------------------      
      
%-Play--------------------------------------------------
   elseif action == 3       %Play
             
       if frameno < nworms
% % % 		   frameno = frameno + frameinterval;   % Increments frameno by one frame interval
		   frameno = frameno + 1;
   		   xp = x(frameno,:);      yp = y(frameno,:);
      	   xp = (xp - mean(xp));   yp = (yp - mean(yp));
%       	   dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));	
      	   dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);	
%            dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%                axis_scale);
   	   else
           action = 2;
	   end

       pause(PLAYPAUSE);   % Controls playback speed
       if validflag(frameno) == 0
           pause(PLAYPAUSE);    % Extra pause to see rejected frame
       end
%-end of Play-------------------------------------------      
      
%-Forward-----------------------------------------------
       
   elseif action == 4       %Forward  -  same comments as for Rewind
         
      if frameno <= nworms - 10
         frameno = frameno + 10;
% % %       if frameno <= index(end) - 10*frameinterval
% % %          frameno = frameno + 10*frameinterval;
      else
% % %          frameno = index(end);
         frameno = nworms;
         action = 2;
      end
      xp = x(frameno,:);        yp = y(frameno,:);
      xp = (xp - mean(xp));     yp = (yp - mean(yp));
%       dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));
      dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);
%       dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%           axis_scale);
      
      pause(PLAYPAUSE*3.3);
%       pause(0.2);
%-end of Forward---------------------------------------      
      
%-FastForward-----------------------------------------------
       
   elseif action == 10       %Forward  -  same comments as for Rewind
         
      if frameno <= nworms - fastinterval
         frameno = frameno + fastinterval;
% % %       if frameno <= index(end) - fastinterval * frameinterval
% % %          frameno = frameno + fastinterval * frameinterval;
      else
         frameno = nworms;
         action = 2;
      end
      xp = x(frameno,:);        yp = y(frameno,:);
      xp = (xp - mean(xp));     yp = (yp - mean(yp));
%       dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));
      dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);
%       dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%           axis_scale);
      
      pause(0.2);
%-end of FastForward---------------------------------------      
      
%-Step- -----------------------------------------------
   elseif action == 5       %Step -
      
      if frameno > 1
          frameno = frameno - 1;    % Single frame rewind
% % %       if frameno > frameinterval
% % %           frameno = frameno - frameinterval;    % Single frame rewind
   	      xp = x(frameno,:);    yp = y(frameno,:);
   	      xp = (xp - mean(xp)); yp = (yp - mean(yp));
%       	dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));
          dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);
%           dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%               axis_scale);
      end
      
      action = 2;
%-end of Step- -----------------------------------------      
      
%-Step+ ------------------------------------------------
   elseif action == 6       %Step +
      
      if frameno < nworms
          frameno = frameno + 1;    % Single frame forward
% % %       if frameno < index(end)
% % %           frameno = frameno + frameinterval;    % Single frame forward
	      xp = x(frameno,:);  yp = y(frameno,:);
   	      xp = (xp - mean(xp));    yp = (yp - mean(yp));
%       	  dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));
      	  dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);
%           dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%               axis_scale);
      end   
         
      action = 2;
%-end of Step+ ------------------------------------------      
      
%-Valid--------------------------------------------------
   elseif action == 7       % Valid-flag toggle
       validflag(frameno:end) = ~validflag(frameno:end);    
            % Toggles valid-flags from current frame to end of data set
%        dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));
       dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);
%        dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%            axis_scale);
       action = 2;
%-end of Valid------------------------------------------      
      
%-Flip--------------------------------------------------
   elseif action == 8       % Flip-flag toggle
       flipflag(frameno:end) = ~flipflag(frameno:end);
            % Toggles flip-flags from current frame to end of data set
%        dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));
       dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);
%        dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%            axis_scale);
       action = 2;
%-end of Flip-------------------------------------------      
      
%-Un_Reject----------------------------------------------
   elseif action == 11       % Un_Reject All
       beep;
       button = questdlg(...
           ['Are you sure you want to Un-Reject all worms?                                      ';
            'WARNING: Pressing ''Yes'' will remove all ''Accept/Reject'' editing performed so far...'],...
           'Hold on there, Chief...', 'No');
       if strcmp(button, 'Yes')
           validflag = ~isnan(x(:,1));
           frameno = 1;
	       xp = x(frameno,:);  yp = y(frameno,:);
   	       xp = (xp - mean(xp));    yp = (yp - mean(yp));
%            dispworm(h, xp, yp, flipflag(frameno), validflag(frameno));
           dispworm(h, xp, yp, flipflag(frameno), validflag(frameno), axis_scale);
%            dispworm_04x(h, xp, yp, flipflag(frameno), validflag(frameno), ...
%                axis_scale);
       end
       action = 2;
%-end of Un_Reject---------------------------------------      
      
%-Done---------------------------------------------------
   elseif action == 12       % Done
       beep;
       button = questdlg(...
           'Are you sure you want to save and quit?', ...
           [salutation '...'], 'Yes', 'No', 'Help', 'No');
       if strcmp(button, 'Yes')             % Yes, quit
           action = -1;
       elseif strcmp(button, 'Help')        % Help
           helpbutton = questdlg(...
                  ['- Pressing ''Yes'' will exit and save all editing performed so far.                                ';...
                   '- To quit without saving, press ''No'' then click in the main Matlab window and press <Ctrl><Break>'; ...
                   '                                                                                                 '; ...
                   'Are you sure you want to exit?                                                                   '], ...
                   'Help', 'Yes', 'No', 'No');
           if strcmp(helpbutton, 'Yes')     % Yes, quit
               action = -1;
           else                             % No, don't quit
               action = 2;
           end
       else                                 % No, don't quit
           action = 2;
       end
%-end of Done--------------------------------------------      
      
   else     % Vamping action... (if action = 2 Stop)
      
      pause(0.05);      % Momentary pause to free up cpu resources while 
                        %  idling (otherwise, idle action consumes 100% 
                        %  of CPU capability).
   end  %of if loop
   
% And with every cycle, refresh plot title   
   if frameno > 0 
           titletxt = sprintf('frame = %d     %10.3f of most common length' ,... 
               [index(frameno)     len(frameno)/mu]);
%                [frameno     len(frameno)/mu]);
%           DON'T DO THIS BECAUSE PREVENTS GOING TO COMMAND LINE
%            TO ACCESS CTRL-BREAK:
%            figure(fig);         % Force to main GUI window
           title([titletxt]);
           drawnow;
%99999999999999999999999999999999999999999999999999999999   
%99999999999999999999999999999999999999999999999999999999   
%



%()()()()()()()()()()()()()()()()()()()()()()()()()()()()
% CJC 2-12-04  COMMENTING OUT THE WHOLE BLOCK BELOW
% UNTIL WE CAN FIND A BETTER WAY TO SPEED PROCESSING.
% SLOWING IF NO IMAGES AVAILABLE BECAUSE EACH CYCLE 
% REPAINTS THE 'Image Not Available' IAMGE.

% Found the better way!  October 2004...
%     if 0   % CJC 2-12-04 FORCE NO 2nd WINDOW  any(imagelist)           % if there are any images in folder to display...
    if images_available     % if there are any images in folder to display...
%     if any(imagelist)           % if there are any images in folder to display...
        if any(imagespacing)    % if there is more than one image...
            % ...find the appropriate image to display.
            appropriate_image = round((index(frameno)-1)/imagespacing)*imagespacing + 1;
        else                    % else...if there is only one image, then
            appropriate_image = imagelist;  % make that one image the one displayed.
        end
%----------end
%-------> indented the block below:
%     appropriate_image = round((index(frameno)-1)/imagespacing)*imagespacing + 1;
%     %     appropriate_image = round((frameno-1)/imagespacing)*imagespacing + 1;
        if current_image ~= appropriate_image
            if any(find(appropriate_image == imagelist))
                % Display appropriate figure
                current_image = appropriate_image; 
                set(0, 'CurrentFigure', fig2)
                clf
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Try changing this 8/26/03:
%             im = imread([directory '\file.' int2str(appropriate_image) '.bmp']);
                imagelist_index = find(imagelist == appropriate_image);
                im = image_array{imagelist_index};
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
                % im = imread('C:\Jane-AVD\Shawn\WetVelocityDecay_5-22-03_SUBSAMPLING\trp-2\worm11\File.201.bmp');
                h2 = imagesc(im);
                set(gca, 'tickLength', [0 0]);
%                axes off;
                axis image;
                % axis ij;
                colormap gray;
                title(['Image for frame:  \bf' int2str(current_image)]);
                set(0, 'CurrentFigure', fig);
                current_image = appropriate_image; 
            else
                % Handle case where appropriate image doesn't exist
                % Keep currently displayed image
                current_image = appropriate_image;
            
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^
                set(0, 'CurrentFigure', fig2)
                displayImageNotAvail    % Local function to plot 'Image Not Avail'
%             image([ones(480,640)]*255)
%             text(.5,.5,'Image Not Available', 'HorizontalAlignment', 'center', 'Units', 'normalized');
%             set(gca, 'tickLength', [0 0]);
% %                 axes off;
%             axis image;
%             % axis ij;
%             colormap gray;
                set(0, 'CurrentFigure', fig);
%^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            
            end     % if any(find...
            
        end     % if current_image ~= appropriate_image
%---------> END OF INDENT BLOCK

%     else
%         set(0, 'CurrentFigure', fig2)
%         image([ones(480,640)]*255)
%         text(.5,.5,'Image Not Available', 'HorizontalAlignment', 'center', 'Units', 'normalized');
%         set(gca, 'tickLength', [0 0]);
% %             axes off;
%         axis image;
%         % axis ij;
%         colormap gray;
%         set(0, 'CurrentFigure', fig);
%         displayImageNotAvail    % Local function to plot 'Image Not Avail'
%         current_image = 1;      % Placeholder
%         appropriate_image = 1;  % Placeholder
        
    end     % if images_available


%     end % if any(imagelist)
     
% END--- CJC 2-12-04  COMMENTING OUT THE WHOLE BLOCK (ABOVE)
%()()()()()()()()()()()()()()()()()()()()()()()()()()()()




%
%99999999999999999999999999999999999999999999999999999999   
%99999999999999999999999999999999999999999999999999999999   
end     % if frameno > 0
   
      
end % End of While loop


%------------------------------------------------------------------------
%------------------------------------------------------------------------

% close the window
close all

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
clear image_array
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



%%%%%%%%%%%%%%%%%%%%%%%CJC-DEVELOPMENT%%%%START%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plots worm length vs frame number, showing rejected frames as red X's
fig3 = figure('Name', figure_name);
ordinal = [1:size(x,1)];

% Set up temporary length vector for plotting length with "holes"
temporaryLen = len;
temporaryLen(~validflag) = NaN;

plot(ordinal, temporaryLen*100/mu , 'b-');
% plot(ordinal(validflag), temporaryLen(validflag)*100/mu , 'b-');
% plot(ordinal(validflag), len(validflag)*100/mu , 'b-');
hold on;
if prod(size(len(~validflag))) ~= 0
    plot(ordinal(~validflag), len(~validflag)*100/mu, 'rx', ...
        'linewidth', 1.5, 'markersize', 9);
end

% plot(len(validflag)/mu , 'b-');
% hold on;
% plot(len(~validflag)/mu, 'ro');
title('Worm Lengths as % of Most Common Length', 'FontWeight', 'bold');
% title('Worm Lengths as % of Mean Length', 'FontWeight', 'bold');
% title('Valid Worm Lengths as % of Mean []');
% axis([1,1100,.60,1.10]);
xlabel('Frame number', 'FontWeight', 'bold');
ylabel('Percent of Most Common Length', 'FontWeight', 'bold');
% ylabel('Percent of Mean Length', 'FontWeight', 'bold');

% Legend:
pctacc = prod(size(len(validflag)))/prod(size(ordinal));
pctrej = prod(size(len(~validflag)))/prod(size(ordinal));
if prod(size(len(~validflag))) ~= 0
    legend(...
        {['Accepted  ' num2str(pctacc*100, '%4.1f') '%']; 
         ['Rejected  ' num2str(pctrej*100, '%4.1f') '%']}, 0);
 else
     legend(...
         {['Accepted  ' num2str(pctacc*100, '%4.1f') '%']}, 0);
 end


grid on;
set(fig3, 'PaperOrientation', 'Landscape');
set(fig3, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
%%%%%%%%%%%%%%%%%%%%%%%CJC-DEVELOPMENT%%%%%END%%%%%%%%%%%%%%%%%%%%%%%%%%



%*******************************************************
%*******************************************************
%*******************************************************
%
% SUBSAMPLING:   (taken from PREORIENT)


index = [1:size(x,1)]';
if subsamplerate ~= 1
    
% ...ON SECOND THOUGHT, NEVER OVERWRITE YOUR ORIGINAL DATA...
%     % save backup copy of original points file:
%     [success,result] = dos(['copy ' directory '\points ' directory '\ORIGINALpoints']);
    

    % extract every "subsamplerate'th" data point from 
    %   x and y vectors
    x       = x(1:subsamplerate:end,:);
    y       = y(1:subsamplerate:end,:);
    index   = index(1:subsamplerate:end);
    validflag = validflag(1:subsamplerate:end);
    flipflag = flipflag(1:subsamplerate:end);
    
% DON'T WASTE EFFORT ON WRITING NEW "POINTS" FILE
% ---> JUST RETURN SUBSAMPLED x AND y!
%     clear points
%     
%     % Block out memory for subsampled points matrix
%     points = NaN * zeros(size(x,1)*2, size(x,2));
% 
%     % Fill in new points matrix:
%     for i = 1:size(x,1)
%         points(i*2-1, :)    = x(i,:);
%         points(i*2, :)      = y(i,:);
%     end     % for i = 1:size(xsub,1)
%     
%     % Save copy to disk
%     save([directory '\points'], 'points', '-ascii');
    
end     % if subsamplerate ~= 1

%
%*******************************************************
%*******************************************************
%*******************************************************






%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign output variables
%%%%%%%%%%%%%%%%%%%%%%%%%%

resx = x;
resy = y;

% Flip the data according to flip-flag
resx(logical(flipflag),:) = resx(logical(flipflag),end:-1:1);
resy(logical(flipflag),:) = resy(logical(flipflag),end:-1:1);

% Null out all invalid data according to valid-flag
resx(logical(~validflag),:) = NaN;
resy(logical(~validflag),:) = NaN;

%%%%%%%%%%%%%%% INTERPOLATION - START %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% But x & y still contain NaN's in the middle...  So,
% Interpolate over SINGLE NaN's:
for i = 2:(size(resx,1)-1)
    if isnan(resx(i,1))
        resx(i,:) = interp1([i-1 ; i+1], [resx(i-1,:) ; resx(i+1,:)], i, 'linear');
        resy(i,:) = interp1([i-1 ; i+1], [resy(i-1,:) ; resy(i+1,:)], i, 'linear');
    end
end
%%%%%%%%%%%%%%% INTERPOLATION - END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%% DIAGNOSTICS %%%%%%%%%%%%%%%%
disp(['Output: ' int2str(size(resx,1)) ' Frames']);
%%%%%%%%% DIAGNOSTICS %%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%
% now return
%%%%%%%%%%%%%%%%%%%%%%%%%%
return;


%--------------------------------------------------------------
%
function [] = displayImageNotAvail()

        image([ones(480,640)]*255)
        text(.5,.5,'Image Not Available', 'HorizontalAlignment', 'center', 'Units', 'normalized');
        set(gca, 'tickLength', [0 0]);
%             axes off;
        axis image;
        % axis ij;
        colormap gray;

%------------------
%
function [a] = salutation()
%Based on:
%WHY    Provides succinct answers to almost any question.
%   WHY, by itself, provides a random answer.
%   WHY(N) provides the N-th answer.
%   Please embellish or modify this function to suit your own tastes.

%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 5.14 $  $Date: 2001/04/15 12:02:27 $

% if nargin > 0, rand('state',n); end

rand('state',sum(100*clock));
switch fix(4*rand)
    case 0,        a = proper_noun;
    case {1 2},    a = [instruction ', ' proper_noun];
    otherwise,     a = instruction;
end
% a(1) = upper(a(1));
% disp(a);

%------------------

function a = proper_noun
switch fix(20*rand) 
    case 0,    a = 'Jack';
    case 1,    a = 'Homer';
    case 2,    a = 'Good Lookin''';
    case 3,    a = 'Big Guy';
    case 4,    a = 'Sugar Lips';
    case 5,    a = 'Honey Child';
    case 6,    a = 'Honey Lamb';
    case 7,    a = 'Honey Baby';
    case 8,    a = 'Honey Doll';
    case 9,    a = 'Honey Pie';
    case 10,    a = 'Sweet Thing';
    case 11,    a = 'Wild Thing';
    case 12,    a = 'Lady';
    case 13,    a = 'Pilgrim';
    case 14,    a = 'Sally';
    case 15,    a = 'Barney';
    case 16,    a = 'Tinky Winky';
    otherwise,  a = 'Dude';
end

function a = instruction
switch fix(5*rand) 
    case 0,    a = 'Hold on';
    case 1,    a = 'Whoa';
    case 2,    a = 'Hold up there';
    case 3,    a = 'Chill';
    case 4,    a = 'Hold Yer Horses';
end
%
%--------------------------------------------------------------
