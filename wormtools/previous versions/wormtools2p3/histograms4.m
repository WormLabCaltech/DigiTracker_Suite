function [velhist, flexhist, frehist, delayhist, ...
        ptvelhist, trackamphist, wavelnthhist, velc_hist] = histograms4(varargin)

%HISTOGRAMS4    Generate histograms of worm movement metrics.
%   FORMAT: histograms4(varargin)
%      where 
%      - "varargin" are the names of data folders for 
%         for comparison with each other.  Each folder must 
%         contain subfolders named worm* (where * is an integer),
%         which subsequently each contain a file called 'metrics'
%         (containing matrices of x & y coordinate data).
%
%   example:  histograms4('C:\Jane-AVD\Arsenite\N2',...
%                         'C:\Jane-AVD\Arsenite\cat-4',...
%                         'C:\Jane-AVD\Arsenite\NL130');
%   (To view head-to-head comparison of 'N2', 'cat-4', and 'NL130'.)
%
%   Displays six charts of histograms:
%   1) Depicting the distribution of mean of velocities along worm's
%      serpentine path. (Mean point velocity of points 5 through end.)
%   1a) Depicting the distribution of "centroid" velocities 
%      (movement of mean position of points 5 through end).
%   2) Depicting the distribution of flex (maximum - minimum bend
%      angle during a range of time), bending frequencies, and 
%      time delays for adjacent bends to move through the same 
%      bend angle as the previous bend.  Displays flex and frequency 
%      for bends 5, 7, 9 and 11; displays time delay for bend pairs 
%      5/6, 7/8 and 9/10.
%   3) Depicting the distribution of point velocities (speed of 
%      a point along a worm's serpentine path).
%   4) Depicting distributions of Track Amplitude (width of a
%      bounding box surrounding worm) and Track Wavelength (the
%      instantaneous wormtrack wavelength).
%   5) Depicting distributions of NORMALIZED Track Amplitude 
%      (width of a bounding box surrounding worm expressed as a
%      percent of worm body length) and NORMALIZED Track Wavelength 
%      (the instantaneous wormtrack wavelength expressed as a 
%      percent of worm body length) 
%   
%   ALTERNATE FORMAT: 
%   [velhist, flexhist, frehist, delayhist, ...
%       ptvelhist, trackamphist, wavelnthhist, velc_hist] = histograms4(varargin)
%      where each of the ___hist variables are vectors or arrays of 
%      histogram data for velocity, amplitude,... etc.

