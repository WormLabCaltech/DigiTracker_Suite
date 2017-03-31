function [vel, theta, mode, velc] = velcalcElly(directory)

%VELCALCELLY    Calculates and plots velocity and quiescence data from xy coordinate data.
%   FORMAT: [vel, theta, mode, velc] = velcalcElly(directory)
%      where 
%      - "directory" is a folder name (with path) containing a worm's
%        'points' and 'data.mat' files.
%         time, columns are data points along a worm's "spine" from
%         head to tail).
%      - "vel" is a vector of instantaneous velocities every N'th
%         frame (where N = fpt).  The velocities are the mean 
%         of point velocities of the rear ~2/3 of the worm 
%         (points 5 to the tail end).  
%      - "theta" is the angle (in radians) of movement
%      - "mode" is a flag indicating forward (1) or backward (-1)
%         movement.
%      - "velc" is a vector of instantaneous velocities of the CENTROID of
%         the rear 2/3 of the worm (mean position of points 5 to tail end). 
%
%      Other useful definitions
%      - "mmpp" is the ratio "millimeters per pixel" which is 
%         a function of microscope and camera optics.  
%      - "spf" (seconds per frame) is the time in seconds between
%         successive frames
%      - "fpt" (literally "frames per timeblock") is the 
%         number of frames to group together for the velocity 
%         calculation.  That is, velocity is calculated by 
%         sampling worm position every N'th frame, where N = fpt.
%
% Based on velcalcCheryl

%   Christopher J. Cronin
%   cjc@caltech.edu
%   Sternberg Lab
%   California Institute of Technology
%   Pasadena  CA  91125
%   February 22, 2013




% Establish whether we Want to Definitely save for Matlab v6.x readability:
FORCE_to_v6 = 1;   % 1 = true, we want to save for v6 readability.
% Check for Matlab version
matlabversion = ver('MATLAB');
matlabversion = str2num(matlabversion.Version);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prompt for values necessary for velocity calculation:
% minutes = inputdlg('Enter recording length (in minutes)  (from index.txt file):','Recording length',1, {num2str(420)}, 'on');
% minutes = minutes{1};
% minutes = str2num(minutes);
     
mmpp = inputdlg('Enter mm / pixel (mmpp) value:','mmpp value',1, {num2str(0.00475)}, 'off');
mmpp = mmpp{1};
mmpp = str2num(mmpp);
    
fpt = inputdlg(['Enter ''frames per timeblock'' value:                                  ';...
                '  (that is, only consider every  x''th frame for velocity calculation)'],...
                'fpt value',1, {num2str(10)}, 'off');
fpt = fpt{1};
fpt = str2num(fpt);
    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find file(s) named points* in input directory:
pointsname = dir([directory filesep 'points*']);

% Take first points* file as our choice:
pointsname = pointsname(1).name;

% Load selected directory 
points = load([directory filesep pointsname]);
load([directory filesep 'data.mat']);

% Calculate length of recording
if size(points,2) == 14
    minutes = points(end,1) / 60;
else
    error('Non-Digi-Recognizer data.  Complain to Chris...');
end

% Calculate spf
spf = (minutes*60)/(size(points,1)/2);     % seconds / #frames

% ...and clear out memory
clear points

% create reference time vector for velocity plot
minV = 0 : minutes/size(x,1) : minutes;
% minV = [  minutes/size(velc,2) : minutes/size(velc,2)   : minutes];

% Velocity Calculations
[vel, theta, mode, velc, velALL, velcALL] = translation3Elly(x, y, mmpp, spf, fpt);
[ptvel, ptdir, ptmode] = pointtranslation(x, y, mmpp, spf, fpt);


%////////////////// FIXME /////////////////////
%////////////////// FIXME /////////////////////
%////////////////// FIXME /////////////////////
velc = velcALL;
fprintf(1,'\n\n\n     ===> velc using WHOLE worm !!!!!!!!! \n\n\n');
%////////////////// FIXME /////////////////////
%////////////////// FIXME /////////////////////
%////////////////// FIXME /////////////////////


% and need to know resulting Seconds per Timeblock:
spt = spf * fpt;    % seconds per timeblock (to enable converting frames to time)

% Decimate reference time vector according to fpt (a la translation3Cheryl)
minV = minV(1:fpt:numel(minV));
minV = minV(1:(end-1));     % Drop last time point b/c one less velocity than position
lastVelTime = minV(end);

