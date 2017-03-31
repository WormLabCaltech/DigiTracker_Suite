function [] = omega(mintime, proxThreshold, varargin)

% OMEGA   Tool to identify potential omega turn events: Qty, start times, and durations.
%   FORMAT: omega(minimumDuration, proxThreshold, 'input_directory_name(s)');
%      where 
%      - "minimumDuration" is the minimum duration (in seconds) for a
%        missing block of worm data to be considered a possible omega turn.
%      - "proxThreshold" is a proximity threshold (expressed as a percent
%        body length [like 0.4 for 40%]) describing how close the worm's
%        head and tail must get to be considered a possible omega turn.
%        Such an event will occur if a worm is moving forward and doubles
%        over BUT its spine length remains within an acceptable range of
%        most-common-length (i.e. wormproc and the user did not reject the
%        worm spines during the event).
%      - 'input_directory_name(s)' are folder names (with paths) containing
%        sub-folders whose names begin with 'worm' and contain files called
%        data.mat and points.
%
% Modified for Adler Dillman and Alon Zaslaver 8/19/2008 to add screen for
% possible omega turn events where the worm's spine is NOT rejected by
% wormproc or the user.  Based on conversation 8/14/2008.
%
% Developed for Adler Dillman starting 5/05/2008 based on conversation
% 4/28/2008.
%
%
%based on:
% function [] = metrics6(mmpp, scnds, fpt, varargin)
%
%METRICS6    Calculate worm motion metrics.
%   FORMAT: metrics6(mmpp, #seconds, fpt, 'input_directory_name(s)');
%      where 
%      - "mmpp" is the ratio "millimeters per pixel" which is 
%         ...
%
%   C. J. Cronin 5-16-08
% 




% % some error checking
if nargout > 0
    error( 'FORMAT: omega(minimumDuration, head_tail_proximityPct, ''input_directory_name(s)'')' );     
end

if nargin < 3
    error( 'FORMAT: omega(minimumDuration, head_tail_proximityPct, ''input_directory_name(s)'')' );     
end

if ~isnumeric(mintime)
    error( 'Must specify minimum duration for missing data to be considered an omega turn' )
end

% Verify proxThreshold is in the range of 0 - 100%
if ~( (proxThreshold >= 0) && (proxThreshold <=1) )
    error('proxThreshold must be in the range of 0 to 1.0 ( i.e. 0-100% ).  See ''help omega.m''');
end

figuretitlefontsize = 14;
markersize = 6;
linewidth = 3;



%--------------------------------------------------------------------
%--------------------------------------------------------------------
% Establish whether we Want to Definitely save for Matlab v6.x readability:
FORCE_to_v6 = 1;   % 1 = true, we want to save for v6 readability.

% Check for Matlab version
matlabversion = ver('MATLAB');
matlabversion = matlabversion.Version;

% NB: Had to change the single str2num... line into the mess below to
% handle cases where The Mathworks, in their infinite wisdom, decides to
% issue yet another manifestation of their version numbering system.  In 
% this case, version 6.5.1 (breaking the pattern of v6.0, v6.5, v7.0,
% v7.1, ...), stopped  
%         matlabversion = str2num(matlabversion.Version); 
% from working.  Grrrrrr.

% matlabversion = str2num(matlabversion.Version);

% Find location of decimal points
p = findstr('.', matlabversion);

if numel(p)>0   % if there's at least one decimal point...
    
    % Ensure that segments of version number don't exceed 2 digits
    % (Assuming that there won't be more than 100 sub-versions ever
    % released...)
    versionlengths = [diff(p) numel(matlabversion)+1-p(end)]-1;
    if any(versionlengths > 2)  
        % Otherwise throw error and hope that somebody can re-code the 
        % next block...
        error('I can''t believe this broke too.  Matlab''s version numbering system is really MADDENING!!!')
    end
    
    integerpart = matlabversion(1 : p(1)-1);
    fractionalpart = matlabversion(p(1) : end);
    
    % set up for loop
    fractionalstr = [];
    p = findstr('.', fractionalpart);
    
    while (numel(p)>0)
        endpart = fractionalpart(p(end)+1:end);     % digits after last decimal point
        endsize = numel(endpart);   % number of digits
        tempstr = '00';     % temporary string
        tempsize = numel(tempstr);  % temporary string's length
        tempstr( (tempsize-endsize+1) : end ) = endpart;    % last digits added to temporary string
        fractionalstr = [tempstr fractionalstr];    % temporary string appended to end of fractional string
        
        % Preparation for next pass through while loop
        fractionalpart = fractionalpart(1:p(end)-1);
        p = findstr('.', fractionalpart);
    end %while (numel...)
    
    % Then piece together integer and fraction strings 
    matlabversion = [integerpart '.' fractionalstr];
    
end

% ...and, FINALLY, convert to number
matlabversion = str2num(matlabversion);

%----------------------------------------------------------------
%----------------------------------------------------------------

%---------------------------------------------------------------
%---------------------------------------------------------------
%---------------------------------------------------------------

% Query for whether to display individual worm details
button = questdlg('Display individual worm details?','Display Details?','No'); 
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

%-THE SET-UP FOR CALCULATING METRICS----------------------------

% Initialize allPopulation arrays
numPopulations              = numel(varargin);
allPopStartsT               = cell(size(varargin));
allPopDurationsT            = cell(size(varargin));
allPopStartsCloseT          = cell(size(varargin));
allPopDurationsCloseT       = cell(size(varargin));
allPopN                     = NaN*zeros(size(varargin));
meanPopDurationsT           = NaN*zeros(size(varargin));
 stdPopDurationsT           = NaN*zeros(size(varargin));
   nPopDurationsT           = NaN*zeros(size(varargin));
meanPopDurationsCloseT      = NaN*zeros(size(varargin));
 stdPopDurationsCloseT      = NaN*zeros(size(varargin));
   nPopDurationsCloseT      = NaN*zeros(size(varargin));
   
meanPopNumStartsT           = NaN*zeros(size(varargin));
 stdPopNumStartsT           = NaN*zeros(size(varargin));
   PopNumStartsT           = NaN*zeros(size(varargin));

allPopLegend                = cell(size(varargin));
maxtime                     = 0;
durationData                = [];
durationLabels              = [];
numStartsData               = [];
numStartsLabels             = [];

poplegendtext = promptforlegend(varargin{:});

% now process data in each directory
for i=1:numPopulations        % cycle through input population directories

    % get contents of each directory
    pd = varargin{i};
    
    d = dir([pd filesep 'worm*']);
    if isempty(d)
        error(['Directory ''' pd ''' is empty or is not currently available.  Check the directory path before trying again.']);
    end     % if isempty(d)
    nd = prod(size(d));
    
    % Initialize variables
    popStartsT          = [];
    popDurationsT       = [];
    popNumStartsT       = [];
    popStartsCloseT     = [];
    popDurationsCloseT  = [];
    popNumStartsCloseT  = [];
    popN = 0;

    % now loop over each item
    for j=1:nd       % cycle through worm directories in each population
        
        % get name of directory
        name = d(j).name;

        % clear variables
        clear x y vel dir mode fre amp off phs ptvel len

        % Set up empty variables
        starts              = [];
        ends                = [];
        duration_frames     = [];
        startsT             = [];
        endsT               = [];
        durationsT          = [];

        startsClose         = [];
        endsClose           = [];
        duration_framesClose= [];
        startsCloseT        = [];
        endsCloseT          = [];
        durationsCloseT     = [];

        if d(j).isdir
            
            % print out blank line
            fprintf(1, '-----------------------------------------------------------\n');
            
            % load in the data
            directory = [pd filesep name];
            %         load([pd filesep name filesep 'data.mat']);
            
            %---------------------------------------------------------------------------        
            % Load data.mat (for x and y)
            load([directory filesep 'data.mat']);
            % Load points (for original points - to calculate ALL non-screened lengths)
            load([directory filesep 'points']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            x5 = x(:,5);
            if exist('timeV','var')==1
                xp = points(1:2:end, 2:end); yp = points(2:2:end, 2:end);
            else    % Check whether points is timestamped
                firstCol = diff(points(:,1));
                firstCol = firstCol(1:2:end);
                firstCol = firstCol(~isnan(firstCol));
                if mean(firstCol) < eps     % timestamped
                    xp = points(1:2:end, 2:end); yp = points(2:2:end, 2:end);
                else    % not timestamped
                    xp = points(1:2:end, 1:end); yp = points(2:2:end, 1:end);
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % print out path name to stdout
            delimiter_positions = findstr(filesep, directory);
            if numel(delimiter_positions) > 1
                foldername = [directory(delimiter_positions(end-1)+1 : end)];
            else
                foldername = directory;
            end
            
            fprintf(1, '%s:', foldername);
            
            
            %-------------------------------------------------------------
            % Screen for sections of missing xy values from data.mat
            %-------------------------------------------------------------
            
            % First find start & end events
            starts = find(isnan(x5(2:end)) & ~isnan(x5(1:end-1)))+1;    % Add 1 to index to match actual first NaN's
            ends = find(~isnan(x5(2:end)) & isnan(x5(1:end-1)));
            
            % Verify that there are potential omega turn events
            if( ~isempty(starts) || ~isempty(ends) )
                
                % Add initial start if data set starts with NaNs
                if(isnan(x5(1)))
                    starts = [1; starts];
                end
                
                % Add end event in case data set ends with NaNs
                if(isnan(x5(end)))
                    ends = [ends; numel(x5)];
                end
                
                % Sanity check:
                if(numel(starts) ~= numel(ends))
                    error('Number of starts do not match number of ends.');
                end
                
                eventindex = [1:1:numel(starts)]';
                %             omegaevents = ones(size(eventindex));
                
                duration_frames = ends - starts;
                
                % Convert to times:
                startsT = timeV(starts);
                endsT   = timeV(ends);
                durationsT = endsT - startsT;
                
                % Time screen:
                timeScreened = durationsT > mintime;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Establish length reference
                % Create vectors of worm lengths
                len = sum(sqrt(diff(x').^2 + diff(y').^2));     % From data.mat file
                lenp = sum(sqrt(diff(xp').^2 + diff(yp').^2));  % From original points file
                
                % Find Most Common Length
                lengths = [1:1:1000];   % Reference vector (wormlengths to 1000 pixels)
                h = hist(lenp,lengths);  % Actual wormlengths into ref vector bins
                
                indx = find( h == max(h) );     % Most common worm length(s)
                indx = indx(1);             % The first (shortest), most common length
                %   (to handle the rare case when there are
                %   two or more most common lengths)-- (if
                %   the first is not the correct choice, the
                %   user will need to manually screen the 
                %   data, or will need to modify this code.
                
                mcl = lengths(indx);        % MOST COMMON WORM LENGTH, in pixels
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Screen to determine if all "missing" frames are shorter than
                % most-common-length
                short = lenp < mcl;     % Vector of 1's and 0's
                lengthScreened = ones(size(eventindex));    % Reference vector
                for e = 1:numel(eventindex)
                    shortworms = short(starts(e) : ends(e));
                    lengthScreened(e) = all(shortworms);
                end % for (eventindex)
                
                % Create the screen vector
                omegaevent = timeScreened & lengthScreened;
                
                % Apply the screen vector
                eventindex = eventindex(omegaevent);
                starts = starts(omegaevent);
                ends = ends(omegaevent);
                duration_frames = duration_frames(omegaevent);
                startsT = startsT(omegaevent);
                endsT = endsT(omegaevent);
                durationsT = endsT - startsT;
%             else
%                 startsT = [];   % Empty placeholder
            end     % if( ~isempty(starts) || ~isempty(ends) )
                

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Screen for head and tail get close to each other but
            % don't get close enough to cause the apparent worm spine
            % length to go undersize.

            % First calculate the distance between head and tail in
            % three ways: at tail (ht1);
            xx1= [x(:,1),x(:,end)];     yy1= [y(:,1),y(:,end)];     ht1 = sqrt(diff(xx1').^2 + diff(yy1').^2);
            xx2= [x(:,2),x(:,end-1)];   yy2= [y(:,2),y(:,end-1)];   ht2 = sqrt(diff(xx2').^2 + diff(yy2').^2);
            xx3= [x(:,3),x(:,end-2)];   yy3= [y(:,3),y(:,end-2)];   ht3 = sqrt(diff(xx3').^2 + diff(yy3').^2);

            % Create vectors of worm lengths
            len1 = sum(sqrt(diff(x').^2 + diff(y').^2));
            len2 = sum(sqrt(diff(x(:,2:end-1)').^2 + diff(y(:,2:end-1)').^2));
            len3 = sum(sqrt(diff(x(:,3:end-2)').^2 + diff(y(:,3:end-2)').^2));

            % Proximity of head and tail cut-off [percent]
%             proxThreshold = 0.50;   % percent

            % Calculte head/tail proximity vs current worm spine length
            %                 proxPct1 = ht1./mcl;
            %                 proxPct2 = ht2./mcl;
            %                 proxPct3 = ht3./mcl;
            proxPct1 = ht1./len1;
            proxPct2 = ht2./len2;
            proxPct3 = ht3./len3;

            % Screen for close-head/tail-proximity events
            proximal3 = ( (proxPct3 <= proxThreshold) & ~isnan(proxPct3) );

            % Set up
            startsClose = [];
            endsClose = [];
            proxCount = 0;
            startsflag = 0;

            % Find starts and ends for 'Close' events
            if proximal3(1) == 1
                startsClose = 1;
                proxCount = 1;
                startsflag = 1;
            end     % if proximal3(1) == 1

            for c = 2:numel(proximal3)-1
                % Find starts
                if ( (proximal3(c) == 1) & (proximal3(c-1) == 0) & ~isnan(proxPct3(c-1)) )
                    startsClose = [startsClose; c];
                    startsflag = 1;
                end     % if ( (proximal3(c) == 1) & (proximal3(c-1) == 0) )

                % Find ends
                if ( (proximal3(c) == 0) & (proximal3(c-1) == 1) & startsflag )
                    endsClose = [endsClose; c];
                    startsflag = 0;
                    proxCount = proxCount + 1;
                end     % if ( (proximal3(c) == 0) & (proximal3(c-1) == 1) & startflag )

            end     % for c = 1:numel(proximal3)

            if ( (proximal3(end) == 1) & startsflag )
                endsClose = [endsClose; numel(proximal3)];
                startsflag = 0;
                proxCount = proxCount + 1;
            end     % if (proximal3(end) == 1)

            % Sanity checks:
            if(numel(startsClose) ~= numel(endsClose))
                error('Number of starts do not match number of ends.');
            end

            if (numel(startsClose) ~= proxCount)
                error('Number of starts do not match number of ends.');
            end


% figure; plot(proxPct3); grid on;

            % Verify that there are potential omega turn events
            if( ~isempty(startsClose))


                eventindexClose = [1:1:numel(startsClose)]';
                %             omegaevents = ones(size(eventindex));

                duration_framesClose = endsClose - startsClose;

                % Convert to times:
                startsCloseT = timeV(startsClose);
                endsCloseT   = timeV(endsClose);
                durationsCloseT = endsCloseT - startsCloseT;

                % Screen to determine if all close proximity frames occur
                % when worm is moving forward

                %--------------------------------------------------
                % Determine mode (forward/backward movement)
                % STOLEN FROM TRANSLATION3.M
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

                mode = 2*((d1 < d2)-0.5);   % 1 = forward, -1 = backward
                                            % Forward motion: small d1, large d2
                                            % Backward motion: Large d1, small d2
                %--------------------------------------------------

                fwd = [NaN, mode] > 0;     % Direction (forward) vector
                directionScreened = ones(size(eventindexClose));    % Reference vector
                for e = 1:numel(eventindexClose)
                    fwdworms = fwd(startsClose(e) : endsClose(e));
                    directionScreened(e) = all(fwdworms);
% mode(startsClose(e) : endsClose(e))                    
                end % for (eventindex)
                            
                % Create the screen vector
                omegaeventClose = (directionScreened == 1);
                
                % Apply the screen vector
                eventindexClose = eventindexClose(omegaeventClose);
                startsClose = startsClose(omegaeventClose);
                endsClose = endsClose(omegaeventClose);
                duration_framesClose = duration_framesClose(omegaeventClose);
                startsCloseT = startsCloseT(omegaeventClose);
                endsCloseT = endsCloseT(omegaeventClose);
                durationsCloseT = endsCloseT - startsCloseT;
%             else
%                 startsCloseT = [];

            end     % if( ~isempty(startsClose) || ~isempty(endsClose) )


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                


            % Print results to Command Window
            if( ~isempty(starts) || ~isempty(startsClose) )
                fprintf(1, '%4d omega turn events\n', numel(starts) + numel(startsClose));
                    
                fprintf(1, '  Identified by short spines  (%d events)\n', numel(starts));
                if isempty(starts)
                    fprintf(1,'  ---> NO SUSPECTED OMEGA TURNS (by short spines) <---\n');
                else
                   fprintf(1, '\tEvent\tStart Time\tDuration [seconds]\n');
                   for e = 1:numel(starts)
                        fprintf(1, '\t%4d: \t  %6.2f  \t %6.2f \n', e, startsT(e), durationsT(e));
                    end
                end     % if isempty(starts)

                
                
                fprintf(1, '  Identified by head-tail proximity  (%d events)\n', numel(startsClose));
                if isempty(startsClose)
                    fprintf(1,'  ---> NO SUSPECTED OMEGA TURNS (by head-tail proximity) <---\n');
                else
                  fprintf(1, '\tEvent\tStart Time\tDuration [seconds]\n');
                  for e = 1:numel(startsClose)
                        fprintf(1, '\t%4d: \t  %6.2f  \t %6.2f \n', e, startsCloseT(e), durationsCloseT(e));
                    end
                end     % if isempty(startsClose)
                
                fprintf(1,'\n');

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if DISPLAYINDIVIDUALS    
                    figure
                    
%                     % Diagnostics (to plot head/tail proximity ratio
%                     % above the omega events plot)
%                     
%                     subplot(2,1,1); 
%                     framecount = numel(proxPct3);
%                     maxtime = ceil(timeV(end));
%                     plot([maxtime/framecount : maxtime/framecount : maxtime],... 
%                         proxPct3); grid on;
%                     set(gca, 'XLim', [0, ceil(timeV(end))])
%                     set(gca, 'XTick', [0:60:ceil(timeV(end))]);
%                     ylimitval = get(gca, 'YLim');
%                     ylimitval(1) = 0;
%                     set(gca, 'YLim', ylimitval);
%                     subplot(2,1,2);

                    legendtext = {};
                    if ~isempty(startsT)
                        plot(startsT, durationsT, 'bo', 'MarkerSize', markersize, 'LineWidth', linewidth);
                        legendtext{end+1} = ['Short Spines'];
                        hold on;
% ADD startsT and durationsT TO POPULATION COLLECTION; INCREMENENT N VALUE                        
                    end
                    if ~isempty(startsCloseT)
                        plot(startsCloseT, durationsCloseT, 'r^', 'MarkerSize', markersize, 'LineWidth', linewidth);
                        legendtext{end+1} = ['Head-Tail Proximity'];
% ADD startsCloseT AND durationsCloseT TO POPULATION COLLECTION; INCREMENT N VALUE                        
                    end
                    grid on
                    set(gca, 'XLim', [0, ceil(timeV(end))])
                    set(gca, 'XTick', [0:60:ceil(timeV(end))]);
                    ylimitval = get(gca, 'YLim');
                    ylimitval(1) = 0;
                    set(gca, 'YLim', ylimitval);
                    title([directory],...
                        'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
                    xlabel('Omega Turn Start Time [seconds]', 'FontWeight', 'bold');
                    ylabel('Omega Turn Duration [seconds]', 'FontWeight', 'bold');
                    if matlabversion >= 7.0
                        legend(legendtext, 'Location','Best');
                    else
                        legend(legendtext, 0);
                    end
                    set(gcf, 'PaperOrientation', 'Landscape');
                    set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
                    set(gca, 'FontWeight', 'bold');
                end     % if DISPLAYINDIVIDUALS

            else
                fprintf(1,'  ---> NO SUSPECTED OMEGA TURNS <---\n');
                fprintf(1,'\n');
            end     % if( ~isempty(starts) || ~isempty(startsClose) )
            
            % Add this worm's data to this condition's collection
            popStartsT          = [popStartsT;          startsT]; 
            popDurationsT       = [popDurationsT;       durationsT];
            popNumStartsT       = [popNumStartsT;       numel(startsT)];
            
            popStartsCloseT     = [popStartsCloseT;     startsCloseT];
            popDurationsCloseT  = [popDurationsCloseT;  durationsCloseT];
            popNumStartsCloseT  = [popNumStartsCloseT;  numel(startsCloseT)];
            
            % Increment worm counter
            popN = popN + 1;
            
            % (Re-)Set maxtime value
            if ceil(timeV(end)) > maxtime
                maxtime = ceil(timeV(end));
            end
            
        end     % if d(j).isdir
        
        clear startsT durationsT startsCloseT durationsCloseT timeV points

    end  % for j = 1:nd --- cycling through worm folders in each population
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot summary "point cloud" for population.
    % Places all points for population on the same chart.
    figure

    legendtext = {};
    if ~isempty(popStartsT)
        plot(popStartsT, popDurationsT, 'bo', 'MarkerSize', markersize, 'LineWidth', linewidth);
        legendtext{end+1} = 'Short Spines';
        hold on;
    end
    if ~isempty(popStartsCloseT)
        plot(popStartsCloseT, popDurationsCloseT, 'r^', 'MarkerSize', markersize, 'LineWidth', linewidth);
        legendtext{end+1} = 'Head-Tail Proximity';
    end
    grid on
    if ( ~isempty(popStartsT) || ~isempty(popStartsCloseT) )
        set(gca, 'XLim', [0, maxtime])
        set(gca, 'XTick', 0:60:maxtime);
        ylimitval = get(gca, 'YLim');
        ylimitval(1) = 0;
        set(gca, 'YLim', ylimitval);
    end     % if ( ~isempty(popStartsT) || ~isempty(popStartsCloseT) )
    title(strtrim(poplegendtext(i,:)),...
        'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
    xlabel('Omega Turn Start Time [seconds]', 'FontWeight', 'bold');
    ylabel('Omega Turn Duration [seconds]', 'FontWeight', 'bold');
    if matlabversion >= 7.0
        legend(legendtext, 'Location','Best');
    else
        legend(legendtext, 0);
    end
    hold off
    set(gcf, 'PaperOrientation', 'Landscape');
    set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
    set(gca, 'FontWeight', 'bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Add population's data to allPopulation array
    allPopStartsT{i}            = popStartsT;
    allPopDurationsT{i}         = popDurationsT;
    allPopStartsCloseT{i}       = popStartsCloseT;
    allPopDurationsCloseT{i}    = popDurationsCloseT;
    
    allPopN(i)                  = popN;
    
    meanPopDurationsT(i)        =  mean(popDurationsT(~isnan(popDurationsT)));
     stdPopDurationsT(i)        =   std(popDurationsT(~isnan(popDurationsT)));
       nPopDurationsT(i)        = numel(popDurationsT(~isnan(popDurationsT)));
    meanPopDurationsCloseT(i)   =  mean(popDurationsCloseT(~isnan(popDurationsCloseT)));
     stdPopDurationsCloseT(i)   =   std(popDurationsCloseT(~isnan(popDurationsCloseT)));
       nPopDurationsCloseT(i)   = numel(popDurationsCloseT(~isnan(popDurationsCloseT)));
       
    meanPopNumStartsT(i)        = mean(popNumStartsT(~isnan(popNumStartsT)));
     stdPopNumStartsT(i)        =  std(popNumStartsT(~isnan(popNumStartsT)));
       nPopNumStartsT(i)        = numel(popNumStartsT(~isnan(popNumStartsT)));
    
     
    allPopLegend{i}             = pd; 
        
    % print out blank line
    fprintf(1, '-----------------------------------------------------------\n');
    fprintf(1, '-----------------------------------------------------------\n');
    
    % Collect Duration Data against Population Legend Text
    durationData = [durationData; popDurationsT];
    durationLabels = strvcat(durationLabels, repmat(strtrim(poplegendtext(i,:)), size(popDurationsT)) );
    
    % Collect Number of Starts Data against Population Legend Text
    numStartsData = [numStartsData; popNumStartsT];
    numStartsLabels = strvcat(numStartsLabels, repmat(strtrim(poplegendtext(i,:)), size(popNumStartsT)) );

end     % for i=1:numPopulations        % cycle through input population directories






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Present comparison of Omega turn DURATIONS per populations on single box plot
figure
% % % % % % % % %    cstr = strtrim(cstr)


% names{1} = repmat('Starved forbes',size(allPopDurationsT{1}))
% names{2} = repmat('Starved PVC',size(allPopDurationsT{2}))
% nnn = strvcat(names{1}, names{2})

% aaa = [aaa;allPopDurationsT{q}];
% nnn = strvcat(names{1}, names{2})


h = boxplot(durationData, durationLabels, 'notch','on');

% % % % Set up x-tick labels
% % % poplegendarray = cell(1,numPopulations);
% % % for i = 1:numPopulations
% % % %     poplegendarray{i} = [strtrim(poplegendtext(i,:)) '  (n=' int2str(allPopN(i)) ')'];
% % %     poplegendarray{i} = [strtrim(poplegendtext(i,:))...
% % %         '  (' int2str(nPopDurationsT(i)) ' turns/' int2str(allPopN(i)) ' animals = ' ...
% % %         num2str(nPopDurationsT(i)/allPopN(i)) ' turns/animal)'];
% % % end
% % % 
% % % % Label x-ticks with conditions    
% % % set(gca, 'xticklabel', poplegendarray)

hold on
% Data annotations
for i = 1:size(h,2)
    boxdata = get(h(5,i));
%     text(boxdata.XData(5), boxdata.YData(5), 'Hello world')
%     text(boxdata.XData(5), boxdata.YData(5), ...
%         {   [int2str(nPopDurationsT(i)) ' turns'];
%             ['n=' int2str(allPopN(i))];
%             ['=' num2str(nPopDurationsT(i)/allPopN(i)) ' avg. turns/animal'] },...
%         'VerticalAlignment','Bottom', 'HorizontalAlignment','Left')

    % Annotate box plot
    text(boxdata.XData(4), boxdata.YData(4), ...
        {   ['#turns=' int2str(nPopDurationsT(i)) ];
            ['n=' int2str(allPopN(i))];
            ['turns/n=' num2str(nPopDurationsT(i)/allPopN(i), '%.2f')] },...
        'VerticalAlignment','Bottom', 'HorizontalAlignment','Left')
    
    % Plot marker at mean Y value
    plot( (boxdata.XData(4) + boxdata.XData(3))/2, meanPopDurationsT(i), ...
          'bo', 'LineWidth', 3, 'MarkerSize', 6);
    
    % Label mean
    text((boxdata.XData(4) + boxdata.XData(3))/2, meanPopDurationsT(i),...
        ['  Mean=' num2str(meanPopDurationsT(i), '%.2f')]);
end
hold off

% Format axes
set(gca,'YGrid','on')
ylimitval = get(gca, 'YLim');
if ylimitval(1) > 0
    ylimitval(1) = 0;
    set(gca, 'YLim', ylimitval);
end
title(['Distribution of Omega Turn Durations  (' num2str(mintime) ' sec minimum duration)'],...
    'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% xlabel('Omega Turn Start Time [seconds]', 'FontWeight', 'bold');
ylabel('Omega Turn Durations (Distribution and Mean) [seconds]', 'FontWeight', 'bold');
% % % if matlabversion >= 7.0
% % %     legend(legendtext, 'Location','Best');
% % % else
% % %     legend(legendtext, 0);
% % % end
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%--------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Present comparison of NUMBER OF OMEGA TURNS PER ANIMAL per populations on single box plot
figure
% % % % % % % % %    cstr = strtrim(cstr)


% names{1} = repmat('Starved forbes',size(allPopDurationsT{1}))
% names{2} = repmat('Starved PVC',size(allPopDurationsT{2}))
% nnn = strvcat(names{1}, names{2})

% aaa = [aaa;allPopDurationsT{q}];
% nnn = strvcat(names{1}, names{2})


h = boxplot(numStartsData, numStartsLabels, 'notch','on');

% % % % Set up x-tick labels
% % % poplegendarray = cell(1,numPopulations);
% % % for i = 1:numPopulations
% % % %     poplegendarray{i} = [strtrim(poplegendtext(i,:)) '  (n=' int2str(allPopN(i)) ')'];
% % %     poplegendarray{i} = [strtrim(poplegendtext(i,:))...
% % %         '  (' int2str(nPopDurationsT(i)) ' turns/' int2str(allPopN(i)) ' animals = ' ...
% % %         num2str(nPopDurationsT(i)/allPopN(i)) ' turns/animal)'];
% % % end
% % % 
% % % % Label x-ticks with conditions    
% % % set(gca, 'xticklabel', poplegendarray)

hold on
% Data annotations
for i = 1:size(h,2)
    boxdata = get(h(5,i));
%     text(boxdata.XData(5), boxdata.YData(5), 'Hello world')
%     text(boxdata.XData(5), boxdata.YData(5), ...
%         {   [int2str(nPopDurationsT(i)) ' turns'];
%             ['n=' int2str(allPopN(i))];
%             ['=' num2str(nPopDurationsT(i)/allPopN(i)) ' avg. turns/animal'] },...
%         'VerticalAlignment','Bottom', 'HorizontalAlignment','Left')

    % Annotate box plot
    text(boxdata.XData(4), boxdata.YData(4), ...
        {   ['#turns=' int2str(nPopDurationsT(i)) ];
            ['n=' int2str(allPopN(i))];
            ['turns/n=' num2str(nPopDurationsT(i)/allPopN(i), '%.2f')] },...
        'VerticalAlignment','Bottom', 'HorizontalAlignment','Left')
    
    % Plot marker at mean Y value
    plot( (boxdata.XData(4) + boxdata.XData(3))/2, meanPopNumStartsT(i), ...
          'bo', 'LineWidth', 3, 'MarkerSize', 6);      
    
    % Label mean
    text((boxdata.XData(4) + boxdata.XData(3))/2, meanPopNumStartsT(i),...
        ['  Mean=' num2str(meanPopNumStartsT(i), '%.2f')]);
end
hold off

% Format axes
set(gca,'YGrid','on')
ylimitval = get(gca, 'YLim');
if ylimitval(1) > 0
    ylimitval(1) = 0;
    set(gca, 'YLim', ylimitval);
end
title(['Distribution of Omega Turns per Animal  (' num2str(mintime) ' sec minimum duration)'],...
    'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% xlabel('Omega Turn Start Time [seconds]', 'FontWeight', 'bold');
ylabel('Number of Omega Turns per Animal (Distribution and Mean)', 'FontWeight', 'bold');
% % % if matlabversion >= 7.0
% % %     legend(legendtext, 'Location','Best');
% % % else
% % %     legend(legendtext, 0);
% % % end
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%     BAR CHARTS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Present comparison of populations on single grouped bar chart
figure
% % % % % % % % %    cstr = strtrim(cstr)
% legendtext = {'Short Spines' 'Head-Tail Proximity'};

% barerrorbar([meanPopDurationsT' meanPopDurationsCloseT'], [stdPopDurationsT', stdPopDurationsCloseT'])
h = barerrorbar(meanPopDurationsT', stdPopDurationsT');

bardata = get(h);

% % Data annotations
% for i = 1:numel(bardata.XData)
%     
%     text(bardata.XData(i)-bardata.BarWidth/2, bardata.YData(i), ...
%         {   ['#turns=' int2str(nPopDurationsT(i)) ];
%             ['n=' int2str(allPopN(i))];
%             ['turns/n=' num2str(nPopDurationsT(i)/allPopN(i))] },...
%         'VerticalAlignment','Bottom', 'HorizontalAlignment','Left')
% end

grid on

poplegendarray = cell(1,numPopulations);
for i = 1:numPopulations
    poplegendarray{i} = strtrim(poplegendtext(i,:));
%     poplegendarray{i} = [strtrim(poplegendtext(i,:))...
%         '  (' int2str(nPopDurationsT(i)) ' turns/' int2str(allPopN(i)) ' animals = ' ...
%         num2str(nPopDurationsT(i)/allPopN(i)) ' turns/animal)'];
end

% Label x-ticks with conditions    
set(gca, 'xticklabel', poplegendarray)

ylimitval = get(gca, 'YLim');
ylimitval(1) = 0;
set(gca, 'YLim', ylimitval);
title(['Mean Omega Turn Durations  (' num2str(mintime) ' sec minimum duration)'],...
    'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% xlabel('Omega Turn Start Time [seconds]', 'FontWeight', 'bold');
ylabel('Mean Omega Turn Duration (+/- 1 Standard Deviation) [seconds]', 'FontWeight', 'bold');
% if matlabversion >= 7.0
%     legend(legendtext, 'Location','Best');
% else
%     legend(legendtext, 0);
% end
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Present comparison of populations on single grouped bar chart
figure
% % % % % % % % %    cstr = strtrim(cstr)
% legendtext = {'Short Spines' 'Head-Tail Proximity'};

h = barerrorbar(meanPopNumStartsT', stdPopNumStartsT');

bardata = get(h);

% % Data annotations
% for i = 1:numel(bardata.XData)
%     
%     text(bardata.XData(i)-bardata.BarWidth/2, bardata.YData(i), ...
%         {   ['#turns=' int2str(nPopDurationsT(i)) ];
%             ['n=' int2str(allPopN(i))];
%             ['turns/n=' num2str(nPopDurationsT(i)/allPopN(i))] },...
%         'VerticalAlignment','Bottom', 'HorizontalAlignment','Left')
% end

grid on

poplegendarray = cell(1,numPopulations);
for i = 1:numPopulations
    poplegendarray{i} = strtrim(poplegendtext(i,:));
%     poplegendarray{i} = [strtrim(poplegendtext(i,:))...
%         '  (' int2str(nPopDurationsT(i)) ' turns/' int2str(allPopN(i)) ' animals = ' ...
%         num2str(nPopDurationsT(i)/allPopN(i)) ' turns/animal)'];
end

% Label x-ticks with conditions    
set(gca, 'xticklabel', poplegendarray)

ylimitval = get(gca, 'YLim');
ylimitval(1) = 0;
set(gca, 'YLim', ylimitval);
title(['Omega Turns per Animal  (' num2str(mintime) ' sec minimum duration)'],...
    'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% xlabel('Omega Turn Start Time [seconds]', 'FontWeight', 'bold');
ylabel('Mean Number of Omega Turns per Animal (+/- 1 Standard Deviation)', 'FontWeight', 'bold');
% if matlabversion >= 7.0
%     legend(legendtext, 'Location','Best');
% else
%     legend(legendtext, 0);
% end
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




return;




