function [] = coverageplot(directory, x, vel, fre)

%COVERAGEPLOT    Plot data coverage chart (percent valid frames).
%   FORMAT: coverageplot(directory, x, vel, fre)
%      where 
%      - "directory" is a string containing a directory name
%         (path) for use as a window title.
%      - "x" is a matrix of x coordinates (ideally from the 
%         data in "directory:). 
%      - "vel" is a vector of velocities (ideally from the 
%         data in "directory"). 
%      - "fre" is a matrix of bending frequencies (ideally from the 
%         data in "directory"). 
%   Plots diagnostic chart depicting worm position, velocity, and
%   bending frequency versus time, with blank areas showing 
%   missing data.  Displays (as a percentage) how much of the time 
%   has valid (i.e. non-missing) data.

%   C. J. Cronin 7-24-02
%   Revised 
%   $Revision: 1.02 $  $Date: 2002/09/03 xx:xx:xx $
% 
% r1.02: Adds help information.  Adds revision history.  Adds
%   comments.




% some error checking
if nargout > 0
	error('FORMAT: coverageplot(directory, x, vel, fre)');   
end

if nargin ~= 4
	error('FORMAT: coverageplot(directory, x, vel, fre)');   
end

      
 % Calculate Statistics
      % Position
      xcolumn = (mean(x(:,5:end)'))';
%       xcolumn = x(:,1);
      xlength = max(size(xcolumn));
      xNotNaN = max(size(xcolumn(logical(~isnan(xcolumn)))));
      xpct = xNotNaN*100/xlength;

      % Velocity
      vellength = max(size(vel));
      velNotNaN = max(size(vel(logical(~isnan(vel)))));
      velpct = velNotNaN*100/vellength;

      % Frequency
      frecolumn = fre(17:(end-16),5);
      frelength = max(size(frecolumn));
      freNotNaN = max(size(frecolumn(logical(~isnan(frecolumn)))));
      frepct = freNotNaN*100/frelength;
      
      % Print statistics
      fprintf(1, '%s\n', [directory]);
      fprintf(1, 'fre:  %5.0d valid frames out of %5.0d = %4.1f%%\n', freNotNaN, frelength, frepct);
      fprintf(1, 'vel:  %5.0d valid frames out of %5.0d = %4.1f%%\n', velNotNaN, vellength, velpct);
      fprintf(1, 'X:    %5.0d valid frames out of %5.0d = %4.1f%%\n\n', xNotNaN, xlength, xpct);


      
% Parse bottom three directory names from directory string for figure title
delimiter_positions = findstr('\', directory);
if size(delimiter_positions, 2) > 2
    figure_name = ['...' directory(delimiter_positions(end-2):end)];
else
    figure_name = directory;
end


% Begin Plot:

figure('Name', figure_name);        % New figure entitled *figure_name*

% Initialize Variables
linewdth = 2;
pos = 3; 
figuretitlefontsize = 14;

% Frequency 
subplot(3,1,1);
plot([17:(frelength+16)], frecolumn, 'LineWidth', linewdth);
title([directory],...     
    'FontWeight', 'bold', 'FontSize', figuretitlefontsize, 'Interpreter', 'none');
xlabel('Frame Number', 'FontWeight', 'bold');
ylabel('Frequency - Bend #5 (Hz)', 'FontWeight', 'bold');
grid on;
axis([0 xlength -0.4 0.8]);
legendtext = ['Frequency: ' num2str(freNotNaN,'%5.0d') ' valid frames out of ' num2str(frelength,'%5.0d') ' = ' num2str(frepct,'%4.1f') '% coverage'];
legend(gca, legendtext, pos);
set(gca, 'FontWeight', 'bold');


% Velocity 
subplot(3,1,2);
plot([1:vellength], vel, 'LineWidth', linewdth);
xlabel('Frame Number', 'FontWeight', 'bold');
ylabel('Velocity  (mm/sec)', 'FontWeight', 'bold');
grid on;
axis([0 xlength -1.2 0.8]);
legendtext = ['Velocity:   ' num2str(velNotNaN,'%5.0d') ' valid frames out of ' num2str(vellength,'%5.0d') ' = ' num2str(velpct,'%4.1f') '% coverage'];
legend(gca, legendtext, pos);
set(gca, 'FontWeight', 'bold');


% Position 
subplot(3,1,3);
plot([1:xlength], xcolumn, 'LineWidth', linewdth);
xlabel('Frame Number', 'FontWeight', 'bold');
ylabel('x-position', 'FontWeight', 'bold');
grid on;
xlim([0 xlength]);
legendtext = ['Position:   ' num2str(xNotNaN,'%5.0d') ' valid frames out of ' num2str(xlength,'%5.0d') ' = ' num2str(xpct,'%4.1f') '% coverage'];
legend(gca, legendtext, pos);
set(gca, 'FontWeight', 'bold');

drawnow

% Format printout
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);



return;