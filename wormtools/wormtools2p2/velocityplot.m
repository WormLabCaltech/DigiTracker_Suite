function [] = velocityplot(directory, vel)

%VELOCITYPLOT    Plot data coverage chart (percent valid frames).
%   FORMAT: velocityplot(directory, x, vel, fre)
%      where 
%      - "directory" is a string containing a directory name
%         (path) for use as a window title.
%      - "vel" is a vector of velocities (ideally from the 
%         data in "directory"). 
%   Plots chart depicting worm velocity versus time, with blank 
%   areas showing missing data.  Displays (as a percentage) how 
%   much of the time has valid (i.e. non-missing) data.
% 
%   Based on coverageplot_02
%
%   C. J. Cronin 2-24-02
%   Revised 10-28-04 CJC
%   $Revision: 1.02 $  $Date: 2004/10/28 xx:xx:xx $
% 

% r1.02: Replaced '\' with filesep as appropriate for portability 
%   to non-Windows platforms.  
%   Dated 10-28-04 x:xxAM.
% 
% r1.01: Initial release.  Developed for Shawn Xu and 
%   Cori Bargmann.  Function based on coverageplot_02
%   Dated 2-24-03 12:50PM.


% some error checking
if nargout > 0
	error('FORMAT: velocityplot(directory, x, vel, fre)');   
end

if nargin ~= 2
	error('FORMAT: velocityplot(directory, vel)');   
end

      
% Calculate Statistics
% Velocity
vellength = max(size(vel));
velNotNaN = max(size(vel(logical(~isnan(vel)))));
velpct = velNotNaN*100/vellength;

      
% Parse bottom three directory names from directory string for figure title
delimiter_positions = findstr(filesep, directory);
% delimiter_positions = findstr('\', directory);
if size(delimiter_positions, 2) > 2
    figure_name = ['...' directory(delimiter_positions(end-2):end)];
else
    figure_name = directory;
end


% Begin Plot:

figure('Name', figure_name);        % New figure entitled *figure_name*

% Initialize Variables
linewdth = 2;
pos = 1;        % ...to position legend in upper right-hand corner
figuretitlefontsize = 14;

% Velocity 
plot([1:vellength], vel, 'LineWidth', linewdth);
% title(['Velocity vs. Time for ' directory ' - ' date],...     
title(['Velocity vs. Time for ' directory ' - ' datestr(now,23)],...     
    'FontWeight', 'bold', 'FontSize', figuretitlefontsize, 'Interpreter', 'none');
xlabel('Frame Number', 'FontWeight', 'bold');
ylabel('Velocity  (mm/sec)', 'FontWeight', 'bold');
grid on;
axis([0 vellength -0.8 0.8]);
ax1 = gca;
legendtext = ['Velocity:   ' num2str(velNotNaN,'%5.0d') ' valid frames out of ' num2str(vellength,'%5.0d') ' = ' num2str(velpct,'%4.1f') '% coverage'];
legend(gca, legendtext, pos);
set(ax1, 'FontWeight', 'bold');

% If we later want to also show time scale in seconds
%   (but reallize that top axis labels overlap with figure title)
% % % ax2 = axes('Position',get(ax1,'Position'),...
% % %            'XAxisLocation','top',...
% % %            'YAxisLocation','right',...
% % %            'Color','none',...
% % %            'XColor','k','YColor','k');
% % % axis([0 180 -0.8 0.8]);
% % % set(ax2, 'FontWeight', 'bold');


drawnow

% Format printout (boilerplate)
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);



return;