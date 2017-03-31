function [] = stats(varargin)

% STATS          Calculate statistics from worm movement metrics.
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
%   1) Velocity (in the worm's track): total, forward and backward
%   2) Centroid Velocity: total, forward and backward
%   3) Bending Frequency (for bend 5 only) for worms moving forward,
%           backward, or either.
%   4) Track Amplitude --expressed as HALF of the TOTAL amplitude (for
%           convenience comparing results with Jan Karbowski's numerical
%           modelling work)-- for worms moving forward, backward, or
%           either.  (Expressed both in mm and as percent of body length.)
%   5) Track Wavelength for worms moving forward, backward, or either. 
%           (Expressed both in mm and as percent of body length.)
%
%   For each measure, the mean value is presented along with the calculated
%   standard deviation and population size.  Note that the population size 
%   'n' refers to different things depending on the 'population' under
%   consideration:
%   a) for individual worms, 'n' is the number of frames for the direction
%           of motion (forward, backward, either).
%   b) for 'condition treated as a single GIANT data set' we daisy-chain
%           the data sets from the worms in each condition, so here 'n'
%           again refers to the number of frames for the direction of
%           motion (as above), but for all the population's worms moving
%           forward, backward or either.
%   c) for 'Conditions treated as Groups of Individual Worms' we are
%           comparing the mean values for each worm with the mean values of
%           the other worms in the same population, so here 'n' is the
%           number of worms in the population.
%   d) for Inter-population means 'n' is number of populations presented
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
%   $INITIAL RELEASE: 1.01 $  $Date: 2004/08/11 xx:xx:xx $
% 

% r1.01: Initial release.  The programming style here is admittedly (by the
%   author) sloppy with VAST amounts of code repetition.  However, this
%   initial release should serve to avail the functionality herein to the
%   community.  As time and the Muse allows, we hope to modularize the code,
%   most likely successively calling a generic prototype function with the
%   relevant details of variable names, titles,...  In addition we hope to
%   provide an easy means for the user to select subsets of output.  
%   Dated 8/11/01 xx:xxAM.
  



% some error checking
if nargout > 7      % ...if too many output arguments
	error('FORMAT: histograms4(directory1, directory2, ....)');   
end

if nargin < 1        % ...if too few input arguments
	error('FORMAT: histograms4(directory1, directory2, ....)');     
end

% Initialize Variables
linewdth = 3;
figuretitlefontsize = 14;

%---------------------------------------------------------------
% % % % % % % Prompt for the chart TITLE information:
% % % % % % prompt = {['Enter chart title information in the form:               ';...
% % % % % %            '                                                         ';...
% % % % % %            '       ''XXX C. elegans Distribution of [metric] for YYY'' ';...
% % % % % %            '                                                         ';...
% % % % % %            'where                                                    ';...
% % % % % %            '   ''XXX...''  is:                                         '],...
% % % % % %        'and  ''...for YYY''   is:'};
% % % % % % dlg_title = 'Chart title information';
% % % % % % num_lines = 1;      
% % % % % % def = {'XXX','for YYY  --  MM/DD/YY'};
% % % % % % answer = inputdlg(prompt,dlg_title,num_lines,def);
% % % % % % if isempty(answer)      % In case user presses cancel
% % % % % %     return;             % abort execution
% % % % % % %     answer = def;       % use the default text  <---I don't like this approach anymore
% % % % % % end
% % % % % % 
% % % % % % titlePrefix = answer{1};
% % % % % % titleSuffix = answer{2};
% % % % % % 
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

answer  = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)      % In case user presses cancel
    return;             % abort execution
%     answer = def;       % use the default text  <---I don't like this approach anymore
end

legendtext = answer{1};
if size(legendtext, 1) < nargin
    error(['ERROR:  Please enter exactly ' int2str(nargin) ' conditions for the legend']);
end
legendtext = legendtext(1:nargin,:);

%---------------------------------------------------------------




% Prevent DivideByZero warning if there are no Statistics for a condition:
originalwarningstate = warning('off', 'MATLAB:divideByZero');   
    % 'originalwarningstate' contains previous state...

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 1 for velocity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % % % ...Moved Figure generation calls to just before plotting v4.06...
% % % 
% % % % for Histogram
% % % velhist = [];

%----- Statistics -1-------------------------------------------------
% Initialize vectors for mean of individual worm means for each condition
vel_Mean_indvMean = [];
vel_STD_indvMean = [];
vel_N_indvMean = [];
%-----
vel_Mean_indvPosMean = [];
vel_STD_indvPosMean = [];
vel_N_indvPosMean = [];
%-----
vel_Mean_indvNegMean = [];
vel_STD_indvNegMean = [];
vel_N_indvNegMean = [];
          %-------%-------%
% Initialize vectors for mean of each condition's data lumped together as a
% single GIANT worm data set
vel_Mean_giantWorm = [];
vel_STD_giantWorm = [];
vel_N_giantWorm = [];
%-----
vel_Mean_giantWormPos = [];
vel_STD_giantWormPos = [];
vel_N_giantWormPos = [];
%-----
vel_Mean_giantWormNeg = [];
vel_STD_giantWormNeg = [];
vel_N_giantWormNeg = [];
%----- Statistics -1end-------------------------------------------------


% % % % Set up for Statistics output
% % % fprintf(1,'\nVELOCITY   [mm/sec]\n');

     
for i=1:nargin      % Each input directory (condition)
   
    % get 'worm*' contents of each directory (condition)
    pd = varargin(i);
    pd = pd{1};
   
    % get 'worm*' contents of each directory (condition)
    d = dir([pd filesep 'worm*']);
    nd = prod(size(d));      % Number of worm*'s
   
    
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
    
    
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
    placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
    
    % On the first pass:
    % Set up for Statistics output
    if i == 1
        fprintf(1,'\nVELOCITY   [mm/sec]\n', placeholderstring);
