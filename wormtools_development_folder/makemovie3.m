function [] = makemovie3(datfile, imscale, profile)

%MAKEMOVIE3  Create movie from DigiRecognizer .dat file
%   FORMAT: makemovie3(datFileName, ImageScale, Profile);
%      where
%       - "datFileName" is the name (with path, if necessary) of the 
%           .dat file created by DigiRecognizer
%       - "ImageScale" is the desired image scaling factor, for example
%               0.25 for a 1/4'th-size movie.  Defaults to 0.5
%       - "Profile" is a string defining the compression settings to apply
%           to the resulting movie file.  Defaults to 'Motion JPEG AVI'.
%           - 'Archival'        - Motion JPEG 2000 file with lossless compression
%           - 'Motion JPEG AVI' - AVI file using Motion JPEG encoding
%           - 'Motion JPEG 2000'- Motion JPEG 2000 file
%           - 'MPEG-4'          - MPEG-4 file with H.264 encoding (systems with Windows 7 or later, or Mac OS X 10.7 and later)
%           - 'Uncompressed AVI'- Uncompressed AVI file with RGB24 video
%           - 'Indexed AVI'     - Uncompressed AVI file with indexed video
%           - 'Grayscale AVI'   - Uncompressed AVI file with grayscale video
%   %   
%   example:  makemovie3('D:\Chris\worm6.dat');
%   example:  makemovie3('D:\Chris\worm6.dat', 0.5);
%   example:  makemovie3('D:\Chris\worm6.dat', 0.5, 'Motion JPEG AVI');
%       (all of which yield a half-scale video file called worm6.avi, saved in D:\Chris with Motion JPEG encoding.)
% 
% Based on makemovie2, but using 'VideoWriter' rather than 'avifile'. 
% VideoWriter was added to Matlab in R2010b, version 7.11
%
% Christopher J. Cronin  (8-18-2016)
% Caltech, Sternberg Lab
% Pasadena  CA  91125
% cjc@caltech.edu




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
    profile = 'Motion JPEG AVI';
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



% Gather important information from .dat file:
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


% Calculate frame rate
dursec = timeBeforeLastImage - timeBeforeFirstImage; %But this is for n-1 images...
dursec = (dursec * numframes)/(numframes-1);    % Corrected for n frames
fpsval = numframes/dursec;



% Set up figure
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


% Create .avi file with same basic name as .dat
mov = VideoWriter(avifilename, profile);
mov.FrameRate = fpsval;
open(mov);

% % mov = avifile([basicfilename '.avi'], ...
% mov = avifile(avifilename, ...
%             'fps', fpsval, ...
%             'quality', 100,...
%             'compression', compression);

% Establish reference start time:
start = now;

% Work through .dat file displaying and capturing each image as a movie
% frame and adding to the .avi file
for i = 1:numframes  
    timestamp = fread(fid,1,'double');
    Im = fread(fid,[sizeX sizeY],'uchar');
    Im=Im';
%     h = image(Im);      % White background


    if diff(clim) > 0
        h = imagesc(Im, clim);  % Scaled to first image's black&white
    else
        h = imagesc(Im);    % If first image was all white
    end
    colormap gray;

%     set(h, 'EraseMode', 'none');
% ---> Perhaps consider EraseMode 'normal' to get rid of overlay problems

    % Annotate image with timestamp
    currentTimestamp = timestamp - timeBeforeFirstImage;
    text(10,10,sprintf('%8.3f sec', currentTimestamp), ... 
        'VerticalAlignment', 'Top', ...
        'HorizontalAlignment', 'Left', ...
        'FontName','FixedWidth', ...
        'FontWeight', 'bold', ...
        'Color', 'black');

    title({ ['Movie extraction in progress - Frame ' int2str(i) ' / ' int2str(numframes)];
            [filestr '.avi'] }, 'Interpreter', 'tex');
%     title(['Movie extraction in progress - Frame ' int2str(i) ' / ' int2str(numframes)]);
%     xlabel([basicfilename '.avi'], 'Interpreter', 'none');

    axis off;
    
    F = getframe;
    % But F always contains a gray band at the last column and last row,
    % so let's trim those off:
    F.cdata(end, :, :) = [];    % to get rid of the last row
    F.cdata(:, end, :) = [];    % to get rid of the last column
    
    if strcmpi(profile, 'Indexed AVI')
        F.cdata(end, :, :) = [];    % to get rid 2nd & 3rd layers
    end
    
    writeVideo(mov,F);
%     mov = addframe(mov,F);
end % for i

% Display "finished" title on figure
elapsed = now-start;
title({ 'Movie extraction  == FINISHED =='
        [int2str(i) ' Frames Total in ' datestr(elapsed,13) ' (' num2str(i/(elapsed*24*60*60), '%5.2f') ' frames/sec)']} );

% Finish writing avi movie file
close(mov);
fclose(fid);
