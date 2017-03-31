function [] = stats(varargin)

%STATS          Calculate statistics from worm movement metrics.
%   FORMAT: stats('Input_directory_name(s)')
%      where 
%      - 'Input_directory_name(s)' are the names of data folders for 
%         for comparison with each other.  Each folder must contain
%         subfolders named worm* (where * is typically an integer), which
%         subsequently each contain a file called 'metrics' (containing
%         matrices of data quantifying aspects of worm locomotion).  
%
%   example:  stats('C:\Jane-AVD\Arsenite\N2',...
%                         'C:\Jane-AVD\Arsenite\cat-4',...
%                         'C:\Jane-AVD\Arsenite\NL130');
%   (To view head-to-head comparison of 'N2', 'cat-4', and 'NL130'.)
%
%   Stats displays statistics for measures of worm locomotion, both for
%   individual worms and for worms treated as populations.  Currenly STATS
%   prints (to the Matlab Command Window) statistics regarding:
%   1) Velocity (in the worm's track)
%   2) Centroid Velocity
%   3) Bending Frequency (for bends 5, 7 and 9 only)
%   4) Flex (for bends 5, 7 and 9 only)
%   5) Track Amplitude 
%   6) Track Wavelength 
%   7) Length-Normalized Track Amplitude 
%   8) Length-Normalized Track Wavelength 
%   In each case, stats reports separate information for behavior
%   demonstrated during forward locomotion, during rearward locomotion, and
%   during combined forward and rearward locomotion.
%
%   For each measure, the mean value is presented along with the calculated
%   standard deviation and population size.  Note that the population size 
%   'n' refers to different things depending on the 'population' under
%   consideration:
%   a) for individual worms, 'n' is the number of frames for the direction
%           of motion (forward, backward, either).
%   b) for 'Conditions treated as Groups of Individual Worms' we are
%           comparing the mean values for each worm with the mean values of
%           the other worms in the same population, so here 'n' is the
%           number of worms in the population.
%   c) for Inter-population means 'n' is number of populations presented
%           for consideration.
%
%   STATS includes:   
%       - a low pass filter for track wavelength and normalized track
%       wavelength that trims off values above one mean worm body length or
%       100% of mean body length.
% 
%   The basic structure of this function is borrowed from:  histograms4_06x
%   (as of 5-13-04) 
% 
%   C J Cronin 8-11-04
%   $Revision: 1.04 $  $Date: 2006/07/28 xx:xx:xx $
% 

