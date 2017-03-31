function [meanforward, meanbackward, meanstopped, rpm, ...
          forwardPct, backwardPct, stoppedPct] = moveduration(...
               filestring, velthreshold, glossoverthreshold_seconds, ...
               verbose, verbosefig, fid)

                            
% MOVEDURATION   Calculate and display durations of behaviors.
%   FORMAT: [meanforward, meanbackward, meanstopped, rpm, ...
%            forwardPct, backwardPct, stoppedPct] = ...
%               moveduration('filestring', ...
%               [velThreshold], [glossOverThreshold], ...
%               [verboseFlag], [verboseFigFlag], [fileID)
%       NB: [xxxxx] are optional arguments
%
% where:
%   (INPUT)
%     filestring :      path and filename of metrics.mat or veldata.mat
%     velthreshold :    speed (in mm/sec) below which worm is considered stopped 
%     glossoverthreshold :    maximum duration (in seconds) of pauses to ignore
%     verboseFlag :     1 (true) or 0 (false) requesting display of all the
%                       details of the worm behavior.  Default is 1 (true).
%     verboseFigFlag :  1 (true) or 0 (false) requesting display of figures
%                       displaying behavior for each worm.  Default is 1 (true).
%     fileID :          Integer file ID number (returned by fopen) for the
%                       target file for writing measures of behavior.
% and:
%   (OUTPUT)
%     meanforward :   mean of forward durations (seconds)
%     meanbackward :  mean of backward durations (seconds)
%     meanstopped :   mean of stopped durations (seconds)
%     rpm :           Reversal frequency  (reversals per minute) 
%       ==> NOTE: Every direction change, fwd-to-bkwd OR bkwd-to-fwd, is
%                 considered a reversal!
%     forwardPct :    Percent of time spent moving forward (%)
%     backwardPct :   Percent of time spent moving forward (%)
%     stoppedPct :    Percent of time spent moving forward (%)
%
%   example:  
%     [meanforward, meanbackward, meanstopped, rpm, ...
%      forwardPct, backwardPct, stoppedPct] = moveduration(...
%        'D:\Cheryl\acute tracks\acute_feb11\worm2\metrics.mat');
%
% originally was a SCRIPT:  moveduration.m  
% calculates vectors of movement (or stop) durations
% Created 3/23/06 for Cheryl and Jagan.
% Revised 6/30/06 for use with POPMOVE, for calculating characteristic
% move/stop behaviors of populations.
% - C J Cronin
% June 30, 2006, Caltech
%


clear vel velc spf fpt seconds_per_frame


% Initialize Variables
figuretitlefontsize = 14;

if nargin < 5
    verbosefig = 1;  % Flag indicating request for intermediate charts
end     % if nargin < 5

if nargin < 4
    verbose = 1;  % Flag indicating request for intermediate text
end     % if nargin < 4

SAVETEXT = false;
if exist('fid', 'var') == 1 && (fid >= 3)
    SAVETEXT = true;
end

% Set flag (default value)
filestringWasStruct = 0;
        
if nargin < 1
    [filename, pathname] = uigetfile( ...
        {'*.mat', 'Matlab files (*.mat)'},'Select file containing ''velc'' data');
else
    if isstruct(filestring)
        % Set flag
        filestringWasStruct = 1;
        
        % File string contains the actual data.  Need to extract the
        % individual variables for later use.
        if isfield(filestring, 'vel')
            vel = filestring.vel;
        end
        if isfield(filestring, 'velc')
            velc = filestring.velc;
        end
        if isfield(filestring, 'spf')
            spf = filestring.spf;
        end
        if isfield(filestring, 'fpt')
            fpt = filestring.fpt;
        end
        if isfield(filestring, 'seconds_per_frame')
            seconds_per_frame = filestring.seconds_per_frame;
        end
        
        % Extract filename and pathname from  Structure 'filestring'
        [pathname,name,ext] = fileparts(filestring.fullfilename);
        
    else
        [pathname,name,ext] = fileparts(filestring);
        
    end
    
    filename = [name ext];
end

% Just in case, ensure that pathname ends with a filesep
if pathname(end) ~= filesep
    pathname(end+1) = filesep;
end


if filename==0
    error('No file selected')
end

if filestringWasStruct == 0
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % LOAD DATA
    %
    % HERE'S THE LOAD CALL...
    load([pathname filename]);
    
    % if verbose
    %     fprintf(1,'\n%s\n', [pathname filename]);
    % end     % if verbose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end







% TEST CONDITION
% vel = [3 0 0 3 3 3 NaN 3 3 -3]
% vel = [0 0 3 3 3 3 3 3 3 0 0 3 3 3 3 3 3 NaN NaN NaN NaN 3 3 -3 -3 -3 0 0 ]
% vel = [0 3 3 0 0 0 NaN 0 0 -3]
% vel = [3 3 3 0 0 -3 -3 -3 -3 NaN NaN 3 3 3 -3 -3 NaN 0 0 ]
% vel = [3 3 3 3 3 0 0 0 0 0 0 3 3 3 3 3 0 0 3 3 3 3 3 0 0 3 3 3 3 3 0 0 0 0 0 3 3 3 3 0 0 0 0 3 0 0 0 3 0 -3]
% vel = [NaN NaN -3 -3 3 3 3 3 3 0 0 0 0 0 0 3 3 3 3 3 0 0 3 3 3 3 3 0 0 3 3 3 3 3 0 0 0 0 0 3 3 3 3 0 0 0 0 3 0 0 0 3 0 -3]


velX = velc;     % To use CENTROID velocity

if strcmp(filename, 'metrics.mat')
    if exist('seconds_per_frame', 'var')==1  % verify that seconds_per_frame exists
        spf = seconds_per_frame;    % force into short veldata.mat format
    else
        error('Need to re-run metrics6 to modernize data')
    end
elseif strcmp(filename, 'veldata.mat')
    if exist('spf', 'var')~=1    % verify that spf exists
        error('Your veldata.mat file doesn''t contain the proper spf value.  See Chris for help.')
    end
end

% Create time vector for reference plot
totalseconds = spf*fpt*numel(velX);
minutevector = [ totalseconds/numel(velX) : totalseconds/numel(velX) : totalseconds ]/60;

if verbosefig
    figure; plot(minutevector, velX, 'o-')      % for Debugging

% % Set legend
% legendtext = {...
%                 ['Forward  (' int2str(numel(forward )) ' instances)']; 
%                 ['Backward (' int2str(numel(backward)) ' instances)']; 
%                 ['Stopped  (' int2str(numel(stopped )) ' instances)']; 
%              };   

    title(['Velocity - from ' pathname filename],...     
      'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% 10-28-04 CJC discovered that ...'Interpreter', 'none'... must be first to avoid
% throwing a 
% 'Warning: Unable to interpret TeX string "\DELETEME_r14_shakeout\worm13"'
% warning.  This is rather maddening...

    % set(gca, 'XTick', []);
    xlabel('Time  [min]', 'FontWeight', 'bold');
    ylabel('Centroid Velocity  [mm/sec]', 'FontWeight', 'bold');
    grid on;
    set(gca, 'FontWeight', 'bold');


    % Format printout
    set(gcf, 'PaperOrientation', 'Landscape');
    set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
end     % if verbosefig



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ERROR CHECKING
%
if ~isreal(velX)
    error('Problem: there are imaginary components in the velocity vector')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SET-UP
%
% threshold = 0.05;   % minimum velocity to be considered movement (absolute value)
% % threshold = 0.1;   % minimum velocity to be considered movement (absolute value)
% 
% glossoverthreshold = 4; % If worm pauses momentarily before continuing in same direction, 
%                         % this is the number of consecutive stops that can be glossed over 
%---------------------------------------------------------------


%---------------------------------------------------------------
% Prompt for the chart parameter information (if necessary):
if nargin<3
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
    velthreshold = str2double(answer{1});

    if verbosefig
        % Add velthreshold lines to reference plot
        hold on
        plot(minutevector([1 end]),  velthreshold*(ones(1,2)),'r-')
        plot(minutevector([1 end]), -velthreshold*(ones(1,2)),'r-')
        hold off
    end     % if verbosefig



% 'glossoverthreshold' requires a bit of calculation to change from time to
% frames.  Each vel value represents movement across a 'timeblock'.  
% We need to change the reported gloss answer from seconds into number of 
% 'timeblocks' (would be frames if fpt=1).  (I'm choosing to ask for gloss
% in terms of time since I don't expect the user to comfortably be able to
% know and account for varying fpt's across various datasets.)

    % We know the 'gloss' answer as seconds:
    glossoverthreshold_seconds = str2double(answer{2});
end     % if nargin<3

% Error checking
if (glossoverthreshold_seconds<0)
    error('Can''t ignore ''negative'' time');
end
% Start changing to timeblocks: divide by (spf*fpt)  [which is seconds per timeblock]
glossoverthreshold = glossoverthreshold_seconds/(spf*fpt); 
% and round to nearest number of timeblocks:
glossoverthreshold = round(glossoverthreshold);

if verbose
    if (glossoverthreshold_seconds>0)
        fprintf(1,'    Ignoring pauses or uncertainties lasting less than %d frames (~%g seconds).\n', glossoverthreshold, glossoverthreshold_seconds);
    else
        fprintf(1, '    Not ignoring pauses or uncertainties of any duration.\n')
    end
    
    if SAVETEXT
        if (glossoverthreshold_seconds>0)
            fprintf(fid,'    Ignoring pauses or uncertainties lasting less than %d frames (~%g seconds).\n', glossoverthreshold, glossoverthreshold_seconds);
        else
            fprintf(fid, '    Not ignoring pauses or uncertainties of any duration.\n');
        end
    end     % if SAVETEXT
end
%---------------------------------------------------------------



% i is a built-in function where i = sqrt(-1);       
% complex number for marking missing data

%---------------------------------------------------------------
% Change concept to ENSURE that there's a NaN at the start and end
% Ensure leading NaN(s) (i.e. velocity set starts with NaN's)
%
% Remove leading NaN's (i.e. if velocity set starts with NaN's)
while ( (numel(velX)>0) && (isnan(velX(1))) )
    velX = velX(2:end);
end
% And restore one and only one NaN
velX = [NaN velX];

% Remove trailing NaN's (i.e. if velocity set ends with NaN's)
while ( (numel(velX)>0) && (isnan(velX(end))) )
    velX = velX(1:end-1);
end
% And restore one and only one NaN
velX = [velX NaN];
%---------------------------------------------------------------

% Ensure that there is non-NaN velX data available
if ~any(~isnan(velX))
    error(['File ''' filestring.fullfilename ''' does not contain velocity data for this time range.']);
end

%---------------------------------------------------------------

state = 9999*ones(size(velX));           % 9999 as filler junk
    state(velX > velthreshold) = 1;         % forward flags
    state(velX < -velthreshold) = -1;       % backward flags
    state(abs(velX) < velthreshold) = 0;    % stopped flags
    state(isnan(velX)) = 1i;             % missing data flags


% % DEBUGGING: 
% figure; plot(vel); hold on; plot(state(imag(state)==0),'r-o')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TRANSITIONS
%
% TRY THIS: first create vector of whether states changing, then select
% only those changes that are fully certain.  That is, eliminate  (or
% flag?) transitions that contained NaN's.
potentialtransitions = diff(state); 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TRANSITIONS
%
% LIST OF TRANSITIONS
% List all instances of state-change; add one to match the ordinal of the
% state changed to...
fulltransitionlist = find(potentialtransitions~=0) + 1; 
% ---> Note that fulltransitionlist also contains transitions to and from 
% formerly NaN states.

% Create flag of whether BOTH preceding and successor states were known
validtransitionflag = ~imag(state(fulltransitionlist-1)) & ... 
                        ~imag(state(fulltransitionlist));
                    

                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DIRECTIONS
%
% Note direction of travel after transitions but trim off of last direction
% to match durations length 
directions      = state(fulltransitionlist(1:end-1) );
predirections   = state(fulltransitionlist-1        );  % may need to trim off last direction
postdirections  = state(fulltransitionlist          );  % may need to trim off last direction

    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DURATIONS
%
% Calculate the period between transitions
fulldurations = diff(fulltransitionlist);
% durations = diff(transitionlist)
% ---> Note that fulldurations contains formerly "NaN" durations and "UNCERTAIN"
% durations too. 

% Flag whether BOTH in- and out-transitions were valid
durationcertainty = validtransitionflag(1:end-1) & validtransitionflag(2:end);
% certaindurationflag = validtransitionflag(1:end-1) & validtransitionflag(2:end);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GLOSS OVER SHORT PAUSES
%
%---------------------------------------------------------------------
% Find the short pauses from when worm is moving forward:
forwardPausesToGlossOver = find( ...
    ( (postdirections(1:end-1)==0) | ... OR         % <---pauses -OR-
      (imag(postdirections(1:end-1))) )     & ...   % <---missing data that are
    (fulldurations <= glossoverthreshold)   & ...   % <---short (below the threshold) where worm was
    (predirections(1:end-1)==1)             & ...   % <---previously moving forward and worm 
    (postdirections(2:end)==1)                  );  % <---winds up moving forward again

% Implement the gloss-overs:
for n = 1:numel(forwardPausesToGlossOver)     % k = forwardPausesToGlossOver
    k = forwardPausesToGlossOver(n);
    postdirections(k:k+1) = [];                         % Eliminate excess postdirections
    predirections(k+1:k+2) = [];                        % Eliminate excess predirections
    durationcertainty(k:k+1) = [];                      % Eliminate excess validdurationflag's
    fulldurations(k-1) = sum(fulldurations(k-1:k+1));   % Find whole forward duration
    fulldurations(k:k+1) = [];                          % Eliminate excess durations
    forwardPausesToGlossOver(n+1:end) = forwardPausesToGlossOver(n+1:end)-2;    % Decrement pause-numbers
%     forwardPausesToGlossOver(n:end) = forwardPausesToGlossOver(n:end)-2;    % Decrement pause-numbers
end % for k = c

%---------------------------------------------------------------------
% Find the short pauses from when worm is moving backward:
backwardPausesToGlossOver = find( ...
    ( (postdirections(1:end-1)==0) | ... OR         % <---pauses -OR-
      (imag(postdirections(1:end-1))) )     & ...   % <---missing data that are
    (fulldurations <= glossoverthreshold)   & ...   % <---short (below the threshold) where worm was
    (predirections(1:end-1)==1)             & ...   % <---previously moving backward and worm 
    (postdirections(2:end)==1)                  );  % <---winds up moving backward again

% Implement the gloss-overs:
for n = 1:numel(backwardPausesToGlossOver)     % k = forwardPausesToGlossOver
    k = backwardPausesToGlossOver(n);
    postdirections(k:k+1) = [];                         % Eliminate excess postdirections
    predirections(k+1:k+2) = [];                        % Eliminate excess predirections
    durationcertainty(k:k+1) = [];                      % Eliminate excess validdurationflag's
    fulldurations(k-1) = sum(fulldurations(k-1:k+1));   % Total backward duration
    fulldurations(k:k+1) = [];                          % Eliminate excess durations
    backwardPausesToGlossOver(n+1:end) = backwardPausesToGlossOver(n+1:end)-2;    % Decrement pause-numbers
%     backwardPausesToGlossOver(n:end) = backwardPausesToGlossOver(n:end)-2;    % Decrement pause-numbers
end % for k = c

% Here's a thought, if we wanted to gloss over NaN's, we could change
% find(... to screen for NaN's for glossing, too. 
% Could change
%     (postdirections(1:end-1)==0)            & ...   % <---pauses that are
% to
%     ( (postdirections(1:end-1)==0) | (imag(postdirections)) )            & ...   % <---pauses that are



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CONVERT DURATION LENGTHS FROM FRAMES (TIMEBLOCKS) TO TIME (SECONDS)
%
fulldurations = fulldurations*(fpt*spf);
if verbose
    fprintf(1, 'Durations (reported in seconds)\n');
    if SAVETEXT
        fprintf(fid, 'Durations (reported in seconds)\n');
    end     % if SAVETEXT
end     % if verbose


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CALCULATE DIRECTIONAL DURATIONS
%
forward     = fulldurations( (postdirections(1:end-1) ==  1) & durationcertainty );
backward    = fulldurations( (postdirections(1:end-1) == -1) & durationcertainty );
stopped     = fulldurations( (postdirections(1:end-1) ==  0) & durationcertainty );

uncertain   = fulldurations( imag(postdirections(1:end-1)) ~=  0 );


uncertainforward    = fulldurations( (postdirections(1:end-1) ==  1) & ~durationcertainty );
uncertainbackward   = fulldurations( (postdirections(1:end-1) == -1) & ~durationcertainty );
uncertainstopped    = fulldurations( (postdirections(1:end-1) ==  0) & ~durationcertainty );




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% "EXTRA-CREDIT" DIRECTIONAL DURATIONS
%
notforward     = fulldurations( (postdirections(1:end-1) ~=  1) & durationcertainty );
notbackward    = fulldurations( (postdirections(1:end-1) ~= -1) & durationcertainty );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CONDITION OUTPUT
%
 %-------------------------------
    if numel(forward)== 0
        forward = [];
    end
    
    if numel(backward) == 0
        backward = [];
    end
 
    if numel(stopped) == 0
        stopped = [];
    end
 %-------------------------------
    if numel(uncertain) == 0
        uncertain = [];
    end
 %-------------------------------
    if numel(uncertainforward) == 0
        uncertainforward = [];
    end
    
    if numel(uncertainbackward) == 0
        uncertainbackward = [];
    end
    
    if numel(uncertainstopped) == 0
        uncertainstopped = [];
    end
 %-------------------------------
    if numel(notforward)== 0
        notforward = [];
    end
    
    if numel(notbackward) == 0
        notbackward = [];
    end
 %-------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% OUTPUT
%
% Prevent DivideByZero warning if there are no Statistics for a condition:
originalwarningstate = warning('off', 'MATLAB:divideByZero');   
    
if verbose
    fprintf(1,'                        \t Mean     \t STD      \t SEM     \tn     \n');

    fprintf(1, '----------------------------------------------------------------------------------------\n')    

    fprintf(1,'Forward:            \t %8.2f \t %8.2f \t %8.2f \t %4d \n', mean(forward), std(forward), std(forward)/sqrt(numel(forward)), numel(forward));
    fprintf(1,'Backward:           \t %8.2f \t %8.2f \t %8.2f \t %4d \n', mean(backward), std(backward), std(backward)/sqrt(numel(backward)), numel(backward));
    fprintf(1,'Stopped:            \t %8.2f \t %8.2f \t %8.2f \t %4d \n', mean(stopped), std(stopped), std(stopped)/sqrt(numel(stopped)), numel(stopped));

    fprintf(1, '----------------------------------------------------------------------------------------\n')    

    fprintf(1,'Uncertain:          \t %8.2f \t %8.2f \t %8.2f \t %4d \n', mean(uncertain), std(uncertain), std(uncertain)/sqrt(numel(uncertain)), numel(uncertain));

    fprintf(1, '----------------------------------------------------------------------------------------\n')    

    fprintf(1,'Uncertain Forward:  \t %8.2f \t %8.2f \t %8.2f \t %4d \n', mean(uncertainforward), std(uncertainforward), std(uncertainforward)/sqrt(numel(uncertainforward)), numel(uncertainforward));
    fprintf(1,'Uncertain Backward: \t %8.2f \t %8.2f \t %8.2f \t %4d \n', mean(uncertainbackward), std(uncertainbackward), std(uncertainbackward)/sqrt(numel(uncertainbackward)), numel(uncertainbackward));
    fprintf(1,'Uncertain Stopped:  \t %8.2f \t %8.2f \t %8.2f \t %4d \n', mean(uncertainstopped), std(uncertainstopped), std(uncertainstopped)/sqrt(numel(uncertainstopped)), numel(uncertainstopped));

    fprintf(1, '----------------------------------------------------------------------------------------\n')    

    fprintf(1,'NOT Backward:       \t %8.2f \t %8.2f \t %8.2f \t %4d \n', mean(notbackward), std(notbackward), std(notbackward)/sqrt(numel(notbackward)), numel(notbackward));
    fprintf(1,'NOT Forward:        \t %8.2f \t %8.2f \t %8.2f \t %4d \n', mean(notforward), std(notforward), std(notforward)/sqrt(numel(notforward)), numel(notforward));

    fprintf(1, '----------------------------------------------------------------------------------------\n')    

    
    if SAVETEXT
        fprintf(fid,'\tMean\tSTD\tSEM\tn\n');
        
        fprintf(fid, '----------------------------------------------------------------------------------------\n');
        
        fprintf(fid,'Forward:\t%8.2f\t%8.2f\t%8.2f\t%4d\n', mean(forward), std(forward), std(forward)/sqrt(numel(forward)), numel(forward));
        fprintf(fid,'Backward:\t%8.2f\t%8.2f\t%8.2f\t%4d\n', mean(backward), std(backward), std(backward)/sqrt(numel(backward)), numel(backward));
        fprintf(fid,'Stopped:\t%8.2f\t%8.2f\t%8.2f\t%4d\n', mean(stopped), std(stopped), std(stopped)/sqrt(numel(stopped)), numel(stopped));
        
        fprintf(fid, '----------------------------------------------------------------------------------------\n');
        
        fprintf(fid,'Uncertain:\t%8.2f\t%8.2f\t%8.2f\t%4d\n', mean(uncertain), std(uncertain), std(uncertain)/sqrt(numel(uncertain)), numel(uncertain));
        
        fprintf(fid, '----------------------------------------------------------------------------------------\n');
        
        fprintf(fid,'Uncertain Forward:\t%8.2f\t%8.2f\t%8.2f\t%4d\n', mean(uncertainforward), std(uncertainforward), std(uncertainforward)/sqrt(numel(uncertainforward)), numel(uncertainforward));
        fprintf(fid,'Uncertain Backward:\t%8.2f\t%8.2f\t%8.2f\t%4d\n', mean(uncertainbackward), std(uncertainbackward), std(uncertainbackward)/sqrt(numel(uncertainbackward)), numel(uncertainbackward));
        fprintf(fid,'Uncertain Stopped:\t%8.2f\t%8.2f\t%8.2f\t%4d\n', mean(uncertainstopped), std(uncertainstopped), std(uncertainstopped)/sqrt(numel(uncertainstopped)), numel(uncertainstopped));
        
        fprintf(fid, '----------------------------------------------------------------------------------------\n');
        
        fprintf(fid,'NOT Backward:\t%8.2f\t%8.2f\t%8.2f\t%4d\n', mean(notbackward), std(notbackward), std(notbackward)/sqrt(numel(notbackward)), numel(notbackward));
        fprintf(fid,'NOT Forward:\t%8.2f\t%8.2f\t%8.2f\t%4d\n', mean(notforward), std(notforward), std(notforward)/sqrt(numel(notforward)), numel(notforward));
        
        fprintf(fid, '----------------------------------------------------------------------------------------\n');
    end     % if SAVETEXT
    
    
end     % if verbose


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% RE-CONFIGURE OUTPUT
%
forward =   sort(forward);  forward =   forward(end:-1:1);
backward =  sort(backward); backward =  backward(end:-1:1);
stopped =   sort(stopped);  stopped =   stopped(end:-1:1);

uncertain = sort(uncertain); uncertain = uncertain(end:-1:1);

uncertainforward =  sort(uncertainforward);     uncertainforward =  uncertainforward(end:-1:1);
uncertainbackward = sort(uncertainbackward);    uncertainbackward = uncertainbackward(end:-1:1);
uncertainstopped =  sort(uncertainstopped);     uncertainstopped =  uncertainstopped(end:-1:1);

notforward =   sort(notforward);  notforward =   notforward(end:-1:1);
notbackward =  sort(notbackward); notbackward =  notbackward(end:-1:1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CONDITION OUTPUT FOR PLOTTING
%   Need to plot empty events as NaN's to act as placeholders, but report
%   number of events as an empty string to get 'zero'
%
forwardPlot     = forward;
backwardPlot    = backward;
stoppedPlot     = stopped;
uncertainPlot           = uncertain;
uncertainforwardPlot    = uncertainforward;
uncertainbackwardPlot   = uncertainbackward;
uncertainstoppedPlot    = uncertainstopped;
notforwardPlot      = notforward;
notbackwardPlot     = notbackward;

 % Replace with NaN's as needed for empty event vectors
 %-------------------------------
    if numel(forward)== 0
        forwardPlot = NaN;
    end
    
    if numel(backward) == 0
        backwardPlot = NaN;
    end
 
    if numel(stopped) == 0
        stoppedPlot = NaN;
    end
 %-------------------------------
    if numel(uncertain) == 0
        uncertainPlot = NaN;
    end
 %-------------------------------
    if numel(uncertainforward) == 0
        uncertainforwardPlot = NaN;
    end
    
    if numel(uncertainbackward) == 0
        uncertainbackwardPlot = NaN;
    end
    
    if numel(uncertainstopped) == 0
        uncertainstoppedPlot = NaN;
    end
 %-------------------------------
    if numel(notforward)== 0
        notforwardPlot = NaN;
    end
    
    if numel(notbackward) == 0
        notbackwardPlot = NaN;
    end
 %-------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DISPLAY OUTPUT
%
if verbosefig
    figure; hold on
    plot(100/numel(forwardPlot) :100/numel(forwardPlot):100,  forwardPlot,  'go-', 'LineWidth', 3);
    plot(100/numel(backwardPlot):100/numel(backwardPlot):100, backwardPlot, 'bo-', 'LineWidth', 3);
    plot(100/numel(stoppedPlot) :100/numel(stoppedPlot):100,  stoppedPlot,  'ro-', 'LineWidth', 3);
    hold off

    % Initialize Variables
    pos = 1;    % 1 = upper right corner
    figuretitlefontsize = 14;

    % Set legend
    legendtext = {...
                ['Forward  (' int2str(numel(forward )) ' instances)']; 
                ['Backward (' int2str(numel(backward)) ' instances)']; 
                ['Stopped  (' int2str(numel(stopped )) ' instances)']; 
                 };   

    title([pathname filename],...     
          'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% 10-28-04 CJC discovered that ...'Interpreter', 'none'... must be first to avoid
% throwing a 
% 'Warning: Unable to interpret TeX string "\DELETEME_r14_shakeout\worm13"'
% warning.  This is rather maddening...

    set(gca, 'XTick', []);
    xlabel('(instance)', 'FontWeight', 'bold');
    ylabel('Behavior Duration  [sec]', 'FontWeight', 'bold');
    grid on;
    legend(gca, legendtext, pos);
    set(gca, 'FontWeight', 'bold');


    % Format printout
    set(gcf, 'PaperOrientation', 'Landscape');
    set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % ALTERNATEDISPLAY OUTPUT
    %
    figure; hold on
    plot(100/numel(notbackwardPlot):100/numel(notbackwardPlot):100, notbackwardPlot, 'yo-', 'LineWidth', 3);
    plot(100/numel(notforwardPlot) :100/numel(notforwardPlot):100,  notforwardPlot,  'mo-', 'LineWidth', 3);
    hold off

    % Initialize Variables
    pos = 1;    % 1 = upper right corner
    figuretitlefontsize = 14;

    % Set legend
    legendtext = {...
                    ['NOT Backward (' int2str(numel(notbackward)) ' instances)']; 
                    ['NOT Forward  (' int2str(numel(notforward )) ' instances)']; 
                 };   

    title([pathname filename],...     
          'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% 10-28-04 CJC discovered that ...'Interpreter', 'none'... must be first to avoid
% throwing a 
% 'Warning: Unable to interpret TeX string "\DELETEME_r14_shakeout\worm13"'
% warning.  This is rather maddening...

    set(gca, 'XTick', []);
    xlabel('(instance)', 'FontWeight', 'bold');
    ylabel('Behavior Duration  [sec]', 'FontWeight', 'bold');
    grid on;
    legend(gca, legendtext, pos);
    set(gca, 'FontWeight', 'bold');


    % Format printout
    set(gcf, 'PaperOrientation', 'Landscape');
    set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
end     % if verbosefig



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  changebf_4     call  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% REVERSAL FREQUENCY CALCULATION
%
% Calculate mode based on the 'state' vector calculated earlier.  Mode
% disregards any stopped-condition data and missing (NaN) data, and just
% looks at the number of changes from forward-to-backward and backward-
% to-forward regardless of what comes between.  State represents
% NaN data as an imaginary number i, thus screen for cases where there
% is not imaginary component in addition to checking for non-NaN and 
% non-zero.
mode = state( ~(isnan(state)) & (state ~= 0) & (imag(state) == 0));

[bfchange, bfforward, bfbackward] = changebf_4(mode, glossoverthreshold); % Get all the data from the change of direction

% Calculate reversals per minute (rpm)
rpm = bfchange/(totalseconds/60);   


%%%%%%%%%%% ===> OLD VERSION CALCULATION <=== %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (was) Calculating modeOLD as:
modeOLD = 9999*ones(size(velX));        % 9999 as filler junk
    modeOLD(velX >= 0)   =  1;          % forward flags
    modeOLD(velX <  0)   = -1;          % backward flags
    modeOLD(isnan(velX)) = NaN;         % missing data flags
% This version only use a velocity threshold of zero, so reversal frequency
% is reported as being overly high for essentially stopped worms.

[bfchangeOLD, bfforwardOLD, bfbackwardOLD] = changebf_4(modeOLD, glossoverthreshold); % Get all the data from the change of direction

% Calculate reversals per minute (rpm)
rpmOLD = bfchangeOLD/(totalseconds/60);   
%%%%%%%%%%% ===> OLD VERSION CALCULATION <=== %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  end of     changebf_4     call  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CALCULATE TIME DISTRIBUTION OF ACTIONS
%
% Calculate percent time spent moving forward, backward and stopped
% (including 'uncertain' actions)
forwardTotDuration  = sum(fulldurations(postdirections(1:end-1) ==  1));
backwardTotDuration = sum(fulldurations(postdirections(1:end-1) == -1));
stoppedTotDuration  = sum(fulldurations(postdirections(1:end-1) ==  0));
TotalDuration = sum([forwardTotDuration, backwardTotDuration, stoppedTotDuration]);

forwardPct  = forwardTotDuration  * 100 / TotalDuration;
backwardPct = backwardTotDuration * 100 / TotalDuration;
stoppedPct  = stoppedTotDuration  * 100 / TotalDuration;




if verbose
    fprintf(1, '----------------------------------------------------------------------------------------\n')    
    fprintf(1, 'Reversal Freqency  [reversals/minute]:  %4.2f\n', rpm)
    fprintf(1, '   Total reversals:  %d  over  %d  minutes\n', ...
        bfchange, round(totalseconds/60));
    fprintf(1, '                               [Previously reported as %d reversals / %d minutes.]\n', ...
        bfchangeOLD, round(totalseconds/60))
    fprintf(1, 'Note:   Reversal frequency calculation always ignores ''stopped'' and ''uncertain'' states.\n')
    if (glossoverthreshold_seconds>0)
        fprintf(1,'Note 2: This reversal frequency calculation ignored actions lasting less than %d frames (~%g seconds).\n', glossoverthreshold, glossoverthreshold_seconds);
    end
    fprintf(1, '----------------------------------------------------------------------------------------\n')    
    fprintf(1, 'Time Distribution:   Forward:  %6.2f%%  (%.1f sec)\n', forwardPct,  forwardTotDuration );
    fprintf(1, '                     Backward: %6.2f%%  (%.1f sec)\n', backwardPct, backwardTotDuration);
    fprintf(1, '                     Stopped:  %6.2f%%  (%.1f sec)\n', stoppedPct,  stoppedTotDuration );
    fprintf(1, '----------------------------------------------------------------------------------------\n')    
    
    fprintf(1, '\n');
    
    if SAVETEXT
        fprintf(fid, '----------------------------------------------------------------------------------------\n');
        fprintf(fid, 'Reversal Freqency  [reversals/minute]:\t%4.2f\n', rpm);
        fprintf(fid, 'Total reversals:\t%d\tover\t%d\tminutes\n', ...
            bfchange, round(totalseconds/60));
        fprintf(fid, '[Previously reported as %d reversals / %d minutes.]\n', ...
            bfchangeOLD, round(totalseconds/60));
        fprintf(fid, 'Note:   Reversal frequency calculation always ignores ''stopped'' and ''uncertain'' states.\n');
        if (glossoverthreshold_seconds>0)
            fprintf(fid,'Note 2: This reversal frequency calculation ignored actions lasting less than %d frames (~%g seconds).\n', glossoverthreshold, glossoverthreshold_seconds);
        end
        fprintf(fid, '----------------------------------------------------------------------------------------\n');
        fprintf(fid, 'Time Distribution:\tForward: (Percent of time)\t%6.2f\t(%.1f sec)\n', forwardPct,  forwardTotDuration );
        fprintf(fid, '\tBackward: (Percent of time)\t%6.2f\t(%.1f sec)\n', backwardPct, backwardTotDuration);
        fprintf(fid, '\tStopped: (Percent of time)\t%6.2f\t(%.1f sec)\n', stoppedPct,  stoppedTotDuration );
        fprintf(fid, '----------------------------------------------------------------------------------------\n');
        
        fprintf(fid, '\n');
    end     % if SAVETEXT


end     % if verbose




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% COLLECT FUNCTION RETURN VALUES
%
meanforward     = mean(forward);
meanbackward    = mean(backward);
meanstopped     = mean(stopped);
% rpm
% % % nforward    = numel(forward);
% % % nbackward   = numel(backward);
% % % nstopped    = numel(stopped);


% Restore original warning state:
warning(originalwarningstate)
% warning on MATLAB:divideByZero;


