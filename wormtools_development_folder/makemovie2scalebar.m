function [] = makemovie2scalebar(datfile, imscale, compression)

%MAKEMOVIE2  Create .avi format movie from DigiRecognizer .dat file
%   FORMAT: makemovie2(datFileName, ImageScale, CodecName);
%      where
%       - "datFileName" is the name (with path, if necessary) of the 
%           .dat file created by DigiRecognizer
%       - "ImageScale" is the desired image scaling factor, for example
%               0.25 for a 1/4'th-size movie.  Defaults to 0.5
%       - "CodecName" is the name of the desired video codec.  Under
%           Windows, Matlab R2006a supplies codecs named:
%               'Indeo3'
%               'Indeo5' (the default codec...)
%               'Cinepak'
%               'MSVC'
%               'None' (that is, no codec/compression...)
%           but *claims* to also be able to recognize the fourcc code of
%           any other codec installed on the PC.
%   
%   example:  makemovie2('D:\Chris\worm6.dat');
%   example:  makemovie2('D:\Chris\worm6.dat', 0.5, 'Cinepak');
%       (both of which yield a file called worm6.avi saved in D:\Chris)
% 
% Christopher J. Cronin  (3-14-2007)
% Caltech
% cjc@caltech.edu


% Based on MoviePlayerAVI script to read in .DAT movie files from DigiRecognizer 

% filenum = 2;

% fpsval = 6;
% dursec = 20;
% startframe = 1;

% filename = {...
%         'W01_nofood.dat'
%         'W02_OP50.dat'
%         'W07_starved.dat'
%     };

