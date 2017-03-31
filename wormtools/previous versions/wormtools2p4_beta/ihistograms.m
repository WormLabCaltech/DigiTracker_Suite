function [velhist, flexhist, frehist, delayhist, ...
        ptvelhist, trackamphist, wavelnthhist] = ihistograms(varargin)

%iHISTOGRAMS    Generate histograms of individual worm movement metrics.
%   FORMAT: ihistograms(varargin)
%      where 
%      - "varargin" are the names of worm folders for 
%         for comparison with each other.  Each folder must 
%         contain a file called 'metrics' (containing matrices 
%         of x & y coordinate data).
%
%   example:  ihistograms('C:\Jane-AVD\Arsenite\N2\worm1',...
%                         'C:\Jane-AVD\Arsenite\N2\worm5',...
%                         'C:\Jane-AVD\Arsenite\N2\worm6');
%            (To view a worm-to-worm comparison of individual 
%             'N2' worms '1', '5', and '6'.)
% 
%   NOTE:  Color palette is currently limited to 10 colors; thus
%          the 11'th and 12'th worms will be the same color as
%          the 1'st and 2'nd...
% 
%   Displays five charts of histograms:
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
%       ptvelhist, trackamphist, wavelnthhist] = ihistograms(varargin)
%      where each of the ___hist variables are vectors or arrays of 
%      histogram data for velocity, amplitude,... etc.

%   C. J. Cronin 5-22-03
%   Revised 
%   $Revision: 1.02 $  $Date: 2004/07/14 xx:xx:xx $
% 
% r1.02: Adds sixth figure displaying CENTROID VELOCITY ('VELC'); we 
%   realized that the original 'VEL' is ~Actually~ the Mean of the 
%   Point Velocities of points 5:end.  Oops.  Changed '\' to 'filesep'
%   where appropriate for portability to non-Windows platforms.  
%   Cleaned up legend and title input routines.
% 
% r1.01: Initial release.  Based on histograms4_05x.
%   5/22/03 10:01AM.
  





% some error checking
if nargout > 7      % ...if too many output arguments
	error('FORMAT: [velhist, flexhist, frehist, delayhist, ptvelhist, trackamphist, wavelnthhist] = ihistograms(directory1, directory2, ....)');   
end

if nargin < 1        % ...if too few input arguments
	error('FORMAT: ihistograms(directory1, directory2, ....)');     
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
prompt = 'Enter chart legend information:';
dlg_title = 'Chart legend information';
num_lines= nargin;

for i = 1:num_lines
    directory = varargin(i);
    directory = directory{1};
    delimiter_positions = findstr(filesep, directory);
    
    % Trim off trailing 'filesep's (if any)
    while delimiter_positions(end) == length(directory)
        directory = directory(1:end-1);
        delimiter_positions = findstr(filesep, directory);
    end
    
    % Establish i'th line of legend text as vector
    if size(delimiter_positions, 2) > 1
        legend_text_line = [directory(delimiter_positions(end-1)+1:end)];
    else
        legend_text_line = directory;
    end
    
    % Replace '\' with ': '
    legend_text_line = strrep(legend_text_line, filesep, ': ');

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

%---------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate Figure 1 for histogram of velocities (mean of point velocities)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

velhist = [];
for i=1:nargin      % Each specified worm folder
   
   % get contents of each directory
   pd = varargin(i);    % Assign i'th input (worm) folder to pd
   pd = pd{1};
   
