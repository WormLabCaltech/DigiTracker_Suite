function [] = lengthcalc(mmpp, varargin)
 
%LENGTHCALC    Display wormlength vs time.
%   FORMAT: lengthcalc(mmpp, varargin)
%      where 
%      - "mmpp" is the ratio "millimeters per pixel" which is 
%         a function of microscope and camera optics.  For the
%         Sternberg Lab's worm tracking rig in Kerckhoff 221:
%             Magnification    mmpp (mm/pixel)
%             -------------    ---------------
%                  6x               0.017
%                 12x               0.0085
%                 25x               0.0041
%                 50x               0.0020
%      - "varargin" are the names of folders containing
%         subfolders named worm* (where * is an integer),
%         which subsequently each contain a file called 'data'
%         (containing matrices of x & y coordinate data).
%
%   example:  lengthcalc(0.0041, ... 
%              'C:\Jane-AVD\Arsenite\N2',...
%              'C:\Jane-AVD\Arsenite\cat-4',...
%              'C:\Jane-AVD\Arsenite\NL130');   
%
%   (...to calculate and view wormlengths for all worm data
%   in the N2, cat-4 and NL130 folders.)
%
%   Output is a set of files called "lengthdata.mat" saved one in 
%   each worm* folder.  Lengthdata.mat files contain the variables:
%   - rawlenmm -- vector containing worm lengths (in millimeters)
%               calculated at each time snapshot.
%   - validflag -- vector of Boolean flags indicating if data
%               was accepted (1) or rejected (0).

%   C. J. Cronin 2-04-01
%   Revised 11-22-03 CJC.
%   $Revision: 1.04 $  $Date: 2003/11/22 xx:xx:xx $
% 
% r1.04: Corrected error-handling for cases where length of len and
%   rawlen vectors are not equal, specifically where len has NaN
%   lengths at the begining of the data set
%   Dated x/xx/03 xx:xxPM.
%
% r1.03: Added error-handling for cases where length of len and
%   rawlen vectors are not equal, specifically where len was trimmed
%   by manproc to eliminate invalid frames at the beginning or end
%   of a dataset.
%   Dated 2/12/03 12:21PM.
%
% r1.02: Revised I/O error checking output to match required input.
%   Dated 2/05/03 1:38PM.
%
% r1.01: Initial release.  Originally developed for Cori Bargmann.
%   Dated 2/04/03 1:46PM.



% I/O error checking
if nargout > 0
	error('FORMAT: lengthcalc(mmpp, ''folder1'', ''folder2'',...)');
end

if nargin < 2
	error('FORMAT: lengthcalc(mmpp, ''folder1'', ''folder2'',...)');
end


%----------------------------------------------------------------
%-THE SET-UP FOR CALCULATING METRICS----------------------------

% Condition-Directories containing worm* folders
for i=1:nargin-1        % because now three non-variable inputs
% for i=1:nargin-2      % Directories containing worm-directories.

% get contents of each directory
    pd = varargin(i);
    pd = pd{1};
    
    d = dir([pd '\worm*']);
    nd = prod(size(d));
   
    % now loop over each item
    for j=1:nd       % worm directories
        % clear variables
        clear x y rawx rawy points fingerprint
        
        
        
