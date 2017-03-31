function [fps] = checkFPS(datfile)

%CHECKFPS  Calculates the Frames-per-Second value for a DigiTracker .DAT file.
%   FORMAT: fps = checkFPS(datFileName);
%      where
%       - "datFileName" is the name (with path, if necessary) of the 
%           .dat file created by DigiRecognizer [Optional: if omitted,
%           checkFPS prompts for the .DAT file to check.]
%       - "fps" is the Frames-per-Second value
%   
%   example:  fps = checkFPS('D:\Chris\worm6.dat')
%   example:  checkFPS
% 
% Christopher J. Cronin  (5-15-2009)
% Caltech
% cjc@caltech.edu


% Lock .m file in memory and create persistent variable for file/folder query.
mlock;
persistent lastDir;

% Check whether we need to prompt for the file name
if nargin < 1
    if isempty(lastDir)
        [FileName,PathName] = uigetfile('*.dat', 'Select .DAT file');
    else
        [FileName,PathName] = uigetfile('*.dat', 'Select .DAT file', lastDir);
    end
    
    if FileName == 0
        fps = [];
        return
    end
    
    datfile = [PathName FileName];
end

% Check for too many inputs
if nargin > 1
    error('Too many input arguments')
end

% Open .dat file for reading
fid = fopen(datfile);
if (fid == -1)
    error(['Can''t open file "%s" for reading.\n' ...
        ' File may not exist or you may not have read permission.'], ...
        datfile);
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

% Reset read position in .dat file to just before first timestamp
fseek(fid, headerSize, 'bof');


dursec = timeBeforeLastImage - timeBeforeFirstImage; %But this is for n-1 images...
dursec = (dursec * numframes)/(numframes-1);    % Corrected for n frames
fpsval = numframes/dursec;


% Display FPS value to command window
fprintf(1, '\n%s\n', datfile);
fprintf(1, 'Frames-per-Second: %g\n\n', fpsval);

% Close the .DAT file
fclose(fid);

% Set the new lastDir (actually to last file...)
lastDir = datfile;
    
% Set the return value
fps = fpsval;