%     fprintf(1,'\n\t%s\tVELOCITY   [mm/sec]\n', placeholderstring);
    end

    
    %   Column Titles
    fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
                   '\tMeanPOS\t  STD  \t   n   \t:'...
                   '\tMeanNEG\t  STD  \t   n   \t '...
                   '\n'], placeholderstring);
    %----- Statistics --------------------------------------------------
         
    % Error checking: Verify that parent directory exists and contains worm folders
    if exist(pd) ~= 7    % if directory does not exist or is not a directory
        error(['ERROR: Directory ''' pd ''' does not exist!']);
    elseif nd == 0       % if directory is empty (no worm folders)
        error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
    end   
    
    % Print Condition Name (and move to next line line)
    fprintf(1,'%s\n',legendtext(i,:));
   
    
    %----- Statistics --------------------------------------------------
    % for Statistics
    vel_indvMean = [];      % Vector of Mean Velocities for each condition
    vel_indvStd  = [];      % Vector of Velocity standard deviations for each condition
    vel_indvN    = [];      % Vector of number of Velocities for each condition
    %-----
    vel_indvPosMean = [];   % Vector of Mean Positive (forward) Velocities for each condition
    vel_indvPosStd  = [];   % Vector of Positive (forward) Velocity standard deviations for each condition
    vel_indvPosN    = [];   % Vector of number of Positive (forward) Velocities for each condition
    %-----
    vel_indvNegMean = [];   % Vector of Mean Negative (rearward) Velocities for each condition
    vel_indvNegStd  = [];   % Vector of Negative (rearward) Velocity standard deviations for each condition
    vel_indvNegN    = [];   % Vector of number of Negative (rearward) Velocities for each condition
    
    % Initialize vectors for velocities treating all worms for a 
    % condition as one big single individual.
    vel_giantWorm    = [];     % Vector of All velocities for condition
    vel_giantWormPos = [];     % Vector of all Positive velocities for condition
    vel_giantWormNeg = [];     % Vector of all Negative velocities for condition
    %----- Statistics -2end-------------------------------------------------
    
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
    
    % Loop over each worm* directory for i'th condition (input directory)
    for j=1:nd   % Through each worm* directory...
        % Extract name of worm* directory
        name = d(j).name;
        
        % clear variables
        clear vel     % Should only need to clear one variable (v4.06)
%         clear amp ampt fingerprint flex fre len     % <--- Only using 'vel'...
%         clear mode phs ptvel theta vel wavelnth

        % Load 'vel' into memory
        load([pd filesep name filesep 'metrics.mat'], 'vel'); % Only load 'vel' (v4.06)
%         load([pd filesep name filesep 'metrics.mat']);  % Why load unnecessary varables???
     




%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
      
        %----- Statistics -3-------------------------------------------------
        % Prepare group statistics:
        % .....all velocities
        vel_indvMean = [vel_indvMean      mean(vel(~isnan(vel))) ];
        vel_indvStd  = [vel_indvStd        std(vel(~isnan(vel))) ];
        vel_indvN    = [vel_indvN    prod(size(vel(~isnan(vel))))]; 
        % .....positive (forward) velocities
        vel_indvPosMean = [vel_indvPosMean      mean(vel(vel>0)) ];
        vel_indvPosStd  = [vel_indvPosStd        std(vel(vel>0)) ];
        vel_indvPosN    = [vel_indvPosN    prod(size(vel(vel>0)))]; 
        % .....negative (rearward) velocities
        vel_indvNegMean = [vel_indvNegMean      mean(vel(vel<0)) ];
        vel_indvNegStd  = [vel_indvNegStd        std(vel(vel<0)) ];
        vel_indvNegN    = [vel_indvNegN    prod(size(vel(vel<0)))]; 
        
        % Print line of statistics for j'th worm of i'th condition
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    wormDirNames(j,:)   ,...
                    vel_indvMean(j)     ,...
                    vel_indvStd(j)      ,...
                    vel_indvN(j)        ,...
                    vel_indvPosMean(j)  ,...
                    vel_indvPosStd(j)   ,...
                    vel_indvPosN(j)     ,...
                    vel_indvNegMean(j)  ,...
                    vel_indvNegStd(j)   ,...
                    vel_indvNegN(j) );
              
                
                
        vel_giantWorm       = [vel_giantWorm        vel(~isnan(vel))];  
        vel_giantWormPos    = [vel_giantWormPos     vel(vel>0)];  
        vel_giantWormNeg    = [vel_giantWormNeg     vel(vel<0)];  
        %----- Statistics -3end-------------------------------------------------
        
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
        
        
    end      % for j=1:nd   % Through each worm* directory...
    
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
    
%----- Statistics -4-------------------------------------------------
%    *************************************************
% conditionOutput = [ vel_indvMean;
%                     vel_indvStd;
%                     vel_indvN;
%                     vel_indvPosMean;
%                     vel_indvPosStd;
%                     vel_indvPosN;
%                     vel_indvNegMean;
%                     vel_indvNegStd;
%                     vel_indvNegN];
%                 
%         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t'...     
%                        '\n'], ...
%                     wormDirNames',...
%                     conditionOutput);
% 
% 
%    *************************************************
   
    
    
    
    
    fprintf(1,'\n\n');    % Force a newline between conditions
   
% % % % %--------                        
% % % % % This is a messy way of solving the single worm handler:                        
% % % % %    if nd == 1
% % % % %        n = [n;nc];      % Adds a second copy of the single worm data
% % % % %    end                  % to allow mean to generate a vector  --  else
% % % % %                         % velhist becomes a scalar
% % % % %    velhist = [velhist; mean(n)];
% % % % %--------  
% % % % % The cleaner way of handling single worms (implemented in v4.06):
% % % %     if nd == 1   % only one worm* directory
% % % %         velhist = [velhist; n];
% % % %     else         % >one worm* directory
% % % %         velhist = [velhist; mean(n)];
% % % %     end
    
    %----- Statistics --------------------------------------------------
    % Vector of Means of each i'th condition treated as a single Giant Worm
    % (all velocities lumped togther, finding group stats here)
    % (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    vel_Mean_giantWorm(i)    = mean(vel_giantWorm(~isnan(vel_giantWorm)));
    vel_STD_giantWorm(i)     = std(vel_giantWorm(~isnan(vel_giantWorm)));
    vel_N_giantWorm(i)       = prod(size(vel_giantWorm(~isnan(vel_giantWorm))));
    %....forward
    vel_Mean_giantWormPos(i) = mean(vel_giantWormPos(~isnan(vel_giantWormPos)));
    vel_STD_giantWormPos(i)  = std(vel_giantWormPos(~isnan(vel_giantWormPos)));
    vel_N_giantWormPos(i)    = prod(size(vel_giantWormPos(~isnan(vel_giantWormPos))));
    %....rearward
    vel_Mean_giantWormNeg(i) = mean(vel_giantWormNeg(~isnan(vel_giantWormNeg)));
    vel_STD_giantWormNeg(i)  = std(vel_giantWormNeg(~isnan(vel_giantWormNeg)));
    vel_N_giantWormNeg(i)    = prod(size(vel_giantWormNeg(~isnan(vel_giantWormNeg))));
    
    % Vector of Mean of Mean Velocities for each i'th condition (one per
    % condition)  (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    vel_Mean_indvMean(i)    = mean(vel_indvMean(~isnan(vel_indvMean)));
    vel_STD_indvMean(i)     = std(vel_indvMean(~isnan(vel_indvMean)));
    vel_N_indvMean(i)       = prod(size(vel_indvMean(~isnan(vel_indvMean))));
    %....forward
    vel_Mean_indvPosMean(i) = mean(vel_indvPosMean(~isnan(vel_indvPosMean)));
    vel_STD_indvPosMean(i)  = std(vel_indvPosMean(~isnan(vel_indvPosMean)));
    vel_N_indvPosMean(i)    = prod(size(vel_indvPosMean(~isnan(vel_indvPosMean))));
    %....rearward
    vel_Mean_indvNegMean(i) = mean(vel_indvNegMean(~isnan(vel_indvNegMean)));
    vel_STD_indvNegMean(i)  = std(vel_indvNegMean(~isnan(vel_indvNegMean)));
    vel_N_indvNegMean(i)    = prod(size(vel_indvNegMean(~isnan(vel_indvNegMean))));
    %----- Statistics -4end-------------------------------------------------

%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
    
   
end     % for i=1:nargin      % Each input directory (condition)


%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************

%----- Statistics -5-------------------------------------------------
%   Print Column Titles before Each Condition:
% Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
conditionplaceholder = char(ones(1,size(legendtext,2))*32);   

%   Print velocity stats for conditions treated as single Giant datasets.
% Title
fprintf(1,'\n---->  Each condition treated as a single GIANT data set\n');
fprintf(1,'VELOCITY   [mm/sec]\n',conditionplaceholder);

%   Column Titles
fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
               '\tMeanPOS\t  STD  \t   n   \t:'...
               '\tMeanNEG\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    legendtext(j,:)   ,...
                    vel_Mean_giantWorm(j)  ,...
                    vel_STD_giantWorm(j)  ,...
                    vel_N_giantWorm(j)  ,...
                    vel_Mean_giantWormPos(j)  ,...
                    vel_STD_giantWormPos(j)  ,...
                    vel_N_giantWormPos(j)  ,...
                    vel_Mean_giantWormNeg(j)  ,...
                    vel_STD_giantWormNeg(j)  ,...
                    vel_N_giantWormNeg(j) );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( vel_Mean_giantWorm )      ,...
                    std(  vel_Mean_giantWorm )      ,...
                    size( vel_Mean_giantWorm,2 )    ,...
                        mean( vel_Mean_giantWormPos )   ,...
                        std(  vel_Mean_giantWormPos )   ,...
                        size( vel_Mean_giantWormPos,2 ) ,...
                    mean( vel_Mean_giantWormNeg )   ,...
                    std(  vel_Mean_giantWormNeg )   ,...
                    size( vel_Mean_giantWormNeg,2 ) );
                
                
                
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Print velocity stats for Mean of Means.
% Title
fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
fprintf(1,'VELOCITY   [mm/sec]\n',conditionplaceholder);
% fprintf(1,'\nVELOCITY   [mm/sec]  --  Conditions treated as groups of individual worms\n');

%   Column Titles
fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
               '\tMean of\t       \t       \t:'...
               '\tMean of\t       \t       \t '...
               '\n'], conditionplaceholder);
fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
               '\tMeanPOS\t  STD  \t   n   \t:'...
               '\tMeanNEG\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                        legendtext(j,:)   ,...
                    vel_Mean_indvMean(j),...
                    vel_STD_indvMean(j) ,...
                    vel_N_indvMean(j)   ,...
                        vel_Mean_indvPosMean(j) ,...
                        vel_STD_indvPosMean(j)  ,...
                        vel_N_indvPosMean(j)    ,...
                    vel_Mean_indvNegMean(j) ,...
                    vel_STD_indvNegMean(j)  ,...
                    vel_N_indvNegMean(j)    );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( vel_Mean_indvMean )      ,...
                    std(  vel_Mean_indvMean )      ,...
                    size( vel_Mean_indvMean,2 )    ,...
                        mean( vel_Mean_indvPosMean )   ,...
                        std(  vel_Mean_indvPosMean )   ,...
                        size( vel_Mean_indvPosMean,2 ) ,...
                    mean( vel_Mean_indvNegMean )   ,...
                    std(  vel_Mean_indvNegMean )   ,...
                    size( vel_Mean_indvNegMean,2 ) );
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%----- Statistics -5end-------------------------------------------------

%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************







% Housekeeping
clear vel_indvMean      vel_indvStd     vel_indvN
clear vel_indvPosMean   vel_indvPosStd  vel_indvPosN
clear vel_indvNegMean   vel_indvNegStd  vel_indvNegN 
clear vel_giantWorm vel_giantWormPos    vel_giantWormNeg

fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');


















































% % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % % Figure 1A for NORMALIZED Velocity
% % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % 
% % % % % 
% % % % % %**************************************************************************
% % % % % %**************************************************************************
% % % % % %----- Statistics -1-------------------------------------------------
% % % % % % Initialize vectors for mean of individual worm means for each condition
% % % % % norm_vel_Mean_indvMean = [];
% % % % % norm_vel_STD_indvMean = [];
% % % % % norm_vel_N_indvMean = [];
% % % % % %-----
% % % % % norm_vel_Mean_indvPosMean = [];
% % % % % norm_vel_STD_indvPosMean = [];
% % % % % norm_vel_N_indvPosMean = [];
% % % % % %-----
% % % % % norm_vel_Mean_indvNegMean = [];
% % % % % norm_vel_STD_indvNegMean = [];
% % % % % norm_vel_N_indvNegMean = [];
% % % % %           %-------%-------%
% % % % % % Initialize vectors for mean of each condition's data lumped together as a
% % % % % % single GIANT (looooong) worm data set
% % % % % norm_vel_Mean_giantWorm = [];
% % % % % norm_vel_STD_giantWorm = [];
% % % % % norm_vel_N_giantWorm = [];
% % % % % %-----
% % % % % norm_vel_Mean_giantWormPos = [];
% % % % % norm_vel_STD_giantWormPos = [];
% % % % % norm_vel_N_giantWormPos = [];
% % % % % %-----
% % % % % norm_vel_Mean_giantWormNeg = [];
% % % % % norm_vel_STD_giantWormNeg = [];
% % % % % norm_vel_N_giantWormNeg = [];
% % % % % %----- Statistics -1end-------------------------------------------------
% % % % % %**************************************************************************
% % % % % %**************************************************************************
% % % % % 
% % % % % 
% % % % % 
% % % % % for i=1:nargin      % Cycle thru each input directory
% % % % %    
% % % % %    % get contents of each directory
% % % % %    pd = varargin(i);
% % % % %    pd = pd{1};
% % % % %    
% % % % %    d = dir([pd filesep 'worm*']);
% % % % %    nd = prod(size(d));
% % % % %    
% % % % %     
% % % % %     %**************************************************************************
% % % % %     %**************************************************************************
% % % % %     %----- Statistics -2-------------------------------------------------
% % % % %     % Remember worm* names & convert into useable format
% % % % %     wormDirNames = {};
% % % % %     for g = 1:nd
% % % % %         wormDirNames{g} = d(g).name;
% % % % %     end
% % % % %     wormDirNames = {str2mat(wormDirNames)};   % Convert string arrays to single cell array
% % % % %     wormDirNames = wormDirNames{1};   % Convert single cell array to matrix of characters
% % % % % 
% % % % %     %   Print Column Titles before Each Condition:
% % % % %     % Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
% % % % %     placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
% % % % %     
% % % % %     % On the first pass:
% % % % %     % Set up for Statistics output
% % % % %     if i == 1
% % % % %         fprintf(1,'\nLENGTH-NORMALIZED VELOCITY   [%% mean length/sec]\n', placeholderstring);
% % % % % %     fprintf(1,'\n\t%s\tVELOCITY   [mm/sec]\n', placeholderstring);
% % % % %     end
% % % % % 
% % % % %     
% % % % %     %   Column Titles
% % % % %     fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
% % % % %                    '\tMeanFWD\t  STD  \t   n   \t:'...
% % % % %                    '\tMeanREV\t  STD  \t   n   \t '...
% % % % %                    '\n'], placeholderstring);
% % % % %     %----- Statistics --------------------------------------------------
% % % % %          
% % % % % % % % %     % Error checking: Verify that parent directory exists and contains worm folders
% % % % % % % % %     if exist(pd) ~= 7    % if directory does not exist or is not a directory
% % % % % % % % %         error(['ERROR: Directory ''' pd ''' does not exist!']);
% % % % % % % % %     elseif nd == 0       % if directory is empty (no worm folders)
% % % % % % % % %         error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
% % % % % % % % %     end   
% % % % %     
% % % % %     % Print Condition Name (and move to next line line)
% % % % %     fprintf(1,'%s\n',legendtext(i,:));
% % % % %    
% % % % %     
% % % % %     %----- Statistics --------------------------------------------------
% % % % %     % for Statistics
% % % % %     norm_vel_indvMean = [];      % Vector of Mean Velocities for each condition
% % % % %     norm_vel_indvStd  = [];      % Vector of Velocity standard deviations for each condition
% % % % %     norm_vel_indvN    = [];      % Vector of number of Velocities for each condition
% % % % %     %-----
% % % % %     norm_vel_indvPosMean = [];   % Vector of Mean Positive (forward) Velocities for each condition
% % % % %     norm_vel_indvPosStd  = [];   % Vector of Positive (forward) Velocity standard deviations for each condition
% % % % %     norm_vel_indvPosN    = [];   % Vector of number of Positive (forward) Velocities for each condition
% % % % %     %-----
% % % % %     norm_vel_indvNegMean = [];   % Vector of Mean Negative (rearward) Velocities for each condition
% % % % %     norm_vel_indvNegStd  = [];   % Vector of Negative (rearward) Velocity standard deviations for each condition
% % % % %     norm_vel_indvNegN    = [];   % Vector of number of Negative (rearward) Velocities for each condition
% % % % %     
% % % % %     % Initialize vectors for velocities treating all worms for a 
% % % % %     % condition as one big single individual.
% % % % %     norm_vel_giantWorm    = [];     % Vector of All velocities for condition
% % % % %     norm_vel_giantWormPos = [];     % Vector of all Positive velocities for condition
% % % % %     norm_vel_giantWormNeg = [];     % Vector of all Negative velocities for condition
% % % % %     %----- Statistics -2end-------------------------------------------------
% % % % %     %**************************************************************************
% % % % %     %**************************************************************************
% % % % %    
% % % % %    
% % % % %    
% % % % %    
% % % % %    for j=1:nd       % Cycle thru each worm* folder
% % % % %       % get name of directory
% % % % %       name = d(j).name;
% % % % %       % clear variables
% % % % %       clear len vel
% % % % %       
% % % % %       % load in the data
% % % % %       load([pd filesep name filesep 'metrics.mat'], 'len', 'vel');
% % % % %       
% % % % %       % Verify that metrics.mat includes *len* variable;
% % % % %       %   if not, display error message and end job.
% % % % %       if ~exist('len')
% % % % %           errortext = ['Worm length data missing ---> Re-run METRICS for ' pd filesep name];
% % % % %           error(errortext)
% % % % %       end
% % % % %       
% % % % %       % Calculate mean length
% % % % %       meanlen = mean(len(~isnan(len)));
% % % % %       
% % % % %       % Calculate normalized ampt and wavelnth
% % % % %       norm_vel = (vel/meanlen)*100;
% % % % %       
% % % % %       
% % % % %       
% % % % %         %**************************************************************************
% % % % %         %**************************************************************************
% % % % %         %----- Statistics -3-------------------------------------------------
% % % % %         
% % % % % % % % % %         % Condition 'vel' 
% % % % % % % % % %         %   In TRANSLATION we calculate the i'th Velocity as 
% % % % % % % % % %         %       (position(i+1)-position(i)) / (time(i+1)-time(i)).
% % % % % % % % % %         %   For n frames there can only be n-1 velocity vectors, but n
% % % % % % % % % %         %   track amplitudes and track wavelngths.  In TRACKS we orient the
% % % % % % % % % %         %   worm in the i'th frame with the i'th velocity vector, so the
% % % % % % % % % %         %   n'th worm has no n'th velocity vector; instead we use the
% % % % % % % % % %         %   n-1'th velocity vector to orient the n'th worm for TRACKS.
% % % % % % % % % %         %   Following that model, we duplicate the last velocity vector
% % % % % % % % % %         %   (the n-1'th) as the n'th velocity, rather than dropping the
% % % % % % % % % %         %   n'th track amplitude and wavelength, though that might in fact
% % % % % % % % % %         %   be a cleaner way of reaching Nirvana...  This is a long way of
% % % % % % % % % %         %   saying:
% % % % % % % % % %         vel = [vel vel(end)];
% % % % % 
% % % % %         % Prepare group statistics:
% % % % %         % .....all velocities
% % % % %         norm_vel_indvMean = [norm_vel_indvMean      mean(norm_vel(~isnan(norm_vel))) ];
% % % % %         norm_vel_indvStd  = [norm_vel_indvStd        std(norm_vel(~isnan(norm_vel))) ];
% % % % %         norm_vel_indvN    = [norm_vel_indvN    prod(size(norm_vel(~isnan(norm_vel))))]; 
% % % % %         % .....positive (forward) velocities
% % % % %         norm_vel_indvPosMean = [norm_vel_indvPosMean      mean(norm_vel( ~isnan(norm_vel) & (vel>0) )) ];
% % % % %         norm_vel_indvPosStd  = [norm_vel_indvPosStd        std(norm_vel( ~isnan(norm_vel) & (vel>0) )) ];
% % % % %         norm_vel_indvPosN    = [norm_vel_indvPosN    prod(size(norm_vel( ~isnan(norm_vel) & (vel>0) )))]; 
% % % % %         % .....negative (rearward) velocities
% % % % %         norm_vel_indvNegMean = [norm_vel_indvNegMean      mean(norm_vel( ~isnan(norm_vel) & (vel<0) )) ];
% % % % %         norm_vel_indvNegStd  = [norm_vel_indvNegStd        std(norm_vel( ~isnan(norm_vel) & (vel<0) )) ];
% % % % %         norm_vel_indvNegN    = [norm_vel_indvNegN    prod(size(norm_vel( ~isnan(norm_vel) & (vel<0) )))]; 
% % % % %         
% % % % %         % Print line of statistics for j'th worm of i'th condition
% % % % %         fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t'...     
% % % % %                        '\n'], ...
% % % % %                     wormDirNames(j,:)   ,...
% % % % %                     norm_vel_indvMean(j)     ,...
% % % % %                     norm_vel_indvStd(j)      ,...
% % % % %                     norm_vel_indvN(j)        ,...
% % % % %                     norm_vel_indvPosMean(j)  ,...
% % % % %                     norm_vel_indvPosStd(j)   ,...
% % % % %                     norm_vel_indvPosN(j)     ,...
% % % % %                     norm_vel_indvNegMean(j)  ,...
% % % % %                     norm_vel_indvNegStd(j)   ,...
% % % % %                     norm_vel_indvNegN(j) );
% % % % %               
% % % % %                 
% % % % %                 
% % % % %         norm_vel_giantWorm       = [norm_vel_giantWorm        norm_vel( ~isnan(norm_vel)           )];  
% % % % %         norm_vel_giantWormPos    = [norm_vel_giantWormPos     norm_vel( ~isnan(norm_vel) & (vel>0) )];  
% % % % %         norm_vel_giantWormNeg    = [norm_vel_giantWormNeg     norm_vel( ~isnan(norm_vel) & (vel<0) )];  
% % % % %         %----- Statistics -3end-------------------------------------------------
% % % % %         %**************************************************************************
% % % % %         %**************************************************************************
% % % % % 
% % % % %       
% % % % % 
% % % % %    end      % for j=1:nd       % Cycle thru each worm* folder
% % % % %    
% % % % %    
% % % % %    
% % % % % %**************************************************************************
% % % % % %**************************************************************************
% % % % % %----- Statistics -4-------------------------------------------------
% % % % % %    *************************************************
% % % % % % conditionOutput = [ vel_indvMean;
% % % % % %                     vel_indvStd;
% % % % % %                     vel_indvN;
% % % % % %                     vel_indvPosMean;
% % % % % %                     vel_indvPosStd;
% % % % % %                     vel_indvPosN;
% % % % % %                     vel_indvNegMean;
% % % % % %                     vel_indvNegStd;
% % % % % %                     vel_indvNegN];
% % % % % %                 
% % % % % %         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
% % % % % %                        '\t%6.3f \t%6.3f \t%6d\t:'...     
% % % % % %                        '\t%6.3f \t%6.3f \t%6d\t'...     
% % % % % %                        '\n'], ...
% % % % % %                     wormDirNames',...
% % % % % %                     conditionOutput);
% % % % % % 
% % % % % % 
% % % % % %    *************************************************
% % % % %    
% % % % %     
% % % % %     fprintf(1,'\n\n');    % Force a newline between conditions
% % % % %    
% % % % %     
% % % % %     %----- Statistics --------------------------------------------------
% % % % %     % Vector of Means of each i'th condition treated as a single Giant Worm
% % % % %     % (all velocities lumped togther, finding group stats here)
% % % % %     % (ONLY FOR ACTUAL VALUES - exclude NaN's):
% % % % %     %....All
% % % % %     norm_vel_Mean_giantWorm(i)    = mean(norm_vel_giantWorm(~isnan(norm_vel_giantWorm)));
% % % % %     norm_vel_STD_giantWorm(i)     = std(norm_vel_giantWorm(~isnan(norm_vel_giantWorm)));
% % % % %     norm_vel_N_giantWorm(i)       = prod(size(norm_vel_giantWorm(~isnan(norm_vel_giantWorm))));
% % % % %     %....forward
% % % % %     norm_vel_Mean_giantWormPos(i) = mean(norm_vel_giantWormPos(~isnan(norm_vel_giantWormPos)));
% % % % %     norm_vel_STD_giantWormPos(i)  = std(norm_vel_giantWormPos(~isnan(norm_vel_giantWormPos)));
% % % % %     norm_vel_N_giantWormPos(i)    = prod(size(norm_vel_giantWormPos(~isnan(norm_vel_giantWormPos))));
% % % % %     %....rearward
% % % % %     norm_vel_Mean_giantWormNeg(i) = mean(norm_vel_giantWormNeg(~isnan(norm_vel_giantWormNeg)));
% % % % %     norm_vel_STD_giantWormNeg(i)  = std(norm_vel_giantWormNeg(~isnan(norm_vel_giantWormNeg)));
% % % % %     norm_vel_N_giantWormNeg(i)    = prod(size(norm_vel_giantWormNeg(~isnan(norm_vel_giantWormNeg))));
% % % % %     
% % % % %     % Vector of Mean of Mean Velocities for each i'th condition (one per
% % % % %     % condition)  (ONLY FOR ACTUAL VALUES - exclude NaN's):
% % % % %     %....All
% % % % %     norm_vel_Mean_indvMean(i)    = mean(norm_vel_indvMean(~isnan(norm_vel_indvMean)));
% % % % %     norm_vel_STD_indvMean(i)     = std(norm_vel_indvMean(~isnan(norm_vel_indvMean)));
% % % % %     norm_vel_N_indvMean(i)       = prod(size(norm_vel_indvMean(~isnan(norm_vel_indvMean))));
% % % % %     %....forward
% % % % %     norm_vel_Mean_indvPosMean(i) = mean(norm_vel_indvPosMean(~isnan(norm_vel_indvPosMean)));
% % % % %     norm_vel_STD_indvPosMean(i)  = std(norm_vel_indvPosMean(~isnan(norm_vel_indvPosMean)));
% % % % %     norm_vel_N_indvPosMean(i)    = prod(size(norm_vel_indvPosMean(~isnan(norm_vel_indvPosMean))));
% % % % %     %....rearward
% % % % %     norm_vel_Mean_indvNegMean(i) = mean(norm_vel_indvNegMean(~isnan(norm_vel_indvNegMean)));
% % % % %     norm_vel_STD_indvNegMean(i)  = std(norm_vel_indvNegMean(~isnan(norm_vel_indvNegMean)));
% % % % %     norm_vel_N_indvNegMean(i)    = prod(size(norm_vel_indvNegMean(~isnan(norm_vel_indvNegMean))));
% % % % %     %----- Statistics -4end-------------------------------------------------
% % % % %     %**************************************************************************
% % % % %     %**************************************************************************
% % % % %                         
% % % % %    
% % % % % end     % for i=1:nargin      % Cycle thru each input directory
% % % % % 
% % % % % 
% % % % % %**************************************************************************
% % % % % %**************************************************************************
% % % % % %----- Statistics -5-------------------------------------------------
% % % % % %   Print Column Titles before Each Condition:
% % % % % % Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
% % % % % conditionplaceholder = char(ones(1,size(legendtext,2))*32);   
% % % % % 
% % % % % %   Print velocity stats for conditions treated as single Giant datasets.
% % % % % % Title
% % % % % fprintf(1,'\n---->  Each condition treated as a single GIANT (looong) data set\n');
% % % % % fprintf(1,'LENGTH-NORMALIZED VELOCITY   [%% mean length/sec]\n',conditionplaceholder);
% % % % % 
% % % % % %   Column Titles
% % % % % fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
% % % % %                '\tMeanFWD\t  STD  \t   n   \t:'...
% % % % %                '\tMeanREV\t  STD  \t   n   \t '...
% % % % %                '\n'], conditionplaceholder);
% % % % % % Rows of data
% % % % % for j = 1:nargin
% % % % %         fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t'...     
% % % % %                        '\n'], ...
% % % % %                     legendtext(j,:)   ,...
% % % % %                     norm_vel_Mean_giantWorm(j)  ,...
% % % % %                     norm_vel_STD_giantWorm(j)  ,...
% % % % %                     norm_vel_N_giantWorm(j)  ,...
% % % % %                     norm_vel_Mean_giantWormPos(j)  ,...
% % % % %                     norm_vel_STD_giantWormPos(j)  ,...
% % % % %                     norm_vel_N_giantWormPos(j)  ,...
% % % % %                     norm_vel_Mean_giantWormNeg(j)  ,...
% % % % %                     norm_vel_STD_giantWormNeg(j)  ,...
% % % % %                     norm_vel_N_giantWormNeg(j) );
% % % % % end     % for j = 1:nargin
% % % % % fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% % % % % % Mean of means:
% % % % % fprintf(1,'\t   Inter-population Means:\n');
% % % % % fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t'...     
% % % % %                        '\n\n'], ...
% % % % %                         conditionplaceholder            ,...
% % % % %                     mean( norm_vel_Mean_giantWorm )      ,...
% % % % %                     std(  norm_vel_Mean_giantWorm )      ,...
% % % % %                     size( norm_vel_Mean_giantWorm,2 )    ,...
% % % % %                         mean( norm_vel_Mean_giantWormPos )   ,...
% % % % %                         std(  norm_vel_Mean_giantWormPos )   ,...
% % % % %                         size( norm_vel_Mean_giantWormPos,2 ) ,...
% % % % %                     mean( norm_vel_Mean_giantWormNeg )   ,...
% % % % %                     std(  norm_vel_Mean_giantWormNeg )   ,...
% % % % %                     size( norm_vel_Mean_giantWormNeg,2 ) );
% % % % %                 
% % % % %                 
% % % % %                 
% % % % %                 
% % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % %   Print velocity stats for Mean of Means.
% % % % % % Title
% % % % % fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
% % % % % fprintf(1,'LENGTH-NORMALIZED VELOCITY   [%% mean length/sec]\n',conditionplaceholder);
% % % % % % fprintf(1,'\nVELOCITY   [mm/sec]  --  Conditions treated as groups of individual worms\n');
% % % % % 
% % % % % %   Column Titles
% % % % % fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
% % % % %                '\tMean of\t       \t       \t:'...
% % % % %                '\tMean of\t       \t       \t '...
% % % % %                '\n'], conditionplaceholder);
% % % % % fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
% % % % %                '\tMeanFWD\t  STD  \t   n   \t:'...
% % % % %                '\tMeanREV\t  STD  \t   n   \t '...
% % % % %                '\n'], conditionplaceholder);
% % % % % % Rows of data
% % % % % for j = 1:nargin
% % % % %         fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t'...     
% % % % %                        '\n'], ...
% % % % %                         legendtext(j,:)   ,...
% % % % %                     norm_vel_Mean_indvMean(j),...
% % % % %                     norm_vel_STD_indvMean(j) ,...
% % % % %                     norm_vel_N_indvMean(j)   ,...
% % % % %                         norm_vel_Mean_indvPosMean(j) ,...
% % % % %                         norm_vel_STD_indvPosMean(j)  ,...
% % % % %                         norm_vel_N_indvPosMean(j)    ,...
% % % % %                     norm_vel_Mean_indvNegMean(j) ,...
% % % % %                     norm_vel_STD_indvNegMean(j)  ,...
% % % % %                     norm_vel_N_indvNegMean(j)    );
% % % % % end     % for j = 1:nargin
% % % % % fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% % % % % % Mean of means:
% % % % % fprintf(1,'\t   Inter-population Means:\n');
% % % % % fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t:'...     
% % % % %                        '\t%6.1f \t%6.1f \t%6d\t'...     
% % % % %                        '\n\n'], ...
% % % % %                         conditionplaceholder            ,...
% % % % %                     mean( norm_vel_Mean_indvMean )      ,...
% % % % %                     std(  norm_vel_Mean_indvMean )      ,...
% % % % %                     size( norm_vel_Mean_indvMean,2 )    ,...
% % % % %                         mean( norm_vel_Mean_indvPosMean )   ,...
% % % % %                         std(  norm_vel_Mean_indvPosMean )   ,...
% % % % %                         size( norm_vel_Mean_indvPosMean,2 ) ,...
% % % % %                     mean( norm_vel_Mean_indvNegMean )   ,...
% % % % %                     std(  norm_vel_Mean_indvNegMean )   ,...
% % % % %                     size( norm_vel_Mean_indvNegMean,2 ) );
% % % % % % 
% % % % % 
% % % % % %----- Statistics -5end-------------------------------------------------
% % % % % %**************************************************************************
% % % % % %**************************************************************************
% % % % % 
% % % % % fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% % % % % fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% % % % % fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');





























































%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 1B for CENTROID velocity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % % % ...Moved Figure generation calls to just before plotting v4.06...
% % % 
% % % % for Histogram
% % % velhist = [];

%----- Statistics -1-------------------------------------------------
% Initialize vectors for mean of individual worm means for each condition
velc_Mean_indvMean = [];
velc_STD_indvMean = [];
velc_N_indvMean = [];
%-----
velc_Mean_indvPosMean = [];
velc_STD_indvPosMean = [];
velc_N_indvPosMean = [];
%-----
velc_Mean_indvNegMean = [];
velc_STD_indvNegMean = [];
velc_N_indvNegMean = [];
          %-------%-------%
% Initialize vectors for mean of each condition's data lumped together as a
% single GIANT worm data set
velc_Mean_giantWorm = [];
velc_STD_giantWorm = [];
velc_N_giantWorm = [];
%-----
velc_Mean_giantWormPos = [];
velc_STD_giantWormPos = [];
velc_N_giantWormPos = [];
%-----
velc_Mean_giantWormNeg = [];
velc_STD_giantWormNeg = [];
velc_N_giantWormNeg = [];
%----- Statistics -1end-------------------------------------------------


% % % % Set up for Statistics output
% % % fprintf(1,'\nVELOCITY   [mm/sec]\n');

     
for i=1:nargin      % Each input directory (condition)
   
    % get 'worm*' contents of each directory (condition)
    pd = varargin(i);
    pd = pd{1};
   
    % get 'worm*' contents of each directory (condition)
    d = dir([pd filesep 'worm*']);
    nd = prod(size(d));      % Number of worm*'s
   
    
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
    
    
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
    placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
    
    % On the first pass:
    % Set up for Statistics output
    if i == 1
        fprintf(1,'\nCENTROID VELOCITY   [mm/sec]\n', placeholderstring);
%     fprintf(1,'\n\t%s\tVELOCITY   [mm/sec]\n', placeholderstring);
    end

    
    %   Column Titles
    fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
                   '\tMeanPOS\t  STD  \t   n   \t:'...
                   '\tMeanNEG\t  STD  \t   n   \t '...
                   '\n'], placeholderstring);
    %----- Statistics --------------------------------------------------
         
    % Error checking: Verify that parent directory exists and contains worm folders
    if exist(pd) ~= 7    % if directory does not exist or is not a directory
        error(['ERROR: Directory ''' pd ''' does not exist!']);
    elseif nd == 0       % if directory is empty (no worm folders)
        error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
    end   
    
    % Print Condition Name (and move to next line line)
    fprintf(1,'%s\n',legendtext(i,:));
   
    
    %----- Statistics --------------------------------------------------
    % for Statistics
    velc_indvMean = [];      % Vector of Mean Velocities for each condition
    velc_indvStd  = [];      % Vector of Velocity standard deviations for each condition
    velc_indvN    = [];      % Vector of number of Velocities for each condition
    %-----
    velc_indvPosMean = [];   % Vector of Mean Positive (forward) Velocities for each condition
    velc_indvPosStd  = [];   % Vector of Positive (forward) Velocity standard deviations for each condition
    velc_indvPosN    = [];   % Vector of number of Positive (forward) Velocities for each condition
    %-----
    velc_indvNegMean = [];   % Vector of Mean Negative (rearward) Velocities for each condition
    velc_indvNegStd  = [];   % Vector of Negative (rearward) Velocity standard deviations for each condition
    velc_indvNegN    = [];   % Vector of number of Negative (rearward) Velocities for each condition
    
    % Initialize vectors for velocities treating all worms for a 
    % condition as one big single individual.
    velc_giantWorm    = [];     % Vector of All velocities for condition
    velc_giantWormPos = [];     % Vector of all Positive velocities for condition
    velc_giantWormNeg = [];     % Vector of all Negative velocities for condition
    %----- Statistics -2end-------------------------------------------------
    
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
    
    % Loop over each worm* directory for i'th condition (input directory)
    for j=1:nd   % Through each worm* directory...
        % Extract name of worm* directory
        name = d(j).name;
        
        % clear variables
        clear velc     % Should only need to clear one variable (v4.06)
%         clear amp ampt fingerprint flex fre len     % <--- Only using 'velc'...
%         clear mode phs ptvel theta vel wavelnth

        % Load 'vel' into memory
        load([pd filesep name filesep 'metrics.mat'], 'velc'); % Only load 'velc' (v4.06)
%         load([pd filesep name filesep 'metrics.mat']);  % Why load unnecessary varables???
     




%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
      
        %----- Statistics -3-------------------------------------------------
        % Prepare group statistics:
        % .....all velocities
        velc_indvMean = [velc_indvMean      mean(velc(~isnan(velc))) ];
        velc_indvStd  = [velc_indvStd        std(velc(~isnan(velc))) ];
        velc_indvN    = [velc_indvN    prod(size(velc(~isnan(velc))))]; 
        % .....positive (forward) velocities
        velc_indvPosMean = [velc_indvPosMean      mean(velc(velc>0)) ];
        velc_indvPosStd  = [velc_indvPosStd        std(velc(velc>0)) ];
        velc_indvPosN    = [velc_indvPosN    prod(size(velc(velc>0)))]; 
        % .....negative (rearward) velocities
        velc_indvNegMean = [velc_indvNegMean      mean(velc(velc<0)) ];
        velc_indvNegStd  = [velc_indvNegStd        std(velc(velc<0)) ];
        velc_indvNegN    = [velc_indvNegN    prod(size(velc(velc<0)))]; 
        
        % Print line of statistics for j'th worm of i'th condition
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    wormDirNames(j,:)   ,...
                    velc_indvMean(j)     ,...
                    velc_indvStd(j)      ,...
                    velc_indvN(j)        ,...
                    velc_indvPosMean(j)  ,...
                    velc_indvPosStd(j)   ,...
                    velc_indvPosN(j)     ,...
                    velc_indvNegMean(j)  ,...
                    velc_indvNegStd(j)   ,...
                    velc_indvNegN(j) );
              
                
                
        velc_giantWorm       = [velc_giantWorm        velc(~isnan(velc))];  
        velc_giantWormPos    = [velc_giantWormPos     velc(velc>0)];  
        velc_giantWormNeg    = [velc_giantWormNeg     velc(velc<0)];  
        %----- Statistics -3end-------------------------------------------------
        
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
        
        
    end      % for j=1:nd   % Through each worm* directory...
    
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
    
%----- Statistics -4-------------------------------------------------
%    *************************************************
% conditionOutput = [ vel_indvMean;
%                     vel_indvStd;
%                     vel_indvN;
%                     vel_indvPosMean;
%                     vel_indvPosStd;
%                     vel_indvPosN;
%                     vel_indvNegMean;
%                     vel_indvNegStd;
%                     vel_indvNegN];
%                 
%         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t'...     
%                        '\n'], ...
%                     wormDirNames',...
%                     conditionOutput);
% 
% 
%    *************************************************
   
    
    
    
    
    fprintf(1,'\n\n');    % Force a newline between conditions
   
% % % % %--------                        
% % % % % This is a messy way of solving the single worm handler:                        
% % % % %    if nd == 1
% % % % %        n = [n;nc];      % Adds a second copy of the single worm data
% % % % %    end                  % to allow mean to generate a vector  --  else
% % % % %                         % velhist becomes a scalar
% % % % %    velhist = [velhist; mean(n)];
% % % % %--------  
% % % % % The cleaner way of handling single worms (implemented in v4.06):
% % % %     if nd == 1   % only one worm* directory
% % % %         velhist = [velhist; n];
% % % %     else         % >one worm* directory
% % % %         velhist = [velhist; mean(n)];
% % % %     end
    
    %----- Statistics --------------------------------------------------
    % Vector of Means of each i'th condition treated as a single Giant Worm
    % (all velocities lumped togther, finding group stats here)
    % (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    velc_Mean_giantWorm(i)    = mean(velc_giantWorm(~isnan(velc_giantWorm)));
    velc_STD_giantWorm(i)     = std(velc_giantWorm(~isnan(velc_giantWorm)));
    velc_N_giantWorm(i)       = prod(size(velc_giantWorm(~isnan(velc_giantWorm))));
    %....forward
    velc_Mean_giantWormPos(i) = mean(velc_giantWormPos(~isnan(velc_giantWormPos)));
    velc_STD_giantWormPos(i)  = std(velc_giantWormPos(~isnan(velc_giantWormPos)));
    velc_N_giantWormPos(i)    = prod(size(velc_giantWormPos(~isnan(velc_giantWormPos))));
    %....rearward
    velc_Mean_giantWormNeg(i) = mean(velc_giantWormNeg(~isnan(velc_giantWormNeg)));
    velc_STD_giantWormNeg(i)  = std(velc_giantWormNeg(~isnan(velc_giantWormNeg)));
    velc_N_giantWormNeg(i)    = prod(size(velc_giantWormNeg(~isnan(velc_giantWormNeg))));
    
    % Vector of Mean of Mean Velocities for each i'th condition (one per
    % condition)  (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    velc_Mean_indvMean(i)    = mean(velc_indvMean(~isnan(velc_indvMean)));
    velc_STD_indvMean(i)     = std(velc_indvMean(~isnan(velc_indvMean)));
    velc_N_indvMean(i)       = prod(size(velc_indvMean(~isnan(velc_indvMean))));
    %....forward
    velc_Mean_indvPosMean(i) = mean(velc_indvPosMean(~isnan(velc_indvPosMean)));
    velc_STD_indvPosMean(i)  = std(velc_indvPosMean(~isnan(velc_indvPosMean)));
    velc_N_indvPosMean(i)    = prod(size(velc_indvPosMean(~isnan(velc_indvPosMean))));
    %....rearward
    velc_Mean_indvNegMean(i) = mean(velc_indvNegMean(~isnan(velc_indvNegMean)));
    velc_STD_indvNegMean(i)  = std(velc_indvNegMean(~isnan(velc_indvNegMean)));
    velc_N_indvNegMean(i)    = prod(size(velc_indvNegMean(~isnan(velc_indvNegMean))));
    %----- Statistics -4end-------------------------------------------------

%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
    
   
end     % for i=1:nargin      % Each input directory (condition)


%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************

%----- Statistics -5-------------------------------------------------
%   Print Column Titles before Each Condition:
% Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
conditionplaceholder = char(ones(1,size(legendtext,2))*32);   

%   Print velocity stats for conditions treated as single Giant datasets.
% Title
fprintf(1,'\n---->  Each condition treated as a single GIANT data set\n');
fprintf(1,'CENTROID VELOCITY   [mm/sec]\n',conditionplaceholder);

%   Column Titles
fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
               '\tMeanPOS\t  STD  \t   n   \t:'...
               '\tMeanNEG\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    legendtext(j,:)   ,...
                    velc_Mean_giantWorm(j)  ,...
                    velc_STD_giantWorm(j)  ,...
                    velc_N_giantWorm(j)  ,...
                    velc_Mean_giantWormPos(j)  ,...
                    velc_STD_giantWormPos(j)  ,...
                    velc_N_giantWormPos(j)  ,...
                    velc_Mean_giantWormNeg(j)  ,...
                    velc_STD_giantWormNeg(j)  ,...
                    velc_N_giantWormNeg(j) );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( velc_Mean_giantWorm )      ,...
                    std(  velc_Mean_giantWorm )      ,...
                    size( velc_Mean_giantWorm,2 )    ,...
                        mean( velc_Mean_giantWormPos )   ,...
                        std(  velc_Mean_giantWormPos )   ,...
                        size( velc_Mean_giantWormPos,2 ) ,...
                    mean( velc_Mean_giantWormNeg )   ,...
                    std(  velc_Mean_giantWormNeg )   ,...
                    size( velc_Mean_giantWormNeg,2 ) );
                
                
                
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Print velocity stats for Mean of Means.
% Title
fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
fprintf(1,'CENTROID VELOCITY   [mm/sec]\n',conditionplaceholder);
% fprintf(1,'\nVELOCITY   [mm/sec]  --  Conditions treated as groups of individual worms\n');

%   Column Titles
fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
               '\tMean of\t       \t       \t:'...
               '\tMean of\t       \t       \t '...
               '\n'], conditionplaceholder);
fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
               '\tMeanPOS\t  STD  \t   n   \t:'...
               '\tMeanNEG\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                        legendtext(j,:)   ,...
                    velc_Mean_indvMean(j),...
                    velc_STD_indvMean(j) ,...
                    velc_N_indvMean(j)   ,...
                        velc_Mean_indvPosMean(j) ,...
                        velc_STD_indvPosMean(j)  ,...
                        velc_N_indvPosMean(j)    ,...
                    velc_Mean_indvNegMean(j) ,...
                    velc_STD_indvNegMean(j)  ,...
                    velc_N_indvNegMean(j)    );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( velc_Mean_indvMean )      ,...
                    std(  velc_Mean_indvMean )      ,...
                    size( velc_Mean_indvMean,2 )    ,...
                        mean( velc_Mean_indvPosMean )   ,...
                        std(  velc_Mean_indvPosMean )   ,...
                        size( velc_Mean_indvPosMean,2 ) ,...
                    mean( velc_Mean_indvNegMean )   ,...
                    std(  velc_Mean_indvNegMean )   ,...
                    size( velc_Mean_indvNegMean,2 ) );
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%----- Statistics -5end-------------------------------------------------

%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************
%**************************************************************************







% Housekeeping
clear velc_indvMean      velc_indvStd     velc_indvN
clear velc_indvPosMean   velc_indvPosStd  velc_indvPosN
clear velc_indvNegMean   velc_indvNegStd  velc_indvNegN 
clear velc_giantWorm velc_giantWormPos    velc_giantWormNeg

fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');

















































%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 2 for amplitudes, frequencies and time delays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

segs = [5];
% segs = [1:11];
% segs = [5:2:11];
nsegs = prod(size(segs));

% % % % figure('Position', [310  40  705  655]);
% % % % drawnow;

% % % % % %-----------------------------------------------------------------------------
% % % % % 
% % % % % for j=1:nsegs
% % % % %    
% % % % %    flexhist{1,j} = [];
% % % % %    for i=1:nargin
% % % % %    
% % % % %    	% get contents of each directory
% % % % %    	pd = varargin(i);
% % % % %    	pd = pd{1};
% % % % %    
% % % % % 		d = dir([pd filesep 'worm*']);
% % % % %   		nd = prod(size(d));
% % % % %       
% % % % % 	   % now loop over each item
% % % % %    	n = [];
% % % % %    	for k=1:nd
% % % % %       	% get name of directory
% % % % %       	name = d(k).name;
% % % % %       	% clear variables
% % % % %       clear amp ampt fingerprint flex fre len 
% % % % %       clear mode phs ptvel theta vel wavelnth
% % % % %       	% load in the data
% % % % %          load([pd filesep name filesep 'metrics.mat']);
% % % % %       	% now do the histogram
% % % % %       	nc = hist(flex(:,segs(j)), [0:0.1:pi]); nc = nc / sum(nc);
% % % % %       	n = [n; nc];
% % % % % 	   end
% % % % %        if nd == 1
% % % % %            n = [n;nc];      % Adds a second copy of the single worm data
% % % % %        end                  % to allow mean to generate a vector  --  else
% % % % %                             % flexhist becomes a scalar
% % % % % 
% % % % %       flexhist{1,j} = [flexhist{1,j}; mean(n)];
% % % % %     
% % % % % % % % % %Set up to do the Histogram Chart title
% % % % % % % % %       if j == 2
% % % % % % % % %           axhandle = gca;   % Attaches page "title" to j-1'st (i.e. top left) axis
% % % % % % % % %       end
% % % % % 
% % % % %    end
% % % % %    
% % % % % % % % %    % now plot
% % % % % % % % %    subplot(3,4,j);
% % % % % % % % %    plot([0:0.1:pi], flexhist{1,j},...
% % % % % % % % %        'LineWidth', linewdth);          % Set LineWidth
% % % % % % % % % 
% % % % % % % % %    title(['\theta' int2str(segs(j))], 'FontWeight', 'bold');
% % % % % % % % %    xlabel('flex (rad)', 'FontWeight', 'bold');      
% % % % % % % % %    axis([0 2 0 0.5]);       % Scale axes to existing data (as of 11-07-01)
% % % % % % % % %    axis square;
% % % % % % % % %    set(gca, 'FontWeight', 'bold');
% % % % % % % % %    grid on;
% % % % % % % % %    drawnow;
% % % % %    
% % % % % end



































% now plot frequencies
for k=1:nsegs       % Bends of interest (e.g. bend 5, 7, 9,..., defined as vector above)
   
    
    
%**************************************************************************
%**************************************************************************
%----- Statistics -1-------------------------------------------------
% Initialize vectors for mean of individual worm means for each condition
fre_Mean_indvMean = [];
fre_STD_indvMean = [];
fre_N_indvMean = [];
%-----
fre_Mean_indvPosMean = [];
fre_STD_indvPosMean = [];
fre_N_indvPosMean = [];
%-----
fre_Mean_indvNegMean = [];
fre_STD_indvNegMean = [];
fre_N_indvNegMean = [];
          %-------%-------%
% Initialize vectors for mean of each condition's data lumped together as a
% single GIANT (looooong) worm data set
fre_Mean_giantWorm = [];
fre_STD_giantWorm = [];
fre_N_giantWorm = [];
%-----
fre_Mean_giantWormPos = [];
fre_STD_giantWormPos = [];
fre_N_giantWormPos = [];
%-----
fre_Mean_giantWormNeg = [];
fre_STD_giantWormNeg = [];
fre_N_giantWormNeg = [];
%----- Statistics -1end-------------------------------------------------
%**************************************************************************
%**************************************************************************

    
   for i=1:nargin   % Each input directory (condition)
   
   	% get contents of each directory
   	pd = varargin(i);
   	pd = pd{1};
   
		d = dir([pd filesep 'worm*']);
  		nd = prod(size(d));
        
        
            %**************************************************************************
    %**************************************************************************
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
    placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
    
    % On the first pass:
    % Set up for Statistics output
    if i == 1
        fprintf(1,'\nFREQUECY   [Hz]   --   Bend #%3d\n', segs(k));
%     fprintf(1,'\n\t%s\tVELOCITY   [mm/sec]\n', placeholderstring);
    end

    
    %   Column Titles
    fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
                   '\tMeanFWD\t  STD  \t   n   \t:'...
                   '\tMeanREV\t  STD  \t   n   \t '...
                   '\n'], placeholderstring);
    %----- Statistics --------------------------------------------------
         
% % % %     % Error checking: Verify that parent directory exists and contains worm folders
% % % %     if exist(pd) ~= 7    % if directory does not exist or is not a directory
% % % %         error(['ERROR: Directory ''' pd ''' does not exist!']);
% % % %     elseif nd == 0       % if directory is empty (no worm folders)
% % % %         error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
% % % %     end   
    
    % Print Condition Name (and move to next line line)
    fprintf(1,'%s\n',legendtext(i,:));
   
    
    %----- Statistics --------------------------------------------------
    % for Statistics
    fre_indvMean = [];      % Vector of Mean Velocities for each condition
    fre_indvStd  = [];      % Vector of Velocity standard deviations for each condition
    fre_indvN    = [];      % Vector of number of Velocities for each condition
    %-----
    fre_indvPosMean = [];   % Vector of Mean Positive (forward) Velocities for each condition
    fre_indvPosStd  = [];   % Vector of Positive (forward) Velocity standard deviations for each condition
    fre_indvPosN    = [];   % Vector of number of Positive (forward) Velocities for each condition
    %-----
    fre_indvNegMean = [];   % Vector of Mean Negative (rearward) Velocities for each condition
    fre_indvNegStd  = [];   % Vector of Negative (rearward) Velocity standard deviations for each condition
    fre_indvNegN    = [];   % Vector of number of Negative (rearward) Velocities for each condition
    
    % Initialize vectors for velocities treating all worms for a 
    % condition as one big single individual.
    fre_giantWorm    = [];     % Vector of All velocities for condition
    fre_giantWormPos = [];     % Vector of all Positive velocities for condition
    fre_giantWormNeg = [];     % Vector of all Negative velocities for condition
    %----- Statistics -2end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************

       
          
	% now loop through each worm* directory
   	for j=1:nd      % through each worm* directory
      	% get name of directory
      	name = d(j).name;
      	% clear variables
        clear fre vel
        clear x y mode xp yp xc yc d1 d2
        
      	% load in the data
%         load([pd filesep name filesep 'metrics.mat'], 'fre', 'vel');
        load([pd filesep name filesep 'metrics.mat'], 'fre');
        load([pd filesep name filesep 'data.mat'], 'x', 'y');
        
%---------------------------------------------------------------------
% Determine mode (forward/backward movement)
        xp = x(1:end-1,:);     % Positions at first time ("t1")
        yp = y(1:end-1,:);
        xc = x(2:end,:);       % Positions at second time ("t2")
        yc = y(2:end,:);

        d1 = sqrt( (xp(:,4:end-2)-xc(:,5:end-1)).^2 ... % "Is the back of the 
                 + (yp(:,4:end-2)-yc(:,5:end-1)).^2 );  % worm moving closer to 
        d1 = mean(d1');                                 % the front of the worm?"

        d2 = sqrt( (xp(:,6:end)-xc(:,5:end-1)).^2 ...   % "Is the front of the 
                 + (yp(:,6:end)-yc(:,5:end-1)).^2 );    % worm moving closer to 
        d2 = mean(d2');                                 % the rear of the worm?"

        mode = 2*((d1 < d2)-0.5);   % Forward motion: small d1, large d2
                                    % Backward motion: Large d1, small d2
%---------------------------------------------------------------------
        
        
        % Extract a k'th column of Frequencies
        fre = fre(:,segs(k))';         % Make column into row (for logical comparison with 'mode', nee 'vel')

         
         
         
        %**************************************************************************
        %**************************************************************************
        %----- Statistics -3-------------------------------------------------
        
        % Condition 'vel' 
        %   In TRANSLATION we calculate the i'th Velocity as 
        %       (position(i+1)-position(i)) / (time(i+1)-time(i)).
        %   For n frames there can only be n-1 velocity vectors, but n
        %   track amplitudes and track wavelngths.  In TRACKS we orient the
        %   worm in the i'th frame with the i'th velocity vector, so the
        %   n'th worm has no n'th velocity vector; instead we use the
        %   n-1'th velocity vector to orient the n'th worm for TRACKS.
        %   Following that model, we duplicate the last velocity vector
        %   (the n-1'th) as the n'th velocity, rather than dropping the
        %   n'th track amplitude and wavelength, though that might in fact
        %   be a cleaner way of reaching Nirvana...  This is a long way of
        %   saying:
%         vel = [vel vel(end)];
        mode = [mode mode(end)];

        % Prepare group statistics:
        % .....all velocities
        fre_indvMean = [fre_indvMean      mean(fre(~isnan(fre))) ];
        fre_indvStd  = [fre_indvStd        std(fre(~isnan(fre))) ];
        fre_indvN    = [fre_indvN    prod(size(fre(~isnan(fre))))]; 
        % .....positive (forward) velocities
        fre_indvPosMean = [fre_indvPosMean      mean(fre( ~isnan(fre) & (mode>0) )) ];
        fre_indvPosStd  = [fre_indvPosStd        std(fre( ~isnan(fre) & (mode>0) )) ];
        fre_indvPosN    = [fre_indvPosN    prod(size(fre( ~isnan(fre) & (mode>0) )))]; 
        % .....negative (rearward) velocities
        fre_indvNegMean = [fre_indvNegMean      mean(fre( ~isnan(fre) & (mode<0) )) ];
        fre_indvNegStd  = [fre_indvNegStd        std(fre( ~isnan(fre) & (mode<0) )) ];
        fre_indvNegN    = [fre_indvNegN    prod(size(fre( ~isnan(fre) & (mode<0) )))]; 
        
        % Print line of statistics for j'th worm of i'th condition
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    wormDirNames(j,:)   ,...
                    fre_indvMean(j)     ,...
                    fre_indvStd(j)      ,...
                    fre_indvN(j)        ,...
                    fre_indvPosMean(j)  ,...
                    fre_indvPosStd(j)   ,...
                    fre_indvPosN(j)     ,...
                    fre_indvNegMean(j)  ,...
                    fre_indvNegStd(j)   ,...
                    fre_indvNegN(j) );
              
                
                
        fre_giantWorm       = [fre_giantWorm        fre( ~isnan(fre)           )];  
        fre_giantWormPos    = [fre_giantWormPos     fre( ~isnan(fre) & (mode>0) )];  
        fre_giantWormNeg    = [fre_giantWormNeg     fre( ~isnan(fre) & (mode<0) )];  
        %----- Statistics -3end-------------------------------------------------
        %**************************************************************************
        %**************************************************************************
         
         
         
    end     % for j=1:nd      % through each worm* directory
            
    
    
%**************************************************************************
%**************************************************************************
%----- Statistics -4-------------------------------------------------
%    *************************************************
% conditionOutput = [ fre_indvMean;
%                     fre_indvStd;
%                     fre_indvN;
%                     fre_indvPosMean;
%                     fre_indvPosStd;
%                     fre_indvPosN;
%                     fre_indvNegMean;
%                     fre_indvNegStd;
%                     fre_indvNegN];
%                 
%         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t'...     
%                        '\n'], ...
%                     wormDirNames',...
%                     conditionOutput);
% 
% 
%    *************************************************
   
    
    fprintf(1,'\n\n');    % Force a newline between conditions
   
    
    %----- Statistics --------------------------------------------------
    % Vector of Means of each i'th condition treated as a single Giant Worm
    % (all velocities lumped togther, finding group stats here)
    % (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    fre_Mean_giantWorm(i)    = mean(fre_giantWorm(~isnan(fre_giantWorm)));
    fre_STD_giantWorm(i)     = std(fre_giantWorm(~isnan(fre_giantWorm)));
    fre_N_giantWorm(i)       = prod(size(fre_giantWorm(~isnan(fre_giantWorm))));
    %....forward
    fre_Mean_giantWormPos(i) = mean(fre_giantWormPos(~isnan(fre_giantWormPos)));
    fre_STD_giantWormPos(i)  = std(fre_giantWormPos(~isnan(fre_giantWormPos)));
    fre_N_giantWormPos(i)    = prod(size(fre_giantWormPos(~isnan(fre_giantWormPos))));
    %....rearward
    fre_Mean_giantWormNeg(i) = mean(fre_giantWormNeg(~isnan(fre_giantWormNeg)));
    fre_STD_giantWormNeg(i)  = std(fre_giantWormNeg(~isnan(fre_giantWormNeg)));
    fre_N_giantWormNeg(i)    = prod(size(fre_giantWormNeg(~isnan(fre_giantWormNeg))));
    
    % Vector of Mean of Mean Velocities for each i'th condition (one per
    % condition)  (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    fre_Mean_indvMean(i)    = mean(fre_indvMean(~isnan(fre_indvMean)));
    fre_STD_indvMean(i)     = std(fre_indvMean(~isnan(fre_indvMean)));
    fre_N_indvMean(i)       = prod(size(fre_indvMean(~isnan(fre_indvMean))));
    %....forward
    fre_Mean_indvPosMean(i) = mean(fre_indvPosMean(~isnan(fre_indvPosMean)));
    fre_STD_indvPosMean(i)  = std(fre_indvPosMean(~isnan(fre_indvPosMean)));
    fre_N_indvPosMean(i)    = prod(size(fre_indvPosMean(~isnan(fre_indvPosMean))));
    %....rearward
    fre_Mean_indvNegMean(i) = mean(fre_indvNegMean(~isnan(fre_indvNegMean)));
    fre_STD_indvNegMean(i)  = std(fre_indvNegMean(~isnan(fre_indvNegMean)));
    fre_N_indvNegMean(i)    = prod(size(fre_indvNegMean(~isnan(fre_indvNegMean))));
    %----- Statistics -4end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************
    
    
    
    
   end      % for i=1:nargin   % Each input directory (condition)
   
   
   
%**************************************************************************
%**************************************************************************
%----- Statistics -5-------------------------------------------------
%   Print Column Titles before Each Condition:
% Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
conditionplaceholder = char(ones(1,size(legendtext,2))*32);   

%   Print velocity stats for conditions treated as single Giant datasets.
% Title
fprintf(1,'\n---->  Each condition treated as a single GIANT (looong) data set\n');
fprintf(1,'FREQUENCY   [Hz]\n',conditionplaceholder);

%   Column Titles
fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    legendtext(j,:)   ,...
                    fre_Mean_giantWorm(j)  ,...
                    fre_STD_giantWorm(j)  ,...
                    fre_N_giantWorm(j)  ,...
                    fre_Mean_giantWormPos(j)  ,...
                    fre_STD_giantWormPos(j)  ,...
                    fre_N_giantWormPos(j)  ,...
                    fre_Mean_giantWormNeg(j)  ,...
                    fre_STD_giantWormNeg(j)  ,...
                    fre_N_giantWormNeg(j) );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( fre_Mean_giantWorm )      ,...
                    std(  fre_Mean_giantWorm )      ,...
                    size( fre_Mean_giantWorm,2 )    ,...
                        mean( fre_Mean_giantWormPos )   ,...
                        std(  fre_Mean_giantWormPos )   ,...
                        size( fre_Mean_giantWormPos,2 ) ,...
                    mean( fre_Mean_giantWormNeg )   ,...
                    std(  fre_Mean_giantWormNeg )   ,...
                    size( fre_Mean_giantWormNeg,2 ) );
                
                
                
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Print velocity stats for Mean of Means.
% Title
fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
fprintf(1,'FREQUENCY   [Hz]\n',conditionplaceholder);
% fprintf(1,'\nVELOCITY   [mm/sec]  --  Conditions treated as groups of individual worms\n');

%   Column Titles
fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
               '\tMean of\t       \t       \t:'...
               '\tMean of\t       \t       \t '...
               '\n'], conditionplaceholder);
fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                        legendtext(j,:)   ,...
                    fre_Mean_indvMean(j),...
                    fre_STD_indvMean(j) ,...
                    fre_N_indvMean(j)   ,...
                        fre_Mean_indvPosMean(j) ,...
                        fre_STD_indvPosMean(j)  ,...
                        fre_N_indvPosMean(j)    ,...
                    fre_Mean_indvNegMean(j) ,...
                    fre_STD_indvNegMean(j)  ,...
                    fre_N_indvNegMean(j)    );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( fre_Mean_indvMean )      ,...
                    std(  fre_Mean_indvMean )      ,...
                    size( fre_Mean_indvMean,2 )    ,...
                        mean( fre_Mean_indvPosMean )   ,...
                        std(  fre_Mean_indvPosMean )   ,...
                        size( fre_Mean_indvPosMean,2 ) ,...
                    mean( fre_Mean_indvNegMean )   ,...
                    std(  fre_Mean_indvNegMean )   ,...
                    size( fre_Mean_indvNegMean,2 ) );
% 

%----- Statistics -5end-------------------------------------------------
%**************************************************************************
%**************************************************************************

fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
   
   
   
   

end     % for k=1:nsegs       % Bends of interest (e.g. bend 5, 7, 9,..., defined as vector above)
















% % % % % %-----------------------------------------------------------------------------
% % % % % % now plot time delays
% % % % % delayhist = cell(1, nsegs-1);
% % % % % for j=1:nsegs-1
% % % % %    
% % % % %    delayhist{1,j} = [];
% % % % %    for i=1:nargin
% % % % %    
% % % % % 	   % get contents of each directory
% % % % %    	pd = varargin(i);
% % % % % 	   pd = pd{1};
% % % % %    
% % % % % 		d = dir([pd filesep 'worm*']);
% % % % %   		nd = prod(size(d));
% % % % %       
% % % % % 	   % now loop over each item
% % % % %    	n = [];
% % % % %    	for k=1:nd
% % % % %       	% get name of directory
% % % % %       	name = d(k).name;
% % % % %       	% clear variables
% % % % %       clear amp ampt fingerprint flex fre len 
% % % % %       clear mode phs ptvel theta vel wavelnth
% % % % %          % load in the data
% % % % %          load([pd filesep name filesep 'metrics.mat']);
% % % % %       	% now do the histogram
% % % % %       	nc = hist(phs(:,segs(j)), [-1.5:0.075:1.5]); nc = nc / sum(nc);
% % % % %       	n = [n; nc];
% % % % %     end
% % % % %     if nd == 1
% % % % %         n = [n;nc];      % Adds a second copy of the single worm data
% % % % %     end                  % to allow mean to generate a vector  --  else
% % % % %                          % delayhist becomes a scalar
% % % % %     delayhist{1,j} = [delayhist{1,j}; mean(n)];
% % % % %             
% % % % %    end
% % % % %    
% % % % % % % % %    % now plot
% % % % % % % % %    subplot(3,4,8+j);
% % % % % % % % %    plot([-1.5:0.075:1.5], delayhist{1,j},...
% % % % % % % % %        'LineWidth', linewdth);      % Set LineWidth
% % % % % % % % % 
% % % % % % % % %    title(['\theta' int2str(segs(j)) ' - \theta' int2str(segs(j)+1)],...
% % % % % % % % %        'FontWeight', 'bold');
% % % % % % % % %    xlabel('time delay (s)', 'FontWeight', 'bold');     
% % % % % % % % % %   axis([-2.5 2.5 0 0.75]);
% % % % % % % % %    axis([-.75 1 0 0.75]);           % Scale axes to existing data (as of 11-07-01)
% % % % % % % % %    axis square;
% % % % % % % % %    set(gca, 'FontWeight', 'bold');
% % % % % % % % %    grid on;
% % % % % % % % %    drawnow;
% % % % %    
% % % % % end
% % % % % 
% % % % % 
% % % % % %-----------------------------------------------------------------------------
% % % % % 
% % % % % % % % % set(gcf, 'PaperOrientation', 'Landscape');
% % % % % % % % % set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
% % % % % % % % % pos = -1;
% % % % % % % % % legend(gca, legendtext);
% % % % % % % % % 
% % % % % % % % % set(gcf, 'CurrentAxes', axhandle);
% % % % % % % % % %axes(axhandle);
% % % % % % % % % % text(5.00, 0.64, 'XXX \itC. elegans\rm\bf Histograms for XXX',...
% % % % % % % % % text(5.00, 0.64, [titlePrefix ' \itC. elegans\rm\bf Histograms ' titleSuffix],...
% % % % % % % % %     'FontWeight', 'bold', ...
% % % % % % % % %     'FontSize', figuretitlefontsize,...
% % % % % % % % %     'HorizontalAlignment', 'center');


































































% % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % % Figure 3 for point velocities
% % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % 
% % % % % vertex = [5:1:13];
% % % % % nvertex = prod(size(vertex));
% % % % % 
% % % % % % figure('Position', [290  60  705  655]);
% % % % % % drawnow;
% % % % % 
% % % % % %-----------------------------------------------------------------------------
% % % % % % now plot point velocities
% % % % % ptvelhist = cell(1, nvertex);
% % % % % for j=1:nvertex
% % % % %    
% % % % %    ptvelhist{1,j} = [];
% % % % %    for i=1:nargin
% % % % %    
% % % % %    	% get contents of each directory
% % % % %    	pd = varargin(i);
% % % % %    	pd = pd{1};
% % % % %    
% % % % % 		d = dir([pd filesep 'worm*']);
% % % % %   		nd = prod(size(d));
% % % % %       
% % % % % 	   % now loop over each item
% % % % %    	n = [];
% % % % %    	for k=1:nd
% % % % %       	% get name of directory
% % % % %       	name = d(k).name;
% % % % %       	% clear variables
% % % % %       clear amp ampt fingerprint flex fre len 
% % % % %       clear mode phs ptvel theta vel wavelnth
% % % % %       	% load in the data
% % % % %          load([pd filesep name filesep 'metrics.mat']);
% % % % %       	% now do the histogram
% % % % %       	nc = hist(ptvel(:,vertex(j)), [-3.333 : 0.03333 : 3.333]); 
% % % % %         nc = nc / sum(nc);
% % % % %       	n = [n; nc];
% % % % % 	   end
% % % % %        if nd == 1
% % % % %            n = [n;nc];      % Adds a second copy of the single worm data
% % % % %        end                  % to allow mean to generate a vector  --  else
% % % % %                             % amphist becomes a scalar
% % % % % 
% % % % %       ptvelhist{1,j} = [ptvelhist{1,j}; mean(n)];
% % % % %     
% % % % % % % % % %Set up to do the Histogram Chart title
% % % % % % % % %       if j == 3
% % % % % % % % %           axhandle = gca;
% % % % % % % % %       end
% % % % % 
% % % % %    end
% % % % %    
% % % % % % % % %    % now plot
% % % % % % % % %    subplot(3,3,j);
% % % % % % % % %    plot([-3.333 : 0.03333 : 3.333], ptvelhist{1,j},...
% % % % % % % % %        'LineWidth', linewdth);          % Set LineWidth
% % % % % % % % % 
% % % % % % % % %    title(['Point ' int2str(vertex(j))], 'FontWeight', 'bold');
% % % % % % % % %    if j > 6
% % % % % % % % %        xlabel('Point Velocity (mm/sec)', 'FontWeight', 'bold');      
% % % % % % % % %    end
% % % % % % % % %    axis([-0.6 0.6 0 0.35]);       % Scale axes to existing data (as of 11-07-01)
% % % % % % % % %    axis square;
% % % % % % % % %    set(gca, 'FontWeight', 'bold');
% % % % % % % % %    grid on;
% % % % % % % % %    drawnow;
% % % % %    
% % % % % end
% % % % % 
% % % % % % % % % set(gcf, 'PaperOrientation', 'Landscape');
% % % % % % % % % set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
% % % % % % % % % pos = -1;
% % % % % % % % % legend(gca, legendtext);
% % % % % % % % % 
% % % % % % % % % set(gcf, 'CurrentAxes', axhandle);
% % % % % % % % % % text(0, 0.43, 'XXX \itC. elegans\rm\bf Distribution of Point Velocities for XXX',...
% % % % % % % % % text(0, 0.43, [titlePrefix ' \itC. elegans\rm\bf Distribution of Point Velocities ' titleSuffix],...
% % % % % % % % %     'FontWeight', 'bold', ...
% % % % % % % % %     'FontSize', figuretitlefontsize,...
% % % % % % % % %     'HorizontalAlignment', 'center');
















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 4A for Track Amplitude ____________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%**************************************************************************
%**************************************************************************
%----- Statistics -1-------------------------------------------------
% Initialize vectors for mean of individual worm means for each condition
ampt_Mean_indvMean = [];
ampt_STD_indvMean = [];
ampt_N_indvMean = [];
%-----
ampt_Mean_indvPosMean = [];
ampt_STD_indvPosMean = [];
ampt_N_indvPosMean = [];
%-----
ampt_Mean_indvNegMean = [];
ampt_STD_indvNegMean = [];
ampt_N_indvNegMean = [];
          %-------%-------%
% Initialize vectors for mean of each condition's data lumped together as a
% single GIANT (looooong) worm data set
ampt_Mean_giantWorm = [];
ampt_STD_giantWorm = [];
ampt_N_giantWorm = [];
%-----
ampt_Mean_giantWormPos = [];
ampt_STD_giantWormPos = [];
ampt_N_giantWormPos = [];
%-----
ampt_Mean_giantWormNeg = [];
ampt_STD_giantWormNeg = [];
ampt_N_giantWormNeg = [];
%----- Statistics -1end-------------------------------------------------
%**************************************************************************
%**************************************************************************



for i=1:nargin      % Cycle thru each input directory
   
   % get contents of each directory
   pd = varargin(i);
   pd = pd{1};
   
   d = dir([pd filesep 'worm*']);
   nd = prod(size(d));
   
    
    %**************************************************************************
    %**************************************************************************
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
    placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
    
    % On the first pass:
    % Set up for Statistics output
    if i == 1
        fprintf(1,'\n(JAN''s HALF-WIDTH) TRACK AMPLITUDE   [mm]\n', placeholderstring);
%     fprintf(1,'\n\t%s\tVELOCITY   [mm/sec]\n', placeholderstring);
    end

    
    %   Column Titles
    fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
                   '\tMeanFWD\t  STD  \t   n   \t:'...
                   '\tMeanREV\t  STD  \t   n   \t '...
                   '\n'], placeholderstring);
    %----- Statistics --------------------------------------------------
         
% % % %     % Error checking: Verify that parent directory exists and contains worm folders
% % % %     if exist(pd) ~= 7    % if directory does not exist or is not a directory
% % % %         error(['ERROR: Directory ''' pd ''' does not exist!']);
% % % %     elseif nd == 0       % if directory is empty (no worm folders)
% % % %         error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
% % % %     end   
    
    % Print Condition Name (and move to next line line)
    fprintf(1,'%s\n',legendtext(i,:));
   
    
    %----- Statistics --------------------------------------------------
    % for Statistics
    ampt_indvMean = [];      % Vector of Mean Velocities for each condition
    ampt_indvStd  = [];      % Vector of Velocity standard deviations for each condition
    ampt_indvN    = [];      % Vector of number of Velocities for each condition
    %-----
    ampt_indvPosMean = [];   % Vector of Mean Positive (forward) Velocities for each condition
    ampt_indvPosStd  = [];   % Vector of Positive (forward) Velocity standard deviations for each condition
    ampt_indvPosN    = [];   % Vector of number of Positive (forward) Velocities for each condition
    %-----
    ampt_indvNegMean = [];   % Vector of Mean Negative (rearward) Velocities for each condition
    ampt_indvNegStd  = [];   % Vector of Negative (rearward) Velocity standard deviations for each condition
    ampt_indvNegN    = [];   % Vector of number of Negative (rearward) Velocities for each condition
    
    % Initialize vectors for velocities treating all worms for a 
    % condition as one big single individual.
    ampt_giantWorm    = [];     % Vector of All velocities for condition
    ampt_giantWormPos = [];     % Vector of all Positive velocities for condition
    ampt_giantWormNeg = [];     % Vector of all Negative velocities for condition
    %----- Statistics -2end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************
   
   
   
   
   for j=1:nd       % Cycle thru each worm* folder
      % get name of directory
      name = d(j).name;
      % clear variables
      clear ampt vel
      
      % load in the data
%       load([pd filesep name filesep 'metrics.mat'], 'ampt', 'vel');
      load([pd filesep name filesep 'metrics.mat'], 'ampt');
      load([pd filesep name filesep 'data.mat'], 'x', 'y');
      
      % For Jan Karbowski, scale AMPT by half
      ampt = 0.5 * ampt;
      
%---------------------------------------------------------------------
% Determine mode (forward/backward movement)
        xp = x(1:end-1,:);     % Positions at first time ("t1")
        yp = y(1:end-1,:);
        xc = x(2:end,:);       % Positions at second time ("t2")
        yc = y(2:end,:);

        d1 = sqrt( (xp(:,4:end-2)-xc(:,5:end-1)).^2 ... % "Is the back of the 
                 + (yp(:,4:end-2)-yc(:,5:end-1)).^2 );  % worm moving closer to 
        d1 = mean(d1');                                 % the front of the worm?"

        d2 = sqrt( (xp(:,6:end)-xc(:,5:end-1)).^2 ...   % "Is the front of the 
                 + (yp(:,6:end)-yc(:,5:end-1)).^2 );    % worm moving closer to 
        d2 = mean(d2');                                 % the rear of the worm?"

        mode = 2*((d1 < d2)-0.5);   % Forward motion: small d1, large d2
                                    % Backward motion: Large d1, small d2
%---------------------------------------------------------------------
      
        %**************************************************************************
        %**************************************************************************
        %----- Statistics -3-------------------------------------------------
        
        % Condition 'vel' 
        %   In TRANSLATION we calculate the i'th Velocity as 
        %       (position(i+1)-position(i)) / (time(i+1)-time(i)).
        %   For n frames there can only be n-1 velocity vectors, but n
        %   track amplitudes and track wavelngths.  In TRACKS we orient the
        %   worm in the i'th frame with the i'th velocity vector, so the
        %   n'th worm has no n'th velocity vector; instead we use the
        %   n-1'th velocity vector to orient the n'th worm for TRACKS.
        %   Following that model, we duplicate the last velocity vector
        %   (the n-1'th) as the n'th velocity, rather than dropping the
        %   n'th track amplitude and wavelength, though that might in fact
        %   be a cleaner way of reaching Nirvana...  This is a long way of
        %   saying:
%         vel = [vel vel(end)];
        mode = [mode mode(end)];

        % Prepare group statistics:
        % .....all velocities
        ampt_indvMean = [ampt_indvMean      mean(ampt(~isnan(ampt))) ];
        ampt_indvStd  = [ampt_indvStd        std(ampt(~isnan(ampt))) ];
        ampt_indvN    = [ampt_indvN    prod(size(ampt(~isnan(ampt))))]; 
        % .....positive (forward) velocities
        ampt_indvPosMean = [ampt_indvPosMean      mean(ampt( ~isnan(ampt) & (mode>0) )) ];
        ampt_indvPosStd  = [ampt_indvPosStd        std(ampt( ~isnan(ampt) & (mode>0) )) ];
        ampt_indvPosN    = [ampt_indvPosN    prod(size(ampt( ~isnan(ampt) & (mode>0) )))]; 
        % .....negative (rearward) velocities
        ampt_indvNegMean = [ampt_indvNegMean      mean(ampt( ~isnan(ampt) & (mode<0) )) ];
        ampt_indvNegStd  = [ampt_indvNegStd        std(ampt( ~isnan(ampt) & (mode<0) )) ];
        ampt_indvNegN    = [ampt_indvNegN    prod(size(ampt( ~isnan(ampt) & (mode<0) )))]; 
        
        % Print line of statistics for j'th worm of i'th condition
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    wormDirNames(j,:)   ,...
                    ampt_indvMean(j)     ,...
                    ampt_indvStd(j)      ,...
                    ampt_indvN(j)        ,...
                    ampt_indvPosMean(j)  ,...
                    ampt_indvPosStd(j)   ,...
                    ampt_indvPosN(j)     ,...
                    ampt_indvNegMean(j)  ,...
                    ampt_indvNegStd(j)   ,...
                    ampt_indvNegN(j) );
              
                
                
        ampt_giantWorm       = [ampt_giantWorm        ampt( ~isnan(ampt)           )];  
        ampt_giantWormPos    = [ampt_giantWormPos     ampt( ~isnan(ampt) & (mode>0) )];  
        ampt_giantWormNeg    = [ampt_giantWormNeg     ampt( ~isnan(ampt) & (mode<0) )];  
        %----- Statistics -3end-------------------------------------------------
        %**************************************************************************
        %**************************************************************************

      

   end      % for j=1:nd       % Cycle thru each worm* folder
   
   
   
%**************************************************************************
%**************************************************************************
%----- Statistics -4-------------------------------------------------
%    *************************************************
% conditionOutput = [ ampt_indvMean;
%                     ampt_indvStd;
%                     ampt_indvN;
%                     ampt_indvPosMean;
%                     ampt_indvPosStd;
%                     ampt_indvPosN;
%                     ampt_indvNegMean;
%                     ampt_indvNegStd;
%                     ampt_indvNegN];
%                 
%         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t'...     
%                        '\n'], ...
%                     wormDirNames',...
%                     conditionOutput);
% 
% 
%    *************************************************
   
    
    fprintf(1,'\n\n');    % Force a newline between conditions
   
    
    %----- Statistics --------------------------------------------------
    % Vector of Means of each i'th condition treated as a single Giant Worm
    % (all velocities lumped togther, finding group stats here)
    % (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    ampt_Mean_giantWorm(i)    = mean(ampt_giantWorm(~isnan(ampt_giantWorm)));
    ampt_STD_giantWorm(i)     = std(ampt_giantWorm(~isnan(ampt_giantWorm)));
    ampt_N_giantWorm(i)       = prod(size(ampt_giantWorm(~isnan(ampt_giantWorm))));
    %....forward
    ampt_Mean_giantWormPos(i) = mean(ampt_giantWormPos(~isnan(ampt_giantWormPos)));
    ampt_STD_giantWormPos(i)  = std(ampt_giantWormPos(~isnan(ampt_giantWormPos)));
    ampt_N_giantWormPos(i)    = prod(size(ampt_giantWormPos(~isnan(ampt_giantWormPos))));
    %....rearward
    ampt_Mean_giantWormNeg(i) = mean(ampt_giantWormNeg(~isnan(ampt_giantWormNeg)));
    ampt_STD_giantWormNeg(i)  = std(ampt_giantWormNeg(~isnan(ampt_giantWormNeg)));
    ampt_N_giantWormNeg(i)    = prod(size(ampt_giantWormNeg(~isnan(ampt_giantWormNeg))));
    
    % Vector of Mean of Mean Velocities for each i'th condition (one per
    % condition)  (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    ampt_Mean_indvMean(i)    = mean(ampt_indvMean(~isnan(ampt_indvMean)));
    ampt_STD_indvMean(i)     = std(ampt_indvMean(~isnan(ampt_indvMean)));
    ampt_N_indvMean(i)       = prod(size(ampt_indvMean(~isnan(ampt_indvMean))));
    %....forward
    ampt_Mean_indvPosMean(i) = mean(ampt_indvPosMean(~isnan(ampt_indvPosMean)));
    ampt_STD_indvPosMean(i)  = std(ampt_indvPosMean(~isnan(ampt_indvPosMean)));
    ampt_N_indvPosMean(i)    = prod(size(ampt_indvPosMean(~isnan(ampt_indvPosMean))));
    %....rearward
    ampt_Mean_indvNegMean(i) = mean(ampt_indvNegMean(~isnan(ampt_indvNegMean)));
    ampt_STD_indvNegMean(i)  = std(ampt_indvNegMean(~isnan(ampt_indvNegMean)));
    ampt_N_indvNegMean(i)    = prod(size(ampt_indvNegMean(~isnan(ampt_indvNegMean))));
    %----- Statistics -4end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************
                        
   
end     % for i=1:nargin      % Cycle thru each input directory


%**************************************************************************
%**************************************************************************
%----- Statistics -5-------------------------------------------------
%   Print Column Titles before Each Condition:
% Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
conditionplaceholder = char(ones(1,size(legendtext,2))*32);   

%   Print velocity stats for conditions treated as single Giant datasets.
% Title
fprintf(1,'\n---->  Each condition treated as a single GIANT (looong) data set\n');
fprintf(1,'(JAN''s HALF-WIDTH) TRACK AMPLITUDE   [mm]\n',conditionplaceholder);

%   Column Titles
fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    legendtext(j,:)   ,...
                    ampt_Mean_giantWorm(j)  ,...
                    ampt_STD_giantWorm(j)  ,...
                    ampt_N_giantWorm(j)  ,...
                    ampt_Mean_giantWormPos(j)  ,...
                    ampt_STD_giantWormPos(j)  ,...
                    ampt_N_giantWormPos(j)  ,...
                    ampt_Mean_giantWormNeg(j)  ,...
                    ampt_STD_giantWormNeg(j)  ,...
                    ampt_N_giantWormNeg(j) );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( ampt_Mean_giantWorm )      ,...
                    std(  ampt_Mean_giantWorm )      ,...
                    size( ampt_Mean_giantWorm,2 )    ,...
                        mean( ampt_Mean_giantWormPos )   ,...
                        std(  ampt_Mean_giantWormPos )   ,...
                        size( ampt_Mean_giantWormPos,2 ) ,...
                    mean( ampt_Mean_giantWormNeg )   ,...
                    std(  ampt_Mean_giantWormNeg )   ,...
                    size( ampt_Mean_giantWormNeg,2 ) );
                
                
                
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Print velocity stats for Mean of Means.
% Title
fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
fprintf(1,'(JAN''s HALF-WIDTH) TRACK AMPLITUDE   [mm]\n',conditionplaceholder);
% fprintf(1,'\nVELOCITY   [mm/sec]  --  Conditions treated as groups of individual worms\n');

%   Column Titles
fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
               '\tMean of\t       \t       \t:'...
               '\tMean of\t       \t       \t '...
               '\n'], conditionplaceholder);
fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                        legendtext(j,:)   ,...
                    ampt_Mean_indvMean(j),...
                    ampt_STD_indvMean(j) ,...
                    ampt_N_indvMean(j)   ,...
                        ampt_Mean_indvPosMean(j) ,...
                        ampt_STD_indvPosMean(j)  ,...
                        ampt_N_indvPosMean(j)    ,...
                    ampt_Mean_indvNegMean(j) ,...
                    ampt_STD_indvNegMean(j)  ,...
                    ampt_N_indvNegMean(j)    );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( ampt_Mean_indvMean )      ,...
                    std(  ampt_Mean_indvMean )      ,...
                    size( ampt_Mean_indvMean,2 )    ,...
                        mean( ampt_Mean_indvPosMean )   ,...
                        std(  ampt_Mean_indvPosMean )   ,...
                        size( ampt_Mean_indvPosMean,2 ) ,...
                    mean( ampt_Mean_indvNegMean )   ,...
                    std(  ampt_Mean_indvNegMean )   ,...
                    size( ampt_Mean_indvNegMean,2 ) );
% 

%----- Statistics -5end-------------------------------------------------
%**************************************************************************
%**************************************************************************

fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');






























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 4B for _______________ TRACK WAVELENGTH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%**************************************************************************
%**************************************************************************
%----- Statistics -1-------------------------------------------------
% Initialize vectors for mean of individual worm means for each condition
wavelnth_Mean_indvMean = [];
wavelnth_STD_indvMean = [];
wavelnth_N_indvMean = [];
%-----
wavelnth_Mean_indvPosMean = [];
wavelnth_STD_indvPosMean = [];
wavelnth_N_indvPosMean = [];
%-----
wavelnth_Mean_indvNegMean = [];
wavelnth_STD_indvNegMean = [];
wavelnth_N_indvNegMean = [];
          %-------%-------%
% Initialize vectors for mean of each condition's data lumped together as a
% single GIANT (looooong) worm data set
wavelnth_Mean_giantWorm = [];
wavelnth_STD_giantWorm = [];
wavelnth_N_giantWorm = [];
%-----
wavelnth_Mean_giantWormPos = [];
wavelnth_STD_giantWormPos = [];
wavelnth_N_giantWormPos = [];
%-----
wavelnth_Mean_giantWormNeg = [];
wavelnth_STD_giantWormNeg = [];
wavelnth_N_giantWormNeg = [];
%----- Statistics -1end-------------------------------------------------
%**************************************************************************
%**************************************************************************



for i=1:nargin      % Cycle thru each input directory
   
   % get contents of each directory
   pd = varargin(i);
   pd = pd{1};
   
   d = dir([pd filesep 'worm*']);
   nd = prod(size(d));
   
    
    %**************************************************************************
    %**************************************************************************
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
    placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
    
    % On the first pass:
    % Set up for Statistics output
    if i == 1
        fprintf(1,'\nTRACK WAVELENGTH   [mm]  (less than one mean bodylength)\n', placeholderstring);
%     fprintf(1,'\n\t%s\tVELOCITY   [mm/sec]\n', placeholderstring);
    end

    
    %   Column Titles
    fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
                   '\tMeanFWD\t  STD  \t   n   \t:'...
                   '\tMeanREV\t  STD  \t   n   \t '...
                   '\n'], placeholderstring);
    %----- Statistics --------------------------------------------------
         
% % % %     % Error checking: Verify that parent directory exists and contains worm folders
% % % %     if exist(pd) ~= 7    % if directory does not exist or is not a directory
% % % %         error(['ERROR: Directory ''' pd ''' does not exist!']);
% % % %     elseif nd == 0       % if directory is empty (no worm folders)
% % % %         error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
% % % %     end   
    
    % Print Condition Name (and move to next line line)
    fprintf(1,'%s\n',legendtext(i,:));
   
    
    %----- Statistics --------------------------------------------------
    % for Statistics
    wavelnth_indvMean = [];      % Vector of Mean Velocities for each condition
    wavelnth_indvStd  = [];      % Vector of Velocity standard deviations for each condition
    wavelnth_indvN    = [];      % Vector of number of Velocities for each condition
    %-----
    wavelnth_indvPosMean = [];   % Vector of Mean Positive (forward) Velocities for each condition
    wavelnth_indvPosStd  = [];   % Vector of Positive (forward) Velocity standard deviations for each condition
    wavelnth_indvPosN    = [];   % Vector of number of Positive (forward) Velocities for each condition
    %-----
    wavelnth_indvNegMean = [];   % Vector of Mean Negative (rearward) Velocities for each condition
    wavelnth_indvNegStd  = [];   % Vector of Negative (rearward) Velocity standard deviations for each condition
    wavelnth_indvNegN    = [];   % Vector of number of Negative (rearward) Velocities for each condition
    
    % Initialize vectors for velocities treating all worms for a 
    % condition as one big single individual.
    wavelnth_giantWorm    = [];     % Vector of All velocities for condition
    wavelnth_giantWormPos = [];     % Vector of all Positive velocities for condition
    wavelnth_giantWormNeg = [];     % Vector of all Negative velocities for condition
    %----- Statistics -2end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************
   
   
   
   
   for j=1:nd       % Cycle thru each worm* folder
      % get name of directory
      name = d(j).name;
      % clear variables
      clear wavelnth vel len
      clear x y
      
      % load in the data
%       load([pd filesep name filesep 'metrics.mat'], 'wavelnth', 'vel', 'len');
% %       load([pd filesep name filesep 'metrics.mat'], 'wavelnth', 'vel');
      load([pd filesep name filesep 'metrics.mat'], 'wavelnth', 'len');
      load([pd filesep name filesep 'data.mat'], 'x', 'y');
      
      % calculate mean length for low-pass filter:
      meanlen = mean(len(~isnan(len)));
      
%---------------------------------------------------------------------
% Determine mode (forward/backward movement)
        xp = x(1:end-1,:);     % Positions at first time ("t1")
        yp = y(1:end-1,:);
        xc = x(2:end,:);       % Positions at second time ("t2")
        yc = y(2:end,:);

        d1 = sqrt( (xp(:,4:end-2)-xc(:,5:end-1)).^2 ... % "Is the back of the 
                 + (yp(:,4:end-2)-yc(:,5:end-1)).^2 );  % worm moving closer to 
        d1 = mean(d1');                                 % the front of the worm?"

        d2 = sqrt( (xp(:,6:end)-xc(:,5:end-1)).^2 ...   % "Is the front of the 
                 + (yp(:,6:end)-yc(:,5:end-1)).^2 );    % worm moving closer to 
        d2 = mean(d2');                                 % the rear of the worm?"

        mode = 2*((d1 < d2)-0.5);   % Forward motion: small d1, large d2
                                    % Backward motion: Large d1, small d2
%---------------------------------------------------------------------
      
        %**************************************************************************
        %**************************************************************************
        %----- Statistics -3-------------------------------------------------
        
        % Condition 'vel' 
        %   In TRANSLATION we calculate the i'th Velocity as 
        %       (position(i+1)-position(i)) / (time(i+1)-time(i)).
        %   For n frames there can only be n-1 velocity vectors, but n
        %   track amplitudes and track wavelngths.  In TRACKS we orient the
        %   worm in the i'th frame with the i'th velocity vector, so the
        %   n'th worm has no n'th velocity vector; instead we use the
        %   n-1'th velocity vector to orient the n'th worm for TRACKS.
        %   Following that model, we duplicate the last velocity vector
        %   (the n-1'th) as the n'th velocity, rather than dropping the
        %   n'th track amplitude and wavelength, though that might in fact
        %   be a cleaner way of reaching Nirvana...  This is a long way of
        %   saying:
%         vel = [vel vel(end)];
        mode = [mode mode(end)];

        % Prepare group statistics:
        % .....all velocities
        wavelnth_indvMean = [wavelnth_indvMean      mean(wavelnth(~isnan(wavelnth) & (wavelnth<meanlen))) ];
        wavelnth_indvStd  = [wavelnth_indvStd        std(wavelnth(~isnan(wavelnth) & (wavelnth<meanlen))) ];
        wavelnth_indvN    = [wavelnth_indvN    prod(size(wavelnth(~isnan(wavelnth) & (wavelnth<meanlen))))]; 
        % .....positive (forward) velocities
        wavelnth_indvPosMean = [wavelnth_indvPosMean      mean(wavelnth( ~isnan(wavelnth) & (mode>0) & (wavelnth<meanlen) )) ];
        wavelnth_indvPosStd  = [wavelnth_indvPosStd        std(wavelnth( ~isnan(wavelnth) & (mode>0) & (wavelnth<meanlen) )) ];
        wavelnth_indvPosN    = [wavelnth_indvPosN    prod(size(wavelnth( ~isnan(wavelnth) & (mode>0) & (wavelnth<meanlen) )))]; 
        % .....negative (rearward) velocities
        wavelnth_indvNegMean = [wavelnth_indvNegMean      mean(wavelnth( ~isnan(wavelnth) & (mode<0) & (wavelnth<meanlen) )) ];
        wavelnth_indvNegStd  = [wavelnth_indvNegStd        std(wavelnth( ~isnan(wavelnth) & (mode<0) & (wavelnth<meanlen) )) ];
        wavelnth_indvNegN    = [wavelnth_indvNegN    prod(size(wavelnth( ~isnan(wavelnth) & (mode<0) & (wavelnth<meanlen) )))]; 
        
        % Print line of statistics for j'th worm of i'th condition
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    wormDirNames(j,:)   ,...
                    wavelnth_indvMean(j)     ,...
                    wavelnth_indvStd(j)      ,...
                    wavelnth_indvN(j)        ,...
                    wavelnth_indvPosMean(j)  ,...
                    wavelnth_indvPosStd(j)   ,...
                    wavelnth_indvPosN(j)     ,...
                    wavelnth_indvNegMean(j)  ,...
                    wavelnth_indvNegStd(j)   ,...
                    wavelnth_indvNegN(j) );
              
                
                
        wavelnth_giantWorm       = [wavelnth_giantWorm        wavelnth( ~isnan(wavelnth) & (wavelnth<meanlen)           )];  
        wavelnth_giantWormPos    = [wavelnth_giantWormPos     wavelnth( ~isnan(wavelnth) & (mode>0) & (wavelnth<meanlen) )];  
        wavelnth_giantWormNeg    = [wavelnth_giantWormNeg     wavelnth( ~isnan(wavelnth) & (mode<0) & (wavelnth<meanlen) )];  
        %----- Statistics -3end-------------------------------------------------
        %**************************************************************************
        %**************************************************************************

      

   end      % for j=1:nd       % Cycle thru each worm* folder
   
   
   
%**************************************************************************
%**************************************************************************
%----- Statistics -4-------------------------------------------------
%    *************************************************
% conditionOutput = [ wavelnth_indvMean;
%                     wavelnth_indvStd;
%                     wavelnth_indvN;
%                     wavelnth_indvPosMean;
%                     wavelnth_indvPosStd;
%                     wavelnth_indvPosN;
%                     wavelnth_indvNegMean;
%                     wavelnth_indvNegStd;
%                     wavelnth_indvNegN];
%                 
%         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t'...     
%                        '\n'], ...
%                     wormDirNames',...
%                     conditionOutput);
% 
% 
%    *************************************************
   
    
    fprintf(1,'\n\n');    % Force a newline between conditions
   
    
    %----- Statistics --------------------------------------------------
    % Vector of Means of each i'th condition treated as a single Giant Worm
    % (all velocities lumped togther, finding group stats here)
    % (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    wavelnth_Mean_giantWorm(i)    = mean(wavelnth_giantWorm(~isnan(wavelnth_giantWorm)));
    wavelnth_STD_giantWorm(i)     = std(wavelnth_giantWorm(~isnan(wavelnth_giantWorm)));
    wavelnth_N_giantWorm(i)       = prod(size(wavelnth_giantWorm(~isnan(wavelnth_giantWorm))));
    %....forward
    wavelnth_Mean_giantWormPos(i) = mean(wavelnth_giantWormPos(~isnan(wavelnth_giantWormPos)));
    wavelnth_STD_giantWormPos(i)  = std(wavelnth_giantWormPos(~isnan(wavelnth_giantWormPos)));
    wavelnth_N_giantWormPos(i)    = prod(size(wavelnth_giantWormPos(~isnan(wavelnth_giantWormPos))));
    %....rearward
    wavelnth_Mean_giantWormNeg(i) = mean(wavelnth_giantWormNeg(~isnan(wavelnth_giantWormNeg)));
    wavelnth_STD_giantWormNeg(i)  = std(wavelnth_giantWormNeg(~isnan(wavelnth_giantWormNeg)));
    wavelnth_N_giantWormNeg(i)    = prod(size(wavelnth_giantWormNeg(~isnan(wavelnth_giantWormNeg))));
    
    % Vector of Mean of Mean Velocities for each i'th condition (one per
    % condition)  (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    wavelnth_Mean_indvMean(i)    = mean(wavelnth_indvMean(~isnan(wavelnth_indvMean)));
    wavelnth_STD_indvMean(i)     = std(wavelnth_indvMean(~isnan(wavelnth_indvMean)));
    wavelnth_N_indvMean(i)       = prod(size(wavelnth_indvMean(~isnan(wavelnth_indvMean))));
    %....forward
    wavelnth_Mean_indvPosMean(i) = mean(wavelnth_indvPosMean(~isnan(wavelnth_indvPosMean)));
    wavelnth_STD_indvPosMean(i)  = std(wavelnth_indvPosMean(~isnan(wavelnth_indvPosMean)));
    wavelnth_N_indvPosMean(i)    = prod(size(wavelnth_indvPosMean(~isnan(wavelnth_indvPosMean))));
    %....rearward
    wavelnth_Mean_indvNegMean(i) = mean(wavelnth_indvNegMean(~isnan(wavelnth_indvNegMean)));
    wavelnth_STD_indvNegMean(i)  = std(wavelnth_indvNegMean(~isnan(wavelnth_indvNegMean)));
    wavelnth_N_indvNegMean(i)    = prod(size(wavelnth_indvNegMean(~isnan(wavelnth_indvNegMean))));
    %----- Statistics -4end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************
                        
   
end     % for i=1:nargin      % Cycle thru each input directory


%**************************************************************************
%**************************************************************************
%----- Statistics -5-------------------------------------------------
%   Print Column Titles before Each Condition:
% Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
conditionplaceholder = char(ones(1,size(legendtext,2))*32);   

%   Print velocity stats for conditions treated as single Giant datasets.
% Title
fprintf(1,'\n---->  Each condition treated as a single GIANT (looong) data set\n');
fprintf(1,'TRACK WAVELENGTH   [mm]  (less than one mean bodylength)\n',conditionplaceholder);

%   Column Titles
fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                    legendtext(j,:)   ,...
                    wavelnth_Mean_giantWorm(j)  ,...
                    wavelnth_STD_giantWorm(j)  ,...
                    wavelnth_N_giantWorm(j)  ,...
                    wavelnth_Mean_giantWormPos(j)  ,...
                    wavelnth_STD_giantWormPos(j)  ,...
                    wavelnth_N_giantWormPos(j)  ,...
                    wavelnth_Mean_giantWormNeg(j)  ,...
                    wavelnth_STD_giantWormNeg(j)  ,...
                    wavelnth_N_giantWormNeg(j) );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( wavelnth_Mean_giantWorm )      ,...
                    std(  wavelnth_Mean_giantWorm )      ,...
                    size( wavelnth_Mean_giantWorm,2 )    ,...
                        mean( wavelnth_Mean_giantWormPos )   ,...
                        std(  wavelnth_Mean_giantWormPos )   ,...
                        size( wavelnth_Mean_giantWormPos,2 ) ,...
                    mean( wavelnth_Mean_giantWormNeg )   ,...
                    std(  wavelnth_Mean_giantWormNeg )   ,...
                    size( wavelnth_Mean_giantWormNeg,2 ) );
                
                
                
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Print velocity stats for Mean of Means.
% Title
fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
fprintf(1,'TRACK WAVELENGTH   [mm]  (less than one mean bodylength)\n',conditionplaceholder);
% fprintf(1,'\nVELOCITY   [mm/sec]  --  Conditions treated as groups of individual worms\n');

%   Column Titles
fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
               '\tMean of\t       \t       \t:'...
               '\tMean of\t       \t       \t '...
               '\n'], conditionplaceholder);
fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n'], ...
                        legendtext(j,:)   ,...
                    wavelnth_Mean_indvMean(j),...
                    wavelnth_STD_indvMean(j) ,...
                    wavelnth_N_indvMean(j)   ,...
                        wavelnth_Mean_indvPosMean(j) ,...
                        wavelnth_STD_indvPosMean(j)  ,...
                        wavelnth_N_indvPosMean(j)    ,...
                    wavelnth_Mean_indvNegMean(j) ,...
                    wavelnth_STD_indvNegMean(j)  ,...
                    wavelnth_N_indvNegMean(j)    );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t:'...     
                       '\t%6.3f \t%6.3f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( wavelnth_Mean_indvMean )      ,...
                    std(  wavelnth_Mean_indvMean )      ,...
                    size( wavelnth_Mean_indvMean,2 )    ,...
                        mean( wavelnth_Mean_indvPosMean )   ,...
                        std(  wavelnth_Mean_indvPosMean )   ,...
                        size( wavelnth_Mean_indvPosMean,2 ) ,...
                    mean( wavelnth_Mean_indvNegMean )   ,...
                    std(  wavelnth_Mean_indvNegMean )   ,...
                    size( wavelnth_Mean_indvNegMean,2 ) );
% 

%----- Statistics -5end-------------------------------------------------
%**************************************************************************
%**************************************************************************

fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');



















































































%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 5A for NORMALIZED Track Amplitude ____________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%**************************************************************************
%**************************************************************************
%----- Statistics -1-------------------------------------------------
% Initialize vectors for mean of individual worm means for each condition
norm_ampt_Mean_indvMean = [];
norm_ampt_STD_indvMean = [];
norm_ampt_N_indvMean = [];
%-----
norm_ampt_Mean_indvPosMean = [];
norm_ampt_STD_indvPosMean = [];
norm_ampt_N_indvPosMean = [];
%-----
norm_ampt_Mean_indvNegMean = [];
norm_ampt_STD_indvNegMean = [];
norm_ampt_N_indvNegMean = [];
          %-------%-------%
% Initialize vectors for mean of each condition's data lumped together as a
% single GIANT (looooong) worm data set
norm_ampt_Mean_giantWorm = [];
norm_ampt_STD_giantWorm = [];
norm_ampt_N_giantWorm = [];
%-----
norm_ampt_Mean_giantWormPos = [];
norm_ampt_STD_giantWormPos = [];
norm_ampt_N_giantWormPos = [];
%-----
norm_ampt_Mean_giantWormNeg = [];
norm_ampt_STD_giantWormNeg = [];
norm_ampt_N_giantWormNeg = [];
%----- Statistics -1end-------------------------------------------------
%**************************************************************************
%**************************************************************************



for i=1:nargin      % Cycle thru each input directory
   
   % get contents of each directory
   pd = varargin(i);
   pd = pd{1};
   
   d = dir([pd filesep 'worm*']);
   nd = prod(size(d));
   
    
    %**************************************************************************
    %**************************************************************************
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
    placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
    
    % On the first pass:
    % Set up for Statistics output
    if i == 1
        fprintf(1,'\nLENGTH-NORMALIZED (JAN''s HALF-WIDTH) TRACK AMPLITUDE   [%% mean length]\n', placeholderstring);
%     fprintf(1,'\n\t%s\tVELOCITY   [mm/sec]\n', placeholderstring);
    end

    
    %   Column Titles
    fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
                   '\tMeanFWD\t  STD  \t   n   \t:'...
                   '\tMeanREV\t  STD  \t   n   \t '...
                   '\n'], placeholderstring);
    %----- Statistics --------------------------------------------------
         
% % % %     % Error checking: Verify that parent directory exists and contains worm folders
% % % %     if exist(pd) ~= 7    % if directory does not exist or is not a directory
% % % %         error(['ERROR: Directory ''' pd ''' does not exist!']);
% % % %     elseif nd == 0       % if directory is empty (no worm folders)
% % % %         error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
% % % %     end   
    
    % Print Condition Name (and move to next line line)
    fprintf(1,'%s\n',legendtext(i,:));
   
    
    %----- Statistics --------------------------------------------------
    % for Statistics
    norm_ampt_indvMean = [];      % Vector of Mean Velocities for each condition
    norm_ampt_indvStd  = [];      % Vector of Velocity standard deviations for each condition
    norm_ampt_indvN    = [];      % Vector of number of Velocities for each condition
    %-----
    norm_ampt_indvPosMean = [];   % Vector of Mean Positive (forward) Velocities for each condition
    norm_ampt_indvPosStd  = [];   % Vector of Positive (forward) Velocity standard deviations for each condition
    norm_ampt_indvPosN    = [];   % Vector of number of Positive (forward) Velocities for each condition
    %-----
    norm_ampt_indvNegMean = [];   % Vector of Mean Negative (rearward) Velocities for each condition
    norm_ampt_indvNegStd  = [];   % Vector of Negative (rearward) Velocity standard deviations for each condition
    norm_ampt_indvNegN    = [];   % Vector of number of Negative (rearward) Velocities for each condition
    
    % Initialize vectors for velocities treating all worms for a 
    % condition as one big single individual.
    norm_ampt_giantWorm    = [];     % Vector of All velocities for condition
    norm_ampt_giantWormPos = [];     % Vector of all Positive velocities for condition
    norm_ampt_giantWormNeg = [];     % Vector of all Negative velocities for condition
    %----- Statistics -2end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************
   
   
   
   
   for j=1:nd       % Cycle thru each worm* folder
      % get name of directory
      name = d(j).name;
      % clear variables
      clear ampt len vel
      clear x y
      
      % load in the data
%       load([pd filesep name filesep 'metrics.mat'], 'ampt', 'len', 'vel');
      load([pd filesep name filesep 'metrics.mat'], 'ampt', 'len');
      load([pd filesep name filesep 'data.mat'], 'x', 'y');
      
      % For Jan Karbowski, scale AMPT by half
      ampt = 0.5 * ampt;
      
      
      % Verify that metrics.mat includes *len* variable;
      %   if not, display error message and end job.
      if ~exist('len')
          errortext = ['Worm length data missing ---> Re-run METRICS for ' pd filesep name];
          error(errortext)
      end
      
      % Calculate mean length
      meanlen = mean(len(~isnan(len)));
      
      % Calculate normalized ampt and wavelnth
      norm_ampt     = (    ampt/meanlen)*100;
      
%---------------------------------------------------------------------
% Determine mode (forward/backward movement)
        xp = x(1:end-1,:);     % Positions at first time ("t1")
        yp = y(1:end-1,:);
        xc = x(2:end,:);       % Positions at second time ("t2")
        yc = y(2:end,:);

        d1 = sqrt( (xp(:,4:end-2)-xc(:,5:end-1)).^2 ... % "Is the back of the 
                 + (yp(:,4:end-2)-yc(:,5:end-1)).^2 );  % worm moving closer to 
        d1 = mean(d1');                                 % the front of the worm?"

        d2 = sqrt( (xp(:,6:end)-xc(:,5:end-1)).^2 ...   % "Is the front of the 
                 + (yp(:,6:end)-yc(:,5:end-1)).^2 );    % worm moving closer to 
        d2 = mean(d2');                                 % the rear of the worm?"

        mode = 2*((d1 < d2)-0.5);   % Forward motion: small d1, large d2
                                    % Backward motion: Large d1, small d2
%---------------------------------------------------------------------



      
        %**************************************************************************
        %**************************************************************************
        %----- Statistics -3-------------------------------------------------
        
        % Condition 'vel' 
        %   In TRANSLATION we calculate the i'th Velocity as 
        %       (position(i+1)-position(i)) / (time(i+1)-time(i)).
        %   For n frames there can only be n-1 velocity vectors, but n
        %   track amplitudes and track wavelngths.  In TRACKS we orient the
        %   worm in the i'th frame with the i'th velocity vector, so the
        %   n'th worm has no n'th velocity vector; instead we use the
        %   n-1'th velocity vector to orient the n'th worm for TRACKS.
        %   Following that model, we duplicate the last velocity vector
        %   (the n-1'th) as the n'th velocity, rather than dropping the
        %   n'th track amplitude and wavelength, though that might in fact
        %   be a cleaner way of reaching Nirvana...  This is a long way of
        %   saying:
%         vel = [vel vel(end)];
        mode = [mode mode(end)];

        % Prepare group statistics:
        % .....all velocities
        norm_ampt_indvMean = [norm_ampt_indvMean      mean(norm_ampt(~isnan(norm_ampt))) ];
        norm_ampt_indvStd  = [norm_ampt_indvStd        std(norm_ampt(~isnan(norm_ampt))) ];
        norm_ampt_indvN    = [norm_ampt_indvN    prod(size(norm_ampt(~isnan(norm_ampt))))]; 
        % .....positive (forward) velocities
        norm_ampt_indvPosMean = [norm_ampt_indvPosMean      mean(norm_ampt( ~isnan(norm_ampt) & (mode>0) )) ];
        norm_ampt_indvPosStd  = [norm_ampt_indvPosStd        std(norm_ampt( ~isnan(norm_ampt) & (mode>0) )) ];
        norm_ampt_indvPosN    = [norm_ampt_indvPosN    prod(size(norm_ampt( ~isnan(norm_ampt) & (mode>0) )))]; 
        % .....negative (rearward) velocities
        norm_ampt_indvNegMean = [norm_ampt_indvNegMean      mean(norm_ampt( ~isnan(norm_ampt) & (mode<0) )) ];
        norm_ampt_indvNegStd  = [norm_ampt_indvNegStd        std(norm_ampt( ~isnan(norm_ampt) & (mode<0) )) ];
        norm_ampt_indvNegN    = [norm_ampt_indvNegN    prod(size(norm_ampt( ~isnan(norm_ampt) & (mode<0) )))]; 
        
        % Print line of statistics for j'th worm of i'th condition
        fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n'], ...
                    wormDirNames(j,:)   ,...
                    norm_ampt_indvMean(j)     ,...
                    norm_ampt_indvStd(j)      ,...
                    norm_ampt_indvN(j)        ,...
                    norm_ampt_indvPosMean(j)  ,...
                    norm_ampt_indvPosStd(j)   ,...
                    norm_ampt_indvPosN(j)     ,...
                    norm_ampt_indvNegMean(j)  ,...
                    norm_ampt_indvNegStd(j)   ,...
                    norm_ampt_indvNegN(j) );
              
                
                
        norm_ampt_giantWorm       = [norm_ampt_giantWorm        norm_ampt( ~isnan(norm_ampt)           )];  
        norm_ampt_giantWormPos    = [norm_ampt_giantWormPos     norm_ampt( ~isnan(norm_ampt) & (mode>0) )];  
        norm_ampt_giantWormNeg    = [norm_ampt_giantWormNeg     norm_ampt( ~isnan(norm_ampt) & (mode<0) )];  
        %----- Statistics -3end-------------------------------------------------
        %**************************************************************************
        %**************************************************************************

      

   end      % for j=1:nd       % Cycle thru each worm* folder
   
   
   
%**************************************************************************
%**************************************************************************
%----- Statistics -4-------------------------------------------------
%    *************************************************
% conditionOutput = [ ampt_indvMean;
%                     ampt_indvStd;
%                     ampt_indvN;
%                     ampt_indvPosMean;
%                     ampt_indvPosStd;
%                     ampt_indvPosN;
%                     ampt_indvNegMean;
%                     ampt_indvNegStd;
%                     ampt_indvNegN];
%                 
%         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t'...     
%                        '\n'], ...
%                     wormDirNames',...
%                     conditionOutput);
% 
% 
%    *************************************************
   
    
    fprintf(1,'\n\n');    % Force a newline between conditions
   
    
    %----- Statistics --------------------------------------------------
    % Vector of Means of each i'th condition treated as a single Giant Worm
    % (all velocities lumped togther, finding group stats here)
    % (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    norm_ampt_Mean_giantWorm(i)    = mean(norm_ampt_giantWorm(~isnan(norm_ampt_giantWorm)));
    norm_ampt_STD_giantWorm(i)     = std(norm_ampt_giantWorm(~isnan(norm_ampt_giantWorm)));
    norm_ampt_N_giantWorm(i)       = prod(size(norm_ampt_giantWorm(~isnan(norm_ampt_giantWorm))));
    %....forward
    norm_ampt_Mean_giantWormPos(i) = mean(norm_ampt_giantWormPos(~isnan(norm_ampt_giantWormPos)));
    norm_ampt_STD_giantWormPos(i)  = std(norm_ampt_giantWormPos(~isnan(norm_ampt_giantWormPos)));
    norm_ampt_N_giantWormPos(i)    = prod(size(norm_ampt_giantWormPos(~isnan(norm_ampt_giantWormPos))));
    %....rearward
    norm_ampt_Mean_giantWormNeg(i) = mean(norm_ampt_giantWormNeg(~isnan(norm_ampt_giantWormNeg)));
    norm_ampt_STD_giantWormNeg(i)  = std(norm_ampt_giantWormNeg(~isnan(norm_ampt_giantWormNeg)));
    norm_ampt_N_giantWormNeg(i)    = prod(size(norm_ampt_giantWormNeg(~isnan(norm_ampt_giantWormNeg))));
    
    % Vector of Mean of Mean Velocities for each i'th condition (one per
    % condition)  (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    norm_ampt_Mean_indvMean(i)    = mean(norm_ampt_indvMean(~isnan(norm_ampt_indvMean)));
    norm_ampt_STD_indvMean(i)     = std(norm_ampt_indvMean(~isnan(norm_ampt_indvMean)));
    norm_ampt_N_indvMean(i)       = prod(size(norm_ampt_indvMean(~isnan(norm_ampt_indvMean))));
    %....forward
    norm_ampt_Mean_indvPosMean(i) = mean(norm_ampt_indvPosMean(~isnan(norm_ampt_indvPosMean)));
    norm_ampt_STD_indvPosMean(i)  = std(norm_ampt_indvPosMean(~isnan(norm_ampt_indvPosMean)));
    norm_ampt_N_indvPosMean(i)    = prod(size(norm_ampt_indvPosMean(~isnan(norm_ampt_indvPosMean))));
    %....rearward
    norm_ampt_Mean_indvNegMean(i) = mean(norm_ampt_indvNegMean(~isnan(norm_ampt_indvNegMean)));
    norm_ampt_STD_indvNegMean(i)  = std(norm_ampt_indvNegMean(~isnan(norm_ampt_indvNegMean)));
    norm_ampt_N_indvNegMean(i)    = prod(size(norm_ampt_indvNegMean(~isnan(norm_ampt_indvNegMean))));
    %----- Statistics -4end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************
                        
   
end     % for i=1:nargin      % Cycle thru each input directory


%**************************************************************************
%**************************************************************************
%----- Statistics -5-------------------------------------------------
%   Print Column Titles before Each Condition:
% Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
conditionplaceholder = char(ones(1,size(legendtext,2))*32);   

%   Print velocity stats for conditions treated as single Giant datasets.
% Title
fprintf(1,'\n---->  Each condition treated as a single GIANT (looong) data set\n');
fprintf(1,'LENGTH-NORMALIZED (JAN''s HALF-WIDTH) TRACK AMPLITUDE   [%% mean length]\n',conditionplaceholder);

%   Column Titles
fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n'], ...
                    legendtext(j,:)   ,...
                    norm_ampt_Mean_giantWorm(j)  ,...
                    norm_ampt_STD_giantWorm(j)  ,...
                    norm_ampt_N_giantWorm(j)  ,...
                    norm_ampt_Mean_giantWormPos(j)  ,...
                    norm_ampt_STD_giantWormPos(j)  ,...
                    norm_ampt_N_giantWormPos(j)  ,...
                    norm_ampt_Mean_giantWormNeg(j)  ,...
                    norm_ampt_STD_giantWormNeg(j)  ,...
                    norm_ampt_N_giantWormNeg(j) );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( norm_ampt_Mean_giantWorm )      ,...
                    std(  norm_ampt_Mean_giantWorm )      ,...
                    size( norm_ampt_Mean_giantWorm,2 )    ,...
                        mean( norm_ampt_Mean_giantWormPos )   ,...
                        std(  norm_ampt_Mean_giantWormPos )   ,...
                        size( norm_ampt_Mean_giantWormPos,2 ) ,...
                    mean( norm_ampt_Mean_giantWormNeg )   ,...
                    std(  norm_ampt_Mean_giantWormNeg )   ,...
                    size( norm_ampt_Mean_giantWormNeg,2 ) );
                
                
                
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Print velocity stats for Mean of Means.
% Title
fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
fprintf(1,'LENGTH-NORMALIZED (JAN''s HALF-WIDTH) TRACK AMPLITUDE   [%% mean length]\n',conditionplaceholder);
% fprintf(1,'\nVELOCITY   [mm/sec]  --  Conditions treated as groups of individual worms\n');

%   Column Titles
fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
               '\tMean of\t       \t       \t:'...
               '\tMean of\t       \t       \t '...
               '\n'], conditionplaceholder);
fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n'], ...
                        legendtext(j,:)   ,...
                    norm_ampt_Mean_indvMean(j),...
                    norm_ampt_STD_indvMean(j) ,...
                    norm_ampt_N_indvMean(j)   ,...
                        norm_ampt_Mean_indvPosMean(j) ,...
                        norm_ampt_STD_indvPosMean(j)  ,...
                        norm_ampt_N_indvPosMean(j)    ,...
                    norm_ampt_Mean_indvNegMean(j) ,...
                    norm_ampt_STD_indvNegMean(j)  ,...
                    norm_ampt_N_indvNegMean(j)    );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( norm_ampt_Mean_indvMean )      ,...
                    std(  norm_ampt_Mean_indvMean )      ,...
                    size( norm_ampt_Mean_indvMean,2 )    ,...
                        mean( norm_ampt_Mean_indvPosMean )   ,...
                        std(  norm_ampt_Mean_indvPosMean )   ,...
                        size( norm_ampt_Mean_indvPosMean,2 ) ,...
                    mean( norm_ampt_Mean_indvNegMean )   ,...
                    std(  norm_ampt_Mean_indvNegMean )   ,...
                    size( norm_ampt_Mean_indvNegMean,2 ) );
% 

%----- Statistics -5end-------------------------------------------------
%**************************************************************************
%**************************************************************************

fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');




























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 5B for NORMALIZED Track Wavelength
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%**************************************************************************
%**************************************************************************
%----- Statistics -1-------------------------------------------------
% Initialize vectors for mean of individual worm means for each condition
norm_wavelnth_Mean_indvMean = [];
norm_wavelnth_STD_indvMean = [];
norm_wavelnth_N_indvMean = [];
%-----
norm_wavelnth_Mean_indvPosMean = [];
norm_wavelnth_STD_indvPosMean = [];
norm_wavelnth_N_indvPosMean = [];
%-----
norm_wavelnth_Mean_indvNegMean = [];
norm_wavelnth_STD_indvNegMean = [];
norm_wavelnth_N_indvNegMean = [];
          %-------%-------%
% Initialize vectors for mean of each condition's data lumped together as a
% single GIANT (looooong) worm data set
norm_wavelnth_Mean_giantWorm = [];
norm_wavelnth_STD_giantWorm = [];
norm_wavelnth_N_giantWorm = [];
%-----
norm_wavelnth_Mean_giantWormPos = [];
norm_wavelnth_STD_giantWormPos = [];
norm_wavelnth_N_giantWormPos = [];
%-----
norm_wavelnth_Mean_giantWormNeg = [];
norm_wavelnth_STD_giantWormNeg = [];
norm_wavelnth_N_giantWormNeg = [];
%----- Statistics -1end-------------------------------------------------
%**************************************************************************
%**************************************************************************



for i=1:nargin      % Cycle thru each input directory
   
   % get contents of each directory
   pd = varargin(i);
   pd = pd{1};
   
   d = dir([pd filesep 'worm*']);
   nd = prod(size(d));
   
    
    %**************************************************************************
    %**************************************************************************
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
    placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
    
    % On the first pass:
    % Set up for Statistics output
    if i == 1
        fprintf(1,'\nLENGTH-NORMALIZED TRACK WAVELENGTH   [%% mean length]   (less than 100%% mean bodylength)\n', placeholderstring);
%     fprintf(1,'\n\t%s\tVELOCITY   [mm/sec]\n', placeholderstring);
    end

    
    %   Column Titles
    fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
                   '\tMeanFWD\t  STD  \t   n   \t:'...
                   '\tMeanREV\t  STD  \t   n   \t '...
                   '\n'], placeholderstring);
    %----- Statistics --------------------------------------------------
         
% % % %     % Error checking: Verify that parent directory exists and contains worm folders
% % % %     if exist(pd) ~= 7    % if directory does not exist or is not a directory
% % % %         error(['ERROR: Directory ''' pd ''' does not exist!']);
% % % %     elseif nd == 0       % if directory is empty (no worm folders)
% % % %         error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
% % % %     end   
    
    % Print Condition Name (and move to next line line)
    fprintf(1,'%s\n',legendtext(i,:));
   
    
    %----- Statistics --------------------------------------------------
    % for Statistics
    norm_wavelnth_indvMean = [];      % Vector of Mean Velocities for each condition
    norm_wavelnth_indvStd  = [];      % Vector of Velocity standard deviations for each condition
    norm_wavelnth_indvN    = [];      % Vector of number of Velocities for each condition
    %-----
    norm_wavelnth_indvPosMean = [];   % Vector of Mean Positive (forward) Velocities for each condition
    norm_wavelnth_indvPosStd  = [];   % Vector of Positive (forward) Velocity standard deviations for each condition
    norm_wavelnth_indvPosN    = [];   % Vector of number of Positive (forward) Velocities for each condition
    %-----
    norm_wavelnth_indvNegMean = [];   % Vector of Mean Negative (rearward) Velocities for each condition
    norm_wavelnth_indvNegStd  = [];   % Vector of Negative (rearward) Velocity standard deviations for each condition
    norm_wavelnth_indvNegN    = [];   % Vector of number of Negative (rearward) Velocities for each condition
    
    % Initialize vectors for velocities treating all worms for a 
    % condition as one big single individual.
    norm_wavelnth_giantWorm    = [];     % Vector of All velocities for condition
    norm_wavelnth_giantWormPos = [];     % Vector of all Positive velocities for condition
    norm_wavelnth_giantWormNeg = [];     % Vector of all Negative velocities for condition
    %----- Statistics -2end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************
   
   
   
   
   for j=1:nd       % Cycle thru each worm* folder
      % get name of directory
      name = d(j).name;
      % clear variables
      clear wavelnth len vel
      clear x y
      
      % load in the data
%       load([pd filesep name filesep 'metrics.mat'], 'wavelnth', 'len', 'vel');
      load([pd filesep name filesep 'metrics.mat'], 'wavelnth', 'len');
      load([pd filesep name filesep 'data.mat'], 'x', 'y');
      
      % Verify that metrics.mat includes *len* variable;
      %   if not, display error message and end job.
      if ~exist('len')
          errortext = ['Worm length data missing ---> Re-run METRICS for ' pd filesep name];
          error(errortext)
      end
      
      % Calculate mean length
      meanlen = mean(len(~isnan(len)));
      
      % Calculate normalized ampt and wavelnth
      norm_wavelnth = (wavelnth/meanlen)*100;
      
%---------------------------------------------------------------------
% Determine mode (forward/backward movement)
        xp = x(1:end-1,:);     % Positions at first time ("t1")
        yp = y(1:end-1,:);
        xc = x(2:end,:);       % Positions at second time ("t2")
        yc = y(2:end,:);

        d1 = sqrt( (xp(:,4:end-2)-xc(:,5:end-1)).^2 ... % "Is the back of the 
                 + (yp(:,4:end-2)-yc(:,5:end-1)).^2 );  % worm moving closer to 
        d1 = mean(d1');                                 % the front of the worm?"

        d2 = sqrt( (xp(:,6:end)-xc(:,5:end-1)).^2 ...   % "Is the front of the 
                 + (yp(:,6:end)-yc(:,5:end-1)).^2 );    % worm moving closer to 
        d2 = mean(d2');                                 % the rear of the worm?"

        mode = 2*((d1 < d2)-0.5);   % Forward motion: small d1, large d2
                                    % Backward motion: Large d1, small d2
%---------------------------------------------------------------------



      
        %**************************************************************************
        %**************************************************************************
        %----- Statistics -3-------------------------------------------------
        
        % Condition 'vel' 
        %   In TRANSLATION we calculate the i'th Velocity as 
        %       (position(i+1)-position(i)) / (time(i+1)-time(i)).
        %   For n frames there can only be n-1 velocity vectors, but n
        %   track amplitudes and track wavelngths.  In TRACKS we orient the
        %   worm in the i'th frame with the i'th velocity vector, so the
        %   n'th worm has no n'th velocity vector; instead we use the
        %   n-1'th velocity vector to orient the n'th worm for TRACKS.
        %   Following that model, we duplicate the last velocity vector
        %   (the n-1'th) as the n'th velocity, rather than dropping the
        %   n'th track amplitude and wavelength, though that might in fact
        %   be a cleaner way of reaching Nirvana...  This is a long way of
        %   saying:
%         vel = [vel vel(end)];
        mode = [mode mode(end)];

        % Prepare group statistics:
        % .....all velocities
        norm_wavelnth_indvMean = [norm_wavelnth_indvMean      mean(norm_wavelnth(~isnan(norm_wavelnth) & (norm_wavelnth < 100))) ];
        norm_wavelnth_indvStd  = [norm_wavelnth_indvStd        std(norm_wavelnth(~isnan(norm_wavelnth) & (norm_wavelnth < 100))) ];
        norm_wavelnth_indvN    = [norm_wavelnth_indvN    prod(size(norm_wavelnth(~isnan(norm_wavelnth) & (norm_wavelnth < 100))))]; 
        % .....positive (forward) velocities
        norm_wavelnth_indvPosMean = [norm_wavelnth_indvPosMean      mean(norm_wavelnth( ~isnan(norm_wavelnth) & (mode>0) & (norm_wavelnth < 100) )) ];
        norm_wavelnth_indvPosStd  = [norm_wavelnth_indvPosStd        std(norm_wavelnth( ~isnan(norm_wavelnth) & (mode>0) & (norm_wavelnth < 100) )) ];
        norm_wavelnth_indvPosN    = [norm_wavelnth_indvPosN    prod(size(norm_wavelnth( ~isnan(norm_wavelnth) & (mode>0) & (norm_wavelnth < 100) )))]; 
        % .....negative (rearward) velocities
        norm_wavelnth_indvNegMean = [norm_wavelnth_indvNegMean      mean(norm_wavelnth( ~isnan(norm_wavelnth) & (mode<0) & (norm_wavelnth < 100) )) ];
        norm_wavelnth_indvNegStd  = [norm_wavelnth_indvNegStd        std(norm_wavelnth( ~isnan(norm_wavelnth) & (mode<0) & (norm_wavelnth < 100) )) ];
        norm_wavelnth_indvNegN    = [norm_wavelnth_indvNegN    prod(size(norm_wavelnth( ~isnan(norm_wavelnth) & (mode<0) & (norm_wavelnth < 100) )))]; 
        
        % Print line of statistics for j'th worm of i'th condition
        fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n'], ...
                    wormDirNames(j,:)   ,...
                    norm_wavelnth_indvMean(j)     ,...
                    norm_wavelnth_indvStd(j)      ,...
                    norm_wavelnth_indvN(j)        ,...
                    norm_wavelnth_indvPosMean(j)  ,...
                    norm_wavelnth_indvPosStd(j)   ,...
                    norm_wavelnth_indvPosN(j)     ,...
                    norm_wavelnth_indvNegMean(j)  ,...
                    norm_wavelnth_indvNegStd(j)   ,...
                    norm_wavelnth_indvNegN(j) );
              
                
                
        norm_wavelnth_giantWorm       = [norm_wavelnth_giantWorm        norm_wavelnth( ~isnan(norm_wavelnth)           & (norm_wavelnth < 100) )];  
        norm_wavelnth_giantWormPos    = [norm_wavelnth_giantWormPos     norm_wavelnth( ~isnan(norm_wavelnth) & (mode>0) & (norm_wavelnth < 100) )];  
        norm_wavelnth_giantWormNeg    = [norm_wavelnth_giantWormNeg     norm_wavelnth( ~isnan(norm_wavelnth) & (mode<0) & (norm_wavelnth < 100) )];  
        %----- Statistics -3end-------------------------------------------------
        %**************************************************************************
        %**************************************************************************

      

   end      % for j=1:nd       % Cycle thru each worm* folder
   
   
   
%**************************************************************************
%**************************************************************************
%----- Statistics -4-------------------------------------------------
%    *************************************************
% conditionOutput = [ wavelnth_indvMean;
%                     wavelnth_indvStd;
%                     wavelnth_indvN;
%                     wavelnth_indvPosMean;
%                     wavelnth_indvPosStd;
%                     wavelnth_indvPosN;
%                     wavelnth_indvNegMean;
%                     wavelnth_indvNegStd;
%                     wavelnth_indvNegN];
%                 
%         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t:'...     
%                        '\t%6.3f \t%6.3f \t%6d\t'...     
%                        '\n'], ...
%                     wormDirNames',...
%                     conditionOutput);
% 
% 
%    *************************************************
   
    
    fprintf(1,'\n\n');    % Force a newline between conditions
   
    
    %----- Statistics --------------------------------------------------
    % Vector of Means of each i'th condition treated as a single Giant Worm
    % (all velocities lumped togther, finding group stats here)
    % (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    norm_wavelnth_Mean_giantWorm(i)    = mean(norm_wavelnth_giantWorm(~isnan(norm_wavelnth_giantWorm)));
    norm_wavelnth_STD_giantWorm(i)     = std(norm_wavelnth_giantWorm(~isnan(norm_wavelnth_giantWorm)));
    norm_wavelnth_N_giantWorm(i)       = prod(size(norm_wavelnth_giantWorm(~isnan(norm_wavelnth_giantWorm))));
    %....forward
    norm_wavelnth_Mean_giantWormPos(i) = mean(norm_wavelnth_giantWormPos(~isnan(norm_wavelnth_giantWormPos)));
    norm_wavelnth_STD_giantWormPos(i)  = std(norm_wavelnth_giantWormPos(~isnan(norm_wavelnth_giantWormPos)));
    norm_wavelnth_N_giantWormPos(i)    = prod(size(norm_wavelnth_giantWormPos(~isnan(norm_wavelnth_giantWormPos))));
    %....rearward
    norm_wavelnth_Mean_giantWormNeg(i) = mean(norm_wavelnth_giantWormNeg(~isnan(norm_wavelnth_giantWormNeg)));
    norm_wavelnth_STD_giantWormNeg(i)  = std(norm_wavelnth_giantWormNeg(~isnan(norm_wavelnth_giantWormNeg)));
    norm_wavelnth_N_giantWormNeg(i)    = prod(size(norm_wavelnth_giantWormNeg(~isnan(norm_wavelnth_giantWormNeg))));
    
    % Vector of Mean of Mean Velocities for each i'th condition (one per
    % condition)  (ONLY FOR ACTUAL VALUES - exclude NaN's):
    %....All
    norm_wavelnth_Mean_indvMean(i)    = mean(norm_wavelnth_indvMean(~isnan(norm_wavelnth_indvMean)));
    norm_wavelnth_STD_indvMean(i)     = std(norm_wavelnth_indvMean(~isnan(norm_wavelnth_indvMean)));
    norm_wavelnth_N_indvMean(i)       = prod(size(norm_wavelnth_indvMean(~isnan(norm_wavelnth_indvMean))));
    %....forward
    norm_wavelnth_Mean_indvPosMean(i) = mean(norm_wavelnth_indvPosMean(~isnan(norm_wavelnth_indvPosMean)));
    norm_wavelnth_STD_indvPosMean(i)  = std(norm_wavelnth_indvPosMean(~isnan(norm_wavelnth_indvPosMean)));
    norm_wavelnth_N_indvPosMean(i)    = prod(size(norm_wavelnth_indvPosMean(~isnan(norm_wavelnth_indvPosMean))));
    %....rearward
    norm_wavelnth_Mean_indvNegMean(i) = mean(norm_wavelnth_indvNegMean(~isnan(norm_wavelnth_indvNegMean)));
    norm_wavelnth_STD_indvNegMean(i)  = std(norm_wavelnth_indvNegMean(~isnan(norm_wavelnth_indvNegMean)));
    norm_wavelnth_N_indvNegMean(i)    = prod(size(norm_wavelnth_indvNegMean(~isnan(norm_wavelnth_indvNegMean))));
    %----- Statistics -4end-------------------------------------------------
    %**************************************************************************
    %**************************************************************************
                        
   
end     % for i=1:nargin      % Cycle thru each input directory


%**************************************************************************
%**************************************************************************
%----- Statistics -5-------------------------------------------------
%   Print Column Titles before Each Condition:
% Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
conditionplaceholder = char(ones(1,size(legendtext,2))*32);   

%   Print velocity stats for conditions treated as single Giant datasets.
% Title
fprintf(1,'\n---->  Each condition treated as a single GIANT (looong) data set\n');
fprintf(1,'LENGTH-NORMALIZED TRACK WAVELENGTH   [%% mean length]   (less than 100%% mean bodylength)\n',conditionplaceholder);

%   Column Titles
fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n'], ...
                    legendtext(j,:)   ,...
                    norm_wavelnth_Mean_giantWorm(j)  ,...
                    norm_wavelnth_STD_giantWorm(j)  ,...
                    norm_wavelnth_N_giantWorm(j)  ,...
                    norm_wavelnth_Mean_giantWormPos(j)  ,...
                    norm_wavelnth_STD_giantWormPos(j)  ,...
                    norm_wavelnth_N_giantWormPos(j)  ,...
                    norm_wavelnth_Mean_giantWormNeg(j)  ,...
                    norm_wavelnth_STD_giantWormNeg(j)  ,...
                    norm_wavelnth_N_giantWormNeg(j) );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( norm_wavelnth_Mean_giantWorm )      ,...
                    std(  norm_wavelnth_Mean_giantWorm )      ,...
                    size( norm_wavelnth_Mean_giantWorm,2 )    ,...
                        mean( norm_wavelnth_Mean_giantWormPos )   ,...
                        std(  norm_wavelnth_Mean_giantWormPos )   ,...
                        size( norm_wavelnth_Mean_giantWormPos,2 ) ,...
                    mean( norm_wavelnth_Mean_giantWormNeg )   ,...
                    std(  norm_wavelnth_Mean_giantWormNeg )   ,...
                    size( norm_wavelnth_Mean_giantWormNeg,2 ) );
                
                
                
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Print velocity stats for Mean of Means.
% Title
fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
fprintf(1,'LENGTH-NORMALIZED TRACK WAVELENGTH   [%% mean length]   (less than 100%% mean bodylength)\n',conditionplaceholder);
% fprintf(1,'\nVELOCITY   [mm/sec]  --  Conditions treated as groups of individual worms\n');

%   Column Titles
fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
               '\tMean of\t       \t       \t:'...
               '\tMean of\t       \t       \t '...
               '\n'], conditionplaceholder);
fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
               '\tMeanFWD\t  STD  \t   n   \t:'...
               '\tMeanREV\t  STD  \t   n   \t '...
               '\n'], conditionplaceholder);
% Rows of data
for j = 1:nargin
        fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n'], ...
                        legendtext(j,:)   ,...
                    norm_wavelnth_Mean_indvMean(j),...
                    norm_wavelnth_STD_indvMean(j) ,...
                    norm_wavelnth_N_indvMean(j)   ,...
                        norm_wavelnth_Mean_indvPosMean(j) ,...
                        norm_wavelnth_STD_indvPosMean(j)  ,...
                        norm_wavelnth_N_indvPosMean(j)    ,...
                    norm_wavelnth_Mean_indvNegMean(j) ,...
                    norm_wavelnth_STD_indvNegMean(j)  ,...
                    norm_wavelnth_N_indvNegMean(j)    );
end     % for j = 1:nargin
fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% Mean of means:
fprintf(1,'\t   Inter-population Means:\n');
fprintf(1,['\t%s\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t:'...     
                       '\t%6.1f \t%6.1f \t%6d\t'...     
                       '\n\n'], ...
                        conditionplaceholder            ,...
                    mean( norm_wavelnth_Mean_indvMean )      ,...
                    std(  norm_wavelnth_Mean_indvMean )      ,...
                    size( norm_wavelnth_Mean_indvMean,2 )    ,...
                        mean( norm_wavelnth_Mean_indvPosMean )   ,...
                        std(  norm_wavelnth_Mean_indvPosMean )   ,...
                        size( norm_wavelnth_Mean_indvPosMean,2 ) ,...
                    mean( norm_wavelnth_Mean_indvNegMean )   ,...
                    std(  norm_wavelnth_Mean_indvNegMean )   ,...
                    size( norm_wavelnth_Mean_indvNegMean,2 ) );
% 

%----- Statistics -5end-------------------------------------------------
%**************************************************************************
%**************************************************************************

fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
fprintf(1,'%s-------------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  And, finally, the wrap-up...   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Resore warning state to that prior to running this function
warning(originalwarningstate);

return;




% NB: Old, outdated stuff saved below for reference...--|
%                                                       |
%                                                       |
%                                                       V








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5


% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % Figure 5 for NORMALIZED Track Amplitude & Wavelength
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % (Same as Figure 4, but normalizing each worm's data to 
% % % % its mean length)
% % % 
% % % 
% % % 
% % % %**************************************************************************
% % % %**************************************************************************
% % % %----- Statistics -1-------------------------------------------------
% % % % Initialize vectors for mean of individual worm means for each condition
% % % norm_ampt_Mean_indvMean = [];
% % % norm_ampt_STD_indvMean = [];
% % % norm_ampt_N_indvMean = [];
% % % %-----
% % % norm_wavelnth_Mean_indvMean = [];
% % % norm_wavelnth_STD_indvMean = [];
% % % norm_wavelnth_N_indvMean = [];
% % %           %-------%-------%
% % % % Initialize vectors for mean of each condition's data lumped together as a
% % % % single GIANT worm data set
% % % norm_ampt_Mean_giantWorm = [];
% % % norm_ampt_STD_giantWorm = [];
% % % norm_ampt_N_giantWorm = [];
% % % %-----
% % % norm_wavelnth_Mean_giantWorm = [];
% % % norm_wavelnth_STD_giantWorm = [];
% % % norm_wavelnth_N_giantWorm = [];
% % % %----- Statistics -1end-------------------------------------------------
% % % %**************************************************************************
% % % %**************************************************************************
% % % 
% % % 
% % % % % % % % ctrs = [0:0.005:1];
% % % % % % % % ctrs_ampt = [0:0.010:1];
% % % % % % % ctrs_ampt_norm = [0:1:100];
% % % % % % % trackamphist_norm = [];
% % % 
% % % % % % % % ctrs = [0:0.020:4];
% % % % % % % % ctrs = [0:0.040:4];
% % % % % % % ctrs_wavelnth_norm = [0:5:400];
% % % % % % % wavelnthhist_norm = [];
% % % 
% % % for i=1:nargin      % Cycle thru each input directory
% % %    
% % %    % get contents of each directory
% % %    pd = varargin(i);
% % %    pd = pd{1};
% % %    
% % %    d = dir([pd filesep 'worm*']);
% % %    nd = prod(size(d));
% % %    
% % %    
% % %     %**************************************************************************
% % %     %**************************************************************************
% % %     %----- Statistics -2-------------------------------------------------
% % %     % Remember worm* names & convert into useable format
% % %     wormDirNames = {};
% % %     for g = 1:nd
% % %         wormDirNames{g} = d(g).name;
% % %     end
% % %     wormDirNames = {str2mat(wormDirNames)};   % Convert string arrays to single cell array
% % %     wormDirNames = wormDirNames{1};   % Convert single cell array to matrix of characters
% % % 
% % %     %   Print Column Titles before Each Condition:
% % %     % Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
% % %     placeholderstring = char(ones(1,size(wormDirNames,2))*32);   
% % %     
% % %     % On the first pass:
% % %     % Set up for Statistics output
% % %     if i == 1
% % %     fprintf(1,['\n\t%s\tLENGTH NORMALIZED     \t:'...
% % %                      '\tLENGTH NORMALIZED     \t'...
% % %                      '\n'], placeholderstring);
% % %     fprintf(1,[  '\t%s\t TRACK AMPLITUDE      \t:'...
% % %                      '\t TRACK WAVELENGTH     \t'...
% % %                      '\n'], placeholderstring);
% % %     fprintf(1,[  '\t%s\t   [%% mean length]    \t:'...
% % %                      '\t   [%% mean length]    \t'...
% % %                      '\n'], placeholderstring);
% % %     end
% % % 
% % %     
% % %     %   Column Titles
% % %     fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
% % %                    '\t Mean  \t  STD  \t   n   \t '...
% % %                    '\n'], placeholderstring);
% % %     %----- Statistics --------------------------------------------------
% % %          
% % %     % Error checking: Verify that parent directory exists and contains worm folders
% % %     if exist(pd) ~= 7    % if directory does not exist or is not a directory
% % %         error(['ERROR: Directory ''' pd ''' does not exist!']);
% % %     elseif nd == 0       % if directory is empty (no worm folders)
% % %         error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
% % %     end   
% % %     
% % %     % Print Condition Name (and move to next line line)
% % %     fprintf(1,'%s\n',legendtext(i,:));
% % %    
% % %     
% % %     %----- Statistics --------------------------------------------------
% % %     % for Statistics
% % %     norm_ampt_indvMean = [];      % Vector of Mean Velocities for each condition
% % %     norm_ampt_indvStd  = [];      % Vector of Velocity standard deviations for each condition
% % %     norm_ampt_indvN    = [];      % Vector of number of Velocities for each condition
% % %     %-----
% % %     norm_wavelnth_indvMean = [];      % Vector of Mean Velocities for each condition
% % %     norm_wavelnth_indvStd  = [];      % Vector of Velocity standard deviations for each condition
% % %     norm_wavelnth_indvN    = [];      % Vector of number of Velocities for each condition
% % %     
% % %     % Initialize vectors for velocities treating all worms for a 
% % %     % condition as one big single individual.
% % %     norm_ampt_giantWorm    = [];     % Vector of All velocities for condition
% % %     norm_wavelnth_giantWorm    = [];     % Vector of All velocities for condition
% % %     %----- Statistics -2end-------------------------------------------------
% % %     %**************************************************************************
% % %     %**************************************************************************
% % %    
% % %    
% % %    
% % % % % %    % now loop over each item
% % % % % % %    n = [];
% % % % % %    n_ampt_norm = [];
% % % % % %    n_wavelnth_norm = [];
% % %    
% % %    for j=1:nd   % Cycles thru all worm* directories...
% % %       % get name of directory
% % %       name = d(j).name;
% % %       % clear variables
% % %       clear ampt wavelnth len
% % %       % load in the data
% % %       load([pd filesep name filesep 'metrics.mat'], 'ampt', 'wavelnth', 'len');
% % %       
% % %       % Verify that metrics.mat includes *len* variable;
% % %       %   if not, display error message and end job.
% % %       if ~exist('len')
% % %           errortext = ['Worm length data missing ---> Re-run METRICS for ' pd filesep name];
% % %           error(errortext)
% % %       end
% % %       
% % %       % Calculate mean length
% % %       meanlen = mean(len(~isnan(len)));
% % %       
% % %       % Calculate normalized ampt and wavelnth
% % %       norm_ampt     = (    ampt/meanlen)*100;
% % %       norm_wavelnth = (wavelnth/meanlen)*100;
% % %       
% % %       
% % %         %**************************************************************************
% % %         %**************************************************************************
% % %         %----- Statistics -3-------------------------------------------------
% % %         % Prepare group statistics:
% % %         % .....all velocities
% % %         norm_ampt_indvMean = [norm_ampt_indvMean      mean(norm_ampt(~isnan(norm_ampt))) ];
% % %         norm_ampt_indvStd  = [norm_ampt_indvStd        std(norm_ampt(~isnan(norm_ampt))) ];
% % %         norm_ampt_indvN    = [norm_ampt_indvN    prod(size(norm_ampt(~isnan(norm_ampt))))]; 
% % %         % .....all velocities
% % %         norm_wavelnth_indvMean = [norm_wavelnth_indvMean      mean(norm_wavelnth(~isnan(norm_wavelnth))) ];
% % %         norm_wavelnth_indvStd  = [norm_wavelnth_indvStd        std(norm_wavelnth(~isnan(norm_wavelnth))) ];
% % %         norm_wavelnth_indvN    = [norm_wavelnth_indvN    prod(size(norm_wavelnth(~isnan(norm_wavelnth))))]; 
% % %         
% % %         % Print line of statistics for j'th worm of i'th condition
% % %         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
% % %                        '\t%6.3f \t%6.3f \t%6d\t'...     
% % %                        '\n'], ...
% % %                     wormDirNames(j,:)   ,...
% % %                     norm_ampt_indvMean(j)     ,...
% % %                     norm_ampt_indvStd(j)      ,...
% % %                     norm_ampt_indvN(j)        ,...
% % %                     norm_wavelnth_indvMean(j)     ,...
% % %                     norm_wavelnth_indvStd(j)      ,...
% % %                     norm_wavelnth_indvN(j) );
% % %               
% % %                 
% % %                 
% % %         norm_ampt_giantWorm       = [norm_ampt_giantWorm        norm_ampt(~isnan(norm_ampt))];  
% % %         norm_wavelnth_giantWorm       = [norm_wavelnth_giantWorm        norm_wavelnth(~isnan(norm_wavelnth))];  
% % %         %----- Statistics -3end-------------------------------------------------
% % %         %**************************************************************************
% % %         %**************************************************************************
% % %       
% % %       
% % % 
% % %       
% % % % % % %       % Generate the histograms from LENGTH-NORMALIZED vectors
% % % % % % %       %    ampt:
% % % % % % %       nc_ampt_norm = hist( ((ampt/meanlen)*100), ctrs_ampt_norm); 
% % % % % % %         nc_ampt_norm = nc_ampt_norm / sum(nc_ampt_norm);
% % % % % % %       n_ampt_norm = [n_ampt_norm; nc_ampt_norm];
% % % % % % %       
% % % % % % %       %    wavelnth:
% % % % % % %       nc_wavelnth_norm = hist( ((wavelnth/meanlen)*100), ctrs_wavelnth_norm); 
% % % % % % %         nc_wavelnth_norm = nc_wavelnth_norm / sum(nc_wavelnth_norm);
% % % % % % %       n_wavelnth_norm = [n_wavelnth_norm; nc_wavelnth_norm];
% % %    end      % for j
% % %    
% % % % % % %    if nd == 1
% % % % % % %        % Adds a second copy of the single worm data
% % % % % % %        % to allow mean to generate a vector  --  else
% % % % % % %        % histogram becomes a scalar
% % % % % % %        n_ampt_norm = [n_ampt_norm; nc_ampt_norm];      
% % % % % % %        n_wavelnth_norm = [n_wavelnth_norm; nc_wavelnth_norm];      
% % % % % % %    end                  
% % % 
% % % 
% % % 
% % % %**************************************************************************
% % % %**************************************************************************
% % % %----- Statistics -4-------------------------------------------------
% % % %    *************************************************
% % % % conditionOutput = [ vel_indvMean;
% % % %                     vel_indvStd;
% % % %                     vel_indvN;
% % % %                     vel_indvPosMean;
% % % %                     vel_indvPosStd;
% % % %                     vel_indvPosN;
% % % %                     vel_indvNegMean;
% % % %                     vel_indvNegStd;
% % % %                     vel_indvNegN];
% % % %                 
% % % %         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
% % % %                        '\t%6.3f \t%6.3f \t%6d\t:'...     
% % % %                        '\t%6.3f \t%6.3f \t%6d\t'...     
% % % %                        '\n'], ...
% % % %                     wormDirNames',...
% % % %                     conditionOutput);
% % % % 
% % % % 
% % % %    *************************************************
% % %    
% % %     
% % %     
% % %     
% % %     
% % %     fprintf(1,'\n\n');    % Force a newline between conditions
% % %    
% % % % % % % %--------                        
% % % % % % % % This is a messy way of solving the single worm handler:                        
% % % % % % % %    if nd == 1
% % % % % % % %        n = [n;nc];      % Adds a second copy of the single worm data
% % % % % % % %    end                  % to allow mean to generate a vector  --  else
% % % % % % % %                         % velhist becomes a scalar
% % % % % % % %    velhist = [velhist; mean(n)];
% % % % % % % %--------  
% % % % % % % % The cleaner way of handling single worms (implemented in v4.06):
% % % % % % %     if nd == 1   % only one worm* directory
% % % % % % %         velhist = [velhist; n];
% % % % % % %     else         % >one worm* directory
% % % % % % %         velhist = [velhist; mean(n)];
% % % % % % %     end
% % %     
% % %     %----- Statistics --------------------------------------------------
% % %     % Vector of Means of each i'th condition treated as a single Giant Worm
% % %     % (all velocities lumped togther, finding group stats here)
% % %     % (ONLY FOR ACTUAL VALUES - exclude NaN's):
% % %     %....All
% % %     norm_ampt_Mean_giantWorm(i)    = mean(norm_ampt_giantWorm(~isnan(norm_ampt_giantWorm)));
% % %     norm_ampt_STD_giantWorm(i)     = std(norm_ampt_giantWorm(~isnan(norm_ampt_giantWorm)));
% % %     norm_ampt_N_giantWorm(i)       = prod(size(norm_ampt_giantWorm(~isnan(norm_ampt_giantWorm))));
% % %     %....All
% % %     norm_wavelnth_Mean_giantWorm(i)    = mean(norm_wavelnth_giantWorm(~isnan(norm_wavelnth_giantWorm)));
% % %     norm_wavelnth_STD_giantWorm(i)     = std(norm_wavelnth_giantWorm(~isnan(norm_wavelnth_giantWorm)));
% % %     norm_wavelnth_N_giantWorm(i)       = prod(size(norm_wavelnth_giantWorm(~isnan(norm_wavelnth_giantWorm))));
% % %     
% % %     % Vector of Mean of Mean Velocities for each i'th condition (one per
% % %     % condition)  (ONLY FOR ACTUAL VALUES - exclude NaN's):
% % %     %....All
% % %     norm_ampt_Mean_indvMean(i)    = mean(norm_ampt_indvMean(~isnan(norm_ampt_indvMean)));
% % %     norm_ampt_STD_indvMean(i)     = std(norm_ampt_indvMean(~isnan(norm_ampt_indvMean)));
% % %     norm_ampt_N_indvMean(i)       = prod(size(norm_ampt_indvMean(~isnan(norm_ampt_indvMean))));
% % %     %....All
% % %     norm_wavelnth_Mean_indvMean(i)    = mean(norm_wavelnth_indvMean(~isnan(norm_wavelnth_indvMean)));
% % %     norm_wavelnth_STD_indvMean(i)     = std(norm_wavelnth_indvMean(~isnan(norm_wavelnth_indvMean)));
% % %     norm_wavelnth_N_indvMean(i)       = prod(size(norm_wavelnth_indvMean(~isnan(norm_wavelnth_indvMean))));
% % %     %----- Statistics -4end-------------------------------------------------
% % %     %**************************************************************************
% % %     %**************************************************************************
% % % 
% % % 
% % % 
% % % % % % %    trackamphist_norm = [trackamphist_norm; mean(n_ampt_norm)];
% % % % % % %    wavelnthhist_norm = [wavelnthhist_norm; mean(n_wavelnth_norm)];
% % %    
% % % end
% % % 
% % % 
% % % 
% % % %**************************************************************************
% % % %**************************************************************************
% % % %----- Statistics -5-------------------------------------------------
% % % %   Print Column Titles before Each Condition:
% % % % Create place-holder string of ' 's (ASCII 32) same width as wormDirNames
% % % conditionplaceholder = char(ones(1,size(legendtext,2))*32);   
% % % 
% % % %   Print velocity stats for conditions treated as single Giant datasets.
% % % % Title
% % % fprintf(1,'\n---->  Each condition treated as a single GIANT (looong) data set\n');
% % % % % % % fprintf(1,['\t%s\tTRACK AMPLITUDE   [mm]\t:'...
% % % % % % %               '\tTRACK WAVELENGTH  [mm]\t '...
% % % % % % %               '\n'],conditionplaceholder);
% % % fprintf(1,[  '\t%s\tLENGTH NORMALIZED     \t:'...
% % %                  '\tLENGTH NORMALIZED     \t'...
% % %                  '\n'], conditionplaceholder);
% % % fprintf(1,[  '\t%s\t TRACK AMPLITUDE      \t:'...
% % %                  '\t TRACK WAVELENGTH     \t'...
% % %                  '\n'], conditionplaceholder);
% % % fprintf(1,[  '\t%s\t   [%% mean length]    \t:'...
% % %                  '\t   [%% mean length]    \t'...
% % %                  '\n'], conditionplaceholder);
% % %       
% % %       
% % %       
% % %       
% % % %   Column Titles
% % % fprintf(1,['\t%s\t Mean  \t  STD  \t   n   \t:'...     
% % %                '\t Mean  \t  STD  \t   n   \t '...
% % %                '\n'], conditionplaceholder);
% % % % Rows of data
% % % for j = 1:nargin
% % %         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
% % %                        '\t%6.3f \t%6.3f \t%6d\t'...     
% % %                        '\n'], ...
% % %                     legendtext(j,:)   ,...
% % %                     norm_ampt_Mean_giantWorm(j)  ,...
% % %                     norm_ampt_STD_giantWorm(j)  ,...
% % %                     norm_ampt_N_giantWorm(j)  ,...
% % %                     norm_wavelnth_Mean_giantWorm(j)  ,...
% % %                     norm_wavelnth_STD_giantWorm(j)  ,...
% % %                     norm_wavelnth_N_giantWorm(j) );
% % % end     % for j = 1:nargin
% % % fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% % % % Mean of means:
% % % fprintf(1,'\t   Inter-population Means:\n');
% % % fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
% % %                        '\t%6.3f \t%6.3f \t%6d\t'...     
% % %                        '\n\n'], ...
% % %                         conditionplaceholder            ,...
% % %                     mean( norm_ampt_Mean_giantWorm )      ,...
% % %                     std(  norm_ampt_Mean_giantWorm )      ,...
% % %                     size( norm_ampt_Mean_giantWorm,2 )    ,...
% % %                         mean( norm_wavelnth_Mean_giantWorm )   ,...
% % %                         std(  norm_wavelnth_Mean_giantWorm )   ,...
% % %                         size( norm_wavelnth_Mean_giantWorm,2 ) );
% % %                 
% % %                 
% % %                 
% % %                 
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %   Print velocity stats for Mean of Means.
% % % % Title
% % % fprintf(1,'\n---->  Conditions treated as Groups of Individual worms\n');
% % % % % % % fprintf(1,['\t%s\tTRACK AMPLITUDE   [mm]\t:'...
% % % % % % %               '\tTRACK WAVELENGTH  [mm]\t '...
% % % % % % %               '\n'],conditionplaceholder);
% % % fprintf(1,[  '\t%s\tLENGTH NORMALIZED     \t:'...
% % %                  '\tLENGTH NORMALIZED     \t'...
% % %                  '\n'], conditionplaceholder);
% % % fprintf(1,[  '\t%s\t TRACK AMPLITUDE      \t:'...
% % %                  '\t TRACK WAVELENGTH     \t'...
% % %                  '\n'], conditionplaceholder);
% % % fprintf(1,[  '\t%s\t   [%% mean length]    \t:'...
% % %                  '\t   [%% mean length]    \t'...
% % %                  '\n'], conditionplaceholder);
% % % 
% % % %   Column Titles
% % % fprintf(1,['\t%s\tMean of\t       \t       \t:'...     
% % %                '\tMean of\t       \t       \t '...
% % %                '\n'], conditionplaceholder);
% % % fprintf(1,['\t%s\t Means \t  STD  \t   n   \t:'...     
% % %                '\t Means \t  STD  \t   n   \t '...
% % %                '\n'], conditionplaceholder);
% % % % Rows of data
% % % for j = 1:nargin
% % %         fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
% % %                        '\t%6.3f \t%6.3f \t%6d\t'...     
% % %                        '\n'], ...
% % %                         legendtext(j,:)   ,...
% % %                     norm_ampt_Mean_indvMean(j),...
% % %                     norm_ampt_STD_indvMean(j) ,...
% % %                     norm_ampt_N_indvMean(j)   ,...
% % %                         norm_wavelnth_Mean_indvMean(j) ,...
% % %                         norm_wavelnth_STD_indvMean(j)  ,...
% % %                         norm_wavelnth_N_indvMean(j)    );
% % % end     % for j = 1:nargin
% % % fprintf(1,'\t%s---------------------------------------------------------------------------------\n',ones(1,size(legendtext,2))*'-');
% % % % Mean of means:
% % % fprintf(1,'\t   Inter-population Means:\n');
% % % fprintf(1,['\t%s\t%6.3f \t%6.3f \t%6d\t:'...     
% % %                        '\t%6.3f \t%6.3f \t%6d\t'...     
% % %                        '\n\n'], ...
% % %                         conditionplaceholder            ,...
% % %                     mean( norm_ampt_Mean_indvMean )      ,...
% % %                     std(  norm_ampt_Mean_indvMean )      ,...
% % %                     size( norm_ampt_Mean_indvMean,2 )    ,...
% % %                         mean( norm_wavelnth_Mean_indvMean )   ,...
% % %                         std(  norm_wavelnth_Mean_indvMean )   ,...
% % %                         size( norm_wavelnth_Mean_indvMean,2 ) );
% % % % 
% % % 
% % % %----- Statistics -5end-------------------------------------------------
% % % %**************************************************************************
% % % %**************************************************************************
% % % 
% % % 
% % % 
% % % % % % % %------------------------------------------------------------------------
% % % % % % % % Plot histograms
% % % % % % % %   Track Amplitude
% % % % % % % subplot(2,1,1);         % Top 
% % % % % % % % plot(ctrs, trackamphist,...
% % % % % % % plot(ctrs_ampt_norm, trackamphist_norm,...
% % % % % % %     'LineWidth', linewdth)   % Set LineWidth 
% % % % % % % grid on;            
% % % % % % % % axis([0,0.6,0,0.15]);
% % % % % % % axis([0,60,0,0.15]);
% % % % % % % title([titlePrefix ' \itC. elegans\rm\bf Distribution of Length-Normalized Track Amplitudes ' titleSuffix],...
% % % % % % %     'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% % % % % % % xlabel('Track Amplitude (% body length)', 'FontWeight', 'bold');
% % % % % % % set(gca, 'FontWeight', 'bold');
% % % % % % % drawnow
% % % % % % % 
% % % % % % % %   Track Wavelength
% % % % % % % subplot(2,1,2);         % Bottom half of page
% % % % % % % % plot(ctrs, wavelnthhist,...
% % % % % % % plot(ctrs_wavelnth_norm, wavelnthhist_norm,...
% % % % % % %     'LineWidth', linewdth)   % Set LineWidth 
% % % % % % % grid on;
% % % % % % % % axis([0,2.5,0,0.3]);
% % % % % % % axis([0,250,0,0.3]);
% % % % % % % title('\bf Distribution of Length-Normalized Track Wavelengths',...
% % % % % % %     'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% % % % % % % xlabel('Track Wavelength (% body length)', 'FontWeight', 'bold');
% % % % % % % drawnow
% % % % % % % 
% % % % % % % % Format output for printer
% % % % % % % set(gcf, 'PaperOrientation', 'Landscape');
% % % % % % % set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
% % % % % % % set(gca, 'FontWeight', 'bold');
% % % % % % % pos = 1;
% % % % % % % legend(gca, legendtext, pos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