%    d = dir([pd '\worm*']);
   d = dir([pd filesep 'metrics.mat']);
   nd = prod(size(d));
   
   % Verify that parent directory exists and contains worm folders
   if exist(pd) ~= 7    % if directory does not exist or is not a directory
       error(['ERROR: Directory ''' pd ''' does not exist!']);
   elseif nd == 0       % if directory is empty (no metrics file)
       error(['ERROR: ''' pd ''' contains no ''metrics'' file!']);
   end   
   
   % now loop over each item
   nc = [];
%    n = [];
% % %    for j=1:nd
%       % get name of directory
%       name = d(j).name;
      % clear variables
      clear amp ampt fingerprint flex fre len 
      clear mode phs ptvel theta vel wavelnth
      % load in the data
      load([pd filesep 'metrics.mat']);
%       load([pd '\' name '\metrics.mat']);
      % now do the histogram
      nc = hist(vel, [-3.333:0.03333:3.333]); nc = nc / sum(nc);
%       n = [n; nc];
% % %    end
%    if nd == 1
%        n = [n;nc];      % Adds a second copy of the single worm data
%    end                  % to allow mean to generate a vector  --  else
%                         % velhist becomes a scalar
%    velhist = [velhist; mean(n)];
   velhist = [velhist; nc];
   
end

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
hold on
drawnow

plot([-3.333:0.03333:3.333], velhist,...
    'LineWidth', linewdth)   % Set LineWidth 
            % velocities scaled up by 3.333x
            
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
pos = 2;
legend(gca, legendtext, pos);

% % % %-------------------------
% % % return
% % % %-------------------------



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate Figure 1A for histogram of CENTROID velocities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

velc_hist = [];
for i=1:nargin      % Each specified worm folder
   
   % get contents of each directory
   pd = varargin(i);    % Assign i'th input (worm) folder to pd
   pd = pd{1};
   
%    d = dir([pd '\worm*']);
   d = dir([pd filesep 'metrics.mat']);
   nd = prod(size(d));
   
   % Verify that parent directory exists and contains worm folders
   if exist(pd) ~= 7    % if directory does not exist or is not a directory
       error(['ERROR: Directory ''' pd ''' does not exist!']);
   elseif nd == 0       % if directory is empty (no metrics file)
       error(['ERROR: ''' pd ''' contains no ''metrics'' file!']);
   end   
   
   % now loop over each item
   nc = [];
%    n = [];
% % %    for j=1:nd
%       % get name of directory
%       name = d(j).name;
      % clear variables
      clear amp ampt fingerprint flex fre len 
      clear mode phs ptvel theta vel wavelnth
      clear velc
      % load in the data
      load([pd filesep 'metrics.mat']);
%       load([pd '\' name '\metrics.mat']);
      % now do the histogram
      nc = hist(velc, [-3.333:0.03333:3.333]); nc = nc / sum(nc);
%       n = [n; nc];
% % %    end
%    if nd == 1
%        n = [n;nc];      % Adds a second copy of the single worm data
%    end                  % to allow mean to generate a vector  --  else
%                         % velc_hist becomes a scalar
%    velhist = [velhist; mean(n)];
   velc_hist = [velc_hist; nc];
   
end

figure('Position', [10  275  560  420]);
grid
axis([-0.6,0.6,0,0.35]);    % Scaled to existing data (as of 11-07-01)
title([titlePrefix ' \itC. elegans\rm\bf Distribution of Instantaneous CENTROID Velocity ' titleSuffix],...
    'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% title([titlePrefix ' \itC. elegans\rm\bf Distribution of Instantaneous Velocity (Mean Point Velocity) ' titleSuffix],...
%     'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% title([titlePrefix ' \itC. elegans\rm\bf Distribution of Instantaneous Velocity ' titleSuffix],...
%     'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
% title('XXX \itC. elegans\rm\bf Distribution of Instantaneous Velocity for XXX',...
%     'FontWeight', 'bold', 'FontSize', figuretitlefontsize);
xlabel('Centroid Velocity (mm/s)', 'FontWeight', 'bold');
hold on
drawnow

plot([-3.333:0.03333:3.333], velc_hist,...
    'LineWidth', linewdth)   % Set LineWidth 
            % velocities scaled up by 3.333x
            
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');
pos = 2;
legend(gca, legendtext, pos);

% % % %-------------------------
% % % return
% % % %-------------------------





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
   for i=1:nargin       % Each specified worm folder
   
   	% get contents of each directory
   	pd = varargin(i);   % Assign i'th input (worm) folder to pd
   	pd = pd{1};
   
% Already verified that directories exist via Figure 1
% 		d = dir([pd '\worm*']);
%   	nd = prod(size(d));
      
	   % now loop over each item
   	nc = [];
% % %    	n = [];
% % %    	for k=1:nd
% % %       	% get name of directory
% % %       	name = d(k).name;
      	% clear variables
      clear amp ampt fingerprint flex fre len 
      clear mode phs ptvel theta vel wavelnth
      	% load in the data
         load([pd filesep 'metrics.mat']);
%          load([pd '\' name '\metrics.mat']);
      	% now do the histogram
      	nc = hist(flex(:,segs(j)), [0:0.1:pi]); nc = nc / sum(nc);
% % %       	n = [n; nc];
% % % 	   end
% % %        if nd == 1
% % %            n = [n;nc];      % Adds a second copy of the single worm data
% % %        end                  % to allow mean to generate a vector  --  else
% % %                             % flexhist becomes a scalar

%       flexhist{1,j} = [flexhist{1,j}; mean(n)];
      flexhist{1,j} = [flexhist{1,j}; nc];
    
%Set up to do the Histogram Chart title
      if j == 2
          axhandle = gca;   % Attaches page "title" to j-1'st (i.e. top left) axis
      end

   end
   
   % now plot
   subplot(3,nsegs,j);
   plot([0:0.1:pi], flexhist{1,j},...
       'LineWidth', linewdth);          % Set LineWidth

   title(['\theta' int2str(segs(j))], 'FontWeight', 'bold');
   xlabel('Flex (rad)', 'FontWeight', 'bold');      
   axis([0 2 0 0.5]);       % Scale axes to existing data (as of 11-07-01)
   axis square;
   set(gca, 'FontWeight', 'bold');
   grid on;
   drawnow;
   
end


%-----------------------------------------------------------------------------
% now plot frequencies
frehist = cell(1, nsegs);
for j=1:nsegs
   
   frehist{1,j} = [];
   for i=1:nargin       % Each specified worm folder
   
   	% get contents of each directory
   	pd = varargin(i);   % Assign i'th input (worm) folder to pd
   	pd = pd{1};
   
% % % 		d = dir([pd '\worm*']);
% % %   	nd = prod(size(d));
      
	   % now loop over each item
   	nc = [];
%    	n = [];
% % %    	for k=1:nd
% % %       	% get name of directory
% % %       	name = d(k).name;
      	% clear variables
      clear amp ampt fingerprint flex fre len 
      clear mode phs ptvel theta vel wavelnth
      	% load in the data
         load([pd filesep 'metrics.mat']);
%          load([pd '\' name '\metrics.mat']);
         % now do the histogram
      	nc = hist(fre(:,segs(j)), [0:0.16665:3.9996]); nc = nc / sum(nc);
% % %       	n = [n; nc];
% % %     end
% % %     if nd == 1
% % %         n = [n;nc];      % Adds a second copy of the single worm data
% % %     end                  % to allow mean to generate a vector  --  else
% % %                          % frehist becomes a scalar
%     frehist{1,j} = [frehist{1,j}; mean(n)];
    frehist{1,j} = [frehist{1,j}; nc];
            
   end
   
   % now plot
   subplot(3,nsegs,4+j);
   plot([0:0.16665:3.9996], frehist{1,j},...
       'LineWidth', linewdth);  % Scale x3.333

   title(['\theta' int2str(segs(j))], 'FontWeight', 'bold');
   xlabel('Frequency (Hz)', 'FontWeight', 'bold');
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
   for i=1:nargin       % Each specified worm folder
   
	   % get contents of each directory
   	pd = varargin(i);   % Assign i'th input (worm) folder to pd
	pd = pd{1};
   
% % % 		d = dir([pd '\worm*']);
% % %   	nd = prod(size(d));
      
	   % now loop over each item
   	nc = [];
%    	n = [];
% % %    	for k=1:nd
% % %       	% get name of directory
% % %       	name = d(k).name;
      	% clear variables
      clear amp ampt fingerprint flex fre len 
      clear mode phs ptvel theta vel wavelnth
         % load in the data
         load([pd filesep 'metrics.mat']);
%          load([pd '\' name '\metrics.mat']);
      	% now do the histogram
      	nc = hist(phs(:,segs(j)), [-1.5:0.075:1.5]); nc = nc / sum(nc);
% % %       	n = [n; nc];
% % %     end
% % %     if nd == 1
% % %         n = [n;nc];      % Adds a second copy of the single worm data
% % %     end                  % to allow mean to generate a vector  --  else
% % %                          % delayhist becomes a scalar
%     delayhist{1,j} = [delayhist{1,j}; mean(n)];
    delayhist{1,j} = [delayhist{1,j}; nc];
            
   end
   
   % now plot
   subplot(3,nsegs,8+j);
   plot([-1.5:0.075:1.5], delayhist{1,j},...
       'LineWidth', linewdth);      % Set LineWidth

   title(['\theta' int2str(segs(j)) ' - \theta' int2str(segs(j)+1)],...
       'FontWeight', 'bold');
   xlabel('Time Delay (s)', 'FontWeight', 'bold');     
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







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 3 for point velocities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vertex = [5:1:13];
nvertex = prod(size(vertex));

figure('Position', [290  60  705  655]);
drawnow;

%-----------------------------------------------------------------------------
% now plot point velocities
ptvelhist = cell(1, nvertex);
for j=1:nvertex
   
   ptvelhist{1,j} = [];
   for i=1:nargin   % Each specified worm folder
   
   	% get contents of each directory
   	pd = varargin(i);   % Assign i'th input (worm) folder to pd
   	pd = pd{1};
   
% % % 		d = dir([pd '\worm*']);
% % %   	nd = prod(size(d));
      
	   % now loop over each item
   	nc = [];
%    	n = [];
% % %    	for k=1:nd
% % %       	% get name of directory
% % %       	name = d(k).name;
      	% clear variables
      clear amp ampt fingerprint flex fre len 
      clear mode phs ptvel theta vel wavelnth
      	% load in the data
         load([pd filesep 'metrics.mat']);
%          load([pd '\' name '\metrics.mat']);
      	% now do the histogram
      	nc = hist(ptvel(:,vertex(j)), [-3.333 : 0.03333 : 3.333]); 
        nc = nc / sum(nc);
% % %       	n = [n; nc];
% % % 	   end
% % %        if nd == 1
% % %            n = [n;nc];      % Adds a second copy of the single worm data
% % %        end                  % to allow mean to generate a vector  --  else
% % %                             % amphist becomes a scalar

%       ptvelhist{1,j} = [ptvelhist{1,j}; mean(n)];
      ptvelhist{1,j} = [ptvelhist{1,j}; nc];
    
%Set up to do the Histogram Chart title
      if j == 3
          axhandle = gca;
      end

   end
   
   % now plot
   subplot(3,3,j);
   plot([-3.333 : 0.03333 : 3.333], ptvelhist{1,j},...
       'LineWidth', linewdth);          % Set LineWidth

   title(['Point ' int2str(vertex(j))], 'FontWeight', 'bold');
   if j > 6
       xlabel('Point Velocity (mm/sec)', 'FontWeight', 'bold');      
   end
   axis([-0.6 0.6 0 0.35]);       % Scale axes to existing data (as of 11-07-01)
   axis square;
   set(gca, 'FontWeight', 'bold');
   grid on;
   drawnow;
   
end

set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
pos = -1;
legend(gca, legendtext);

set(gcf, 'CurrentAxes', axhandle);
% text(0, 0.43, 'XXX \itC. elegans\rm\bf Distribution of Point Velocities for XXX',...
text(0, 0.43, [titlePrefix ' \itC. elegans\rm\bf Distribution of Point Velocities ' titleSuffix],...
    'FontWeight', 'bold', ...
    'FontSize', figuretitlefontsize,...
    'HorizontalAlignment', 'center');






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 4 for Track Amplitude & Wavelength
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate Figure 4 for histograms of Track Amplitude & Wavelength
% % figure('Position', [10  275  560  420]);
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
   pd = varargin(i);    % Assign i'th input (worm) folder to pd
   pd = pd{1};
   
% % %    d = dir([pd '\worm*']);
% % %    nd = prod(size(d));
   
   % now loop over each item
%    n = [];
   n_ampt = [];
   n_wavelnth = [];
   
% % %    for j=1:nd       % Cycle thru each worm* folder
% % %       % get name of directory
% % %       name = d(j).name;
      % clear variables
      clear amp ampt fingerprint flex fre len 
      clear mode phs ptvel theta vel wavelnth
      % load in the data
      load([pd filesep 'metrics.mat']);
%       load([pd '\' name '\metrics.mat']);

      % Generate the histograms
      %   ampt:
      nc_ampt = hist(ampt, ctrs_ampt); 
        nc_ampt = nc_ampt / sum(nc_ampt);
% % %       n_ampt = [n_ampt; nc_ampt];
      
      %   wavelnth:
      nc_wavelnth = hist(wavelnth, ctrs_wavelnth); 
        nc_wavelnth = nc_wavelnth / sum(nc_wavelnth);
% % %       n_wavelnth = [n_wavelnth; nc_wavelnth];
% % %    end
% % %    if nd == 1
% % %        % Adds a second copy of the single worm data
% % %        % to allow mean to generate a vector  --  else
% % %        % histogram becomes a scalar
% % %        n_ampt = [n_ampt; nc_ampt];      
% % %        n_wavelnth = [n_wavelnth; nc_wavelnth];      
% % %    end                  
                        
%    trackamphist = [trackamphist; mean(n_ampt)];
%    wavelnthhist = [wavelnthhist; mean(n_wavelnth)];
   trackamphist = [trackamphist; nc_ampt];
   wavelnthhist = [wavelnthhist; nc_wavelnth];
   
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
set(gca, 'FontWeight', 'bold');
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
set(gca, 'FontWeight', 'bold');
pos = 1;
legend(gca, legendtext, pos);
drawnow

% Format output for printer
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);




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

for i=1:nargin      % Cycle thru each worm
   
   % get contents of each directory
   pd = varargin(i);    % Assign i'th input (worm) folder to pd
   pd = pd{1};
   
% % %    d = dir([pd '\worm*']);
% % %    nd = prod(size(d));
   
   % now loop over each item
%    n = [];
   n_ampt_norm = [];
   n_wavelnth_norm = [];
   
% % %    for j=1:nd   % Cycles thru all worm* directories...
% % %       % get name of directory
% % %       name = d(j).name;
      % clear variables
      clear amp ampt fingerprint flex fre len 
      clear mode phs ptvel theta vel wavelnth
      % load in the data
      load([pd filesep 'metrics.mat']);
%       load([pd '\' name '\metrics.mat']);

      % Verify that metrics.mat includes *len* variable;
      %   if not, display error message and end job.
      if ~exist('len')
          errortext = ['Worm length data missing ---> Re-run METRICS for ' pd];
%           errortext = ['Worm length data missing ---> Re-run METRICS for ' pd '\' name];
          error(errortext)
      end
      
      % Calculate mean length
      meanlen = mean(len(~isnan(len)));
      
      % Generate the histograms from LENGTH-NORMALIZED vectors
      %    ampt:
      nc_ampt_norm = hist( ((ampt/meanlen)*100), ctrs_ampt_norm); 
        nc_ampt_norm = nc_ampt_norm / sum(nc_ampt_norm);
% % %       n_ampt_norm = [n_ampt_norm; nc_ampt_norm];
      
      %    wavelnth:
      nc_wavelnth_norm = hist( ((wavelnth/meanlen)*100), ctrs_wavelnth_norm); 
        nc_wavelnth_norm = nc_wavelnth_norm / sum(nc_wavelnth_norm);
% % %       n_wavelnth_norm = [n_wavelnth_norm; nc_wavelnth_norm];
% % %    end      % for j
% % %    
% % %    if nd == 1
% % %        % Adds a second copy of the single worm data
% % %        % to allow mean to generate a vector  --  else
% % %        % histogram becomes a scalar
% % %        n_ampt_norm = [n_ampt_norm; nc_ampt_norm];      
% % %        n_wavelnth_norm = [n_wavelnth_norm; nc_wavelnth_norm];      
% % %    end                  
                        
% % %    trackamphist_norm = [trackamphist_norm; mean(n_ampt_norm)];
% % %    wavelnthhist_norm = [wavelnthhist_norm; mean(n_wavelnth_norm)];
   trackamphist_norm = [trackamphist_norm; nc_ampt_norm];
   wavelnthhist_norm = [wavelnthhist_norm; nc_wavelnth_norm];
   
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
set(gca, 'FontWeight', 'bold');
pos = 1;
legend(gca, legendtext, pos);
drawnow

% Format output for printer
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);





return;