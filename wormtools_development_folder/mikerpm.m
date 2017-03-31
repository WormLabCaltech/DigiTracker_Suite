function [ftbCount, stbCount] = mikerpm(foldername)

%MIKERPM    Calculate the number of forward-to-backward and stopped-to-backward reversals for a single worm.
%   FORMAT: [ftbCount, stbCount] = mikerpm(foldername)
%      where 
%      - "foldername" is the name of a folder containing files called
%        metrics.mat and data.mat 
%      - "ftbCount" and "stbCount" are the number of valid
%        forward-to-backward and stopped-to-backward reversals performed by
%        the worm during the recording.  'Validity' of a reversal event
%        means that the distance of forward movement (or duration of being
%        stopped) duration BEFORE the reversal, and the distance of
%        backward movement AFTER the reversal are longer than the
%        software-defined thresholds for minimum movement distance or
%        stopped duration.  
%        
% Based on the original mikerpm script to calculate Reversals per Minute,
% developed for Mike & Meenakshi 


DEBUG = false;

VERBOSE = false;

SHOWPLOTS = false;  % Use this to blind plotting routine

if nargin < 1
    foldername = uigetdir;
    if foldername == 0
        error('===> Please call function with the syntax: mikerpm(''D:\Mike\worm1_N2_01''); <===');
    end
end

clear amp ampt contr cumDist dataset_length_in_seconds distanceTravelled
clear distance TravelledRaw fingerprint flex fpt fre fwdToBkwd
clear input_director_list len mmpp mode phs ptvel seconds_per_frame
clear theta timeV transitions tv v vel velc wavelnth x y

% foldername = 'D:\Chris\Mike\N2visver\worm3_N2_13.04.22_04(normal)';
% % foldername = 'D:\Chris\Mike\N2\worm1_N2_01';
% % foldername = 'D:\Chris\Mike\N2\worm2_N2_02';
% % foldername = 'D:\Chris\Mike\N2\worm3_N2_03';
% % foldername = 'D:\Chris\Mike\DeadWorms\worm1_SC_13.03.30_26h_01';
% % foldername = 'D:\Chris\Mike\DeadWorms\worm2_SC_13.03.30_26h_02';
% % foldername = 'D:\Chris\Mike\DeadWorms\worm3_SC_13.03.30_26h_03';