% plot velc
figure; plot(minV, velc, 'b.'); grid on;

currentaxis = axis;
axis([currentaxis(1:2) -0.2 0.2]);
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


% title(directory, 'FontWeight', 'bold', 'Interpreter', 'none');
title([directory '   --   fpt = ' num2str(fpt)], 'FontWeight', 'bold', 'Interpreter', 'none');

xlabel('Time  [minutes]', 'FontWeight', 'bold');
ylabel('Velocity  [mm/sec]', 'FontWeight', 'bold');


set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Save x and y matrices (& fingerprint) in file "data" 
%   in input directory
if ( FORCE_to_v6 & (matlabversion >= 7.0) )
%     save([directory filesep 'data'], 'x', 'y', 'timeV', 'fingerprint' , '-v6');    
    save([directory filesep 'veldata'], 'velc', 'fpt', 'vel', 'mode', 'spf', 'mmpp', 'fingerprint' , '-v6');    
else
%     save([directory filesep 'data'], 'x', 'y', 'timeV', 'fingerprint');    
    save([directory filesep 'veldata'], 'velc', 'fpt', 'vel', 'mode', 'spf', 'mmpp', 'fingerprint');    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot just the Lethargus part...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Query for extraction info
options.WindowStyle = 'normal';
startTime = inputdlg('Start Time for Lethargus plot? [minutes]','Start Time?',1, {num2str(0)}, options);
startTime = startTime{1};
startTime = str2num(startTime);

duration = inputdlg('Duration of Lethargus plot [minutes]?','Duration?',1, {num2str(420)}, options);
duration = duration{1};
duration = str2num(duration);


keep = find((minV >= startTime) & (minV <= (startTime + duration)) );

%-------------------------------------------------------------------

% Re-plot extracted points:
% plot velc
figure; plot(minV(keep), velc(keep), 'b.-'); grid on;

set(gca, 'XTick',  0:60:minV(end));     % Set ticks to hours

currentaxis = axis;
axis([minV(keep(1)) minV(keep(end)) -0.2 0.2]);
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


% title(directory, 'FontWeight', 'bold', 'Interpreter', 'none');
title([directory '   --   fpt = ' num2str(fpt)], 'FontWeight', 'bold', 'Interpreter', 'none');

xlabel('Time  [minutes]', 'FontWeight', 'bold');
ylabel('Velocity  [mm/sec]', 'FontWeight', 'bold');


set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');

%-------------------------------------------------------------------

% % And RE-Re-plot extracted points with time starting from zero:
% % plot velc
% minVOffset = minV - minV(keep(1));
% % minV = minV - minV(keep(1));
% figure; plot(minVOffset(keep), velc(keep), 'b.-'); grid on;
% 
% set(gca, 'XTick',  0:60:minVOffset(end));     % Set ticks to hours
% 
% currentaxis = axis;
% axis([minVOffset(keep(1)) minVOffset(keep(end)) -0.2 0.2]);
% %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% 
% 
% % title(directory, 'FontWeight', 'bold', 'Interpreter', 'none');
% title([directory '   --   fpt = ' num2str(fpt)], 'FontWeight', 'bold', 'Interpreter', 'none');
% 
% xlabel('Time  [minutes]', 'FontWeight', 'bold');
% ylabel('Velocity  [mm/sec]', 'FontWeight', 'bold');
% 
% 
% set(gcf, 'PaperOrientation', 'Landscape');
% set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
% set(gca, 'FontWeight', 'bold');




%-------------------------------------------------------------------
%-------------------------------------------------------------------
%--- QUIESCENCE ----------------------------------------------------
%-------------------------------------------------------------------
%-------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Query for quiescence info
options.WindowStyle = 'normal';

stoppedVel = inputdlg('Maximum speed still considered ''stopped''? [mm/sec]','Stopped Speed?',1, {num2str(0.001)}, options);
stoppedVel = stoppedVel{1};
stoppedVel = str2num(stoppedVel);

windowLengthMinutes = inputdlg('Size of sliding window [minutes] for calculating quiescence fraction?','Quiescence Fraction Window Size?',1, {num2str(10)}, options);
windowLengthMinutes = windowLengthMinutes{1};
windowLengthMinutes = str2num(windowLengthMinutes);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stoppedVel = 0.001;     % mm/sec
% windowLengthMinutes = 10;   % in minutes, duh