% ACTUAL WORK OF FUNCTION GOES HERE... 
      
        % get name of directory
        name = d(j).name;
        directory = [pd '\' name];
      
%----------------------------------------------------------------
        % Load in data
        % ...Raw Data
        load([directory '\points']);
        rawx = points(1:2:end,:);      % x-data in odd rows of points
        rawy = points(2:2:end,:);      % y-data in even rows of points

        % ...Screened Data
        load([directory '\data.mat']);
%----------------------------------------------------------------

%----------------------------------------------------------------
      % Prepare Figure Titles
      % --Parse bottom two directory names from directory string 
      if ~exist(directory)
          directory = ' ';
      end
      delimiter_positions = findstr('\', directory);
      if size(delimiter_positions, 2) > 2
          figure_name = ['...' directory(delimiter_positions(end-2):end)];
      else
          figure_name = directory;
      end
%----------------------------------------------------------------

%----------------------------------------------------------------

% Calculate length vectors
rawlen = sum( sqrt( diff(rawx').^2 + diff(rawy').^2 ) );
len    = sum( sqrt( diff(   x').^2 + diff(   y').^2 ) );


% Revision 1.03:
% Sometimes "len" vector will be shorter than "rawlen"; results
% from cases where first frame(s) and/or last frame(s) of 
% dataset was/were invalid.  (Invalid frames at the start or end
% of a dataset are snipped off by design.)
% 
% To keep the "validflag" calculation (below) from crashing, 
% need to make len and rawlen the same length by trimming the
% appropriate values off of rawlen:

% Precondition len to trim NaN's off beginning
while(isnan(len(1)))
    len = len(2:end);
end


if prod(size(rawlen)) ~= prod(size(len))
    deltalen = prod(size(rawlen)) - prod(size(len));
    testalign = 1;
    % ...because of round-off error, "roundn" to round 
    % data to 4 decimal places
    while roundn(len(1),-4) ~= roundn(rawlen(testalign),-4)
        testalign = testalign + 1;
    end
    rawlen = rawlen(testalign : testalign+prod(size(len))-1);
end


% %----------------------------------------------------------------
% % Based on MANPROC code, create vector of flags indicating 
% % validity of length vector elements (i.e. determine which worms 
% % were automatically cut from raw data
% lengths = [1:1:1000];   % Reference vector (wormlengths to 1000 pixels)
% h = hist(rawlen,lengths);  % Actual wormlengths into ref vector bins
% 
% indx = find( h == max(h) );     % Most common worm length(s)
% indx = indx(1);             % The first (shortest), most common length
%                             %   (to handle the rare case when there are
%                             %   two or more most common lengths)-- (if
%                             %   the first is not the correct choice, the
%                             %   user will need to manually screen the 
%                             %   data, or will need to modify this code.
%                             
% mcl = lengths(indx);         % MCL = MOST COMMON WORM LENGTH, in pixels
% 
% validflag = ~isnan(rawx(:,1));     % Initialize valid flags to 1's (i.e. 
%                                 %   "yes, valid" for coordinates with 
%                                 %   numeric data; set to 0's (i.e. 
%                                 %   "invalid" for coordinates without data.
% 
% shortlength = 0.89*mcl;                          % 89% of mean length
% longlength = 1.12*mcl;                           % 112% of mean length
% 
% validflag = validflag & ((rawlen' >= shortlength) & (rawlen' <= longlength));   
%                                                 % (Also) Invalidates worms
%                                                 %   more than 112% or 
%                                                 %   less than  89% of
%                                                 %   most common length
% %----------------------------------------------------------------

%----------------------------------------------------------------
% Create validflag vector based on difference between len and rawlen
validflag = abs(rawlen - len) < .0001;
%----------------------------------------------------------------

      
%----------------------------------------------------------------
% Scale length vectors from pixels to mm
rawlenmm = rawlen*mmpp;
% lenmm = len*mmpp;
%----------------------------------------------------------------


%----------------------------------------------------------------
% Plot scaled worm length vs frame number, showing rejected frames 
% in red 
figure('Name', figure_name);
ordinal = [1:size(rawx,1)];
plot(ordinal(validflag), rawlenmm(validflag), 'b.', ...
    'linewidth', 1.5, 'markersize', 9);  % N.B.: linewidth irrelevant to points
hold on;
if prod(size(rawlenmm(~validflag))) ~= 0
    plot(ordinal(~validflag), rawlenmm(~validflag), 'rx', ...
        'linewidth', 1.5, 'markersize', 9);
end

axis([0 size(rawx,1) 0 1.40005]);   % ensure 1.4 visible on axes

% Titles
title('Worm Length vs Time', 'FontWeight', 'bold');
xlabel('Frame number', 'FontWeight', 'bold');
ylabel('Length (mm)', 'FontWeight', 'bold');

% Legend:
pctacc = prod(size(rawlenmm(validflag)))/prod(size(ordinal));
pctrej = prod(size(rawlenmm(~validflag)))/prod(size(ordinal));
if prod(size(rawlenmm(~validflag))) ~= 0
    legend(...
        {['Accepted  ' num2str(pctacc*100, '%4.1f') '%']; 
         ['Rejected  ' num2str(pctrej*100, '%4.1f') '%']}, 0);
 else
     legend(...
         {['Accepted  ' num2str(pctacc*100, '%4.1f') '%']}, 0);
 end
%----------------------------------------------------------------


%----------------------------------------------------------------
% Paper configuration
grid on;
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
%----------------------------------------------------------------

% ... End of ACTUAL WORK OF FUNCTION 
%----------------------------------------------------------------


      
%-SAVE RESULTS---------------------------------------------------

      save([directory '\lengthdata.mat'], ...
           'rawlenmm', 'validflag'); 


%       % Load fingerprint file from WormTools directory...
%       load(fullfile(matlabroot, 'toolbox','WormTools', 'fingerprint.mat'), 'fingerprint');

%       save([pd '\' name '\metrics.mat'], ...
%            'vel', 'fre', 'theta', 'amp', 'flex', 'phs', 'ptvel', ...
%            'mode', 'ampt', 'wavelnth', 'fingerprint'); 
      
      
%-COMPLETE-------------------------------------------------------

   end  % for j = 1:nd
   
end     % for i=1:nargin-3

return;