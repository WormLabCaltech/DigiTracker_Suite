len = sum(sqrt(diff(x').^2 + diff(y').^2)); % Corrected...
%len = sqrt(sum(diff(x').^2 + diff(y').^2)); % Vector of worm lengths
%                                            % at each time snapshot


%-------------------------------------------------------------------

set(0,'DefaultAxesColorOrder',...
    [    0         0    1.0000  % Dark Blue
         0    0.5000         0  % Medium Green
    1.0000         0         0  % Red
         0    0.7500    0.7500  % Cyan
    0.7500         0    0.7500  % Magenta
    0.7500    0.7500         0  % Dark Yellow
    0.2500    0.2500    0.2500  % Dark Gray
    1.0000    0.6500    0.2500  % Orange
    0.7500    0.5000    0.2500  % Brown
    0.7500    0.5000    1.0000]);% Light Purple
    


% Changing the Default ColorOrder.   You can define a new ColorOrder 
% that MATLAB uses within a particular figure, for all axes within 
% any figures created during the MATLAB session, or as a user-defined 
% default that MATLAB always uses.

% To change the ColorOrder for all plots in the current figure, set 
% a default in that figure. For example, to set ColorOrder to the 
% colors red, green, and blue, use the statement,
set(gcf,'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1])

% To define a new ColorOrder that MATLAB uses for all plotting during 
% your entire MATLAB session, set a default on the root level so axes 
% created in any figure use your defaults.
set(0,'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1])

% To define a new ColorOrder that MATLAB always uses, place the 
% previous statement in your startup.m file.


%-------------------------------------------------------------------



% Code to format plots for landscape output
set(gcf, 'PaperOrientation', 'Landscape');
set(gcf, 'PaperPosition', [0.25  0.25  10.5  8.0]);
set(gca, 'FontWeight', 'bold');

% To ensure color plot from Wormwriter Color
%   or grayscale plot from Wormwriter2
%   (was getting blank plots from ...2 and ...Color on 6/25/03
%   when plots were automatically setting to 'renderer' = 'zbuffer')
%   (Plots were also blank with 'renderer' = 'opengl'.)
set(gcf, 'Renderer', 'painters');

%-------------------------------------------------------------------


% Parse bottom two directory names from directory string for figure title
delimiter_positions = findstr('\', directory);
if size(delimiter_positions, 2) > 1
    figure_name = ['...' directory(delimiter_positions(end-1):end)];
else
    figure_name = directory;
end

%-------------------------------------------------------------------



% correct head position
InvalidInput = 1;     % Flag to verify valid input
while InvalidInput
   resp = input(['Frame #' int2str(frameno) '- (c) correct (i) incorrect? '], 's');
   if(( prod(size(resp)) == 1 ) & (XOR((resp == 'i') , (resp =='c')))) 
       points = [points frameno];     % Builds 'points' vector for 
                                      % use in reordering worms
       if resp == 'i'     % If head position is incorrect, reverse 
                          % point order
          x(frameno,:) = x(frameno,end:-1:1);
          y(frameno,:) = y(frameno,end:-1:1);
       end
       InvalidInput = 0;  % Set flag to False (i.e. NOT INvalid 
                          % input) to exit loop
   else
       beep
       fprintf(1, '     ---> Please enter ''c'' or ''i'' only...\n'); % Warning for bad input
   end
end


%-------------------------------------------------------------------


directory = input('Enter Directory name> ','s');


%-------------------------------------------------------------------


% Progress status display query
InvalidInput = 1;     % Flag to verify valid input
displayprogress = 0;       % Defaults to no chart display
fprintf(1,'\n');
while InvalidInput
    InvalidInput = 0;   % Assume valid input
    resp = input(['Display progress status?  (y)yes (n)no?  '], 's');
    if(( prod(size(resp)) == 1 ) & (XOR((resp == 'y') , (resp =='n')))) 
        if resp == 'y'     % Yes, display progress...
            displayprogress = 1;
        end
    elseif isempty(resp)    % placeholder for valid input requiring no action
        
    else                    % Invalid because not [], 'y' or 'n'...
        beep
        fprintf(1, '     ---> Please enter ''y'' or ''n'' only...\n'); % Warning for bad input
        InvalidInput = 1;   % Restores Invalid input
   end
end


%-------------------------------------------------------------------


% QUERY FOR CUSTOMIZING WHICH BENDS TO DISPLAY IN 2ND FIGURE:
bendnum = input('\n For which bend shall I display the histogram? (Default is bend 11) ');
if isempty(bendnum) | ~isnumeric(bendnum)
    bendnum = 11;
    fprintf(1, 'I''ll take that as "11"\n\n');
end


%-------------------------------------------------------------------


%                            ONLY TYPE UP TO HERE --------------->|
%                          Wormwriter2 will print to here --------------->|


%-------------------------------------------------------------------


% METRONOME:
beep_pause = input('Metronome rate (seconds between beeps): ');
Fs = 10000;
x = -pi:0.01:pi;
y = sin(x*Fs/10);
i = 1;
while i
    wavplay(y,Fs,'async');
    pause(beep_pause);
end

%-------------------------------------------------------------------

% Hour:Min:SecPM - formatted time:
datestr(now,14)

%-------------------------------------------------------------------

a = { 'Yes' 'YES' 'y' 'Y' 'yes'}
sum(strcmp(a,'Yes'))

%-------------------------------------------------------------------

% To create FINGERPRINT file
fngrprnt = dir(fullfile(matlabroot, 'toolbox','wormtools', 'Archive', '*_RELEASE.m'));  
fingerprint = strvcat(fngrprnt.name);

%-------------------------------------------------------------------

% Saleem's 'lengths' code:  
%   (Elegant way to extract non-NaN members of a 2D matrix)
      len = [];
      load(name);
      invalid = sum(  isnan(x') | isnan(y')  ) > 0;
      % ISNAN creates logical matrix of isnan/~isnan's 
      %   --- same size as x or y, but transposed
      % Logical OR (|) creates logical matrix combining x & y
      %   --- same size as x or y, but still transposed
      % SUM compresses 13 row matrix to 1 row
      % >0 indicates whether data ISNAN
      
      % extract only ~isnan elements from x & y
      x = x(~invalid,:);
      y = y(~invalid,:);
      
      % and finally do the length calculation 
      x = diff(x')';
      y = diff(y')';
      len = [len mean(sum(sqrt(x.^2 + y.^2)'))];

%-------------------------------------------------------------------

% Remove any rows of matrix X containing NaNs. 
% (per Matlab Help---> 
%   "Mathematics: Data Analysis and Statistics: Data Preprocessing"
X(any(isnan(X)'),:) = [];

%-------------------------------------------------------------------

% Standard loop to load and process data
for i=1:nargin
   
   % get contents of each directory
   pd = varargin{i};
%    pd = varargin(i);
%    pd = pd{1};
   
   d = dir([pd '\worm*']);
   nd = prod(size(d));
   
   % now loop over each item
   n = [];
   for j=1:nd
      % get name of directory
      name = d(j).name;
      % clear variables
      clear x y vel fre theta amp flex phs ptvel 
      clear mode ampt wavelnth metrics_fingerprint
      % load in the data
      load([pd '\' name '\metrics.mat']);
      % now do the histogram
      nc = hist(ampt, ctrs); nc = nc / sum(nc);
%       nc = hist(ampt, [-3.333:0.03333:3.333]); nc = nc / sum(nc);
      n = [n; nc];
   end
   if nd == 1
       n = [n;nc];      % Adds a second copy of the single worm data
   end                  % to allow mean to generate a vector  --  else
                        % velhist becomes a scalar
   trackamphist = [trackamphist; mean(n)];
   
end

%-------------------------------------------------------------------

% To have a single plot command roll through the color order, repeatedly:

% Establish the list of colors:
colorlist = get(gca, 'colororder');
numcolors = size(colorlist,1);

% Then inside the printing loop determine the current color:
for j = 1:someNumber
      color_number_temp = j/numcolors;
      currentcolornumber = (color_number_temp - floor(color_number_temp)) * numcolors;
      plot(xm,ym,'color', colorlist(currentcolornumber));
end

%-------------------------------------------------------------------

% To establish (up to four) Default Line Styles for a session:
set(0, 'DefaultAxesLineStyleOrder', '-|--|:|-.');

% Matlab cycles through all the colors for a figure using the first line
% style, then repeats the colors with the next line style,...
%-------------------------------------------------------------------
