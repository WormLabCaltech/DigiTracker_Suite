function [] = popmove(varargin)

% POPMOVE        Calculate behavior durations from population data.
%   FORMAT: popmove('Input_directory_name(s)')
%      where 
%      - 'Input_directory_name(s)' are the names of data folders for 
%         for comparison with each other.  Each folder must contain
%         subfolders named worm* (where * is typically an integer), which
%         subsequently each contain a file called 'metrics' (containing
%         matrices of data quantifying aspects of worm locomotion).  
%
%   example:  popmove('C:\Jane-AVD\Arsenite\N2',...
%                         'C:\Jane-AVD\Arsenite\cat-4',...
%                         'C:\Jane-AVD\Arsenite\NL130');
%   (To view head-to-head comparison of 'N2', 'cat-4', and 'NL130'.)
%
%   Popmove displays the durations of forward, backward and (if requested)
%   stopped behaviors, as well as the calculated reversals per minute.
%   Mean values are displayed for each individual worm in the subject
%   populations.  Individual worms' data are pooled and used to calculate
%   mean-of-means values for inter-population comparison.  
%   
%   Popmove makes use of a function called BARERRORBAR, written and
%   contributed to the Matlab community by Kenneth D. Morton Jr. and J.
%   Simeon Stohl.  (See the BARERRORBAR function for author contact
%   information.)
%
%   C. J. Cronin
%   June 30, 2006, Caltech
%

% r1.02: Changed Matlab version check to gloss over tertiary version
%   numbers, e.g. version 6.5.1 becomes "6.5".  
%   Dated XX/XX/XX X:XXPM.
% 
% r1.01: Initial version
%   6/30/06 11:35AM.



% ================================================================
% =========== SETUP ==============================================
% ================================================================

if nargin==0
    % PROMPT FOR INPUT DIRECTORIES
    error('POPMOVE needs input directories...  C''mon, toss me a bone, would ya!?!');
end

verbose = 0;        % Set flag to 0 to suppress intermediate charts from moveduration.

% Define Constants
MEAN_COL    = 1;
STD_COL     = 2;
NUMEL_COL   = 3;
SEM_COL     = 4;

FWD         = 1;
BKWD        = 2;
STOPPED     = 3;
RPM         = 4;
FWDPCT      = 5;
BKWDPCT     = 6;
STOPPCT     = 7;

%----------------------------------------------------------------
% Establish whether we Want to Definitely save for Matlab v6.x readability:
FORCE_to_v6 = 1;   % 1 = true, we want to save for v6 readability.
% Check for Matlab version
matlabversion = getmatlabversion;

%----------------------------------------------------------------
%---------------------------------------------------------------

% Ask whether to early- vs late-data 
% (split data sets into "before" and "after" for comparison)
button = questdlg('Care to compare data in early vs. late time ranges?',...
'Split data time-wise?','Yes','No', 'Cancel','No');
if strcmp(button,'No')
   timeRanges = 1;
