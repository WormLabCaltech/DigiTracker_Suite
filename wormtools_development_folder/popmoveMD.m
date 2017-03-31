function [] = popmoveMD(varargin)

% POPMOVEMD        Calculate behavior durations from population data (for Meenakshi Doma.
%   FORMAT: popmoveMD('Input_directory_name(s)')
%      where 
%      - 'Input_directory_name(s)' are the names of data folders for 
%         for comparison with each other.  Each folder must contain
%         subfolders named worm* (where * is typically an integer), which
%         subsequently each contain a file called 'metrics' (containing
%         matrices of data quantifying aspects of worm locomotion).  
%
%   example:  popmoveMD('C:\Jane-AVD\Arsenite\N2',...
%                         'C:\Jane-AVD\Arsenite\cat-4',...
%                         'C:\Jane-AVD\Arsenite\NL130');
%   (To view head-to-head comparison of 'N2', 'cat-4', and 'NL130'.)
%
%   popmoveMD compares the behaviors of one or more populations of worms:
%   Individual worms' data are pooled and used to calculate mean-of-means
%   values for inter-population comparison.  popmoveMD displays mean values
%   of: 
%   - reversals/minute (where a reversal is a forward->backward or
%     stopped-> backward change,
%   - durations of forward and backward movement and stopped episodes
%   - distances travelled when moving forward or backward
%   - speed of movement when moving forward or backward
%   (For durations and distances, the user is prompted for threshold values
%   determining 'valid' movements or stopped events.)
%
%   In addition, popmoveMD can display the underlying data from each worm
%   in the population under study.
%
%   When comparing exactly two populations, popmoveMD will offer to run
%   t-Tests on each measure of behavior.  The user is prompted for whether
%   to assume the variances in each measure are the same.  (See Matlab's
%   ttest2 documentation for further discussion.)
%
%   popmoveMD uses a function called mikerpmMD as an engine to extract
%   individual worms' measures of behaviors.  mikerpmMD was based on
%   mikerpm which was developed for this project.
%   
%   The plotting functions in popmoveMD (although currently not implemented
%   makes use of a function called BARERRORBAR, written and 
%   contributed to the Matlab community by Kenneth D. Morton Jr. and J.
%   Simeon Stohl.  (See the BARERRORBAR function for author contact
%   information.)
%
%   Based on popmove.m
%
%   Christopher J. Cronin
%   cjc@caltech.edu
%   Sternberg Lab, Caltech
%   Pasadena, CA  91125
%   June 27, 2013
%


% ================================================================
% =========== SETUP ==============================================
% ================================================================

DEBUG = false;

if nargin==0
    % PROMPT FOR INPUT DIRECTORIES
    error('POPMOVE needs input directories...  C''mon, toss me a bone, would ya!?!');
end

% Define Constants
MEAN_COL    = 1;
STD_COL     = 2;
NUMEL_COL   = 3;
SEM_COL     = 4;

RPM         = 1;
FWD_DUR     = 2;
BKWD_DUR    = 3;
ForB_DUR    = 4;
STOP_DUR    = 5;
FWD_DIST    = 6;
BKWD_DIST   = 7;
ForB_DIST   = 8;
FWD_SPEED   = 9;
BKWD_SPEED  = 10;
ForB_SPEED  = 11;

% Use these for indexing during p-value calculations
FWD     = 1;
BKWD    = 2;
FORB    = 3;
STOPPED = 4;

% % % FWD         = 1;
% % % BKWD        = 2;
% % % STOPPED     = 3;
% % % RPM         = 4;
% % % FWDPCT      = 5;    % popmoveMD shouldn't use this
% % % BKWDPCT     = 6;    % popmoveMD shouldn't use this
% % % STOPPCT     = 7;    % popmoveMD shouldn't use this



timeRanges = 1;     % For first cut don't want to deal with comparing early vs late time ranges!!!

% % % % Ask whether to early- vs late-data 
% % % % (split data sets into "before" and "after" for comparison)
% % % button = questdlg('Care to compare data in early vs. late time ranges?',...
% % % 'Split data time-wise?','Yes','No', 'Cancel','No');
% % % if strcmp(button,'No')
% % %    timeRanges = 1;
% % % elseif strcmp(button,'Yes')
% % %     % FOR A SINGLE TIME BREAKPOINT (i.e. TWO RANGES)
% % %     timeRanges = 2;
% % %     prompt = 'Break the data into ''before'' and ''after'' at what time (in seconds)?';
% % %     dlg_title = 'Time breakpoint?';
% % %     num_lines = 1;
% % %     def = {'300'};     % Time breakpoint
% % %     answer = inputdlg(prompt,dlg_title,num_lines,def);
% % %     if isempty(answer)      % In case user presses cancel
% % %         return
% % %     end
% % %     [breakpoint status] = str2num(answer{1});  % Use curly bracket for subscript
% % %     if ~status || (mod(breakpoint,1) ~= 0) || (numel(breakpoint) ~= 1)
% % %         error(['''' prompt ''' dialog expects a single integer.']);
% % %     end
% % %     
% % % % FOR AN ARBITRARY NUMBER OF RANGES, TRY SOMETHING LIKE THIS: 
% % % % (NB: THERE SEEM TO BE SOME PROBLEMS WITH ASSEMBLING THE PROMPT...)
% % % %     prompt = 'How many time ranges?';
% % % %     dlg_title = 'How many time ranges?';
% % % %     num_lines = 1;
% % % %     def = {'1'};     % Velocity Threshold, Ignore
% % % %     answer = inputdlg(prompt,dlg_title,num_lines,def);
% % % %     if isempty(answer)      % In case user presses cancel
% % % %         return
% % % %         %         answer = def;       % use the default text
% % % %     end
% % % %     [timeRanges status] = str2num(answer{1});  % Use curly bracket for subscript
% % % %     if ~status || ~isinteger(timeRanges)
% % % %         error(['''' prompt ''' dialog expects a single integer.']);
% % % %     end
% % % %     if timeRanges < 1
% % % %         error(['''' prompt ''' dialog expects an integer greater than one.']);
% % % %     end
% % % %     % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % %     
% % % %     
% % % %     % Define the time break-points
% % % %     prompt = {['What are the breakpoints (in minutes)?';...
% % % %                '1                                     ' ]};
% % % %     if timeRanges > 2
% % % %        for breakpoint = 2:(timeRanges-1)
% % % %            prompt = [prompt num2cell(breakpoint)];
% % % %        end
% % % %     end
% % % %     dlg_title = 'Time breakpoints';
% % % %     num_lines = 1;
% % % %     def = {'1','2', '3'};     % Velocity Threshold, Ignore
% % % %     answer = inputdlg(prompt,dlg_title,num_lines,def);
% % % %     if isempty(answer)      % In case user presses cancel
% % % %         return
% % % %     end
% % %     
% % % else
% % %    return
% % % end


%----------------------------------------------------------------
%---------------------------------------------------------------
% Prompt for the chart parameter information (if necessary):
% if nargin<3
prompt = {['Stop threshold [mm/sec]                                      ';...
           '  (any movement less than this speed is considered ''stopped'')' ],...
          ['Minimum travel distance [mm]                                 ';...
           '  (movement less than this far is considered ''invalid'')      '],...
          ['Minimum stopped frames [# video frames]                          ';...
           '  (pauses of less than this many frames are considered ''invalid'')']};
dlg_title = 'Enter analysis parameters';
num_lines = 1;      
def = {'0.05', '0.3', '3'};     % Stop threshold, Minimum valid disance, Minimum valid stopped frames
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)      % In case user presses cancel
    return
%         answer = def;       % use the default text
end

% Set parameters
stopThreshold = str2double(answer{1});
minDist = str2double(answer{2});
minStoppedFrames = str2double(answer{3});



%---------------------------------------------------------------
%---------------------------------------------------------------

legendtext = promptforlegend(varargin{:});
legendtextCHAR = char(legendtext);      % matrix-version
legendtextCELL = cellstr(legendtext);   % cell-version
% legendtext = promptforlegend_01x(varargin{:});

legendtextWidth = size(legendtextCHAR,2);

%---------------------------------------------------------------
%---------------------------------------------------------------

% These aren't relevant to popmoveMD currently...

% % % % Ask whether to display stopped, too
% % % button = questdlg('Shall I display stopped durations, too?',...
% % % 'Stopped, too?','Yes','No', 'Cancel','Yes');
% % % if strcmp(button,'Yes')
% % %    displaystopped = 1;
% % % elseif strcmp(button,'No')
% % %    displaystopped = 0;
% % % else 
% % %    return
% % % end
% % % 
% % % %---------------------------------------------------------------
% % % %---------------------------------------------------------------

% % % % Ask whether to show figures for each and every worm
% % % button = questdlg({'Display figures for each worm?';...
% % %                     '(Note: Too many worms may cause Matlab to run out of memory and crash...)'},...
% % % 'Figures for each individual worm?','Yes','No', 'Cancel','No');
% % % if strcmp(button,'Yes')
% % %    verbosefig = 1;
% % % elseif strcmp(button,'No')
% % %    verbosefig = 0;
% % % else 
% % %    return
% % % end
% % % 
% % % 
% % % %---------------------------------------------------------------
% % % %---------------------------------------------------------------

% Ask whether to show painful details of each and every worm
button = questdlg('Care to see the details (text) of each worm?',...
'Gory details?','Yes','No', 'Cancel','No');
if strcmp(button,'Yes')
   VERBOSE = 1;
elseif strcmp(button,'No')
   VERBOSE = 0;
else 
   return
end


%---------------------------------------------------------------
%---------------------------------------------------------------


% Comment out the plots window until we re-implement plotting
SHOWPLOTS = false;

% % Show plots?
% button = questdlg('Wanna see plots of your data?',...
%     'Show plots?','Not really','No', 'Absolutely not!', 'No');
% if isempty(button)
%     return
% else
%     SHOWPLOTS = false;
% end
    

%---------------------------------------------------------------
%---------------------------------------------------------------


% If we have exactly 2 conditions to compare offer to run t-Tests
RUNTTEST = false;   % default
if nargin == 2
    EQUALVARS = 'equal';  % default-- Assuming equal variances 

    button = questdlg({'You are comparing exactly two populations...',...
        'Wanna run t-Tests on ''em???',...
        '...And shall we assume the variances to be equal or unequal',...
        '   when calculating the p-values?',...
        '(Refer to Matlab''s ''ttest2'' documentation for details.)'},...
        'Run t-Tests?','Yes, equal', 'Yes, unequal', 'No', 'No');
    if isempty(button)
        return
    else
        if strcmp(button, 'Yes, equal')
            RUNTTEST = true;
        elseif strcmp(button, 'Yes, unequal')
            RUNTTEST = true;
            EQUALVARS = 'unequal';
        end
    end
    
end
    

%---------------------------------------------------------------
%---------------------------------------------------------------


% Query for whether to save output in a text file
SAVETEXT = false;   % Default to NOT save file
fid = -1;           % Set default file ID to "un-openable"
button = questdlg({'Want to save the data to a tab-delimited file?';...
                   '(e.g. for import into Microsoft Excel)'},'Save data?','No');
if strcmp(button, 'Yes')
    [filename,pathname] = uiputfile({'*.txt', 'Text files (*.txt)'},'Save As');
    if (~ischar(filename) || ~ischar(pathname)) && ((filename == 0) && (pathname == 0))
        return
    end
    savefilename = fullfile(pathname, filename);
    fid = fopen(savefilename,'w');
    if fid==-1
        error(['Cannot open file ''' savefilename ''' for writing.']);
    end
    SAVETEXT = true;
elseif strcmp(button, 'No')
    SAVETEXT = false;
else
    return
end

if SAVETEXT
    fileID = [1 fid];   % To screen and open file
else
    fileID = [1];   % Just to screen
end



%---------------------------------------------------------------
%---------------------------------------------------------------
    flags.debug     = DEBUG;
    flags.verbose   = VERBOSE;
    flags.showplots = SHOWPLOTS;
    
    thresholds.stopSpeed        = stopThreshold;
    thresholds.minDist          = minDist;
    thresholds.minStoppedFrames = minStoppedFrames;
%---------------------------------------------------------------
%---------------------------------------------------------------




% ================================================================
% =========== DATA ACCUMULATION ==================================
% ================================================================

% Pre-allocate data matrix for
% - 11 attributes ( Reversals/min;
%                   Mean durations fwd-, bkwd-, fwd_or_bkwd- and stopped;
%                   Mean distances fwd-, bkwd- and fwd_or_bkwd(absolute value);
%                   Mean speeds fwd-, bkwd- and fwd_or_bkwd(absolute value) )
% - 4 aspects (Mean, STD, numel, SEM)
% - 'nargin' input directories (i.e. 'conditions')
% - 'timeRanges' time ranges (early-late vs a single 'all') -- ALWAYS 1 FOR NOW!!!
data = NaN * ones(11,4,nargin,timeRanges);


if VERBOSE
    conditionDirNamesCHAR = char(varargin);
    conditionDirNamesWidth = size(conditionDirNamesCHAR,2);
        
    % Set up for printing individual worm data
    for fff = fileID 
        fprintf(fff, 'LEGEND:\n');
        fprintf(fff, 'RPM  = Reversals/minute\n');
        fprintf(fff, 'Dur  = Mean duration of movement (in direction noted) or stop events [seconds]\n');
        fprintf(fff, 'Dist = Mean distance travelled (in direction noted) [mm]\n');
        fprintf(fff, 'Spd  = Mean speed of travel (in direction noted)\n');
        fprintf(fff, 'Revs = Number of reversals (fwd->bkd or stopped->bkwd)\n');
        fprintf(fff, '(F)  = ...when moving Forward\n');
        fprintf(fff, '(B)  = ...when moving Backward\n');
        fprintf(fff, '(FB) = ...when moving forward OR backward (taking the absolute values)\n');
        fprintf(fff, '(S)  = ...whenStopped\n');
        
        fprintf(fff, '%s\n', repmat('-', 1, 80));
    end % for fff = fileID 
end     % VERBOSE


for k=1:nargin      % cycle through input directories

    % get contents of each directory
    pd = varargin{k};
   
    d = dir([pd filesep 'worm*']);
    nd = numel(d);
   
    % Pre-allocate conditionData matrix:
    % - 11 attributes ( reversals/min;
    %                   Mean durations fwd-, bkwd-, fwd_or_bkwd- and stopped;
    %                   Mean distances fwd-, bkwd- and fwd_or_bkwd(absolute value);
    %                   Mean speeds fwd-, bkwd- and fwd_or_bkwd(absolute value) )
    % - nd worms in the input directory
    conditionData = NaN * ones(11, nd, timeRanges);
    
    if VERBOSE
        % Figure out how wide the condition and worm folder lists are (for printing)
        wormDirNames = cell(nd,1);
        for w = 1:nd
            wormDirNames{w} = d(w).name;
        end
        wormDirNamesCHAR = char(wormDirNames);
        wormDirNamesWidth = size(wormDirNamesCHAR, 2);
        
        % Make a copy of the legendtextCHAR array for the VERBOSE view
        legendtextCHARindiv = legendtextCHAR;
        
        % Pad narrower char array 
        if legendtextWidth > wormDirNamesWidth
            wormDirNamesCHAR      = [wormDirNamesCHAR      repmat( blanks(legendtextWidth - wormDirNamesWidth), size(wormDirNamesCHAR,1),      1 )];
        elseif legendtextWidth < wormDirNamesWidth
            legendtextCHARindiv = [legendtextCHARindiv repmat( blanks(wormDirNamesWidth - legendtextWidth), size(legendtextCHARindiv,1), 1 )];
        end
 
% Decided to use Legend text instead of the full path to the input directories 
%         % Pad narrower char array 
%         if conditionDirNamesWidth > wormDirNamesWidth
%             wormDirNamesCHAR      = [wormDirNamesCHAR      repmat( blanks(conditionDirNamesWidth - wormDirNamesWidth), size(wormDirNamesCHAR,1),      1 )];
%         elseif conditionDirNamesWidth < wormDirNamesWidth
%             conditionDirNamesCHAR = [conditionDirNamesCHAR repmat( blanks(wormDirNamesWidth - conditionDirNamesWidth), size(conditionDirNamesCHAR,1), 1 )];
%         end
        
        % Set up for printing individual worm data
        for fff = fileID 
            % Print header row for condition
            fprintf(fff, '%s\t  RPM\t  Dur(F)\t  Dur(B)\t  Dur(FB)\t  Dur(S)\t  Dist(F)\t  Dist(B)\t  Dist(FB)\t  Spd(F)\t  Spd(B)\t  Spd(FB)\tRevs\n', legendtextCHARindiv(k,:));
        end % for fff = fileID 
    end     % VERBOSE

    % now cycle through each worm directory in input directory k
    for j=1:nd       % worm directories
        
        % get name of directory
        name = d(j).name;
        
        if VERBOSE
            % Cycle through each worm-- for now only print the worm name...
            for fff = fileID 
                fprintf(fff, '%s\t', wormDirNamesCHAR(j,:));
            end     % for fff = fileID 
        else
            % Show progress to the user
            for fff = fileID 
                fprintf(fff, 'Processing %s\n', [pd, filesep name]);
            end     % for fff = fileID 
        end     % if VERBOSE
        
        % clear variables
  % FIXME CJC -- MAKE SURE THESE ARE ALL
        clear x y vel dir mode fre amp off phs ptvel len
        
        % Prepare file name
        directory = [pd filesep name];
        if exist([directory filesep 'metrics.mat'], 'file')==2
            fullfilename = [directory filesep 'metrics.mat'];
% % %         elseif exist([directory filesep 'veldata.mat'], 'file')==2
% % %             fullfilename = [directory filesep 'veldata.mat'];
        else
            fullfilename = [];
            warning(['No suitable velocity data available in: ' directory]);
        end       % if exist
        
        %vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
% % %         if timeRanges > 1
% % %             
% % %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %             %
% % %             % LOAD DATA
% % %             %
% % %             % First, query name (if necessary)
% % %             if nargin >= 1  % if presented with file name as a string
% % %                 [pathname,name,ext] = fileparts(fullfilename);
% % %                 filename = [name ext];
% % %             else
% % %                 [filename, pathname] = uigetfile( ...
% % %                     {'*.mat', 'Matlab files (*.mat)'},'Select file containing ''velc'' data');
% % %             end
% % %             
% % %             % Just in case, ensure that pathname ends with a filesep
% % %             if pathname(end) ~= filesep
% % %                 pathname(end+1) = filesep;
% % %             end
% % %             
% % %             
% % %             if filename==0
% % %                 error('No file selected')
% % %             end
% % %             
% % %             % HERE'S THE LOAD CALL...
% % %             behaviorData = load([pathname filename]);
% % %             
% % %             % Add fullfilename to the cell array
% % %             behaviorData.fullfilename = fullfilename;
% % %             lowerData.fullfilename = behaviorData.fullfilename;
% % %             upperData.fullfilename = behaviorData.fullfilename;
% % %             
% % %             % Create reference time vector
% % %             if isfield(behaviorData, 'spf')
% % %                 behaviorData.timeV = behaviorData.spf * (1:numel(behaviorData.vel));
% % %             end
% % %             if isfield(behaviorData, 'seconds_per_frame')
% % %                 behaviorData.timeV = behaviorData.seconds_per_frame * (1:numel(behaviorData.vel));
% % %             end
% % %             
% % %             % Identify breakpoint element:
% % %             lowerRange = find(behaviorData.timeV <= breakpoint);
% % %             upperRange = find(behaviorData.timeV >  breakpoint);
% % % %             lastLower = find( (timeV(1:end-1)<=breakpoint) & (timeV(2:end)>breakpoint) );
% % %             
% % %                 % Abridge values of vel, velc, spf, fpt and seconds_per_frame
% % %                 if isfield(behaviorData, 'vel')
% % %                     lowerData.vel = behaviorData.vel(lowerRange);
% % %                     upperData.vel = behaviorData.vel(upperRange);
% % %                 end
% % %                 if isfield(behaviorData, 'velc')
% % %                     lowerData.velc = behaviorData.velc(lowerRange);
% % %                     upperData.velc = behaviorData.velc(upperRange);
% % %                 end
% % %                 if isfield(behaviorData, 'spf')
% % %                     lowerData.spf = behaviorData.spf;
% % %                     upperData.spf = behaviorData.spf;
% % %                 end
% % %                 if isfield(behaviorData, 'fpt')
% % %                     lowerData.fpt = behaviorData.fpt;
% % %                     upperData.fpt = behaviorData.fpt;
% % %                 end
% % %                 if isfield(behaviorData, 'seconds_per_frame')
% % %                     lowerData.seconds_per_frame = behaviorData.seconds_per_frame;
% % %                     upperData.seconds_per_frame = behaviorData.seconds_per_frame;
% % %                 end
% % %                 
% % %                 % Extract filename and pathname from  Structure 'filestring'
% % % %                 [pathname,name,ext] = fileparts(filestring.fullfilename);
% % %                 
% % % %                 tempBehaviorData
% % %                 
% % %                 % ----------------------------------------------------------------
% % %                 % ----------- CALL TO moveduration -------------------------------
% % %                 % ----------------------------------------------------------------
% % %                 [meanforwardLower, meanbackwardLower, meanstoppedLower, ...
% % %                     rpmLower, fwdPctLower, bkwdPctLower, stopPctLower] = ...
% % %                     moveduration(lowerData, velthreshold, ...
% % %                     glossoverthreshold_seconds, verbose, verbosefig, fid);
% % %                 %
% % %                 [meanforwardUpper, meanbackwardUpper, meanstoppedUpper, ...
% % %                     rpmUpper, fwdPctUpper, bkwdPctUpper, stopPctUpper] = ...
% % %                     moveduration(upperData, velthreshold, ...
% % %                     glossoverthreshold_seconds, verbose, verbosefig, fid);
% % %                 %
% % %                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %                 
% % %         else


%vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
%vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
%vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

            if ~isempty(fullfilename)
                % ----------------------------------------------------------------
                % ----------- CALL TO mikerpm ------------------------------------
                % ----------------------------------------------------------------
                [reversals, durations, distances, speeds] = mikerpmMD(directory, thresholds, flags);

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


                
                
%                 [meanforward, meanbackward, meanstopped, rpm, ...
%                     fwdPct, bkwdPct, stopPct] = ...
%                     moveduration(fullfilename, velthreshold, ...
%                     glossoverthreshold_seconds, verbose, verbosefig, fid);
                
% % %                 % ----------------------------------------------------------------
% % %                 % ----------- CALL TO moveduration -------------------------------
% % %                 % ----------------------------------------------------------------
% % %                 [meanforward, meanbackward, meanstopped, rpm, ...
% % %                     fwdPct, bkwdPct, stopPct] = ...
% % %                     moveduration(fullfilename, velthreshold, ...
% % %                     glossoverthreshold_seconds, verbose, verbosefig, fid);
                
                conditionData(:,j) =   [reversals.rpm;
                                        durations.fwd;
                                        durations.bkwd;
                                        durations.all;
                                        durations.stopped;
                                        distances.fwd;
                                        distances.bkwd;
                                        distances.abs;
                                        speeds.fwd;
                                        speeds.bkwd;
                                        speeds.abs];
            else
                conditionData(:,j) =   [NaN;
                                        NaN;
                                        NaN;
                                        NaN;
                                        NaN;
                                        NaN;
                                        NaN;
                                        NaN;
                                        NaN;
                                        NaN;
                                        NaN];
% % %                 meanforward =   NaN;
% % %                 meanbackward =  NaN;
% % %                 meanstopped =   NaN;
% % %                 rpm =           NaN;
% % %                 fwdPct =        NaN;
% % %                 bkwdPct =       NaN;
% % %                 stopPct =       NaN;
            end     % if ~isempty(fuulfilename)
% % %         end     % if timeRanges > 1
        
        
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%         % For Debugging:
%         disp([meanforward, meanbackward, meanstopped, rpm])
        

% % %         if timeRanges > 1
% % %             condition(:,j,1) = [meanforwardLower;
% % %                                 meanbackwardLower;
% % %                                 meanstoppedLower;
% % %                                 rpmLower;
% % %                                 fwdPctLower;
% % %                                 bkwdPctLower;
% % %                                 stopPctLower];
% % %             condition(:,j,2) = [meanforwardUpper;
% % %                                 meanbackwardUpper;
% % %                                 meanstoppedUpper;
% % %                                 rpmUpper;
% % %                                 fwdPctUpper;
% % %                                 bkwdPctUpper;
% % %                                 stopPctUpper];
% % %         else
            
            
% % %             condition(:,j)  =  [meanforward;
% % %                                 meanbackward;
% % %                                 meanstopped;
% % %                                 rpm;
% % %                                 fwdPct;
% % %                                 bkwdPct;
% % %                                 stopPct];
% % %         end

        if VERBOSE
            % Now finish printing the detailed worm values...
            for fff = fileID 
                fprintf(fff, '%6.2f\t%6.2f  \t%6.2f  \t%6.2f   \t%6.2f  \t%6.2f   \t%6.2f   \t%6.2f    \t%6.2f  \t%6.2f  \t%6.2f   \t%3d\n', ...
                    [conditionData(:,j)', reversals.total]);
            end     % for fff = fileID 
        end
        
    end     % for j=1:nd

    % Between input directories (i.e. conditions) print line
    for fff = fileID 
        fprintf(fff,'========================================================================================\n');
    end     % for fff = fileID 

    for r = 1:size(conditionData,3)
%     for r = 1:size(condition,3)
        
        % Assemble measures of behavior
        for f = 1:size(data,1)
            rowTemp = conditionData(f,:,r);
            data(f,MEAN_COL ,k,r) =  mean( rowTemp(~isnan(rowTemp)) );
            data(f,STD_COL  ,k,r) =   std( rowTemp(~isnan(rowTemp)) );
            data(f,NUMEL_COL,k,r) = numel( rowTemp(~isnan(rowTemp)) );
            data(f,SEM_COL  ,k,r) =  data(f,2,k,r) / sqrt(data(f,3,k,r));     % std/(numel)^0.5

        end

    end

    % Gather t-Test data (but only if there's exactly 2 input conditions
    if RUNTTEST
        tTest_RPM{k}        = conditionData(RPM,:);
        
        tTest_Duration{FWD}{k}     = conditionData(FWD_DUR,:);
        tTest_Duration{BKWD}{k}    = conditionData(BKWD_DUR,:);
        tTest_Duration{FORB}{k}    = conditionData(ForB_DUR,:);
        tTest_Duration{STOPPED}{k} = conditionData(STOP_DUR,:);
        
        tTest_Distance{FWD}{k}   = conditionData(FWD_DIST,:);
        tTest_Distance{BKWD}{k}  = conditionData(BKWD_DIST,:);
        tTest_Distance{FORB}{k}  = conditionData(ForB_DIST,:);
        
        tTest_Speed{FWD}{k}   = conditionData(FWD_SPEED,:);
        tTest_Speed{BKWD}{k}  = conditionData(BKWD_SPEED,:);
        tTest_Speed{FORB}{k}  = conditionData(ForB_SPEED,:);
        
    end


    clear rowTemp conditionData
    
end     % for k=1:nargin      % cycle through input directories


% =====================================================


% Now assemble data matrices for plotting

% Always display stopped condition
DurationAttribs     = [FWD_DUR,   BKWD_DUR,   ForB_DUR,  STOP_DUR];
DistanceAttribs     = [FWD_DIST,  BKWD_DIST,  ForB_DIST];
SpeedAttribs        = [FWD_SPEED, BKWD_SPEED, ForB_SPEED];
            % PctAttribs      = [FWDPCT BKWDPCT STOPPCT];

% % % if displaystopped
% % %     FwBkwAttribs    = [FWD BKWD STOPPED];
% % %     PctAttribs      = [FWDPCT BKWDPCT STOPPCT];
% % % else
% % %     FwBkwAttribs    = [FWD BKWD];
% % %     PctAttribs      = [FWDPCT BKWDPCT];
% % % end


if timeRanges == 1
    
    rpm_mean    = permute( data(RPM, MEAN_COL, :), [3, 1, 2] );
    rpm_std     = permute( data(RPM, STD_COL,  :), [3, 1, 2] );
    rpm_sem     = permute( data(RPM, SEM_COL,  :), [3, 1, 2] );
    rpm_n       = permute( data(RPM, NUMEL_COL,:), [3, 1, 2] );

    dur         = permute( data(DurationAttribs, MEAN_COL, :), [3, 1, 2] );
    dur_STD     = permute( data(DurationAttribs, STD_COL,  :), [3, 1, 2] );
    dur_SEM     = permute( data(DurationAttribs, SEM_COL,  :), [3, 1, 2] );
    dur_n       = permute( data(DurationAttribs, NUMEL_COL,:), [3, 1, 2] );
    
    dist        = permute( data(DistanceAttribs, MEAN_COL, :), [3, 1, 2] );
    dist_STD    = permute( data(DistanceAttribs, STD_COL,  :), [3, 1, 2] );
    dist_SEM    = permute( data(DistanceAttribs, SEM_COL,  :), [3, 1, 2] );
    dist_n      = permute( data(DistanceAttribs, NUMEL_COL,:), [3, 1, 2] );
    
    speed       = permute( data(SpeedAttribs, MEAN_COL, :), [3, 1, 2] );
    speed_STD   = permute( data(SpeedAttribs, STD_COL,  :), [3, 1, 2] );
    speed_SEM   = permute( data(SpeedAttribs, SEM_COL,  :), [3, 1, 2] );
    speed_n     = permute( data(SpeedAttribs, NUMEL_COL,:), [3, 1, 2] );
    
    
    
% % %     fwd_bkwd        = permute( data(FwBkwAttribs, MEAN_COL, :), [3, 1, 2] );
% % %     fwd_bkwd_STD    = permute( data(FwBkwAttribs, STD_COL,  :), [3, 1, 2] );
% % %     fwd_bkwd_SEM    = permute( data(FwBkwAttribs, SEM_COL,  :), [3, 1, 2] );
% % %     fwd_bkwd_n      = permute( data(FwBkwAttribs, NUMEL_COL,:), [3, 1, 2] );
% % %     
% % %     pctTime         = permute( data(PctAttribs, MEAN_COL, :), [3, 1, 2] );
% % %     pctTime_STD     = permute( data(PctAttribs, STD_COL,  :), [3, 1, 2] );
% % %     pctTime_SEM     = permute( data(PctAttribs, SEM_COL,  :), [3, 1, 2] );
% % %     pctTime_n       = permute( data(PctAttribs, NUMEL_COL,:), [3, 1, 2] );
% % % 
% % %     rpm_mean        = permute( data(RPM, MEAN_COL, :), [3, 1, 2] );
% % %     rpm_std         = permute( data(RPM, STD_COL,  :), [3, 1, 2] );
% % %     rpm_sem         = permute( data(RPM, SEM_COL,  :), [3, 1, 2] );
% % %     rpm_n           = permute( data(RPM, NUMEL_COL,:), [3, 1, 2] );
    

% % % else
% % %     % More than one time range
% % %     % Set up empty matrices first:
% % %     fwd_bkwd        = NaN*ones((nargin*3)-1, numel(FwBkwAttribs));
% % %     fwd_bkwd_STD    = fwd_bkwd;     % copy the empty matrix
% % %     fwd_bkwd_SEM    = fwd_bkwd;     % copy the empty matrix
% % %     fwd_bkwd_n      = fwd_bkwd;     % copy the empty matrix
% % % 
% % %     pctTime         = NaN*ones((nargin*3)-1, numel(PctAttribs));
% % %     pctTime_STD     = pctTime;     % copy the empty matrix
% % %     pctTime_SEM     = pctTime;     % copy the empty matrix
% % %     pctTime_n       = pctTime;     % copy the empty matrix
% % % 
% % %     rpm_mean        = NaN*ones((nargin*3)-1, 1);
% % %     rpm_std         = rpm_mean;     % copy the empty matrix
% % %     rpm_sem         = rpm_mean;     % copy the empty matrix
% % %     rpm_n           = rpm_mean;     % copy the empty matrix
% % % 
% % %     for g = 1:timeRanges
% % %         fwd_bkwd(     g:3:(nargin*3)-1, FwBkwAttribs) = permute( data(FwBkwAttribs, MEAN_COL, :, g), [3, 1, 2, 4] );
% % %         fwd_bkwd_STD( g:3:(nargin*3)-1, FwBkwAttribs) = permute( data(FwBkwAttribs, STD_COL,  :, g), [3, 1, 2, 4] );
% % %         fwd_bkwd_SEM( g:3:(nargin*3)-1, FwBkwAttribs) = permute( data(FwBkwAttribs, SEM_COL,  :, g), [3, 1, 2, 4] );
% % %         fwd_bkwd_n(   g:3:(nargin*3)-1, FwBkwAttribs) = permute( data(FwBkwAttribs, NUMEL_COL,:, g), [3, 1, 2, 4] );
% % %         
% % %         pctTime(     g:3:(nargin*3)-1, 1:numel(PctAttribs)) = permute( data(PctAttribs, MEAN_COL, :, g), [3, 1, 2, 4] );
% % %         pctTime_STD( g:3:(nargin*3)-1, 1:numel(PctAttribs)) = permute( data(PctAttribs, STD_COL,  :, g), [3, 1, 2, 4] );
% % %         pctTime_SEM( g:3:(nargin*3)-1, 1:numel(PctAttribs)) = permute( data(PctAttribs, SEM_COL,  :, g), [3, 1, 2, 4] );
% % %         pctTime_n(   g:3:(nargin*3)-1, 1:numel(PctAttribs)) = permute( data(PctAttribs, NUMEL_COL,:, g), [3, 1, 2, 4] );
% % %         
% % %         rpm_mean(g:3:(nargin*3)-1) = permute( data(RPM, MEAN_COL, :, g), [3, 1, 2, 4] );
% % %         rpm_std( g:3:(nargin*3)-1) = permute( data(RPM, STD_COL,  :, g), [3, 1, 2, 4] );
% % %         rpm_sem( g:3:(nargin*3)-1) = permute( data(RPM, SEM_COL,  :, g), [3, 1, 2, 4] );
% % %         rpm_n(   g:3:(nargin*3)-1) = permute( data(RPM, NUMEL_COL,:, g), [3, 1, 2, 4] );
% % %         
% % %     end     % g = 1:timeRanges

    
end     % if timeRanges == 1



if SHOWPLOTS

% % %     % ================================================================
% % %     % =========== BAR GRAPH ==========================================
% % %     % ================================================================
% % % 
% % %     % = = = = = = = = = = = = = = = = = = = = = = = 
% % %     % = = = = = Duration of Movement plot = = = = = 
% % %     % = = = = = = = = = = = = = = = = = = = = = = = 
% % %     figure
% % % 
% % %     % Plot Bar chart with Error Bars
% % % 
% % %     % Set legend text
% % %     potentiallegends = { 'Mean Forward Duration (+/- 1 SEM)', ...
% % %         'Mean Backward Duration (+/- 1 SEM)', ...
% % %         'Mean Stopped Duration (+/- 1 SEM)' };
% % % 
% % %     % Two different print schemes, depending on version of Matlab
% % %     if matlabversion < 7
% % % 
% % %         % Plot as groups of two bars (Forward, Backward)
% % %         H = bar( fwd_bkwd);
% % % 
% % % 
% % %         % Annotate with legend
% % %         %   NB: for < v7.0 need to display legend BEFORE applying error bars.
% % %         %   Not the case with >= 7.0...
% % %         legend(potentiallegends{1:size(fwd_bkwd,2)})
% % % 
% % %         hold on
% % %         % Add the Error Bars
% % %         for i = 1:size(fwd_bkwd,2)     % FWD, RWD, [stopped]
% % %             xpos = mean( get(H(i), 'XData') );
% % %     %         ypos = get(H(i), 'YData');   ypos = ypos(2,:);
% % %             errorbar( xpos, fwd_bkwd(:,i)', fwd_bkwd_SEM(:,i)', 'r.')
% % %         end     % for i = 1:size(fwd_bkwd,2)
% % %         hold off
% % % 
% % %     else    % i.e. >= 7
% % % 
% % %         % Plot as groups of bars with ERROR BARS
% % %         if nargin==1
% % %             barerrorbar(...
% % %                 [fwd_bkwd; NaN*ones(size(fwd_bkwd))], ...
% % %                 [fwd_bkwd_SEM; NaN*ones(size(fwd_bkwd_SEM))]);
% % %             set(gca, 'XLim', [0.5 nargin+0.5])
% % %         else
% % %             barerrorbar(fwd_bkwd, fwd_bkwd_SEM);
% % %         end
% % % 
% % %         % Annotate with legend
% % %         legend(potentiallegends{1:size(fwd_bkwd,2)})
% % % 
% % %     end     % if matlabversion < 7
% % % 
% % %     % Set ticks for each XTickLabel
% % %     set(gca, 'XTick', 1:size(fwd_bkwd,1) );
% % % 
% % %     % Fix XLims
% % %     if size(fwd_bkwd,1) <= 5
% % %         set(gca, 'XLim', [0.5 size(fwd_bkwd,1)+0.5]);
% % %     else
% % %         set(gca, 'XLim', [0 size(fwd_bkwd,1)+1]);
% % %     end
% % %     % if size(fwd_bkwd,1) <= 5
% % %     %     set(gca, 'XLim', [0.5 numel(rpm_mean)+0.5]);
% % %     % else
% % %     %     set(gca, 'XLim', [0 numel(rpm_mean)+1]);
% % %     % end
% % %     % -----------------------------------------------------------
% % % 
% % %     % and now, Format the chart:
% % %     set(gca, 'YGrid', 'on')
% % %     set(gca, 'FontWeight', 'bold');
% % % 
% % %     titletxt = 'Duration of Movement';
% % %     title(titletxt);
% % %     set(gcf, 'Name', titletxt);
% % % 
% % %     xlabel('Condition');
% % %     ylabel('Duration of movement  [sec]');
% % % 
% % %     % Label x-ticks with conditions    
% % %     if timeRanges>1
% % %         legendtextTemp = cell(size(fwd_bkwd,1), 1);
% % %         legendtextTemp(:) = {''};   % Initialize to empty strings
% % % 
% % %         for h = 1:nargin
% % %             legendtextTemp{(h-1)*3+1} = [legendtextCELL{h} ' (0-' int2str(breakpoint) ')'];
% % %             legendtextTemp{(h-1)*3+2} = [legendtextCELL{h} ' (' int2str(breakpoint) '-end)'];
% % %         end
% % %         legendtextCHAR = char(legendtextTemp);
% % %         legendtextCELL = legendtextTemp;
% % %     end
% % %     set(gca, 'xticklabel', legendtextCELL)
% % % 
% % %     % Rotate XTickLabels, if requested
% % %     if rot==1
% % %         xticklabel_rotate([],90,[], 'FontWeight', 'bold');
% % %     end     % if rot==1
% % % 
% % %     % Code to format plots for landscape output
% % %     set(gcf, 'PaperOrientation', 'Landscape');
% % %     set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
% % % 
% % %     % To ensure color plot from Wormwriter Color
% % %     %   or grayscale plot from Wormwriter2
% % %     %   (was getting blank plots from ...2 and ...Color on 6/25/03
% % %     %   when plots were automatically setting to 'renderer' = 'zbuffer')
% % %     %   (Plots were also blank with 'renderer' = 'opengl'.)
% % %     set(gcf, 'Renderer', 'painters');
% % % 
% % %     % - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% % % 
% % %     % = = = = = = = = = = = = = = = = = = = = = = = 
% % %     % = = = = = Reversals per Minute plot = = = = = 
% % %     % = = = = = = = = = = = = = = = = = = = = = = = 
% % %     figure
% % % 
% % %     % The bars:
% % %     bar( rpm_mean );
% % %     set(gca, 'YGrid', 'on')
% % % 
% % %     % Set ticks for each XTickLabel
% % %     set(gca, 'XTick', 1:size(fwd_bkwd,1) );
% % % 
% % %     % Fix XLims
% % %     if numel(rpm_mean) <= 5
% % %         set(gca, 'XLim', [0.5 numel(rpm_mean)+0.5]);
% % %     else
% % %         set(gca, 'XLim', [0 numel(rpm_mean)+1]);
% % %     end
% % % 
% % %     % Annotate with legend
% % %     potentiallegends = 'Reversals/min (+/- 1 SEM)';
% % % 
% % %     % Annotate with legend
% % %     legend(potentiallegends)
% % % 
% % %     hold on
% % %     errorbar(rpm_mean, rpm_sem, 'r.');
% % %     hold off  
% % % 
% % %     set(gca, 'FontWeight', 'bold');
% % % 
% % %     titletxt = 'Reversals per Minute';
% % %     title(titletxt);
% % %     set(gcf, 'Name', titletxt);
% % % 
% % %     xlabel('Condition');
% % %     ylabel('Reversals per Minute');
% % % 
% % %     set(gca, 'xticklabel', legendtextCELL)
% % % 
% % %     % Rotate XTickLabels, if requested
% % %     if rot==1
% % %         xticklabel_rotate([],90,[], 'FontWeight', 'bold');
% % %     end     % if rot==1
% % % 
% % %     % Code to format plots for landscape output
% % %     set(gcf, 'PaperOrientation', 'Landscape');
% % %     set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
% % % 
% % %     % To ensure color plot from Wormwriter Color
% % %     %   or grayscale plot from Wormwriter2
% % %     %   (was getting blank plots from ...2 and ...Color on 6/25/03
% % %     %   when plots were automatically setting to 'renderer' = 'zbuffer')
% % %     %   (Plots were also blank with 'renderer' = 'opengl'.)
% % %     set(gcf, 'Renderer', 'painters');

end     % if SHOWPLOTS





% ================================================================
% =========== DATA DISPLAY =======================================
% ================================================================
% Print out values to the Command Window and maybe to text file

% ----------------------------------------------------------------
% ----------- INTRODUCTORY NOTES ---------------------------------
% ----------------------------------------------------------------

% Label output
for fff = fileID
    fprintf(fff,'========================================================================================\n');
    fprintf(fff,'\n');
    fprintf(fff, '    Speeds less than %g mm/sec (forward or backward) are considered stopped.\n', stopThreshold);
    fprintf(fff,'Mean of mean values:\n');
end     % for fff = fileID

mode = char('Forward', 'Backward', 'Fwd OR Bkwd', 'Stopped', 'Reversals');

textwidth = max(size(mode,2), size(legendtextCHAR,2));  % Text padding size

legendPrePad = blanks(3);

% Pad text with blanks as needed
modeWidth = size(mode,2);
paddedLegendWidth = size(legendtextCHAR,2) + size(legendPrePad,2);
titleTextWidth = max(modeWidth, paddedLegendWidth);  % left column width

if modeWidth > paddedLegendWidth
    legendtextCHAR = [legendtextCHAR repmat( blanks(modeWidth - paddedLegendWidth), size(legendtextCHAR,1), 1)];
elseif modeWidth < paddedLegendWidth
    mode = [mode repmat( blanks(paddedLegendWidth - modeWidth), size(mode,1), 1)];
end
    

attribLabel = char('Reversals/min', 'Duration [sec]', 'Distance [mm]', 'Speed [mm/sec]');
attribLabelWidth = size(attribLabel,2);



% ----------------------------------------------------------------
% ----------- REVERSALS PER MINUTE -------------------------------
% ----------------------------------------------------------------

for fff = fileID 
    % Print a line to separate Reversals/min from behavior durations
    fprintf(fff,'%s\n', repmat('  -', [1,round( (titleTextWidth + attribLabelWidth )/3) + 13]));

    % Print Reversals/min
    fprintf(fff, '%s\t%s %s\t%s %s\t%s %s\t%s\n', ...
            mode(5,:), ...    blanks(textwidth + 3 - size(mode,2)), ...
                    attribLabel(1,:), ...
                        blanks(1), ...
                            '  STD ', ...
                                blanks(1), ...
                                    '  SEM ', ...
                                        blanks(1), ...
                                            '  n');
    for k = 1:size(rpm_mean,1)
        if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
            fprintf(fff,'%s%s\t  %6.2f %s\t%6.2f %s\t%6.2f %s\t%3d\n', ...
                legendPrePad,...
                legendtextCHAR(k,:), ...    blanks(textwidth + 3 - size(legendtextCHAR,2)), ... was blanks(textwidth + 2 - size(legendtextCHAR,2)), ...
                        rpm_mean(k), ...
                            blanks(attribLabelWidth - 8 + 1), ...
                                rpm_std(k), ...
                                    blanks(1), ...
                                        rpm_sem(k), ...
                                            blanks(1), ...
                                                rpm_n(k));
        end     % if (timeRanges==1) || (mod(k,3)~=0)
    end     % for k = 1:size(rpm_mean,1)
    
    if RUNTTEST
        [~, p] = ttest2(tTest_RPM{1:2}, [], [], EQUALVARS);
        fprintf(fff, '%s\tp = %6.4f\n', blanks(titleTextWidth), p);
    end     % RUNTTEST
end     % for fff = fileID 




% ----------------------------------------------------------------
% ----------- DURATIONS ------------------------------------------
% ----------------------------------------------------------------

for fff = fileID 
    % Print a line to separate title from output
    fprintf(fff,'%s\n', repmat('  -', [1,round( (titleTextWidth + attribLabelWidth )/3) + 13]));

    % Print Forward, Backward, Fwd AND Bkwd  and Stopped durations
    for j = 1:size(dur,2)
        fprintf(fff, '%s\t%s %s\t%s %s\t%s %s\t%s\n', ...
                mode(j,:), ...    blanks(textwidth + 3 - size(mode,2)), ...
                        attribLabel(2,:), ...
                            blanks(1), ...
                                '  STD ',...
                                    blanks(1), ...
                                        '  SEM ', ...
                                            blanks(1), ...
                                                '  n');
        for k = 1:size(dur,1)
            if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
                fprintf(fff,'%s%s\t  %6.2f %s\t%6.2f %s\t%6.2f %s\t%3d\n', ...
                    legendPrePad,...
                    legendtextCHAR(k,:), ...    blanks(textwidth + 2 - size(legendtextCHAR,2)), ...
                            dur(k,j), ...
                                blanks(attribLabelWidth - 8 + 1), ...
                                    dur_STD(k,j), ...
                                        blanks(1), ...
                                            dur_SEM(k,j), ...
                                                blanks(1), ...
                                                    dur_n(k,j));    
            end     % if (timeRanges==1) || (mod(k,3)~=0)
        end     % k = 1:size(dur,1)
        
        if RUNTTEST
            [~, p] = ttest2(tTest_Duration{j}{1:2}, [], [], EQUALVARS);
            fprintf(fff, '%s\tp = %6.4f\n', blanks(titleTextWidth), p);
        end     % RUNTTEST

    end     % for j = 1:2
end     % for fff = fileID 




% ----------------------------------------------------------------
% ----------- DISTANCES ------------------------------------------
% ----------------------------------------------------------------

for fff = fileID 
    % Print a line to separate title from output
    fprintf(fff,'%s\n', repmat('  -', [1,round( (titleTextWidth + attribLabelWidth )/3) + 13]));

    % Print Forward, Backward and Fwd AND Bkwd distances
    for j = 1:size(dist,2)
        fprintf(fff, '%s\t%s %s\t%s %s\t%s %s\t%s\n', ...
                mode(j,:), ...    blanks(textwidth + 3 - size(mode,2)), ...
                        attribLabel(3,:), ...
                            blanks(1), ...
                                '  STD ',...
                                    blanks(1), ...
                                        '  SEM ', ...
                                            blanks(1), ...
                                                '  n');
        for k = 1:size(dist,1)
            if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
                fprintf(fff,'%s%s\t  %6.2f %s\t%6.2f %s\t%6.2f %s\t%3d\n', ...
                    legendPrePad,...
                    legendtextCHAR(k,:), ...    blanks(textwidth + 2 - size(legendtextCHAR,2)), ...
                            dist(k,j), ...
                                blanks(attribLabelWidth - 8 + 1), ...
                                    dist_STD(k,j), ...
                                        blanks(1), ...
                                            dist_SEM(k,j), ...
                                                blanks(1), ...
                                                    dist_n(k,j));    
            end     % if (timeRanges==1) || (mod(k,3)~=0)
        end     % k = 1:size(dist,1)
        
        if RUNTTEST
            [~, p] = ttest2(tTest_Distance{j}{1:2}, [], [], EQUALVARS);
            fprintf(fff, '%s\tp = %6.4f\n', blanks(titleTextWidth), p);
        end     % RUNTTEST

    end     % for j = 1:2
end     % for fff = fileID 




% ----------------------------------------------------------------
% ----------- SPEEDS ---------------------------------------------
% ----------------------------------------------------------------

for fff = fileID 
    % Print a line to separate title from output
    fprintf(fff,'%s\n', repmat('  -', [1,round( (titleTextWidth + attribLabelWidth )/3) + 13]));

    % Print Forward, Backward and Fwd AND Bkwd speeds
    for j = 1:size(speed,2)
        fprintf(fff, '%s\t%s %s\t%s %s\t%s %s\t%s\n', ...
                mode(j,:), ...    blanks(textwidth + 3 - size(mode,2)), ...
                        attribLabel(4,:), ...
                            blanks(1), ...
                                '  STD ',...
                                    blanks(1), ...
                                        '  SEM ', ...
                                            blanks(1), ...
                                                '  n');
        for k = 1:size(dist,1)
            if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
                fprintf(fff,'%s%s\t  %6.2f %s\t%6.2f %s\t%6.2f %s\t%3d\n', ...
                    legendPrePad,...
                    legendtextCHAR(k,:), ...    blanks(textwidth + 2 - size(legendtextCHAR,2)), ...
                            speed(k,j), ...
                                blanks(attribLabelWidth - 8 + 1), ...
                                    speed_STD(k,j), ...
                                        blanks(1), ...
                                            speed_SEM(k,j), ...
                                                blanks(1), ...
                                                    speed_n(k,j));    
            end     % if (timeRanges==1) || (mod(k,3)~=0)
        end     % k = 1:size(dist,1)
        
        if RUNTTEST
            [~, p] = ttest2(tTest_Speed{j}{1:2}, [], [], EQUALVARS);
            fprintf(fff, '%s\tp = %6.4f\n', blanks(titleTextWidth), p);
        end     % RUNTTEST

    end     % for j = 1:2
end     % for fff = fileID 








% ----------------------------------------------------------------
% ----------- END NOTES ------------------------------------------
% ----------------------------------------------------------------

for fff = fileID 
    fprintf(fff, '\n');
%         fprintf(fff, '  ==> FIXME <===\n');
    
    % Print a reversal definition warning
    fprintf(fff,'NOTE:  A ''reversal'' in this context is defined as a change from a\n');
    fprintf(fff,'       valid forward movement to a valid backward movement _OR_ a \n');
    fprintf(fff,'       change from a valid stop to a valid backward movement.\n');
    
    fprintf(fff,'========================================================================================\n');
    fprintf(fff,'========================================================================================\n');
end     % for fff = fileID 



if SAVETEXT
    fclose(fid);
end     % if SAVETEXT

return