windowLengthFrames = floor(windowLengthMinutes * numel(minV)/lastVelTime);
lowerHalfWindow = floor((windowLengthFrames-1)/2);
upperHalfWindow =  ceil((windowLengthFrames-1)/2);

stopped = abs(velc) < stoppedVel;
stoppedALL = abs(velcALL) < stoppedVel;     % Stopped vector considering whole worm

Q = NaN*ones(size(velc));   % Placeholder vector
for i = (1 + lowerHalfWindow) : (numel(velc) - upperHalfWindow)
    Q(i) = mean(  stopped(i-lowerHalfWindow:i+upperHalfWindow) );
%     QQ(i) = mean( abs(velc(i:i+windowLengthFrames)) < stoppedVel );
end

% for i = 1:numel(velc)-windowLengthFrames
%     QQ(i) = mean( abs(velc(i:i+windowLengthFrames)) < stoppedVel );
% end

% Plot to see QUIESCENCE
%-------------------------------------------------------------------
fig = figure('Toolbar', 'figure');  % Toolbar forces zoom tools to remain
backcolor = get(gcf, 'Color');

h = uicontrol('Style', 'pushbutton',...
                'Position',[20 20 100 40],...
                'String','Got it...',...
                'Callback','uiresume(gcbf)');
t1 = uicontrol('Style', 'text', ...
                'Position', [132, 13, 338, 48], ... 
                'HorizontalAlignment', 'left', ...
                'BackgroundColor', backcolor, ...
                'String', ...
                {   'Use Data-Cursor to select START of Lethargus'; 
                    '(i.e. when Fraction Quiescence >= 0.05 for at least 20 minutes)'; 
                    'then press ''Got it...'''});

ax = axes('position',[.1  .25  .8  .65]);
plot(minV, Q, 'r.-'); grid on


% figure; plot(minV, Q, 'r.-'); grid on
% % figure; plot(minV(1:numel(Q)), Q, 'r.-'); grid on

% set(gca, 'XTick',  0:60:minV(end));     % Set ticks to hours

title([directory '   --   fpt = ' num2str(fpt) '   --   Window width = ' num2str(windowLengthMinutes) ' minutes'], 'FontWeight', 'bold', 'Interpreter', 'none');

xlabel('Time  [minutes]', 'FontWeight', 'bold');
ylabel('Fraction Quiescence', 'FontWeight', 'bold');


set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');



dcm_obj = datacursormode(fig);

set(dcm_obj,'DisplayStyle','datatip',...
'SnapToDataVertex','on','Enable','on')

uiwait(gcf);    % Wait for button press
c_info = getCursorInfo(dcm_obj);
LStartIndex = c_info.DataIndex;
close(fig);
%-------------------------------------------------------------------
%-------------------------------------------------------------------

fig = figure('Toolbar', 'figure');  % Toolbar forces zoom tools to remain
backcolor = get(gcf, 'Color');

h = uicontrol('Style', 'pushbutton',...
                'Position',[20 20 100 40],...
                'String','Done!',...
                'Callback','uiresume(gcbf)');
t1 = uicontrol('Style', 'text', ...
                'Position', [132, 13, 338, 48], ... 
                'HorizontalAlignment', 'left', ...
                'BackgroundColor', backcolor, ...
                'String', ...
                {   'Use Data-Cursor to select END of Lethargus'; 
                    '(i.e. when Fraction Quiescence < 0.05)'; 
                    'then press ''Done!'''});

ax = axes('position',[.1  .25  .8  .65]);
plot(minV, Q, 'r.-'); grid on
hold on; 
plot(minV(LStartIndex), Q(LStartIndex), 'bs', 'LineWidth', 2);  % Annotate start of lethargus
hold off;

% figure; plot(minV, Q, 'r.-'); grid on
% % figure; plot(minV(1:numel(Q)), Q, 'r.-'); grid on

% set(gca, 'XTick',  0:60:minV(end));     % Set ticks to hours

title([directory '   --   fpt = ' num2str(fpt) '   --   Window width = ' num2str(windowLengthMinutes) ' minutes'], 'FontWeight', 'bold', 'Interpreter', 'none');