load([foldername filesep 'metrics.mat']);
load([foldername filesep 'data.mat']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% USER DEFINED VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% What are we to use for velocity?
v = vel;    % could be, e.g., ptvel(:,7); if we want to try an individual point.

if DEBUG
%   v for test:
%   v = [0.2 0.2 0.2 0.2 0.2 -0.2 -0.2 -0.2 -0.2 -0.2 ...
%       0.2 0.2 0.2 0.2 0.2 -0.2 -0.2 -0.2 -0.2 -0.2];
 
    v = [42.1 42.1 42.1 42.1 42.1 -42.1 -42.1 -42.1 -42.1 -42.1 ...
         42.1 42.1 42.1 42.1 42.1 -42.1 -42.1 -42.1 -42.1 -42.1]
 
    % mode = v/0.2; 
    mode = v/42.1; 

    x = [0 cumsum(v)]';
    x = [x x x x x x x x x x x x x];
    y = 0*x;
end

% How fast slow is "stopped?"
stopThreshold = 0.05;   % mm/sec

% Minimum "run" distance [mm]
minDist = 0.3;  % 0.05;

% Minimum stopped frames [frames]
minStoppedFrames = 3;   % was 1;   % was 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% /USER DEFINED VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%---- xMode (for transitions) ------------------------------------------
% Define mode for three states (plus missing data) where:
%     2 = forward
%     0 = stopped (i.e. less than speed threshold)
%    -1 = backward
% 	  8 = missing data          was 999
% to find identify movement state changes.
xmode = NaN * ones(size(v));     % Placeholder
xmode(v >   stopThreshold) =  2;     % Forward
xmode(v < (-stopThreshold))= -1;     % Backward
xmode(abs(v) <=  stopThreshold) =  0;    % Stopped
xmode(isnan(v)) = 8;                   % NaN   was 999
%---- xMode (for transitions) ------------------------------------------


distanceTravelledRaw = sqrt(diff(x(:,7)).^2 + diff(y(:,7)).^2)';

distanceTravelled = distanceTravelledRaw;
distanceTravelled(isnan(distanceTravelledRaw)) = 0;        % Call missing data no-moves

modeWithNaN = mode;
modeWithNaN(isnan(distanceTravelledRaw)) = NaN;

distanceTravelled_mm = distanceTravelled .* mode * mmpp;  % Distances in mm

tv = timeV(2:end);

cumDist = cumsum(distanceTravelled_mm);


%--- Transitions -------------------------------------------------------
transitions = diff(xmode);
transitionsOnly = transitions(transitions ~= 0);

btf = find(transitions ==  3);  % backward to forward
ftb = find(transitions == -3);  % forward to backward
stf = find(transitions ==  2);  % stopped to forward
fts = find(transitions == -2);  % forward to stopped
bts = find(transitions ==  1);  % backward to stopped
stb = find(transitions == -1);  % stopped to backward

ftN = find(transitions ==  6);  % forward to NaN
stN = find(transitions ==  8);  % stopped to NaN
btN = find(transitions ==  9);  % backward to NaN

Ntf = find(transitions == -6);  % NaN to forward
Nts = find(transitions == -8);  % NaN to stopped
Ntb = find(transitions == -9);  % NaN to backward



transitionList = find(transitions);

runDist = [cumDist(transitionList(1)), ...
           diff(cumDist(transitionList)), ...
           cumDist(end)-cumDist(transitionList(end))];
runFrames = [transitionList(1), ... 
             diff(transitionList), ...
             numel(transitions)-transitionList(end)];


% ----- Runs ---------------------------------------------------------
runState = NaN * ones(size(runDist));
runState(find(transitionsOnly == -2 | transitionsOnly == -3)) =  1;   % Forward runs
runState(find(transitionsOnly ==  2 | transitionsOnly == -1)) =  0;   % Stopped runs
runState(find(transitionsOnly ==  3 | transitionsOnly ==  1)) = -1;   % Backward runs
% % % runState([ftb fts]) =  1;   % Forward runs
% % % runState([stf stb]) =  0;   % Stopped runs
% % % runState([btf bts]) = -1;   % Backward runs
runState(end) = xmode(end);

% Set up flag vectors
validRun = zeros(size(runDist));     % Guilty till proven innocent placeholder
validRun( (abs(runState)>0) & (abs(runDist)>minDist) ) = 1;  % Far-enough runs
validRun( (runState==0) & (runFrames>=minStoppedFrames) ) = 1; % Long-enough stops

% validTransition = zeros(size(transitionsOnly));     % Guilty till proven innocent placeholder
validTransition = validRun(1:end-1) & validRun(2:end);  

validTransitionsOnly = transitionsOnly(validTransition);
validFTB = find(validTransitionsOnly == -3);
validSTB = find(validTransitionsOnly == -1);

validTransitionList = transitionList(validTransition);


cdStopped = NaN * ones(size(cumDist)); cdStopped(xmode==0) = cumDist(xmode==0);
cdForward = NaN * ones(size(cumDist)); cdForward(xmode==2) = cumDist(xmode==2);
cdBackward = NaN * ones(size(cumDist)); cdBackward(xmode==-1) = cumDist(xmode==-1);

% List only valid FTB or STB transitions:
selectValidTransitionList = transitionList(validTransition & ((transitionsOnly == -3)|(transitionsOnly == -1)));
validFTBTransitionList = transitionList(validTransition & (transitionsOnly == -3));
validSTBTransitionList = transitionList(validTransition & (transitionsOnly == -1));

% Calculate time duration of data set
% recordingLengthSeconds = round(timeV(end) - timeV(1));  % Round to nearest integer
% ...already in metrics.mat: dataset_length_in_seconds

% Seconds per timeblock (frames/timeblock [fpt] usually == 1, but JIC)
spt = seconds_per_frame * fpt;


%======================================================================
% ASSEMBLE DATA PAYLOAD 
%======================================================================

% Calculate the number of valid ftb and stb reversals
ftbCount = numel(validFTBTransitionList); 
stbCount = numel(validSTBTransitionList); 

reversalCount = numel([validFTB validSTB]);


% Reversals per minute
reversalsPerMinute = reversalCount/(dataset_length_in_seconds/60);

%======================================================================
% Durations
% All events (valid and invalid
fwdMeanRunDurations_sec         = mean(runFrames(runState==1))      * spt;
bkwdMeanRunDurations_sec        = mean(runFrames(runState==(-1)))   * spt;
allMeanRunDurations_sec         = mean(runFrames(abs(runState)==1)) * spt;
stoppedMeanRunDurations_sec     = mean(runFrames(runState==0))      * spt;

% Valid events only
fwdMeanValidRunDurations_sec    = mean(runFrames(runState==1      & validRun==1)) * spt;
bkwdMeanValidRunDurations_sec   = mean(runFrames(runState==(-1)   & validRun==1)) * spt;
allMeanValidRunDurations_sec    = mean(runFrames(abs(runState)==1 & validRun==1)) * spt;
stoppedValidMeanRunDurations_sec= mean(runFrames(runState==0      & validRun==1)) * spt;

%======================================================================
% Distances
% All events (valid and invalid)
fwdMeanRunDistances         = mean(runDist(runState==1));
bkwdMeanRunDistances        = mean(abs(runDist(runState==(-1))));
allMeanRunDistances         = mean(abs(runDist(abs(runState)==1)));

% Valid events only
fwdMeanValidRunDistances    = mean(runDist(runState==1          & validRun==1));
bkwdMeanValidRunDistances   = mean(abs(runDist(runState==(-1)   & validRun==1)));
allMeanValidRunDistances    = mean(abs(runDist(abs(runState)==1 & validRun==1)));


%======================================================================
% Speeds
fwdMeanSpeed    = mean(v(v>stopThreshold));
bkwdMeanSpeed   = mean(v(v<(-stopThreshold)));
allMeanSpeed    = mean(abs(v(abs(v)>stopThreshold)));


%======================================================================
% Write reversal info to screen 
fprintf(1, ['\nForward to Backward: ' int2str(numel(validFTB)) ' \n']);
fprintf(1, ['Stopped to Backward: ' int2str(numel(validSTB)) ' \n']);
fprintf(1, ['\n\nTotal Reversals: ' int2str(reversalCount) ' \n\n']);



if SHOWPLOTS

    %======================================================================
    %==== PLOTTING ========================================================
    %======================================================================

    %--- PLOT 1 ------------------
    % Only if VERBOSE
    if VERBOSE
        figure; plot(transitions(transitionList), 'o-'); grid on
    end
    %--- /PLOT 1 ------------------

    %--- PLOT 2 ------------------
    % Only if VERBOSE
    if VERBOSE
        figure; plot(tv, cumDist, '.-');
        hold on;  plot(tv(ftb), cumDist(ftb), 'ro', 'LineWidth', 2); hold off
        % hold on;  plot(tv(fts), cumDist(fts), 'ko', 'LineWidth', 2); hold off
        hold on;  plot(tv(stb), cumDist(stb), 'bo', 'LineWidth', 2); hold off

        hold on;  plot(tv(validTransitionList), cumDist(validTransitionList), 'gs', 'LineWidth', 3, 'MarkerSize', 24); hold off

        xlabel('Time  [seconds]', 'FontWeight', 'bold');
        ylabel('Cumulative Distance Travelled  [mm]', 'FontWeight', 'bold');
        legend({'CumDist', 'FTB', 'STB', 'ValidTransitionList'}, 'Location', 'Best');
        title(foldername,...     
                  'Interpreter', 'none', 'FontWeight', 'bold');  %, 'FontSize', figuretitlefontsize);% legend({'CumDist', 'FTB', 'FTS', 'STB'});
        % Format printout
        set(gcf, 'PaperOrientation', 'Landscape');
        set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
    end
    %--- PLOT /2 ------------------

    %--- PLOT 3 ------------------
    % Only if VERBOSE
    if VERBOSE
        legendtext = [];    % blank placeholder

        figure; 
        if numel(cdForward(~isnan(cdForward))) > 0
            hold on; plot(tv, cdForward, 'b', 'LineWidth', 2); hold off
            legendtext{end+1} = 'Forward';
        end
        if numel(cdStopped(~isnan(cdStopped))) > 0
            hold on; plot(tv, cdStopped, 'k', 'LineWidth', 2); hold off
            legendtext{end+1} = 'Stopped';
        end
        if numel(cdBackward(~isnan(cdBackward))) > 0
            hold on; plot(tv, cdBackward, 'r', 'LineWidth', 2); hold off
            legendtext{end+1} = 'Backward';
        end

        % figure; plot(tv, cdBackward, 'r', 'LineWidth', 2);
        % hold on; plot(tv, cdStopped, 'k', 'LineWidth', 2); hold off
        % hold on; plot(tv, cdForward, 'b', 'LineWidth', 2); hold off

        if ftb, hold on;  plot(tv(ftb), cumDist(ftb), 'ro', 'LineWidth', 2); hold off; legendtext{end+1} = 'FTB'; end
        if fts, hold on;  plot(tv(fts), cumDist(fts), 'ko', 'LineWidth', 2); hold off; legendtext{end+1} = 'FTS'; end
        if stb, hold on;  plot(tv(stb), cumDist(stb), 'bo', 'LineWidth', 2); hold off; legendtext{end+1} = 'STB'; end
        if btf, hold on;  plot(tv(btf), cumDist(btf), 'mo', 'LineWidth', 2); hold off; legendtext{end+1} = 'BTF'; end
        if bts, hold on;  plot(tv(bts), cumDist(bts), 'yo', 'LineWidth', 2); hold off; legendtext{end+1} = 'BTS'; end
        if stf, hold on;  plot(tv(stf), cumDist(stf), 'co', 'LineWidth', 2); hold off; legendtext{end+1} = 'STF'; end

        if validTransitionList, hold on;  plot(tv(validTransitionList), cumDist(validTransitionList), 'gs', 'LineWidth', 3, 'MarkerSize', 24); hold off;  legendtext{end+1} = 'ValidTransitionList'; end

        xlabel('Time  [seconds]', 'FontWeight', 'bold');
        ylabel('Cumulative Distance Travelled  [mm]', 'FontWeight', 'bold');
        legend(legendtext, 'Location', 'Best');
        % legend({'Backward', 'Stopped', 'Forward', 'FTB', 'FTS', 'STB', 'BTF', 'BTS', 'STF', 'ValidTransitionList'}, 'Location', 'Best');
        title(foldername,...     
                  'Interpreter', 'none', 'FontWeight', 'bold');  %, 'FontSize', figuretitlefontsize);% legend({'CumDist', 'FTB', 'FTS', 'STB'});
        % Format printout
        set(gcf, 'PaperOrientation', 'Landscape');
        set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
    end
    %--- PLOT /3 ------------------

    %--- PLOT 4 ------------------
    % Plain 'n simple plot
    figure; plot(tv, cumDist, '-');
    xlabel('Time  [seconds]', 'FontWeight', 'bold');
    ylabel('Cumulative Distance Travelled  [mm]', 'FontWeight', 'bold');
    % title(foldername,...     
    %           'Interpreter', 'none', 'FontWeight', 'bold');  %, 'FontSize', figuretitlefontsize);% legend({'CumDist', 'FTB', 'FTS', 'STB'});
    title({foldername; ...
           ['Min. movement speed: ' num2str(stopThreshold) ' mm/sec']; ...  
           ['Min. "run" distance: ' num2str(minDist) ' mm']; ...
           ['Min. stopped duration: ' int2str(minStoppedFrames) ' frames']},...     
              'Interpreter', 'none', 'FontWeight', 'bold');  %, 'FontSize', figuretitlefontsize);% legend({'CumDist', 'FTB', 'FTS', 'STB'});

    ylim = get(gca, 'YLim');
    yticklabel = get(gca, 'YTickLabel');

    hold on
    createMinorYGrid(minDist)
    hold off


    % set(gca, 'YGrid', 'on');
    % % set(gca, 'YMinorGrid', 'on');
    % set(gca, 'YTick', [ylim(1) : minDist : ylim(2)]);

    % Format printout
    set(gcf, 'PaperOrientation', 'Landscape');
    set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
    %--- PLOT /4 ------------------

    % %--- PLOT 5 ------------------
    % figure; plot(tv, cumDist, '-');
    % hold on;  plot(tv(ftb), cumDist(ftb), 'ro', 'LineWidth', 2); hold off
    % hold on;  plot(tv(stb), cumDist(stb), 'bo', 'LineWidth', 2); hold off
    % 
    % hold on;  plot(tv(selectValidTransitionList), cumDist(selectValidTransitionList), 'gs', 'LineWidth', 3, 'MarkerSize', 24); hold off
    % 
    % xlabel('Time  [seconds]', 'FontWeight', 'bold');
    % ylabel('Cumulative Distance Travelled  [mm]', 'FontWeight', 'bold');
    % legend({'CumDist', 'FTB', 'STB', 'ValidTransitionList'}, 'Location', 'Best');
    % title(foldername,...     
    %           'Interpreter', 'none', 'FontWeight', 'bold');  %, 'FontSize', figuretitlefontsize);% legend({'CumDist', 'FTB', 'FTS', 'STB'});
    % % Format printout
    % set(gcf, 'PaperOrientation', 'Landscape');
    % set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
    % %--- PLOT /5 ------------------

    %--- PLOT 6 ------------------
    figure; plot(tv, cumDist, '-');
    hold on;  plot(tv(ftb), cumDist(ftb), 'ro', 'LineWidth', 2); hold off
    hold on;  plot(tv(stb), cumDist(stb), 'bo', 'LineWidth', 2); hold off

    hold on;  plot(tv(validFTBTransitionList), cumDist(validFTBTransitionList), 'rs', 'LineWidth', 3, 'MarkerSize', 24); hold off
    hold on;  plot(tv(validSTBTransitionList), cumDist(validSTBTransitionList), 'bs', 'LineWidth', 3, 'MarkerSize', 24); hold off

    xlabel('Time  [seconds]', 'FontWeight', 'bold');
    ylabel('Cumulative Distance Travelled  [mm]', 'FontWeight', 'bold');
    % legend({'CumDist', ...
    %     'FTB', ,...
    %     'STB', ...
    %     ['Valid FTB: ' int2str(numel(validFTBTransitionList))], ['Valid STB: ' int2str(numel(validSTBTransitionList))]},...
    %     'Location', 'Best');
    legend({'CumDist', ...
        ['FTB (', int2str(ftbCount) ' valid)'], ...
        ['STB (', int2str(stbCount) ' valid)']}, ...
        'Location', 'Best');
    % title({foldername; ...
    %       ['Min. movement speed: ' num2str(stopThreshold) 'mm/sec,  Min. "run" distance: ' num2str(minDist) 'mm, Min. stopped duration: ' int2str(minStoppedFrames) ' frames']},...     
    %           'Interpreter', 'none', 'FontWeight', 'bold');  %, 'FontSize', figuretitlefontsize);% legend({'CumDist', 'FTB', 'FTS', 'STB'});
    title({foldername; ...
           ['Min. movement speed: ' num2str(stopThreshold) ' mm/sec']; ...  
           ['Min. "run" distance: ' num2str(minDist) ' mm']; ...
           ['Min. stopped duration: ' int2str(minStoppedFrames) ' frames']},...     
              'Interpreter', 'none', 'FontWeight', 'bold');  %, 'FontSize', figuretitlefontsize);% legend({'CumDist', 'FTB', 'FTS', 'STB'});
    % Format printout
    set(gcf, 'PaperOrientation', 'Landscape');
    set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
    %--- PLOT /6 ------------------


    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    % % First figure out whether there's any pruning to be done
    % firstValidRun = find(validRun==1, 1, 'first');
    % if isempty(firstValidRun)
    %     error('No valid runs!');
    % end
    % lastValidRun = find(validRun==1, 1, 'last');
    % if ~any(validRun(firstValidRun:lastValidRun)==0)
    %     disp('ATTENTION: No invalid runs so no pruning to be done!!');
    %     return
    % end
    % 
    % prunelist = [];
    % for i = firstValidRun+1:numel(validRun)
    %     if validRun(i) == 0
    %         prunelist = [prunelist, i];
    %         validRun(i) = [];
    %         
    %         validTransition(i) = 
    %     end
    %     
    %     
    % end

end     % if SHOWPLOTS

return;



function createMinorYGrid(tick_dist)

    my_yticks = get(gca, 'YTick');
    my_ylim   = get(gca, 'YLim');
    my_xlim   = get(gca, 'XLim');
    
%     tick_dist= (my_yticks(2)-my_yticks(1))/nMinorDiv;
    offset   = mod((my_yticks(1) - my_ylim(1)), tick_dist);
    
    % specify the minor grid vector
    yg = [my_ylim(1) : tick_dist : my_ylim(2)];
    yg = yg + offset;
    
    % specify the Y-position and the height of minor grids
    xg = get(gca, 'XLim');  % [0 0.1];
    yy = reshape([yg;yg;NaN(1,length(yg))],1,length(yg)*3);
    xx = repmat([xg NaN],1,length(yg));
    plot(xx,yy, ':', 'Color', [.9 .9 .9]);
    axis([my_xlim(1), my_xlim(2) my_ylim(1) my_ylim(2)]);