%   C. J. Cronin 7-24-02
%   Revised 
%   $Revision: 4.07 $  $Date: 2006/07/28 xx:xx:xx $
% 
% r4.07: Adds population sizes to legend automatically.  Adds label
%   '(Proportion of animals)' to the y-axis of histograms.
%
% r4.06: Adds sixth figure displaying CENTROID VELOCITY ('VELC'); we 
%   realized that the original 'VEL' is ~Actually~ the Mean of the 
%   Point Velocities of points 5:end.  Oops.  Changed '\' to 'filesep'
%   where appropriate for portability to non-Windows platforms.  Cleaned
%   up routines for handling single worm data sets during histogram
%   preparation.  Cleaned up legend and title input routines.
%   Dated 7/14/04 1:57AM.
% 
% r4.05: Adds fifth figure displaying Track Amplitude and Track
%   Wavelength NORMALIZED TO EACH WORM'S MEAN LENGTH.  Improves 
%   automatic generation of legend text.  Revises help information.
%   Dated 5/22/03 4:21PM.
%
% r4.04: Adds dialog boxes to configure chart titles and legends.
%   Corrects fourth figure's "Track Wavelength" title, eliminating
%   the unnecessary "for XXX" text.
%   Dated 2/20/03 3:14PM.
% 
% r4.03: Adds fourth figure displaying Track Amplitude and Track
%   Wavelength.  Changes second plot to display Flex instead of
%   Amplitude.  Adds a check to verify that each input directory
%   contains worm* folders.  Revises help information.
%   Dated 2/03/03 10:25AM.
%   
% r4.02: Adds help information.  Adds revision history.  Adds
%   comments.  
%   Dated 9/03/02 5:22PM.
%
% r4.01: Adds third figure displaying point velocity histograms.
%   Dated 5/31/02 5:03PM.
%   
% r3.03: Allows histograms to handle n=1.
%   Dated 2/08/02 12:35PM.
%   
% r3.02: Customized version of histograms3x 2.01 to print special
%   titles for Aldicarb.
%   Dated 1/31/02 3:04PM.
%   
% r3.01: Corrects scale for 3-minute recording.  (Was set for 
%   10-minute recording.)  Standardizes figure positions on paper.
%   NOTE: Skipping r2.01 because files are actually named ...3x
%   Dated 11/13/01 4:16PM.
% 
% r1.02: Positions figures.
%   9/24/01 10:43AM.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note:  This version of Histograms is modified to scale
% the Instantaneous Velocity, Frequency, and Time Delay
% histograms by a factor of 1/3 to correct for a tradition of 
% using a scaling factor that was too big.  The modified version
% of Histograms allows the shape of new plots to match the shape
% of corresponding previously-created plots, but with the correct
% (scaled) values displayed.
% 
% The details...
% Historically, function Metrics has been run using a ScF factor
% (that is, Seconds per Frame) of "600/# frames," disregarding
% the actual recording time.  "600" would correspond to 
% the number of seconds in a 10 minute recording (10min * 60 sec/min); 
% for a typical 3 minute recording the ScF should be "180/# frames" 
% (where 180 = 3 minutes * 60 seconds/min).  This is the "0.3" 
% (i.e. 0.3 = 180/600) scaling difference that this version of 
% Histograms intends to correct.
% 
% All velocities, for example, previously reported by Metrics would 
% be 0.3 of their actual, true values because of using an ScF of
% "600/..." instead of "180/...".  Simply changing the Scf scaling 
% factor supplied to Metrics (to "180/...") forces Metrics to report 
% the actual, true values of velocity, frequency, and time delay, 
% but the plot shapes displayed by an un-modified-Histograms are
% much more jagged because the number of "bins" used by the "hist"
% function in Histograms are proportionally 0.3x the size of the 
% velocity, etc., data being displayed, so 1/(0.3)x more peaks are
% displayed by corresponding histograms.  This version of Histograms
% corrects for this by altering the number of "bins" for velocity,
% frequency, and time delay by the 0.3 factor.
% 
% Version 3x2 adds capability to display histograms for a condition
% where n=1.  (Previous versions would not display curves for n=1.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Jagan Srinivasan 15th June 2004 
%this is formatting for MACINTOSH using filesep instead of \
% works fine on the mac !!!!! 


% some error checking
if nargout > 8      % ...if too many output arguments
    error('FORMAT: histograms4(directory1, directory2, ....)');   
end

if nargin < 1        % ...if too few input arguments
    error('FORMAT: histograms4(directory1, directory2, ....)');     
end

% Initialize Variables
linewdth = 3;
figuretitlefontsize = 14;

%---------------------------------------------------------------
% Prompt for the chart TITLE information:
prompt = {['Enter chart title information in the form:                             ';...
            '                                                                       ';...
            '       ''XXX C. elegans Distribution of [metric] FOR YYY  --  MM/DD/YY'' ';...
            '                                                                       ';...
            'where                                                                  ';...
            '   ''XXX...''  is:                                                       '],...
        'and  ''...FOR YYY''   is:'};
dlg_title = 'Chart title information';
num_lines = 1;      
def = {' ',' '};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)      % In case user presses cancel
    return
    %     answer = def;       % use the default text
end

titlePrefix = answer{1};
titleSuffix = answer{2};

%---------------------------------------------------------------
% Prompt for the chart LEGEND text:
%this is formatting for macintosh using filesep instead of \
% Jagan Srinivasan 15th June 2004

prompt = 'Enter chart legend information:';
dlg_title = 'Chart legend information';
num_lines= nargin;

for i = 1:num_lines
    directory = varargin(i);
    directory = directory{1};
    delimiter_positions = findstr(filesep, directory);
    
    % Trim off trailing '\'s (if any)
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
    return
    %     answer = def;       % use the default text
end

legendtext = answer{1};
if size(legendtext, 1) < nargin
    error(['ERROR:  Please enter exactly ' int2str(nargin) ' conditions for the legend']);
end
legendtext = legendtext(1:nargin,:);

% Convert back to String Array for further annotation...
legendtext = cellstr(legendtext);
%---------------------------------------------------------------