xlabel('Time  [minutes]', 'FontWeight', 'bold');
ylabel('Fraction Quiescence', 'FontWeight', 'bold');


set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');



dcm_obj = datacursormode(fig);

set(dcm_obj,'DisplayStyle','datatip',...
'SnapToDataVertex','on','Enable','on')

uiwait(gcf);    % Wait for button press
c_info = getCursorInfo(dcm_obj);
LEndIndex = c_info.DataIndex;
close(fig);
%-------------------------------------------------------------------
%-------------------------------------------------------------------
%-------------------------------------------------------------------

figure; plot(minV, Q, 'r.-'); grid on
hold on; 
plot(minV(LStartIndex), Q(LStartIndex), 'bs', 'LineWidth', 2);  % Annotate start of lethargus
plot(minV(LEndIndex), Q(LEndIndex), 'bs', 'LineWidth', 2);  % Annotate end of lethargus
hold off;   

% % figure; plot(minV(1:numel(Q)), Q, 'r.-'); grid on

% set(gca, 'XTick',  0:60:minV(end));     % Set ticks to hours

title([directory '   --   fpt = ' num2str(fpt) '   --   Window width = ' num2str(windowLengthMinutes) ' minutes'], 'FontWeight', 'bold', 'Interpreter', 'none');

xlabel('Time  [minutes]', 'FontWeight', 'bold');
ylabel('Fraction Quiescence', 'FontWeight', 'bold');


set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');

%-------------------------------------------------------------------
%-------------------------------------------------------------------
%-------------------------------------------------------------------
%-------------------------------------------------------------------

LDuration = minV(LEndIndex) - minV(LStartIndex);
fprintf(1, ['\nLethargus duration: ' num2str(LDuration) ' minutes\n']);
fprintf(1, ['(from ' num2str(minV(LStartIndex)) ' to ' num2str(minV(LEndIndex)) ')\n\n']);



% return

% statechange = diff(stopped);
% 
% startQ = find(statechange == 1);
% endQ = find(statechange == -1);
% 
% Qdurations = minV(endQ) - minV(startQ);

%==============================================================
Lstopped = stopped(LStartIndex:LEndIndex);
minVstopped = minV(LStartIndex:LEndIndex);

Lstatechange = diff(Lstopped);

LstartQ = find(Lstatechange == 1);
LendQ = find(Lstatechange == -1);

if (LendQ(1)<=(LstartQ(1)))
    LendQ(1) = [];   % Just trim off extra 'end' index from start of end-vector
%     error('Mismatched FIRST start and end');
end
if (LendQ(end)<=(LstartQ(end)))
    LstartQ(end) = [];  % Just trim off extra 'start' index from end of start-vector
%     error('Mismatched LAST start and end');
end

if (numel(LendQ)~=(numel(LstartQ)))
    % We shouldn't get here, but just in case there's still a mismatch
    % throw an error
    error('Mismatched NUMBER OF starts and ends.  Complain to Chris.');
end

Qdurations = minVstopped(LendQ) - minVstopped(LstartQ);

%---------------------------------
figure; plot(Qdurations, 'b.-'); grid on
title([directory '   --   fpt = ' num2str(fpt) '   --   Window width = ' num2str(windowLengthMinutes) ' minutes'], 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('[index of event, first through last during Lethargus]', 'FontWeight', 'bold');
ylabel('Quiescent-Event Durations [minutes]', 'FontWeight', 'bold');

set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');

%---------------------------------
%---------------------------------
figure; plot(sort(Qdurations, 'descend'), 'm.-'); grid on
title([directory '   --   fpt = ' num2str(fpt) '   --   Window width = ' num2str(windowLengthMinutes) ' minutes'], 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('[index of event, sorted: longest duration to shortest...]', 'FontWeight', 'bold');
ylabel('Sorted Quiescent-Event Durations [minutes]', 'FontWeight', 'bold');

set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
%---------------------------------
%---------------------------------
%---------------------------------

fprintf(1, ['Total stopped duration during Lethargus: ' num2str(sum(Qdurations)) ' minutes\n\n']);




% %&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% %&&&&&&&   In case we want to see velc vs velcALL   &&&&&&&&&&&&&
% figure; plot(minV, velc, 'b.-', 'LineWidth', 3); grid on
% hold on; plot(minV, velcALL, 'r.-', 'LineWidth', 2); hold off
% %&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% %&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&



return