% % fid = fopen('D:\DigiTracker_20060105\Digital\raw data\D6.dat');
% % fid = fopen('D:\Jagan\Jagan_Exp74\W01_nofood.dat'); % Jagan's
% fid = fopen(['D:\Jagan\Jagan_Exp74\' filename{filenum}]); % Jagan's

% Error checking
if nargin < 1
    error('Not enough input arguments')
end

% Set default video scale
if nargin < 2
    imscale = 0.5;
end

% Re-establish default codec
if nargin<3
    compression = 'Indeo5';
end

% Extract .dat file name and path
[pathstr,filestr,ext] = fileparts(datfile);
basicfilename = [pathstr filesep filestr];
avifilename = [basicfilename '.avi'];


% Open .dat file for reading
fid = fopen(datfile);
if (fid == -1)
    error(['Can''t open file "%s" for reading.\n' ...
        ' File may not exist or you may not have read permission.'], ...
        datfile);
end

% Verify that .avi file doesn't exist.  
 if ~isempty(dir(avifilename))
     
     % Query about overwrite if file exists.
     button = questdlg(sprintf('File "%s" exists...  Overwrite?', avifilename),'Overwrite?','No');
     if ~strcmp(button, 'Yes')    %(button ~= 'Yes')
         fprintf(1, '\nFile "%s" exists...  Try renaming either .avi or .dat file.\n', avifilename);
         return;    % stop function and return to command window
     end
     
 end



% Find image size
sizeX = fread(fid,1,'uint32');
sizeY = fread(fid,1,'uint32');

% Determine number of frames:  
headerSize = 2*4;  % two 4 byte (uint) values

timestampSize = 8;  % one 8 byte (double) value
imageSize = (sizeX * sizeY) * 1;  % 640*480 single byte (uchar) values 
merSize = timestampSize + imageSize;    % size of image plus header info...

fseek(fid, 0, 'eof');
position = ftell(fid);
numframes = (position - headerSize)/merSize;

% Calculate recording duration and framerate
fseek(fid, -merSize, 'eof');
timeBeforeLastImage = fread(fid, 1, 'double'); 

fseek(fid, headerSize, 'bof');
timeBeforeFirstImage = fread(fid, 1, 'double');

% Read in first image to find scaling limits
Im = fread(fid,[sizeX sizeY],'uchar');
clim = [min(min(Im)), max(max(Im))];

% Reset read position in .dat file to just before first timestamp
fseek(fid, headerSize, 'bof');


dursec = timeBeforeLastImage - timeBeforeFirstImage; %But this is for n-1 images...
dursec = (dursec * numframes)/(numframes-1);    % Corrected for n frames
fpsval = numframes/dursec;




% Set up to display figure
% fig=figure;
% ax = axes('Units', 'pixels');
% axis ij;
% axis([1 640 1 480]);


fig = figure;
figposition = get(fig, 'Position');
set(fig, 'Units', 'pixels');
ax = axes('Units', 'pixels');
axis ij;
axis([1 sizeX 1 sizeY]);
axposition = get(ax, 'Position');
set(fig, 'Position', [50, 50, figposition(3)+((sizeX*imscale)-axposition(3)), 1.1*(figposition(4)+((sizeY*imscale)-axposition(4))) ]);
set(ax, 'Position', [axposition(1:2), sizeX*imscale, sizeY*imscale]);
set(fig, 'Resize', 'off');



set(fig,'DoubleBuffer','on');
% set(gca,'xlim',[-80 80],'ylim',[-80 80],...
%        'NextPlot','replace','Visible','off')

% Create .avi file with same basic name as .dat
% mov = avifile([basicfilename '.avi'], ...
mov = avifile(avifilename, ...
            'fps', fpsval, ...
            'quality', 100,...
            'compression', compression);

% Establish reference start time:
start = now;

% Work through .dat file displaying and capturing each image as a movie
% frame and adding to the .avi file
for i = 1:numframes  
    timestamp = fread(fid,1,'double');
    Im = fread(fid,[sizeX sizeY],'uchar');
    Im=Im';
%     h = image(Im);      % White background


    h = imagesc(Im, clim);  % Scaled to first image's black&white
%     h = imagesc(Im);    % Gray background
    colormap gray;
%     set(gca, 'tickLength', [0 0]);
% %     set(gca, 'tickdir', 'out')
% %     set(h, 'EraseMode', 'xor');
    set(h, 'EraseMode', 'none');
% ---> Perhaps consider EraseMode 'normal' to get rid of overlay problems

    % Annotate image with timestamp
    currentTimestamp = timestamp - timeBeforeFirstImage;
%     text(10,10,num2str(currentTimestamp, '%8.3f'), ... 
    text(10,10,sprintf('%8.3f sec', currentTimestamp), ... 
        'VerticalAlignment', 'Top', ...
        'HorizontalAlignment', 'Left', ...
        'FontName','FixedWidth', ...
        'FontWeight', 'bold', ...
        'Color', 'black');

    title(['Movie extraction in progress - Frame ' int2str(i) ' / ' int2str(numframes)]);
    xlabel([basicfilename '.avi'], 'Interpreter', 'none');

    axis off;
    
    
    %------------------------------------------
    %------------------------------------------
    % Scale bar:
    hold on;
    barLengthMILIMETERS = 0.100;
    mmpp = 0.00378;
    barLengthPIXELS = barLengthMILIMETERS/mmpp;
    
    % 1x origin
    barX1 = 50;
    barX2 = barX1 + barLengthPIXELS;
    barX = [barX1 barX2];
    barY = [430 430];
    
    barXScaled = floor(barX * imscale);
    barYScaled = floor(barY * imscale);
    
    plot(barXScaled, barYScaled, 'k', 'LineWidth', 5)
%     plot([50,150], [430,430], 'k', 'LineWidth', 5)
    hold off
    %------------------------------------------
    %------------------------------------------

    
    
    F = getframe;
    % But F always contains a gray band at the last column and last row,
    % so let's trim those off:
    F.cdata(end, :, :) = [];    % to get rid of the last row
    F.cdata(:, end, :) = [];    % to get rid of the last column
    
    mov = addframe(mov,F);
end % for i

% Display "finished" title on figure
elapsed = now-start;
title({ 'Movie extraction  == FINISHED =='
        [int2str(i) ' Frames Total in ' datestr(elapsed,13) ' (' num2str(i/(elapsed*24*60*60), '%5.2f') ' frames/sec)']} );

% Finish writing avi movie file
mov = close(mov);
fclose(fid);