% % % % %---------------------------------------------------------------
% % % % % Prompt for the chart LEGEND text:
% % % % prompt = 'Enter chart legend information:';
% % % % dlg_title = 'Chart legend information';
% % % % num_lines= nargin;
% % % % for i = 1:num_lines
% % % %     defaulttext{i} = ['condition' int2str(i)];
% % % % end
% % % % def = {str2mat(defaulttext)};
% % % % answer  = inputdlg(prompt,dlg_title,num_lines,def);
% % % % if isempty(answer)      % In case user presses cancel
% % % %     answer = def;       % use the default text
% % % % end
% % % % 
% % % % legendtext = answer{1};
% % % % if size(legendtext, 1) < nargin
% % % %     error(['ERROR:  Please enter exactly ' int2str(nargin) ' conditions for the legend']);
% % % % end
% % % % legendtext = legendtext(1:nargin,:);
% % % % 
% % % % %   Old: (Used to be like this...)
% % % %     % legendtext = int2str([1:1:nargin]');    % Place holders for legend
% % % % %---------------------------------------------------------------




% generate Figure 1 for histogram of velocities
figure('Position', [10  275  560  420]);
grid
axis([-0.6,0.6,0,0.35]);    % Scaled to existing data (as of 11-07-01)
title([titlePrefix ' \itC. elegans\rm\bf Distribution of Instantaneous Velocity (Mean Point Velocity) ' titleSuffix],...
    'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% title([titlePrefix ' \itC. elegans\rm\bf Distribution of Instantaneous Velocity ' titleSuffix],...
%     'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% title('XXX \itC. elegans\rm\bf Distribution of Instantaneous Velocity for XXX',...
%     'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
xlabel('Velocity (mm/s)', 'FontWeight', 'bold');
ylabel('(Proportion of animals)', 'FontWeight', 'bold');
hold on
drawnow

leg = cell(nargin, 1);  % Non-functional

velhist = [];
for i=1:nargin
    
    % get contents of each directory
    % formatting for macintosh by using filesep instead of \ Jagan   
    pd = varargin(i);
    pd = pd{1};
    
    d = dir([pd filesep 'worm*']);
    nd = prod(size(d));
    
    % Verify that parent directory exists and contains worm folders
    if exist(pd) ~= 7    % if directory does not exist or is not a directory
        error(['ERROR: Directory ''' pd ''' does not exist!']);
    elseif nd == 0       % if directory is empty (no worm folders)
        error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
    end   
    
    % now loop over each item
    n = [];
    for j=1:nd
        % get name of directory
        name = d(j).name;
        % Only process items that are DIRECTORIES:
        if d(j).isdir
            % clear variables
            clear amp ampt fingerprint flex fre len 
            clear mode phs ptvel theta vel wavelnth
            % load in the data
            load([pd filesep name filesep 'metrics.mat']);
            % now do the histogram
            nc = hist(vel, [-3.333:0.03333:3.333]); nc = nc / sum(nc);
            n = [n; nc];
        end % if d(j).isdir
    end % for j=1:nd
    %    if nd == 1
    %        n = [n;nc];      % Adds a second copy of the single worm data
    %    end                  % to allow mean to generate a vector  --  else
    %                         % velhist becomes a scalar
    %    velhist = [velhist; mean(n)];
    
    % The cleaner way of handling single worms (implemented in v4.06):
    if nd == 1   % only one worm* directory
        velhist = [velhist; n];
    else         % >one worm* directory
        velhist = [velhist; mean(n)];
    end
    
    % Add population size to legendtext
    legendtext{i} = [legendtext{i} '  (n=' int2str(nd) ')'];
    
end     % for i=1:nargin

% Restore legendtext to a matrix (after having annotated with population size, n=...):
legendtext = char(legendtext);


plot([-3.333:0.03333:3.333], velhist,...
    'LineWidth', linewdth)   % Set LineWidth 
% velocities scaled up by 3.333x

set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
pos = 2;
legend(gca, legendtext, pos);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate Figure 1A for histogram of (rear) CENTROID velocities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position', [10  275  560  420]);
grid
axis([-0.6,0.6,0,0.35]);    % Scaled to existing data (as of 11-07-01)
title([titlePrefix ' \itC. elegans\rm\bf Distribution of Instantaneous CENTROID Velocity ' titleSuffix],...
    'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% title('XXX \itC. elegans\rm\bf Distribution of Instantaneous Velocity for XXX',...
%     'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
xlabel('Centroid Velocity (mm/s)', 'FontWeight', 'bold');
ylabel('(Proportion of animals)', 'FontWeight', 'bold');
hold on
drawnow

velc_hist = [];
for i=1:nargin
    
    % get contents of each directory
    pd = varargin(i);
    pd = pd{1};
    
    d = dir([pd filesep 'worm*']);
    nd = prod(size(d));
    
    % Verify that parent directory exists and contains worm folders
    if exist(pd) ~= 7    % if directory does not exist or is not a directory
        error(['ERROR: Directory ''' pd ''' does not exist!']);
    elseif nd == 0       % if directory is empty (no worm folders)
        error(['ERROR: ''' pd ''' contains no ''worm__'' folders!']);
    end   
    
    % now loop over each item
    n = [];
    for j=1:nd
        % get name of directory
        name = d(j).name;
        % Only process items that are DIRECTORIES:
        if d(j).isdir
            % clear variables
            clear amp ampt fingerprint flex fre len mode phs ptvel theta vel wavelnth 
            clear velc
            
            % load in the data
            load([pd filesep name filesep 'metrics.mat']);
            
            % now do the histogram
            nc = hist(velc, [-3.333:0.03333:3.333]); nc = nc / sum(nc);
            n = [n; nc];
        end % if d(j).isdir
    end % for j=1:nd
    %    if nd == 1
    %        n = [n;nc];      % Adds a second copy of the single worm data
    %    end                  % to allow mean to generate a vector  --  else
    %                         % velhist becomes a scalar
    %    velc_hist = [velc_hist; mean(n)];
    
    % The cleaner way of handling single worms (implemented in v4.06):
    if nd == 1   % only one worm* directory
        velc_hist = [velc_hist; n];
    else         % >one worm* directory
        velc_hist = [velc_hist; mean(n)];
    end
    
end

plot([-3.333:0.03333:3.333], velc_hist,...
    'LineWidth', linewdth)   % Set LineWidth 
% velocities scaled up by 3.333x

set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
pos = 2;
legend(gca, legendtext, pos);










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 2 for amplitudes, frequencies and time delays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

segs = [5:2:11];
nsegs = prod(size(segs));

figure('Position', [310  40  705  655]);
drawnow;

%-----------------------------------------------------------------------------
% now plot flex
flexhist = cell(1, nsegs);
for j=1:nsegs
    
    flexhist{1,j} = [];
    for i=1:nargin
        
        % get contents of each directory
        pd = varargin(i);
        pd = pd{1};
        
        d = dir([pd filesep 'worm*']);
        nd = prod(size(d));
        
        % now loop over each item
        n = [];
        for k=1:nd
            % get name of directory
            name = d(k).name;
            % Only process items that are DIRECTORIES:
            if d(k).isdir
                % clear variables
                clear amp ampt fingerprint flex fre len 
                clear mode phs ptvel theta vel wavelnth
                % load in the data
                load([pd filesep name filesep 'metrics.mat']);
                % now do the histogram
                nc = hist(flex(:,segs(j)), [0:0.1:pi]); nc = nc / sum(nc);
                n = [n; nc];
            end % if d(k).isdir
            
        end
        %        if nd == 1
        %            n = [n;nc];      % Adds a second copy of the single worm data
        %        end                  % to allow mean to generate a vector  --  else
        %                             % flexhist becomes a scalar
        % 
        %       flexhist{1,j} = [flexhist{1,j}; mean(n)];
        
        % The cleaner way of handling single worms (implemented in v4.06):
        if nd == 1   % only one worm* directory
            flexhist{1,j} = [flexhist{1,j}; n];
        else         % >one worm* directory
            flexhist{1,j} = [flexhist{1,j}; mean(n)];
        end
        
        %Set up to do the Histogram Chart title
        if j == 2
            axhandle = gca;   % Attaches page "title" to j-1'st (i.e. top left) axis
        end
        
    end
    
    % now plot
    subplot(3,4,j);
    plot([0:0.1:pi], flexhist{1,j},...
        'LineWidth', linewdth);          % Set LineWidth
    
    title(['\theta' int2str(segs(j))], 'FontWeight', 'bold');
    xlabel('Flex (rad)', 'FontWeight', 'bold');   
    if j==1
        ylabel('(Proportion of animals)', 'FontWeight', 'bold');
    end
    
    axis([0 2 0 0.5]);       % Scale axes to existing data (as of 11-07-01)
    axis square;
    set(gca, 'FontWeight', 'bold');
    grid on;
    drawnow;
    
end


%-----------------------------------------------------------------------------
% % % %-----------------------------------------------------------------------------
% % % % now plot amplitudes
% % % amphist = cell(1, nsegs);
% % % for j=1:nsegs
% % %    
% % %    amphist{1,j} = [];
% % %    for i=1:nargin
% % %    
% % %    	% get contents of each directory
% % %    	pd = varargin(i);
% % %    	pd = pd{1};
% % %    
% % % 		d = dir([pd '\worm*']);
% % %   		nd = prod(size(d));
% % %       
% % % 	   % now loop over each item
% % %    	n = [];
% % %    	for k=1:nd
% % %       	% get name of directory
% % %       	name = d(k).name;
% % %       	% clear variables
% % %          clear x y vel dir mode fre amp off phs
% % %       	% load in the data
% % %          load([pd '\' name '\metrics.mat']);
% % %       	% now do the histogram
% % %       	nc = hist(amp(:,segs(j)), [0:0.1:pi]); nc = nc / sum(nc);
% % %       	n = [n; nc];
% % % 	   end
% % %        if nd == 1
% % %            n = [n;nc];      % Adds a second copy of the single worm data
% % %        end                  % to allow mean to generate a vector  --  else
% % %                             % amphist becomes a scalar
% % % 
% % %       amphist{1,j} = [amphist{1,j}; mean(n)];
% % %     
% % % %Set up to do the Histogram Chart title
% % %       if j == 2
% % %           axhandle = gca;   % Attaches page "title" to j-1'st (i.e. top left) axis
% % %       end
% % % 
% % %    end
% % %    
% % %    % now plot
% % %    subplot(3,4,j);
% % %    plot([0:0.1:pi], amphist{1,j},...
% % %        'LineWidth', linewdth);          % Set LineWidth
% % % 
% % %    title(['\theta' int2str(segs(j))], 'FontWeight', 'bold');
% % %    xlabel('amplitude (rad)', 'FontWeight', 'bold');      
% % %    axis([0 2 0 0.5]);       % Scale axes to existing data (as of 11-07-01)
% % %    axis square;
% % %    set(gca, 'FontWeight', 'bold');
% % %    grid on;
% % %    drawnow;
% % %    
% % % end
% % % 
% % % 
% % % %-----------------------------------------------------------------------------
% now plot frequencies
frehist = cell(1, nsegs);
for j=1:nsegs
    
    frehist{1,j} = [];
    for i=1:nargin
        
        % get contents of each directory
        pd = varargin(i);
        pd = pd{1};
        
        d = dir([pd filesep 'worm*']);
        nd = prod(size(d));
        
        % now loop over each item
        n = [];
        for k=1:nd
            % get name of directory
            name = d(k).name;
            % Only process items that are DIRECTORIES:
            if d(k).isdir
                % clear variables
                clear amp ampt fingerprint flex fre len 
                clear mode phs ptvel theta vel wavelnth
                % load in the data
                load([pd filesep name filesep 'metrics.mat']);
                % now do the histogram
                nc = hist(fre(:,segs(j)), [0:0.16665:3.9996]); nc = nc / sum(nc);
                n = [n; nc];
            end % if d(j).isdir
        end % for k=1:nd
        %     if nd == 1
        %         n = [n;nc];      % Adds a second copy of the single worm data
        %     end                  % to allow mean to generate a vector  --  else
        %                          % frehist becomes a scalar
        %     frehist{1,j} = [frehist{1,j}; mean(n)];
        % The cleaner way of handling single worms (implemented in v4.06):
        if nd == 1   % only one worm* directory
            frehist{1,j} = [frehist{1,j}; n];
        else         % >one worm* directory
            frehist{1,j} = [frehist{1,j}; mean(n)];
        end
        
    end
    
    % now plot
    subplot(3,4,4+j);
    plot([0:0.16665:3.9996], frehist{1,j},...
        'LineWidth', linewdth);  % Scale x3.333
    
    title(['\theta' int2str(segs(j))], 'FontWeight', 'bold');
    xlabel('Frequency (Hz)', 'FontWeight', 'bold');
    if j == 1
        ylabel('(Proportion of animals)', 'FontWeight', 'bold');
    end
    
    axis([0 1 0 0.80]);
    axis square;
    set(gca, 'FontWeight', 'bold');
    grid on;
    drawnow;
    
end


%-----------------------------------------------------------------------------
% now plot time delays
delayhist = cell(1, nsegs-1);
for j=1:nsegs-1
    
    delayhist{1,j} = [];
    for i=1:nargin
        
        % get contents of each directory
        pd = varargin(i);
        pd = pd{1};
        
        d = dir([pd filesep 'worm*']);
        nd = prod(size(d));
        
        % now loop over each item
        n = [];
        for k=1:nd
            % get name of directory
            name = d(k).name;
            % Only process items that are DIRECTORIES:
            if d(k).isdir
                % clear variables
                clear amp ampt fingerprint flex fre len 
                clear mode phs ptvel theta vel wavelnth
                % load in the data
                load([pd filesep name filesep 'metrics.mat']);
                % now do the histogram
                nc = hist(phs(:,segs(j)), [-1.5:0.075:1.5]); nc = nc / sum(nc);
                n = [n; nc];
            end % if d(k).isdir
        end % for k=1:nd
        %     if nd == 1
        %         n = [n;nc];      % Adds a second copy of the single worm data
        %     end                  % to allow mean to generate a vector  --  else
        %                          % delayhist becomes a scalar
        %     delayhist{1,j} = [delayhist{1,j}; mean(n)];
        
        % The cleaner way of handling single worms (implemented in v4.06):
        if nd == 1   % only one worm* directory
            delayhist{1,j} = [delayhist{1,j}; n];
        else         % >one worm* directory
            delayhist{1,j} = [delayhist{1,j}; mean(n)];
        end
        
    end
    
    % now plot
    subplot(3,4,8+j);
    plot([-1.5:0.075:1.5], delayhist{1,j},...
        'LineWidth', linewdth);      % Set LineWidth
    
    title(['\theta' int2str(segs(j)) ' - \theta' int2str(segs(j)+1)],...
        'FontWeight', 'bold');
    xlabel('Time Delay (s)', 'FontWeight', 'bold');     
    if j == 1
        ylabel('(Proportion of animals)', 'FontWeight', 'bold');
    end
    %   axis([-2.5 2.5 0 0.75]);
    axis([-.75 1 0 0.75]);           % Scale axes to existing data (as of 11-07-01)
    axis square;
    set(gca, 'FontWeight', 'bold');
    grid on;
    drawnow;
    
end


%-----------------------------------------------------------------------------

set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
pos = -1;
legend(gca, legendtext);

set(gcf, 'CurrentAxes', axhandle);
%axes(axhandle);
% text(5.00, 0.64, 'XXX \itC. elegans\rm\bf Histograms for XXX',...
text(5.00, 0.64, [titlePrefix ' \itC. elegans\rm\bf Histograms ' titleSuffix],...
    'FontWeight', 'bold', ...
    'FontSize', figuretitlefontsize,...
    'HorizontalAlignment', 'center');







% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Figure 3 for point velocities
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% vertex = [5:1:13];
% nvertex = prod(size(vertex));
% 
% figure('Position', [290  60  705  655]);
% drawnow;
% 
% %-----------------------------------------------------------------------------
% % now plot point velocities
% ptvelhist = cell(1, nvertex);
% for j=1:nvertex
%    
%    ptvelhist{1,j} = [];
%    for i=1:nargin
%    
%    	% get contents of each directory
%    	pd = varargin(i);
%    	pd = pd{1};
%    
% 		d = dir([pd filesep 'worm*']);
%   		nd = prod(size(d));
%       
% 	   % now loop over each item
%    	n = [];
%    	for k=1:nd
%       	% get name of directory
%       	name = d(k).name;
%       	% clear variables
%       clear amp ampt fingerprint flex fre len 
%       clear mode phs ptvel theta vel wavelnth
%       	% load in the data
%          load([pd filesep  name filesep 'metrics.mat']);
%       	% now do the histogram
%       	nc = hist(ptvel(:,vertex(j)), [-3.333 : 0.03333 : 3.333]); 
%         nc = nc / sum(nc);
%       	n = [n; nc];
% 	   end
% %        if nd == 1
% %            n = [n;nc];      % Adds a second copy of the single worm data
% %        end                  % to allow mean to generate a vector  --  else
% %                             % amphist becomes a scalar
% % 
% %       ptvelhist{1,j} = [ptvelhist{1,j}; mean(n)];
%       
% % The cleaner way of handling single worms (implemented in v4.06):
%     if nd == 1   % only one worm* directory
%         ptvelhist{1,j} = [ptvelhist{1,j}; n];
%     else         % >one worm* directory
%         ptvelhist{1,j} = [ptvelhist{1,j}; mean(n)];
%     end
%       
%       
%     
% %Set up to do the Histogram Chart title
%       if j == 3
%           axhandle = gca;
%       end
% 
%    end
%    
%    % now plot
%    subplot(3,3,j);
%    plot([-3.333 : 0.03333 : 3.333], ptvelhist{1,j},...
%        'LineWidth', linewdth);          % Set LineWidth
% 
%    title(['Point ' int2str(vertex(j))], 'FontWeight', 'bold');
%    if j > 6
%        xlabel('Point Velocity (mm/sec)', 'FontWeight', 'bold');      
%    end
%    axis([-0.6 0.6 0 0.35]);       % Scale axes to existing data (as of 11-07-01)
%    axis square;
%    set(gca, 'FontWeight', 'bold');
%    grid on;
%    drawnow;
%    
% end
% 
% set(gcf, 'PaperOrientation', 'Landscape');
% set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
% pos = -1;
% legend(gca, legendtext);
% 
% set(gcf, 'CurrentAxes', axhandle);
% % text(0, 0.43, 'XXX \itC. elegans\rm\bf Distribution of Point Velocities for XXX',...
% text(0, 0.43, [titlePrefix ' \itC. elegans\rm\bf Distribution of Point Velocities ' titleSuffix],...
%     'FontWeight', 'bold', ...
%     'FontSize', figuretitlefontsize,...
%     'HorizontalAlignment', 'center');
% 





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 4 for Track Amplitude & Wavelength
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate Figure 4 for histograms of Track Amplitude & Wavelength
% figure('Position', [10  275  560  420]);
% figure('Position', [50  225  560  420]);
figure('Position', [50  225  800  500]);

%-----------------------------------------------------------------------------
% now plot Track Amplitudes


% ctrs = [0:0.005:1];
ctrs_ampt = [0:0.010:1];
trackamphist = [];

% ctrs = [0:0.020:4];
% ctrs = [0:0.040:4];
ctrs_wavelnth = [0:0.050:4];
wavelnthhist = [];

for i=1:nargin      % Cycle thru each input directory
    
    % get contents of each directory
    pd = varargin(i);
    pd = pd{1};
    
    d = dir([pd filesep 'worm*']);
    nd = prod(size(d));
    
    % now loop over each item
    %    n = [];
    n_ampt = [];
    n_wavelnth = [];
    
    for j=1:nd       % Cycle thru each worm* folder
        % get name of directory
        name = d(j).name;
        % Only process items that are DIRECTORIES:
        if d(j).isdir
            % clear variables
            clear amp ampt fingerprint flex fre len 
            clear mode phs ptvel theta vel wavelnth
            % load in the data
            load([pd filesep name filesep 'metrics.mat']);
            
            % Generate the histograms
            %   ampt:
            nc_ampt = hist(ampt, ctrs_ampt); 
            nc_ampt = nc_ampt / sum(nc_ampt);
            %       nc = hist(ampt, [-3.333:0.03333:3.333]); nc = nc / sum(nc);
            n_ampt = [n_ampt; nc_ampt];
            
            %   wavelnth:
            nc_wavelnth = hist(wavelnth, ctrs_wavelnth); 
            nc_wavelnth = nc_wavelnth / sum(nc_wavelnth);
            n_wavelnth = [n_wavelnth; nc_wavelnth];
        end %if d(j).isdir
    end % for j=1:nd
    %    if nd == 1
    %        % Adds a second copy of the single worm data
    %        % to allow mean to generate a vector  --  else
    %        % histogram becomes a scalar
    %        n_ampt = [n_ampt; nc_ampt];      
    %        n_wavelnth = [n_wavelnth; nc_wavelnth];      
    %    end                  
    %                         
    %    trackamphist = [trackamphist; mean(n_ampt)];
    %    wavelnthhist = [wavelnthhist; mean(n_wavelnth)];
    
    % The cleaner way of handling single worms (implemented in v4.06):
    if nd == 1   % only one worm* directory
        trackamphist = [trackamphist; n_ampt];
        wavelnthhist = [wavelnthhist; n_wavelnth];
    else         % >one worm* directory
        trackamphist = [trackamphist; mean(n_ampt)];
        wavelnthhist = [wavelnthhist; mean(n_wavelnth)];
    end
    
    
    
end

% Plot histograms
%   Track Amplitude
subplot(2,1,1);         % Top 
% plot(ctrs, trackamphist,...
plot(ctrs_ampt, trackamphist,...
    'LineWidth', linewdth)   % Set LineWidth 
grid on;            
axis([0,0.6,0,0.15]);
title([titlePrefix ' \itC. elegans\rm\bf Distribution of Track Amplitudes ' titleSuffix],...
    'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
xlabel('Track Amplitude (mm)', 'FontWeight', 'bold');
ylabel('(Proportion of animals)', 'FontWeight', 'bold');

set(gca, 'FontWeight', 'bold');
pos = 1;
legend(gca, legendtext, pos);
drawnow

%   Track Wavelength
subplot(2,1,2);         % Bottom half of page
% plot(ctrs, wavelnthhist,...
plot(ctrs_wavelnth, wavelnthhist,...
    'LineWidth', linewdth)   % Set LineWidth 
grid on;
axis([0,2.5,0,0.3]);
title('\bf Distribution of Track Wavelengths',...
    'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
xlabel('Track Wavelength (mm)', 'FontWeight', 'bold');
ylabel('(Proportion of animals)', 'FontWeight', 'bold');

set(gca, 'FontWeight', 'bold');
pos = 1;
legend(gca, legendtext, pos);
drawnow

% Format output for printer
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
pos = 1;
legend(gca, legendtext, pos);

% % % % % % CONSOLIDATED WAVELENGTH INTO AMPT...
% % % % % %-----------------------------------------------------------------------------
% % % % % % now plot Track Wavelength
% % % % % 
% % % % % % ctrs = [0:0.020:4];
% % % % % % ctrs = [0:0.040:4];
% % % % % ctrs = [0:0.050:4];
% % % % % wavelnthhist = [];
% % % % % for i=1:nargin
% % % % %    
% % % % %    % get contents of each directory
% % % % %    pd = varargin(i);
% % % % %    pd = pd{1};
% % % % %    leg(i,1) = {pd};     % Non-functional
% % % % %    
% % % % %    d = dir([pd '\worm*']);
% % % % %    nd = prod(size(d));
% % % % %    
% % % % %    % now loop over each item
% % % % %    n = [];
% % % % %    for j=1:nd
% % % % %       % get name of directory
% % % % %       name = d(j).name;
% % % % %       % clear variables
% % % % %       clear x y vel fre theta amp flex phs ptvel 
% % % % %       clear mode ampt wavelnth metrics_fingerprint
% % % % %       % load in the data
% % % % %       load([pd '\' name '\metrics.mat']);
% % % % %       % now do the histogram
% % % % % %       nc = hist(wavelnth, [-3.333:0.03333:3.333]); nc = nc / sum(nc);
% % % % %       nc = hist(wavelnth, ctrs); nc = nc / sum(nc);
% % % % %       n = [n; nc];
% % % % %    end
% % % % %    if nd == 1
% % % % %        n = [n;nc];      % Adds a second copy of the single worm data
% % % % %    end                  % to allow mean to generate a vector  --  else
% % % % %                         % velhist becomes a scalar
% % % % %    wavelnthhist = [wavelnthhist; mean(n)];
% % % % %    
% % % % % end
% % % % % 
% % % % % subplot(2,1,2);
% % % % % % plot([-3.333:0.03333:3.333], wavelnthhist,...
% % % % % plot(ctrs, wavelnthhist,...
% % % % %     'LineWidth', linewdth)   % Set LineWidth 
% % % % %             % velocities scaled up by 3.333x
% % % % % grid on;
% % % % % 
% % % % % axis([0,2.5,0,0.3]);
% % % % % title('\bf Distribution of Track Wavelengths',...
% % % % %     'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% % % % % xlabel('Track Wavelength (mm)', 'FontWeight', 'bold');
% % % % % drawnow
% % % % %             
% % % % %             
% % % % %             
% % % % % set(gcf, 'PaperOrientation', 'Landscape');
% % % % % set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
% % % % % set(gca, 'FontWeight', 'bold');
% % % % % pos = 1;
% % % % % legend(gca, legendtext, pos);
% % % % % 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 5 for NORMALIZED Track Amplitude & Wavelength
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (Same as Figure 4, but normalizing each worm's data to 
% its mean length)

% figure('Position', [50  225  560  420]);
figure('Position', [50  225  800  500]);

%------------------------------------------------------------------------
% now plot Track Amplitudes


% ctrs = [0:0.005:1];
% ctrs_ampt = [0:0.010:1];
ctrs_ampt_norm = [0:1:100];
trackamphist_norm = [];

% ctrs = [0:0.020:4];
% ctrs = [0:0.040:4];
ctrs_wavelnth_norm = [0:5:400];
wavelnthhist_norm = [];

for i=1:nargin      % Cycle thru each input directory
    
    % get contents of each directory
    pd = varargin(i);
    pd = pd{1};
    
    d = dir([pd filesep 'worm*']);
    nd = prod(size(d));
    
    % now loop over each item
    %    n = [];
    n_ampt_norm = [];
    n_wavelnth_norm = [];
    
    for j=1:nd   % Cycles thru all worm* directories...
        % get name of directory
        name = d(j).name;
        % Only process items that are DIRECTORIES:
        if d(j).isdir
            % clear variables
            clear amp ampt fingerprint flex fre len 
            clear mode phs ptvel theta vel wavelnth
            % load in the data
            load([pd filesep name filesep 'metrics.mat']);
            
            % Verify that metrics.mat includes *len* variable;
            %   if not, display error message and end job.
            if ~exist('len')
                errortext = ['Worm length data missing ---> Re-run METRICS for ' pd filesep name];
                error(errortext)
            end
            
            % Calculate mean length
            meanlen = mean(len(~isnan(len)));
            
            % Generate the histograms from LENGTH-NORMALIZED vectors
            %    ampt:
            nc_ampt_norm = hist( ((ampt/meanlen)*100), ctrs_ampt_norm); 
            nc_ampt_norm = nc_ampt_norm / sum(nc_ampt_norm);
            n_ampt_norm = [n_ampt_norm; nc_ampt_norm];
            
            %    wavelnth:
            nc_wavelnth_norm = hist( ((wavelnth/meanlen)*100), ctrs_wavelnth_norm); 
            nc_wavelnth_norm = nc_wavelnth_norm / sum(nc_wavelnth_norm);
            n_wavelnth_norm = [n_wavelnth_norm; nc_wavelnth_norm];
        end % if d(j).isdir
    end      % for j
    
    %    if nd == 1
    %        % Adds a second copy of the single worm data
    %        % to allow mean to generate a vector  --  else
    %        % histogram becomes a scalar
    %        n_ampt_norm = [n_ampt_norm; nc_ampt_norm];      
    %        n_wavelnth_norm = [n_wavelnth_norm; nc_wavelnth_norm];      
    %    end                  
    %                         
    %    trackamphist_norm = [trackamphist_norm; mean(n_ampt_norm)];
    %    wavelnthhist_norm = [wavelnthhist_norm; mean(n_wavelnth_norm)];
    
    % The cleaner way of handling single worms (implemented in v4.06):
    if nd == 1   % only one worm* directory
        trackamphist_norm = [trackamphist_norm; n_ampt_norm];
        wavelnthhist_norm = [wavelnthhist_norm; n_wavelnth_norm];
    else         % >one worm* directory
        trackamphist_norm = [trackamphist_norm; mean(n_ampt_norm)];
        wavelnthhist_norm = [wavelnthhist_norm; mean(n_wavelnth_norm)];
    end
    
    
    
    
end

%------------------------------------------------------------------------
% Plot histograms
%   Track Amplitude
subplot(2,1,1);         % Top 
% plot(ctrs, trackamphist,...
plot(ctrs_ampt_norm, trackamphist_norm,...
    'LineWidth', linewdth)   % Set LineWidth 
grid on;            
% axis([0,0.6,0,0.15]);
axis([0,60,0,0.15]);
title([titlePrefix ' \itC. elegans\rm\bf Distribution of Length-Normalized Track Amplitudes ' titleSuffix],...
    'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
xlabel('Track Amplitude (% body length)', 'FontWeight', 'bold');
ylabel('(Proportion of animals)', 'FontWeight', 'bold');

set(gca, 'FontWeight', 'bold');
pos = 1;
legend(gca, legendtext, pos);
drawnow

%   Track Wavelength
subplot(2,1,2);         % Bottom half of page
% plot(ctrs, wavelnthhist,...
plot(ctrs_wavelnth_norm, wavelnthhist_norm,...
    'LineWidth', linewdth)   % Set LineWidth 
grid on;
% axis([0,2.5,0,0.3]);
axis([0,250,0,0.3]);
title('\bf Distribution of Length-Normalized Track Wavelengths',...
    'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
xlabel('Track Wavelength (% body length)', 'FontWeight', 'bold');
ylabel('(Proportion of animals)', 'FontWeight', 'bold');

set(gca, 'FontWeight', 'bold');
pos = 1;
legend(gca, legendtext, pos);
drawnow

% Format output for printer
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
pos = 1;
legend(gca, legendtext, pos);





return;