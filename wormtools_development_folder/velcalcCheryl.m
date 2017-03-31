function [vel, theta, mode, velc] = velcalcCheryl(directory)



% Establish whether we Want to Definitely save for Matlab v6.x readability:
FORCE_to_v6 = 1;   % 1 = true, we want to save for v6 readability.
% Check for Matlab version
matlabversion = ver('MATLAB');
matlabversion = str2num(matlabversion.Version);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prompt for values necessary for velocity calculation:
    minutes = inputdlg('Enter recording length (in minutes)  (from index.txt file):','Recording length',1, {num2str(240)}, 'on');
    minutes = minutes{1};
    minutes = str2num(minutes);
     
    mmpp = inputdlg('Enter mm / pixel (mmpp) value:','mmpp value',1, {num2str(0.0041)}, 'off');
    mmpp = mmpp{1};
    mmpp = str2num(mmpp);
    
    fpt = inputdlg(['Enter ''frames per timeblock'' value:                                  ';...
                     '  (that is, only consider every  x''th frame for velocity calculation)'],...
        'fpt value',1, {num2str(1)}, 'off');
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

% Calculate spf
spf = (minutes*60)/(size(points,1)/2);     % seconds / #frames

% ...and clear out memory
clear points

% Velocity Calculation
[vel, theta, mode, velc] = translation3Cheryl(x, y, mmpp, spf, fpt);

% create reference time vector for velocity plot
minV = [  minutes/size(velc,2) : minutes/size(velc,2)   : minutes];

% plot velc
figure; plot(minV,velc,'b.'); grid on;

currentaxis = axis;
axis([currentaxis(1:2) -0.1 0.25]);
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

return