elseif strcmp(button,'Yes')
    % FOR A SINGLE TIME BREAKPOINT (i.e. TWO RANGES)
    timeRanges = 2;
    prompt = 'Break the data into ''before'' and ''after'' at what time (in seconds)?';
    dlg_title = 'Time breakpoint?';
    num_lines = 1;
    def = {'300'};     % Time breakpoint
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if isempty(answer)      % In case user presses cancel
        return
    end
    [breakpoint status] = str2num(answer{1});  % Use curly bracket for subscript
    if ~status || (mod(breakpoint,1) ~= 0) || (numel(breakpoint) ~= 1)
        error(['''' prompt ''' dialog expects a single integer.']);
    end
    
% FOR AN ARBITRARY NUMBER OF RANGES, TRY SOMETHING LIKE THIS: 
% (NB: THERE SEEM TO BE SOME PROBLEMS WITH ASSEMBLING THE PROMPT...)
%     prompt = 'How many time ranges?';
%     dlg_title = 'How many time ranges?';
%     num_lines = 1;
%     def = {'1'};     % Velocity Threshold, Ignore
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
%     if isempty(answer)      % In case user presses cancel
%         return
%         %         answer = def;       % use the default text
%     end
%     [timeRanges status] = str2num(answer{1});  % Use curly bracket for subscript
%     if ~status || ~isinteger(timeRanges)
%         error(['''' prompt ''' dialog expects a single integer.']);
%     end
%     if timeRanges < 1
%         error(['''' prompt ''' dialog expects an integer greater than one.']);
%     end
%     % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     
%     
%     % Define the time break-points
%     prompt = {['What are the breakpoints (in minutes)?';...
%                '1                                     ' ]};
%     if timeRanges > 2
%        for breakpoint = 2:(timeRanges-1)
%            prompt = [prompt num2cell(breakpoint)];
%        end
%     end
%     dlg_title = 'Time breakpoints';
%     num_lines = 1;
%     def = {'1','2', '3'};     % Velocity Threshold, Ignore
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
%     if isempty(answer)      % In case user presses cancel
%         return
%     end
    
else
   return
end


%----------------------------------------------------------------
%---------------------------------------------------------------
% Prompt for the chart parameter information (if necessary):
% if nargin<3
prompt = {['Velocity threshold [mm/sec]                                  ';...
           '  (any movement less than this speed is considered ''stopped'')' ],...                                                                    ';...
          ['Shall I ''ignore'' short pauses and missing data?                     '
           '  How many seconds at a time?  (Decimal values like 0.5 are fine...)'  ]};
dlg_title = 'Enter analysis parameters';
num_lines = 1;      
def = {'0.05','0'};     % Velocity Threshold, Ignore
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)      % In case user presses cancel
    return
%         answer = def;       % use the default text
end

% Set parameters
velthreshold = str2num(answer{1});


% 'glossoverthreshold' requires a bit of calculation to change from time to
% frames.  Each vel value represents movement across a 'timeblock'.  
% We need to change the reported gloss answer from seconds into number of 
% 'timeblocks' (would be frames if fpt=1).  (I'm choosing to ask for gloss
% in terms of time since I don't expect the user to comfortably be able to
% know and account for varying fpt's across various datasets.)

% We know the 'gloss' answer as seconds:
glossoverthreshold_seconds = str2num(answer{2});
% Error checking
if (glossoverthreshold_seconds<0)
    error('Can''t ignore ''negative'' time');
end

%---------------------------------------------------------------
%---------------------------------------------------------------

legendtext = promptforlegend(varargin{:});
legendtextCHAR = char(legendtext);      % matrix-version
legendtextCELL = cellstr(legendtext);   % cell-version
% legendtext = promptforlegend_01x(varargin{:});

%---------------------------------------------------------------
%---------------------------------------------------------------

% Ask whether to display stopped, too
button = questdlg('Shall I display stopped durations, too?',...
'Stopped, too?','Yes','No', 'Cancel','Yes');
if strcmp(button,'Yes')
   displaystopped = 1;
elseif strcmp(button,'No')
   displaystopped = 0;
else 
   return
end

%---------------------------------------------------------------
%---------------------------------------------------------------

% Ask whether to show figures for each and every worm
button = questdlg({'Display figures for each worm?';...
                    '(Note: Too many worms may cause Matlab to run out of memory and crash...)'},...
'Figures for each individual worm?','Yes','No', 'Cancel','No');
if strcmp(button,'Yes')
   verbosefig = 1;
elseif strcmp(button,'No')
   verbosefig = 0;
else 
   return
end


%---------------------------------------------------------------
%---------------------------------------------------------------

% Ask whether to show painful details of each and every worm
button = questdlg('Care to see the details (text) of each worm?',...
'Gory details?','Yes','No', 'Cancel','No');
if strcmp(button,'Yes')
   verbose = 1;
elseif strcmp(button,'No')
   verbose = 0;
else 
   return
end


%---------------------------------------------------------------
%---------------------------------------------------------------

% If there are *lots* of input folders (more than 5), offer to 
% rotate X-labels 
rot = 0;    % Default to NOT rotate labels
if nargin > 5 
    % Ask whether to rotate long labels on summary figures
    button = questdlg({'You are comparing lots of input conditions...'; ...
        'Shall I rotate the condition labels to fit better?'},...
        'Rotate X-Labels?','Yes','No', 'Cancel','Yes');
    if strcmp(button,'Yes')
        rot = 1;
    elseif strcmp(button,'No')
        rot = 0;
    else
        return
    end
    
end     % if narargin > 5


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

%---------------------------------------------------------------
%---------------------------------------------------------------




% ================================================================
% =========== DATA ACCUMULATION ==================================
% ================================================================

% Pre-allocate data matrix for
% - 7 attributes (Durations fwd-, bkwd- and stopped; Reversals/min; Percent
%                 Fwd-, Bkwd- and Stopped)
% - 4 aspects (Mean, STD, numel, SEM)
% - 'nargin' input directories (i.e. 'conditions')
% - 'timeRanges' time ranges (early-late vs a single 'all')
data = NaN * ones(7,4,nargin,timeRanges);

for k=1:nargin      % cycle through input directories

    % get contents of each directory
    pd = varargin{k};
   
    d = dir([pd filesep 'worm*']);
    nd = numel(d);
   
    % Clear & pre-allocate condition matrix:
    % - 7 attributes (Durations fwd-, bkwd- and stopped; Reversals/min; Percent
%                     Fwd-, Bkwd- and Stopped)
    % - nd worms in the input directory
    condition = NaN * ones(7, nd, timeRanges);

    % now cycle through each worm directory in input directory k
    for j=1:nd       % worm directories
        
        % get name of directory
        name = d(j).name;
        
        % print out message to stdout
        fprintf(1, 'Processing %s\n', [pd, filesep name]);
        if verbose
            fprintf(1, '    Speeds less than %g mm/sec (forward or backward) are considered stopped.\n', velthreshold);
        end
        % ...and to file if desired
        if SAVETEXT
            fprintf(fid, 'Processing %s\n', [pd, filesep name]);
            if verbose
                fprintf(fid, '    Speeds less than %g mm/sec (forward or backward) are considered stopped.\n', velthreshold);
            end
        end     % if SAVETEXT
        
        % clear variables
        clear x y vel dir mode fre amp off phs ptvel len
        
        % Prepare file name
        directory = [pd filesep name];
        if exist([directory filesep 'metrics.mat'], 'file')==2
            fullfilename = [directory filesep 'metrics.mat'];
        elseif exist([directory filesep 'veldata.mat'], 'file')==2
            fullfilename = [directory filesep 'veldata.mat'];
        else
            fullfilename = [];
            warning(['No suitable velocity data available in: ' directory]);
        end       % if exist
        
        %vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
        if timeRanges > 1
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %
            % LOAD DATA
            %
            % First, query name (if necessary)
            if nargin >= 1  % if presented with file name as a string
                [pathname,name,ext] = fileparts(fullfilename);
                filename = [name ext];
            else
                [filename, pathname] = uigetfile( ...
                    {'*.mat', 'Matlab files (*.mat)'},'Select file containing ''velc'' data');
            end
            
            % Just in case, ensure that pathname ends with a filesep
            if pathname(end) ~= filesep
                pathname(end+1) = filesep;
            end
            
            
            if filename==0
                error('No file selected')
            end
            
            % HERE'S THE LOAD CALL...
            behaviorData = load([pathname filename]);
            
            % Add fullfilename to the cell array
            behaviorData.fullfilename = fullfilename;
            lowerData.fullfilename = behaviorData.fullfilename;
            upperData.fullfilename = behaviorData.fullfilename;
            
            % Create reference time vector
            if isfield(behaviorData, 'spf')
                behaviorData.timeV = behaviorData.spf * (1:numel(behaviorData.vel));
            end
            if isfield(behaviorData, 'seconds_per_frame')
                behaviorData.timeV = behaviorData.seconds_per_frame * (1:numel(behaviorData.vel));
            end
            
            % Identify breakpoint element:
            lowerRange = find(behaviorData.timeV <= breakpoint);
            upperRange = find(behaviorData.timeV >  breakpoint);
%             lastLower = find( (timeV(1:end-1)<=breakpoint) & (timeV(2:end)>breakpoint) );
            
                % Abridge values of vel, velc, spf, fpt and seconds_per_frame
                if isfield(behaviorData, 'vel')
                    lowerData.vel = behaviorData.vel(lowerRange);
                    upperData.vel = behaviorData.vel(upperRange);
                end
                if isfield(behaviorData, 'velc')
                    lowerData.velc = behaviorData.velc(lowerRange);
                    upperData.velc = behaviorData.velc(upperRange);
                end
                if isfield(behaviorData, 'spf')
                    lowerData.spf = behaviorData.spf;
                    upperData.spf = behaviorData.spf;
                end
                if isfield(behaviorData, 'fpt')
                    lowerData.fpt = behaviorData.fpt;
                    upperData.fpt = behaviorData.fpt;
                end
                if isfield(behaviorData, 'seconds_per_frame')
                    lowerData.seconds_per_frame = behaviorData.seconds_per_frame;
                    upperData.seconds_per_frame = behaviorData.seconds_per_frame;
                end
                
                % Extract filename and pathname from  Structure 'filestring'
%                 [pathname,name,ext] = fileparts(filestring.fullfilename);
                
%                 tempBehaviorData
                
                % ----------------------------------------------------------------
                % ----------- CALL TO moveduration -------------------------------
                % ----------------------------------------------------------------
                [meanforwardLower, meanbackwardLower, meanstoppedLower, ...
                    rpmLower, fwdPctLower, bkwdPctLower, stopPctLower] = ...
                    moveduration(lowerData, velthreshold, ...
                    glossoverthreshold_seconds, verbose, verbosefig, fid);
                %
                [meanforwardUpper, meanbackwardUpper, meanstoppedUpper, ...
                    rpmUpper, fwdPctUpper, bkwdPctUpper, stopPctUpper] = ...
                    moveduration(upperData, velthreshold, ...
                    glossoverthreshold_seconds, verbose, verbosefig, fid);
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
        else
            if ~isempty(fullfilename)
                % ----------------------------------------------------------------
                % ----------- CALL TO moveduration -------------------------------
                % ----------------------------------------------------------------
                [meanforward, meanbackward, meanstopped, rpm, ...
                    fwdPct, bkwdPct, stopPct] = ...
                    moveduration(fullfilename, velthreshold, ...
                    glossoverthreshold_seconds, verbose, verbosefig, fid);
                
                
            else
                meanforward =   NaN;
                meanbackward =  NaN;
                meanstopped =   NaN;
                rpm =           NaN;
                fwdPct =        NaN;
                bkwdPct =       NaN;
                stopPct =       NaN;
            end     % if ~isempty(fuulfilename)
        end     % if timeRanges > 1
        
        
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%         % For Debugging:
%         disp([meanforward, meanbackward, meanstopped, rpm])
        

        if timeRanges > 1
            condition(:,j,1) = [meanforwardLower;
                                meanbackwardLower;
                                meanstoppedLower;
                                rpmLower;
                                fwdPctLower;
                                bkwdPctLower;
                                stopPctLower];
            condition(:,j,2) = [meanforwardUpper;
                                meanbackwardUpper;
                                meanstoppedUpper;
                                rpmUpper;
                                fwdPctUpper;
                                bkwdPctUpper;
                                stopPctUpper];
        else
            condition(:,j)  =  [meanforward;
                                meanbackward;
                                meanstopped;
                                rpm;
                                fwdPct;
                                bkwdPct;
                                stopPct];
        end
        
    end     % for j=1:nd

    fprintf(1,'========================================================================================\n');
    if SAVETEXT
        fprintf(fid,'========================================================================================\n');
    end     % if SAVETEXT

    for r = 1:size(condition,3)
        
        % Assemble measures of behavior
        for f = 1:size(data,1)
            rowTemp = condition(f,:,r);
            data(f,MEAN_COL ,k,r) =  mean( rowTemp(~isnan(rowTemp)) );
            data(f,STD_COL  ,k,r) =   std( rowTemp(~isnan(rowTemp)) );
            data(f,NUMEL_COL,k,r) = numel( rowTemp(~isnan(rowTemp)) );
            data(f,SEM_COL  ,k,r) =  data(f,2,k,r) / sqrt(data(f,3,k,r));     % std/(numel)^0.5
        end
    end
    
    clear rowTemp condition
    
end     % for k=1:nargin      % cycle through input directories
      
% Now assemble data matrices for plotting

if displaystopped
    FwBkwAttribs    = [FWD BKWD STOPPED];
    PctAttribs      = [FWDPCT BKWDPCT STOPPCT];
else
    FwBkwAttribs    = [FWD BKWD];
    PctAttribs      = [FWDPCT BKWDPCT];
end


if timeRanges == 1
    
    fwd_bkwd        = permute( data(FwBkwAttribs, MEAN_COL, :), [3, 1, 2] );
    fwd_bkwd_STD    = permute( data(FwBkwAttribs, STD_COL,  :), [3, 1, 2] );
    fwd_bkwd_SEM    = permute( data(FwBkwAttribs, SEM_COL,  :), [3, 1, 2] );
    fwd_bkwd_n      = permute( data(FwBkwAttribs, NUMEL_COL,:), [3, 1, 2] );
    
    pctTime         = permute( data(PctAttribs, MEAN_COL, :), [3, 1, 2] );
    pctTime_STD     = permute( data(PctAttribs, STD_COL,  :), [3, 1, 2] );
    pctTime_SEM     = permute( data(PctAttribs, SEM_COL,  :), [3, 1, 2] );
    pctTime_n       = permute( data(PctAttribs, NUMEL_COL,:), [3, 1, 2] );

    rpm_mean        = permute( data(RPM, MEAN_COL, :), [3, 1, 2] );
    rpm_std         = permute( data(RPM, STD_COL,  :), [3, 1, 2] );
    rpm_sem         = permute( data(RPM, SEM_COL,  :), [3, 1, 2] );
    rpm_n           = permute( data(RPM, NUMEL_COL,:), [3, 1, 2] );
    

else
    % More than one time range
    % Set up empty matrices first:
    fwd_bkwd        = NaN*ones((nargin*3)-1, numel(FwBkwAttribs));
    fwd_bkwd_STD    = fwd_bkwd;     % copy the empty matrix
    fwd_bkwd_SEM    = fwd_bkwd;     % copy the empty matrix
    fwd_bkwd_n      = fwd_bkwd;     % copy the empty matrix

    pctTime         = NaN*ones((nargin*3)-1, numel(PctAttribs));
    pctTime_STD     = pctTime;     % copy the empty matrix
    pctTime_SEM     = pctTime;     % copy the empty matrix
    pctTime_n       = pctTime;     % copy the empty matrix

    rpm_mean        = NaN*ones((nargin*3)-1, 1);
    rpm_std         = rpm_mean;     % copy the empty matrix
    rpm_sem         = rpm_mean;     % copy the empty matrix
    rpm_n           = rpm_mean;     % copy the empty matrix

    for g = 1:timeRanges
        fwd_bkwd(     g:3:(nargin*3)-1, FwBkwAttribs) = permute( data(FwBkwAttribs, MEAN_COL, :, g), [3, 1, 2, 4] );
        fwd_bkwd_STD( g:3:(nargin*3)-1, FwBkwAttribs) = permute( data(FwBkwAttribs, STD_COL,  :, g), [3, 1, 2, 4] );
        fwd_bkwd_SEM( g:3:(nargin*3)-1, FwBkwAttribs) = permute( data(FwBkwAttribs, SEM_COL,  :, g), [3, 1, 2, 4] );
        fwd_bkwd_n(   g:3:(nargin*3)-1, FwBkwAttribs) = permute( data(FwBkwAttribs, NUMEL_COL,:, g), [3, 1, 2, 4] );
        
        pctTime(     g:3:(nargin*3)-1, 1:numel(PctAttribs)) = permute( data(PctAttribs, MEAN_COL, :, g), [3, 1, 2, 4] );
        pctTime_STD( g:3:(nargin*3)-1, 1:numel(PctAttribs)) = permute( data(PctAttribs, STD_COL,  :, g), [3, 1, 2, 4] );
        pctTime_SEM( g:3:(nargin*3)-1, 1:numel(PctAttribs)) = permute( data(PctAttribs, SEM_COL,  :, g), [3, 1, 2, 4] );
        pctTime_n(   g:3:(nargin*3)-1, 1:numel(PctAttribs)) = permute( data(PctAttribs, NUMEL_COL,:, g), [3, 1, 2, 4] );
        
        rpm_mean(g:3:(nargin*3)-1) = permute( data(RPM, MEAN_COL, :, g), [3, 1, 2, 4] );
        rpm_std( g:3:(nargin*3)-1) = permute( data(RPM, STD_COL,  :, g), [3, 1, 2, 4] );
        rpm_sem( g:3:(nargin*3)-1) = permute( data(RPM, SEM_COL,  :, g), [3, 1, 2, 4] );
        rpm_n(   g:3:(nargin*3)-1) = permute( data(RPM, NUMEL_COL,:, g), [3, 1, 2, 4] );
        
    end     % g = 1:timeRanges

    
end     % if timeRanges == 1





% ================================================================
% =========== BAR GRAPH ==========================================
% ================================================================

% = = = = = = = = = = = = = = = = = = = = = = = 
% = = = = = Duration of Movement plot = = = = = 
% = = = = = = = = = = = = = = = = = = = = = = = 
figure

% Plot Bar chart with Error Bars

% Set legend text
potentiallegends = { 'Mean Forward Duration (+/- 1 SEM)', ...
    'Mean Backward Duration (+/- 1 SEM)', ...
    'Mean Stopped Duration (+/- 1 SEM)' };

% Two different print schemes, depending on version of Matlab
if matlabversion < 7

    % Plot as groups of two bars (Forward, Backward)
    H = bar( fwd_bkwd);

    
    % Annotate with legend
    %   NB: for < v7.0 need to display legend BEFORE applying error bars.
    %   Not the case with >= 7.0...
    legend(potentiallegends{1:size(fwd_bkwd,2)})

    hold on
    % Add the Error Bars
    for i = 1:size(fwd_bkwd,2)     % FWD, RWD, [stopped]
        xpos = mean( get(H(i), 'XData') );
%         ypos = get(H(i), 'YData');   ypos = ypos(2,:);
        errorbar( xpos, fwd_bkwd(:,i)', fwd_bkwd_SEM(:,i)', 'r.')
    end     % for i = 1:size(fwd_bkwd,2)
    hold off

else    % i.e. >= 7

    % Plot as groups of bars with ERROR BARS
    if nargin==1
        barerrorbar(...
            [fwd_bkwd; NaN*ones(size(fwd_bkwd))], ...
            [fwd_bkwd_SEM; NaN*ones(size(fwd_bkwd_SEM))]);
        set(gca, 'XLim', [0.5 nargin+0.5])
    else
        barerrorbar(fwd_bkwd, fwd_bkwd_SEM);
    end
    
    % Annotate with legend
    legend(potentiallegends{1:size(fwd_bkwd,2)})
    
end     % if matlabversion < 7

% Set ticks for each XTickLabel
set(gca, 'XTick', 1:size(fwd_bkwd,1) );

% Fix XLims
if size(fwd_bkwd,1) <= 5
    set(gca, 'XLim', [0.5 size(fwd_bkwd,1)+0.5]);
else
    set(gca, 'XLim', [0 size(fwd_bkwd,1)+1]);
end
% if size(fwd_bkwd,1) <= 5
%     set(gca, 'XLim', [0.5 numel(rpm_mean)+0.5]);
% else
%     set(gca, 'XLim', [0 numel(rpm_mean)+1]);
% end
% -----------------------------------------------------------

% and now, Format the chart:
set(gca, 'YGrid', 'on')
set(gca, 'FontWeight', 'bold');

titletxt = 'Duration of Movement';
title(titletxt);
set(gcf, 'Name', titletxt);

xlabel('Condition');
ylabel('Duration of movement  [sec]');
    
% Label x-ticks with conditions    
if timeRanges>1
    legendtextTemp = cell(size(fwd_bkwd,1), 1);
    legendtextTemp(:) = {''};   % Initialize to empty strings
    
    for h = 1:nargin
        legendtextTemp{(h-1)*3+1} = [legendtextCELL{h} ' (0-' int2str(breakpoint) ')'];
        legendtextTemp{(h-1)*3+2} = [legendtextCELL{h} ' (' int2str(breakpoint) '-end)'];
    end
    legendtextCHAR = char(legendtextTemp);
    legendtextCELL = legendtextTemp;
end
set(gca, 'xticklabel', legendtextCELL)

% Rotate XTickLabels, if requested
if rot==1
    xticklabel_rotate([],90,[], 'FontWeight', 'bold');
end     % if rot==1

% Code to format plots for landscape output
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);

% To ensure color plot from Wormwriter Color
%   or grayscale plot from Wormwriter2
%   (was getting blank plots from ...2 and ...Color on 6/25/03
%   when plots were automatically setting to 'renderer' = 'zbuffer')
%   (Plots were also blank with 'renderer' = 'opengl'.)
set(gcf, 'Renderer', 'painters');
    
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

% = = = = = = = = = = = = = = = = = = = = = = = 
% = = = = = Reversals per Minute plot = = = = = 
% = = = = = = = = = = = = = = = = = = = = = = = 
figure
    
% The bars:
bar( rpm_mean );
set(gca, 'YGrid', 'on')

% Set ticks for each XTickLabel
set(gca, 'XTick', 1:size(fwd_bkwd,1) );

% Fix XLims
if numel(rpm_mean) <= 5
    set(gca, 'XLim', [0.5 numel(rpm_mean)+0.5]);
else
    set(gca, 'XLim', [0 numel(rpm_mean)+1]);
end

% Annotate with legend
potentiallegends = 'Reversals/min (+/- 1 SEM)';
     
% Annotate with legend
legend(potentiallegends)
    
hold on
errorbar(rpm_mean, rpm_sem, 'r.');
hold off  

set(gca, 'FontWeight', 'bold');

titletxt = 'Reversals per Minute';
title(titletxt);
set(gcf, 'Name', titletxt);

xlabel('Condition');
ylabel('Reversals per Minute');
    
set(gca, 'xticklabel', legendtextCELL)

% Rotate XTickLabels, if requested
if rot==1
    xticklabel_rotate([],90,[], 'FontWeight', 'bold');
end     % if rot==1

% Code to format plots for landscape output
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);

% To ensure color plot from Wormwriter Color
%   or grayscale plot from Wormwriter2
%   (was getting blank plots from ...2 and ...Color on 6/25/03
%   when plots were automatically setting to 'renderer' = 'zbuffer')
%   (Plots were also blank with 'renderer' = 'opengl'.)
set(gcf, 'Renderer', 'painters');
 




% ================================================================
% =========== DATA DISPLAY =======================================
% ================================================================
% Print out values to the Command Window

% fwd_bkwd
% fwd_bkwd_SEM

% ----------------------------------------------------------------
% ----------- INTRODUCTORY NOTES ---------------------------------
% ----------------------------------------------------------------

% Label output
fprintf(1,'========================================================================================\n');
fprintf(1,'\n');
fprintf(1, '    Speeds less than %g mm/sec (forward or backward) are considered stopped.\n', velthreshold);
if (glossoverthreshold_seconds>0)
    fprintf(1,'    Ignoring pauses or uncertainties lasting less than %g seconds.\n', glossoverthreshold_seconds);
else
    fprintf(1, '    Not ignoring pauses or uncertainties of any duration.\n');
end
fprintf(1,'Mean of mean values:\n');

if SAVETEXT
    fprintf(fid,'========================================================================================\n');
    fprintf(fid,'\n');
    fprintf(fid, '    Speeds less than %g mm/sec (forward or backward) are considered stopped.\n', velthreshold);
    if (glossoverthreshold_seconds>0)
        fprintf(fid,'    Ignoring pauses or uncertainties lasting less than %g seconds.\n', glossoverthreshold_seconds);
    else
        fprintf(fid, '    Not ignoring pauses or uncertainties of any duration.\n');
    end
    fprintf(fid,'Mean of mean values:\n');
end     % if SAVETEXT

mode = char('Forward', 'Backward', 'Stopped', 'Reversals');

textwidth = max(size(mode,2), size(legendtextCHAR,2));  % Text padding size


% ----------------------------------------------------------------
% ----------- DURATIONS ------------------------------------------
% ----------------------------------------------------------------

% Print a line to separate title from output
fprintf(1,'%s\n', repmat('  -', [1,round(textwidth/3) + 15]));


% Print Forward, Backward and maybe Stopped durations
for j = 1:size(fwd_bkwd,2)
    fprintf(1, '%s %s %s %s %s %s %s %s %s\n', ...
            mode(j,:), ...
                blanks(textwidth + 3 - size(mode,2)), ...
                    'Duration (sec)', ...
                        blanks(4), ...
                            'STD',...
                                blanks(4), ...
                                    'SEM', ...
                                        blanks(4), ...
                                            'n');
    for k = 1:size(fwd_bkwd,1)
        if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
            fprintf(1,'   %s %s %6.2f %s %6.2f %s %6.2f %s %3d\n', ...
                legendtextCHAR(k,:), ...
                    blanks(textwidth + 2 - size(legendtextCHAR,2)), ...
                        fwd_bkwd(k,j), ...
                            blanks(8), ...
                                fwd_bkwd_STD(k,j), ...
                                    blanks(1), ...
                                        fwd_bkwd_SEM(k,j), ...
                                            blanks(1), ...
                                                fwd_bkwd_n(k,j));    
        end     % if (timeRanges==1) || (mod(k,3)~=0)
    end     % k = 1:size(fwd_bkwd,1)
end     % for j = 1:2

if SAVETEXT
    % Print a line to separate title from output
    fprintf(fid,'%s\n', repmat('  -', [1,round(textwidth/3) + 15]));


    for j = 1:size(fwd_bkwd,2)
        fprintf(fid, '%s\t%s\t%s\t%s\t%s\n', ...
                mode(j,:), ...
                        'Duration (sec)', ...
                                'STD',...
                                        'SEM', ...
                                                'n');
        for k = 1:size(fwd_bkwd,1)
            if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
                fprintf(fid,'   %s\t%6.2f\t%6.2f\t%6.2f\t%3d\n', ...
                    legendtextCHAR(k,:), ...
                        fwd_bkwd(k,j), ...
                            fwd_bkwd_STD(k,j), ...
                                fwd_bkwd_SEM(k,j), ...
                                    fwd_bkwd_n(k,j));
            end     % if (timeRanges==1) || (mod(k,3)~=0)
        end     % k = 1:size(fwd_bkwd,1)
    end     % for j = 1:2
end     % if SAVETEXT


% ----------------------------------------------------------------
% ----------- REVERSALS PER MINUTE -------------------------------
% ----------------------------------------------------------------

% Print a line to separate Reversals/min from behavior durations
fprintf(1,'%s\n', repmat('  -', [1,round(textwidth/3) + 15]));

% Print Reversals/min
fprintf(1, '%s %s %s %s %s %s %s %s %s\n', ...
        mode(4,:), ...
            blanks(textwidth + 3 - size(mode,2)), ...
                'Reversals/min', ...
                    blanks(5), ...
                        'STD', ...
                            blanks(4), ...
                                'SEM', ...
                                    blanks(4), ...
                                        'n');
for k = 1:size(rpm_mean,1)
    if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
        fprintf(1,'   %s %s %6.2f %s %6.2f %s %6.2f %s %3d\n', ...
            legendtextCHAR(k,:), ...
                blanks(textwidth + 2 - size(legendtextCHAR,2)), ...
                    rpm_mean(k), ...
                        blanks(8), ...
                            rpm_std(k), ...
                                blanks(1), ...
                                    rpm_sem(k), ...
                                        blanks(1), ...
                                            rpm_n(k));    
    end     % if (timeRanges==1) || (mod(k,3)~=0)
end     % for k = 1:size(rpm_mean,1)

if SAVETEXT
    % Print a line to separate Reversals/min from behavior durations
    fprintf(fid,'%s\n', repmat('  -', [1,round(textwidth/3) + 15]));

    % Print Reversals/min
    fprintf(fid, '%s\t%s\t%s\t%s\t%s\n', ...
            mode(4,:), ...
                    'Reversals/min', ...
                            'STD', ...
                                    'SEM', ...
                                            'n');
    for k = 1:size(rpm_mean,1)
        if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
            fprintf(fid,'   %s\t%6.2f\t%6.2f\t%6.2f\t%3d\n', ...
                legendtextCHAR(k,:), ...
                        rpm_mean(k), ...
                                rpm_std(k), ...
                                        rpm_sem(k), ...
                                                rpm_n(k));
        end     % if (timeRanges==1) || (mod(k,3)~=0)
    end     % for k = 1:size(rpm_mean,1)
end     % if SAVETEXT

% ----------------------------------------------------------------
% ----------- TIME DISTRIBUTION ----------------------------------
% ----------------------------------------------------------------

% Print a line to separate title from output
fprintf(1,'%s\n', repmat('  -', [1,round(textwidth/3) + 15]));


% Print Forward, Backward and maybe Stopped time distributions
for j = 1:size(pctTime,2)
    fprintf(1, '%s %s %s %s %s %s %s %s %s\n', ...
            mode(j,:), ...
                blanks(textwidth + 3 - size(mode,2)), ...
                    'Percent of Time', ...
                        blanks(3), ...
                            'STD',...
                                blanks(4), ...
                                    'SEM', ...
                                        blanks(4), ...
                                            'n');
    for k = 1:size(pctTime,1)
        if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
            fprintf(1,'   %s %s %6.2f%% %s %6.2f %s %6.2f %s %3d\n', ...
                legendtextCHAR(k,:), ...
                    blanks(textwidth + 2 - size(legendtextCHAR,2)), ...
                        pctTime(k,j), ...
                            blanks(7), ...
                                pctTime_STD(k,j), ...
                                    blanks(1), ...
                                        pctTime_SEM(k,j), ...
                                            blanks(1), ...
                                                pctTime_n(k,j));
        end     % if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
    end     % for k = 1:size(pctTime,1)
end     % for j = 1:2

if SAVETEXT
    % Print a line to separate title from output
    fprintf(fid,'%s\n', repmat('  -', [1,round(textwidth/3) + 15]));


    % Print Forward, Backward and maybe Stopped time distributions
    for j = 1:size(pctTime,2)
        fprintf(fid, '%s\t%s\t%s\t%s\t%s\n', ...
                mode(j,:), ...
                        'Percent of Time', ...
                                'STD',...
                                        'SEM', ...
                                                'n');
        for k = 1:size(pctTime,1)
            if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
                fprintf(fid,'   %s [%%]\t%6.2f\t%6.2f\t%6.2f\t%3d\n', ...
                    legendtextCHAR(k,:), ...
                        pctTime(k,j), ...
                            pctTime_STD(k,j), ...
                                pctTime_SEM(k,j), ...
                                    pctTime_n(k,j));
            end     % if (timeRanges==1) || (mod(k,3)~=0)  % skip the NaN's
        end     % for k = 1:size(pctTime,1)
    end     % for j = 1:2

end     % if SAVETEXT


% ----------------------------------------------------------------
% ----------- END NOTES ------------------------------------------
% ----------------------------------------------------------------

fprintf(1, '\n');
fprintf(1, 'Note: -Reversal frequency calculation always ignores ''stopped'' and ''uncertain'' states.\n');
if glossoverthreshold_seconds>0
    fprintf(1, '      -This reversal frequency calculation ignored actions lasting less than %g seconds.\n', glossoverthreshold_seconds);
end

fprintf(1,'========================================================================================\n');
fprintf(1,'========================================================================================\n');

if SAVETEXT
    fprintf(fid, '\n');
    fprintf(fid, 'Note: -Reversal frequency calculation always ignores ''stopped'' and ''uncertain'' states.\n');
    if glossoverthreshold_seconds>0
        fprintf(fid, '      -This reversal frequency calculation ignored actions lasting less than %g seconds.\n', glossoverthreshold_seconds);
    end

    fprintf(fid,'========================================================================================\n');
    fprintf(fid,'========================================================================================\n');
end     % if SAVETEXT



if SAVETEXT
    fclose(fid);
end     % if SAVETEXT

return