% Subversion change control:
% 2007/05/15 - Changed how Matlab version number is established to handle
%   cases like version 6.5.1 (as opposed to the 6.0, 6.5, 7.0, 7.1 pattern
%   of single decimals.  New version can handle up to 99 sub-versions per
%   version segment, i.e. from 6.00.00, through 6.99.99.  Actually will
%   handle any number of segments (i.e. 6.aa.bb.cc...nn), but Matlab's
%   str2num function seems limited to 4 decimal places, so any
%   sub-versioning beyond 6.aa.bb is ignored.
%
% r1.04: Created parallel plotting functions to work properly under
%   pre-v7.0 Matlab and v7.x and later Matlab.  Made LEGEND text input
%   dialog box resizeable.
% 
% r1.03: Bugfix-- 3/10/05 discovered that for metrics with multiple
%   bendnumber (e.g. frequency or flex) we were not resetting allData, 
%   allGroup, fwdData, fwdGroup, rwdData, and rwdGroup for each pass
%   through bendnum loop.  Moved reset to inside of bendnum loop.
% 
% r1.02x: Added plots of statistics. 
%   Dated 10/04/04 xx:xxAM.
%
% r1.01: Initial release.  The programming style here is admittedly (by the
%   author) sloppy with VAST amounts of code repetition.  However, this
%   initial release should serve to avail the functionality herein to the
%   community.  As time and the Muse allows, we hope to modularize the code,
%   most likely successively calling a generic prototype function with the
%   relevant details of variable names, titles,...  In addition we hope to
%   provide an easy means for the user to select subsets of output.  
%   Dated 8/11/01 11:37AM.




%--------------------------------------------------------------------
% Some Error Checking
if nargout > 7      % ...if too many output arguments
    errordlg('FORMAT: stats(directory1, directory2, ....)');   
    % 	error('FORMAT: histograms4(directory1, directory2, ....)');   
end

if nargin < 1        % ...if too few input arguments
    errordlg('FORMAT: stats(directory1, directory2, ....)');     
    % 	error('FORMAT: stats(directory1, directory2, ....)');     
end

%--------------------------------------------------------------------
%----------------------------------------------------------------
% Establish whether we Want to Definitely save for Matlab v6.x readability:
FORCE_to_v6 = 1;   % 1 = true, we want to save for v6 readability.

% Check for Matlab version
matlabversion = getmatlabversion;

%----------------------------------------------------------------
%---------------------------------------------------------------

% Initialize Variables
linewdth = 3;
figuretitlefontsize = 14;

METRICSofINTEREST = [1 2 3 4 5 6 7 8 9];

ALPHA = 0.05;        % DEFAULT -- for 1% or 99% confidence interval

% Set up data capture VIA ARRAY
FRIENDLYMETRICNAME_ARRAY ...
                      = {'Velocity', ...
                                    'Centroid Velocity', ...
                                                'Frequency', ...
                                                        'Flex', ...
                                                                'Time Delay',...
                                                                        'Track Amplitude', ...
                                                                                'Track Wavelength  (less than 1 mean body length)',  ...
                                                                                            'Length-Normalized Track Amplitude', ...
                                                                                                                'Length-Normalized Track Wavelength  (less than 100% mean bodylength)'    };
METRICNAME_ARRAY      = {'vel',     'velc',     'fre',  'flex', 'phs',  'ampt', 'wavelnth', 'ampt',             'wavelnth'      };
METRICUNITS_ARRAY     = {'mm/sec',  'mm/sec',   'Hz',   'rad',  'sec',  'mm',   'mm',       '% mean length',    '% mean length'};
SCREENOPERAND_ARRAY   = {'~= ',     '~= ',      '~= ',  '~= ',  '~=',   '~= ',  '< ',       '~= ',              '< '            };
SCREENCONDITION_ARRAY = {'Inf',     'Inf',      'Inf',  'Inf',  'Inf',  'Inf',  'meanlen',  'Inf',              '100'           };
% BENDNUMBERS_ARRAY     = { [1],      [1],        [5 6], ...
BENDNUMBERS_ARRAY     = { [1],      [1],        [5 7 9], ...
                                                        [5 7 9],...
                                                                [5 7 9],...
                                                                        [1],    [1],        [1],                [1]             };
LENGTHNORMALIZE_ARRAY = { [0],      [0],        [0],    [0],    [0],    [0],    [0],        [1],                [1]             };
SCALE_ARRAY           = { [1],      [1],        [1],    [1],    [1],    [1],    [1],        [1],                [1]             };
% half width ampt: SCALE_ARRAY           = { [1],      [1],        [1],    [1],    [1],     [1],    [1],        [0.5],                [1]             };
DISPLAYBEND_ARRAY     = { [0],      [0],        [1],    [1],    [2],    [0],    [0],        [0],                [0]             };


%---------------------------------------------------------------

% Prompt for the chart LEGEND text:
prompt = 'Enter chart legend information:';
dlg_title = 'Chart legend information';
num_lines= nargin;

for i = 1:num_lines
    directory = varargin(i);
    directory = directory{1};
    delimiter_positions = findstr(filesep, directory);
    
    % Trim off trailing fileseps (if any)
    while delimiter_positions(end) == length(directory)
        directory = directory(1:end-1);
        delimiter_positions = findstr(filesep, directory);
    end
    
    % Establish end of i'th line of legend text as vector
    legend_text_line = [directory(delimiter_positions(end)+1:end)];
    
    %     % Replace '\' with ': '
    %     legend_text_line = strrep(legend_text_line, '\', ': ');
    
    % Replace '_' with ' '  (prevents subscripts via TexInterpreter)
    legend_text_line = strrep(legend_text_line, '_', ' ');
    
    % Convert vector into array
    defaulttext{i} = legend_text_line;
end

def = {str2mat(defaulttext)};   % Convert legend text array to matrix

answer  = inputdlg(prompt,dlg_title,num_lines,def, 'on');
if isempty(answer)      % In case user presses cancel
    return;             % abort execution
    %     answer = def;       % use the default text  <---I don't like this approach anymore
end

legendtext = answer{1};
if size(legendtext, 1) < nargin
    errordlg(['ERROR:  Please enter exactly ' int2str(nargin) ' conditions for the legend']);
    %     error(['ERROR:  Please enter exactly ' int2str(nargin) ' conditions for the legend']);
end
legendtext = legendtext(1:nargin,:);

%---------------------------------------------------------------
%---------------------------------------------------------------
%---------------------------------------------------------------

% Query for whether to display individual worm details
button = questdlg('Display individual worm details?','Display Details?'); 
if strcmp(button, 'Yes')
    DISPLAYINDIVIDUALS = 1;
elseif strcmp(button, 'No')
    DISPLAYINDIVIDUALS = 0;
else
    return
end

%---------------------------------------------------------------
%---------------------------------------------------------------
%---------------------------------------------------------------
% Prompt for the chart ALPHA:
prompt = 'Enter Alpha value:  For example, enter 0.05 for alpha = 5% (for 95% confidence interval)';
dlg_title = 'Alpha input';
num_lines= 1;
def = {num2str(ALPHA)};      % {'0.05'};


answer  = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)      % In case user presses cancel
    return;             % abort execution
end

if ~isempty(answer{1})
    ALPHA = str2num(answer{1});
end

fprintf(1, '\n\tAlpha value: %5.3f\n', ALPHA);

%---------------------------------------------------------------
%---------------------------------------------------------------
%---------------------------------------------------------------


% Prevent DivideByZero warning if there are no Statistics for a condition:
originalwarningstate = warning('off', 'MATLAB:divideByZero');   
% 'originalwarningstate' contains previous state...



for f = METRICSofINTEREST    
    
    % % Setup data capture TEMPORARY
    % FRIENDLYMETRICNAME = 'Velocity';
    % METRICNAME = 'vel';
    % METRICUNITS = 'mm/sec';
    % SCREENOPERAND = '< ';
    % SCREENCONDITION = '100';
    
    % Assign:
    FRIENDLYMETRICNAME = FRIENDLYMETRICNAME_ARRAY{f};
    METRICNAME = METRICNAME_ARRAY{f};
    METRICUNITS = METRICUNITS_ARRAY{f};
    SCREENOPERAND = SCREENOPERAND_ARRAY{f};
    SCREENCONDITION = SCREENCONDITION_ARRAY{f};    
    BENDNUMBERS = BENDNUMBERS_ARRAY{f};
    LENGTHNORMALIZE = LENGTHNORMALIZE_ARRAY{f};
    SCALE = SCALE_ARRAY{f};
    DISPLAYBEND = DISPLAYBEND_ARRAY{f};
    
    
    
    
    
    
    
    
    %--------------------------------------------------------------------
    %--------------------------------------------------------------------
    %--------------------------------------------------------------------
    %--------------------------------------------------------------------
    %--------------------------------------------------------------------
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generic Statistics Calculation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for bendnum = BENDNUMBERS
        
        allData = [];
        allGroup = {};
        fwdData = [];
        fwdGroup = {};
        rwdData = [];
        rwdGroup = {};
        
        
        for i=1:nargin      % Each input directory (condition)
            
            % get 'worm*' contents of each directory (condition)
            pd = varargin(i);
            pd = pd{1};
            
            % get 'worm*' contents of each directory (condition)
            d = dir([pd filesep 'worm*']);
            nd = prod(size(d));      % Number of worm*'s
            
            %%%%%%% NEW  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            array{i} = NaN*ones(nd, 9);     % Mean|STD|n| MeanFWD|STD|n| MeanRWD|STD|n
            %%%%%%% NEW  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            %**************************************************************************
            %**************************************************************************
            
            if DISPLAYINDIVIDUALS    
                %----- Statistics -2-------------------------------------------------
                % Remember worm* names & convert into useable format
                wormDirNames = {};
                for g = 1:nd
                    wormDirNames{g} = d(g).name;
                end
                wormDirNames = {str2mat(wormDirNames)};   % Convert string arrays to single cell array
                wormDirNames = wormDirNames{1};   % Convert single cell array to matrix of characters
                
                %   Print Column Titles before Each Condition:
                % Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
                placeholderstring = repmat(' ',1,size(wormDirNames,2));   
                %                 placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
                
                % On the first pass:
                % Set up for Statistics output
                if i == 1
                    if DISPLAYBEND==1
                        fprintf(1,'\n%s   [%s]   --   Bend #%d\n', FRIENDLYMETRICNAME, METRICUNITS, bendnum);
                    elseif DISPLAYBEND==2
                        fprintf(1,'\n%s   [%s]   --   Bends #%d-#%d\n', FRIENDLYMETRICNAME, METRICUNITS, bendnum, bendnum+1);
                    else
                        fprintf(1,'\n%s   [%s]\n', FRIENDLYMETRICNAME, METRICUNITS);
                    end
                end     % if i == 1  Set up for Statistics output  - On the first pass:
                
                
                %   Column Titles
                fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
                        '\tMeanFWD\t  STD  \t   n   \t:'...
                        '\tMeanRWD\t  STD  \t   n   \t '...
                        '\n'], placeholderstring);
                
            end  % if DISPLAYINDIVIDUALS    
            
            
            %--- More Error Checking -----------------------------------------------------------------
            
            % Error checking: Verify that parent directory exists and contains worm folders
            if exist(pd) ~= 7    % if directory does not exist or is not a directory
                errordlg(['ERROR: Directory ''' pd ''' does not exist!']);
                %         error(['ERROR: Directory ''' pd ''' does not exist!']);
            elseif nd == 0       % if directory is empty (no worm folders)
                errordlg(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
                %         error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
            end   
            
            %--------------------------------------------------------------------
            if DISPLAYINDIVIDUALS    
                % Print Condition Name (and move to next line line)
                fprintf(1,'%s\n',legendtext(i,:));
            end  %if DISPLAYINDIVIDUALS    
            
            
            
            %**************************************************************************
            %**************************************************************************
            %**************************************************************************
            %**************************************************************************
            %**************************************************************************
            %----- Start Calculating Statistics --------------------------------------------------
            
            % Loop over each worm* directory for i'th condition (input directory)
            for j=1:nd   % Through each worm* directory...
                
                % Extract name of worm* directory
                name = d(j).name;
                if d(j).isdir   % Only process items that are DIRECTORIES
                    
                    % clear variables
                    clear vel     % Should only need to clear one variable (v4.06)
                    %         clear amp ampt fingerprint flex fre len     % <--- Only using 'vel'...
                    %         clear mode phs ptvel theta vel wavelnth
                    
                    % Load Vel(ocity) and Len(gth) into memory
                    load([pd filesep name filesep 'metrics.mat'], 'vel', 'len'); 
                    % [WAS]        load([pd filesep name filesep 'metrics.mat'], 'vel'); % Only load 'vel' (v4.06)
                    
                    % Calculate meanlen in case needed for a screen or length-normalization:
                    meanlen = mean(len(~isnan(len)));
                    
                    if prod(size(vel)) == 1
                        errordlg( [ 'Something is wrong: Velocity is a scaler...  Check METRICS for:  ' [pd filesep name] ])
                    elseif size(vel,1)==1
                        vel = vel';     % Change into column vector
                    end
                    
                    % Load the Metric-of-interest:
                    temporaryMetricStructure = load([pd filesep name filesep 'metrics.mat'], METRICNAME); 
                    METRIC = temporaryMetricStructure.(METRICNAME);
                    
                    % In case Metric is a row-vector, convert to column:
                    if prod(size(METRIC)) == 1
                        errordlg( [ 'Something is wrong: Velocity is a scaler...  Check METRICS for:  ' [pd filesep name] ])
                    elseif size(METRIC,1)==1
                        METRIC = METRIC';     % Change into column vector
                    end
                    
                    % Extract bendnum'th column of METRIC for analysis:  (a la fre or
                    % flex calculations)
                    if size(METRIC,2) > 1
                        METRIC = METRIC(:,bendnum);
                    end
                    
                    % If necessary, adjust vel length to match METRIC length:
                    if numel(vel) ~= numel(METRIC)
                        if abs( numel(vel) - numel(METRIC)) > 1     % Shouldn't be a length difference of more than 1
                            errordlg( ['Whoa, Dude, something''s wrong with your vector lengths- Check Metrics for:  ' [pd filesep name] ]);
                        elseif numel(vel) > numel(METRIC)   % Vel vector *should* be shorter
                            errordlg( ['Yo, Punk, something''s wrong with your Velocity vector length- Check Metrics for:  ' [pd filesep name] ])
                        else
                            vel = [vel; vel(end)];
                        end
                    end
                    
                    % Scale yer data, Cowboy:
                    METRIC = METRIC * SCALE;
                    
                    % Length normalize METRIC, if necessary:
                    if LENGTHNORMALIZE
                        METRIC = ( METRIC/meanlen)*100;
                    end
                    
                    
                    
                    %---Screen results (e.g. <100% mean body length or ~= Infinity...)------------------
                    evalString = [ '[' num2str(METRIC', '%15.5f') ']' SCREENOPERAND SCREENCONDITION];     % NB: num2str requires a row
                    screen_results = eval(evalString)';     % Evaluate and change back to a column
                    %         evalString = [ '[' num2str(METRIC') ']' SCREENOPERAND SCREENCONDITION];     
                    %                   NB: num2str requires a row
                    % Discovered a case where evalString loses an element of METRIC because two
                    % numbers run together during the num2str function.  Solution is to define
                    % a nice Wiiiiide format with *plenty???* of room.
                    
                    
                    %---- Collect and Populate data array with individual worm data --------------------------------
                    % NB: 
                    %   i is CONDITIOM
                    %   j is  worm*
                    
                    array{i}(j,1) =      mean(METRIC(  ~isnan(METRIC) & screen_results               ));
                    array{i}(j,2) =       std(METRIC(  ~isnan(METRIC) & screen_results               ));
                    array{i}(j,3) =     numel(METRIC(  ~isnan(METRIC) & screen_results               ));
                    
                    array{i}(j,4) =      mean(METRIC(  ~isnan(METRIC) & screen_results & (vel > 0)   ));
                    array{i}(j,5) =       std(METRIC(  ~isnan(METRIC) & screen_results & (vel > 0)   ));
                    array{i}(j,6) =     numel(METRIC(  ~isnan(METRIC) & screen_results & (vel > 0)   ));
                    
                    array{i}(j,7) =      mean(METRIC(  ~isnan(METRIC) & screen_results & (vel < 0)   ));
                    array{i}(j,8) =       std(METRIC(  ~isnan(METRIC) & screen_results & (vel < 0)   ));
                    array{i}(j,9) =     numel(METRIC(  ~isnan(METRIC) & screen_results & (vel < 0)   ));
                    
                    
                    
                    %----- Sanity Check for Complex numbers --------------------------------------------------
                    if ~isreal( array{i}(j,:) )
                        fprintf(1, [ 'Complex Angle Value:  Check METRICS for:  ' [pd filesep name] '\n' ])
                    end
                    
                    %----- Sanity Check for Complex numbers --------------------------------------------------
                    
                    
                    % Add mean of FWD+RWD data for j'th worm to "All data" matrix
                    allData = [allData, array{i}(j,1)];
                    % and attribute data to i'th group
                    allGroup(numel(allGroup) + 1) = cellstr(legendtext(i,:));
                    
                    % Add mean of Data for Forward-moving (fwd) worms to "FWD data"
                    % matrix
                    fwdData = [fwdData, array{i}(j,4)];
                    % and attribute data to i'th group
                    fwdGroup(numel(fwdGroup) + 1) = cellstr(legendtext(i,:));   
                    
                    % Add mean of Data for Rearward-moving (rwd) worms to "RWD data"
                    % matrix
                    rwdData = [rwdData, array{i}(j,7)];
                    % and attribute data to i'th group
                    rwdGroup(numel(rwdGroup) + 1) = cellstr(legendtext(i,:));
                    
                    
                    if DISPLAYINDIVIDUALS    
                        % Print line of statistics for j'th worm of i'th condition
                        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                                '\t%6.3f \t%6.3f \t%6d\t:'...     
                                '\t%6.3f \t%6.3f \t%6d\t'...     
                                '\n'], ...
                            wormDirNames(j,:)   ,...
                            array{i}(j,1),...     %  vel_indvMean(j)     ,...
                            array{i}(j,2),...     %  vel_indvStd(j)      ,...
                            array{i}(j,3),...     %  vel_indvN(j)        ,...
                            array{i}(j,4),...     %  vel_indvPosMean(j)  ,...
                            array{i}(j,5),...     %  vel_indvPosStd(j)   ,...
                            array{i}(j,6),...     %  vel_indvPosN(j)     ,...
                            array{i}(j,7),...     %  vel_indvNegMean(j)  ,...
                            array{i}(j,8),...     %  vel_indvNegStd(j)   ,...
                            array{i}(j,9) );        %  vel_indvNegN(j) );
                    end  % if DISPLAYINDIVIDUALS    
                    
                    
                    
                    
                    
                    %**************************************************************************
                    %**************************************************************************
                    %**************************************************************************
                    %**************************************************************************
                    %**************************************************************************
                    
                end % if d(j).isdir   % Only process items that are DIRECTORIES
            end      % for j=1:nd   % Through each worm* directory...
            
            
            if DISPLAYINDIVIDUALS    
                fprintf(1,'\n\n');    % Force a newline between conditions
            end   % if DISPLAYINDIVIDUALS    
            
            
            %**************************************************************************
            %**************************************************************************
            %**************************************************************************
            %**************************************************************************
            %**************************************************************************
            
            % Try to "Nice" the program by pausing to allowing a break... (once per
            % condition)
            pause(0.0001);
            
        end     % for i=1:nargin      % Each input directory (condition)
        
        
        %**************************************************************************
        %**************************************************************************
        %**************************************************************************
        %**************************************************************************
        %**************************************************************************
        
        % Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
        conditionplaceholder = repmat(' ',1,size(legendtext,2));   
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   Print stats for Mean of Means for METRIC.
        % Title
        fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
        if DISPLAYBEND==1
            fprintf(1,'%s   [%s]   --   Bend #%d\n', FRIENDLYMETRICNAME, METRICUNITS, bendnum);
        elseif DISPLAYBEND==2
            fprintf(1,'%s   [%s]   --   Bends #%d-#%d\n', FRIENDLYMETRICNAME, METRICUNITS, bendnum, bendnum+1);
        else
            fprintf(1,'%s   [%s]\n', FRIENDLYMETRICNAME, METRICUNITS);
        end
        
        %   Column Titles
        fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
                '\tMean of\t       \t       \t:'...
                '\tMean of\t       \t       \t '...
                '\n'], conditionplaceholder);
        fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
                '\tMeanFWD\t  STD  \t   n   \t:'...
                '\tMeanRWD\t  STD  \t   n   \t '...
                '\n'], conditionplaceholder);
        
        
        
        
        % meanData:  allData | fwdData | rwdData
        meanData = NaN*ones(nargin,3);
        
        
        
        % Rows of data
        for j = 1:nargin
            
            % Temporay vectors of data:
            allDataTEMP = array{j}(:,1);      % allData
            fwdDataTEMP = array{j}(:,4);      % fwdData
            rwdDataTEMP = array{j}(:,7);      % rwdData
            
            % Remove NaN's for vectors (for printing and processing)
            allDataTEMP = allDataTEMP(~isnan(allDataTEMP));
            fwdDataTEMP = fwdDataTEMP(~isnan(fwdDataTEMP));
            rwdDataTEMP = rwdDataTEMP(~isnan(rwdDataTEMP));
            
            % Print mean of conditions
            fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                    '\t%6.3f \t%6.3f \t%6d\t:'...     
                    '\t%6.3f \t%6.3f \t%6d\t'...     
                    '\n'], ...
                legendtext(j,:)   ,...
                mean( allDataTEMP ),...       % FWD+RWD
                std( allDataTEMP ),...       % FWD+RWD
                numel( allDataTEMP ),...       % FWD+RWD
                mean( fwdDataTEMP ),...       % FWD
                std( fwdDataTEMP ),...       % FWD
                numel( fwdDataTEMP ),...       % FWD
                mean( rwdDataTEMP ),...       % RWD
                std( rwdDataTEMP ),...       % RWD
                numel( rwdDataTEMP )     );    % RWD
            
            
            
            % Populate meanData matrix (without NaN's)
            meanData(j,1,1) =  mean( allDataTEMP );      % allData
            meanData(j,1,2) =   std( allDataTEMP );      % allData
            meanData(j,1,3) = numel( allDataTEMP );      % allData
            
            meanData(j,2,1) =  mean( fwdDataTEMP );      % fwdData
            meanData(j,2,2) =   std( fwdDataTEMP );      % fwdData
            meanData(j,2,3) = numel( fwdDataTEMP );      % fwdData
            
            meanData(j,3,1) =  mean( rwdDataTEMP );      % rwdData
            meanData(j,3,2) =   std( rwdDataTEMP );      % rwdData
            meanData(j,3,3) = numel( rwdDataTEMP );      % rwdData
            
            % Clean up
            clear allDataTEMP fwdDataTEMP rwdDataTEMP 
            
            
        end     % for j = 1:nargin
        
        charplaceholder = [];
        for nmbr = 1:size(legendtext,2)
            charplaceholder = [charplaceholder '-'];
        end
        
        fprintf(1,'\t%s---------------------------------------------------------------------------------\n', charplaceholder);
        
        % Mean of means:
        fprintf(1,'\t   Inter-population Means:\n');
        
        % Modified this to use the 3-D meanData:
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                '\t%6.3f \t%6.3f \t%6d\t:'...     
                '\t%6.3f \t%6.3f \t%6d\t'...     
                '\n\n'], ...
            conditionplaceholder            ,...
            mean( meanData(:,1,1) ),...              % mean( vel_Mean_indvMean )      ,...
            std( meanData(:,1,1) ),...              % std(  vel_Mean_indvMean )      ,...
            numel( meanData(:,1,1) ),...              % size( vel_Mean_indvMean,2 )    ,...
            mean( meanData(:,2,1) ),...              % mean( vel_Mean_indvPosMean )   ,...
            std( meanData(:,2,1) ),...              % std(  vel_Mean_indvPosMean )   ,...
            numel( meanData(:,2,1) ),...              % size( vel_Mean_indvPosMean,2 ) ,...
            mean( meanData(:,3,1) ),...              % mean( vel_Mean_indvNegMean )   ,...
            std( meanData(:,3,1) ),...              % std(  vel_Mean_indvNegMean )   ,...
            numel( meanData(:,3,1) )  );              % size( vel_Mean_indvNegMean,2 ) );
        
        
        
        %**************************************************************************
        %**************************************************************************
        %**************************************************************************
        %************* BAR CHART **************************************************
        %**************************************************************************
        
        %**************************************************************************
        %
        %
        %
        % and Graphically:
        figure
        
        barlegend  = { ['Mean ' FRIENDLYMETRICNAME ' (+/- 1 STD)'], ...
                ['Mean Forward ' FRIENDLYMETRICNAME ' (+/- 1 STD)'], ...
                ['Mean Rearward ' FRIENDLYMETRICNAME ' (+/- 1 STD)']  };
        
        % Bar Chart Plotting functions
        % Split into two parallel functions for pre- and post-v7.0 Matlab:
        if matlabversion < 7.0
            
            % Plot as groups of three bars (Mean, Mean Forward, Mean Rearward)
            % WAS: H = bar(  vel_data(:,:,1)  );
            H = bar(  meanData(:,:,1)  );
            
            % Annotate with legend
            legend(barlegend);
            %             legend({ ['Mean ' FRIENDLYMETRICNAME ' (+/- 1 STD)'], ...
            %                      ['Mean Forward ' FRIENDLYMETRICNAME ' (+/- 1 STD)'], ...
            %                      ['Mean Rearward ' FRIENDLYMETRICNAME ' (+/- 1 STD)']  });
            
            hold on
            
            for i = 1:3     % Mean, MeanFWD, MeanRWD
                xpos = mean( get(H(i), 'XData') );
                ypos = get(H(i), 'YData');   ypos = ypos(2,:);
                errorbar( xpos, meanData(:,i,1)', meanData(:,i,2)', 'r.')
                %     errorbar( xpos, vel_data(:,i,1)', vel_data(:,i,2)', 'r.')
                % %     errorbar( xpos, ypos, vel_data(:,i,2)', 'k.')
            end    
            
        else    % i.e. matlabversion >= 7.0
            
            % Plot as groups of bars with ERROR BARS
            barerrorbar(meanData(:,:,1), meanData(:,:,2));
            
            % Annotate with legend
            legend(barlegend)
            
        end
        
        set(gca, 'YGrid', 'on')
        set(gca, 'FontWeight', 'bold');
        
        if DISPLAYBEND==1
            titletxt = [FRIENDLYMETRICNAME ' -- Bend #' int2str(bendnum)];
        elseif DISPLAYBEND==2 
            titletxt = [FRIENDLYMETRICNAME ' -- Bends #' int2str(bendnum) ' - #' int2str(bendnum+1)];
        else 
            titletxt = FRIENDLYMETRICNAME;
        end
        title(titletxt);
        set(gcf, 'Name', titletxt);
        
        
        % if DISPLAYBEND
        %     title( [FRIENDLYMETRICNAME ' -- Bend # ' int2str(bendnum)] )
        % else 
        %     title(FRIENDLYMETRICNAME);
        % end
        
        
        % title('Velocity');
        xlabel('Condition');
        ylabel([ FRIENDLYMETRICNAME '  (' METRICUNITS ')' ]);
        % ylabel('Velocity  (mm/sec)');
        set(gca, 'xticklabel', legendtext)
        
        % Code to format plots for landscape output
        set(gcf, 'PaperOrientation', 'Landscape');
        set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
        
        % To ensure color plot from Wormwriter Color
        %   or grayscale plot from Wormwriter2
        %   (was getting blank plots from ...2 and ...Color on 6/25/03
        %   when plots were automatically setting to 'renderer' = 'zbuffer')
        %   (Plots were also blank with 'renderer' = 'opengl'.)
        set(gcf, 'Renderer', 'painters');
        
        %
        %
        %
        %**************************************************************************
        
        %**************************************************************************
        %**************************************************************************
        %**************************************************************************
        %**************************************************************************
        %**************************************************************************
        
        if DISPLAYBEND==1
            BENDTEXT = [' (Bend #' int2str(bendnum) ') ' ];
        elseif DISPLAYBEND==2
            BENDTEXT = [' (Bends #' int2str(bendnum) '-#' int2str(bendnum+1) ') ' ];
        else
            BENDTEXT = [' '];
        end
        
        if nargin>2
            CLICKTEXT = ['  -  Click on the group you want to test'];
        else
            CLICKTEXT = [' '];
        end
        
        % ALPHATEXT = [' (alpha = ' num2str(ALPHA) ') ' ];
        ALPHATEXT = [' (' num2str(100*(1-ALPHA)) '% Confidence Level) ' ];
        
        
        
        
        %    THE NON-PARAMETRIC VERSION IS p = kruskalwallis(X)
        
        % ANOVA:
        figure
        
        % [pFWD,table,statsFWD] = anova1(fwdData, fwdGroup);
        [pFWD,table,statsFWD] = anova1_no_table(fwdData, fwdGroup);
        % Only bother with multcompare if there is question on which two are
        % different:
        if nargin > 1   % SEE IF CJC LIKES MULT COMPARE FOR SINGLES/DOUBLES TOO... was 2
            [c,m] = multcompare(statsFWD, ALPHA);
        else
            ylabel( [ FRIENDLYMETRICNAME '   [' METRICUNITS ']' ] );
        end
        % title(['\bfForward ' FRIENDLYMETRICNAME BENDTEXT ALPHATEXT CLICKTEXT]);
        
        titletxt = ['Forward ' FRIENDLYMETRICNAME BENDTEXT];
        title(['\bf' titletxt ALPHATEXT CLICKTEXT]);
        set(gcf, 'Name', titletxt);
        
        % Code to format plots for landscape output
        set(gcf, 'PaperOrientation', 'Landscape');
        set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
        
        
        figure
        
        [pRWD,table,statsRWD] = anova1_no_table(rwdData, rwdGroup);
        ylabel( [ FRIENDLYMETRICNAME '   [' METRICUNITS ']' ] );
        %     title(['\bfRearward ' FRIENDLYMETRICNAME BENDTEXT CLICKTEXT]);
        % Only bother with multcompare if there is question on which two are
        % different:
        if nargin > 1   % SEE IF CJC LIKES MULT COMPARE FOR SINGLES/DOUBLES TOO... was 2
            [c,m] = multcompare(statsRWD, ALPHA);
        else
            ylabel( [ FRIENDLYMETRICNAME '   [' METRICUNITS ']' ] );
        end
        % title(['\bfRearward ' FRIENDLYMETRICNAME BENDTEXT ALPHATEXT CLICKTEXT]);
        
        titletxt = ['Rearward ' FRIENDLYMETRICNAME BENDTEXT];
        title(['\bf' titletxt ALPHATEXT CLICKTEXT]);
        set(gcf, 'Name', titletxt);
        
        % Code to format plots for landscape output
        set(gcf, 'PaperOrientation', 'Landscape');
        set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
        drawnow; 
        
        % % % fprintf(1,'\n\tForward %s ---> p = %f\n\n', FRIENDLYMETRICNAME, p);
        
        
        
        % p-Values don't really make sense if there's only one condition, so:
        if nargin > 1
            verdict = {'All Means Same '   'MEANS DIFFERENT'};
            
            fprintf(1,'\tNull hypothesis: All conditions share same mean?   (alpha = %5.3f)\n', ALPHA);
            fprintf(1,['\t%s\t\t\t\t\t\t\t\t%s\t\t\t\t%s\n'], ...
                conditionplaceholder, verdict{ (pFWD < ALPHA)+1 }, verdict{ (pRWD<ALPHA)+1 });
            fprintf(1,['\t%s\t\t\t\t\t\t\t\t(Fwd) p =%6.3f\t\t\t\t(Rwd) p =%6.3f\n\n'], ...
                conditionplaceholder, pFWD, pRWD);
        end
        
        
        
        
        fprintf(1,'%s-------------------------------------------------------------------------------------\n',repmat( '-',1,size(legendtext,2) ));
        fprintf(1,'%s-------------------------------------------------------------------------------------\n',repmat( '-',1,size(legendtext,2) ));
        %         fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
        %         fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
    end     % for bendnum = BENDNUMBERS
    %     fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
    fprintf(1,'%s-------------------------------------------------------------------------------------\n',repmat( '-',1,size(legendtext,2) ));
    
    
    % Housekeeping
    clear FRIENDLYMETRICNAME
    clear METRICNAME
    clear METRICUNITS
    clear SCREENOPERAND
    clear SCREENCONDITION
    clear BENDNUMBERS
    clear LENGTHNORMALIZE
    clear SCALE
    clear DISPLAYBEND
    
    
    
end     % for f  = METRICSofINTEREST

% 
% 
% 
% 
% 

% Restore original warning state:
warning(originalwarningstate)


return




