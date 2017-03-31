function [] = movie2dat(movieName)

%MOVIE2DAT  Create DigiTracker-style .dat file from movie file
%   FORMAT: movie2dat(movieName)
%      where 
%      - "movieName" is the name of a movie file (of a format that Matlab
%         can recognize).
%
%   example:  movie2dat('c:\Chris\myBestMovie.avi');
%
%   Output is a '.dat' file with the same name as movieName (but with the
%   file extension changed to .dat) in the same folder as the input movie.
%
%   Note:
%    Movie file formats recognized by Matlab depend on the platform on
%    which Matlab is running.  For a description of acceptable formats see:
%    http://www.mathworks.com/help/techdoc/ref/mmreaderclass.html
%
%
% - Christopher J. Cronin  (cjc@caltech.edu)
%   California Institute of Technology
%   Sternberg Lab
%   Pasadena, CA  USA
%   March 17, 2011

% Developed for Bhagwati Gupta to adapt non-DigiTracker video for use with
% Caltech's DigiRecognizer and wormtools (the DigiTracker Suite).


% Create movie object
obj = mmreader(movieName);

% Gather statistics about movie
sizeX   = obj.Width;
sizeY   = obj.Height;

numFrames = obj.NumberOfFrames;
spf = 1/obj.FrameRate;


% Check for existance of eponymous .dat file
[pathstr, name, ext] = fileparts(movieName);
datName = [pathstr filesep name '.dat'];

if (exist(datName, 'file') == 2)
    if isvalid(obj)
        delete(obj);
        clear obj
    end
    error(['.dat file ''' datName ''' already exists.']);
end

% Create dat file with introductory info
datID = fopen(datName, 'w');

% Write width and height
fwrite(datID, sizeX, 'uint32', 'ieee-le');
fwrite(datID, sizeY, 'uint32', 'ieee-le');

% Close dat file
fclose(datID);

% Set up for virtual time stamp
timestamp = 0;

% Loop through all frames writing timestamp and images
for i = 1:numFrames
    % Read image and convert to 8-bit grayscale
    im = read(obj, i);
    im = rgb2gray(im);  % convert to grayscale
    im = im';   % to match DigiTracker format
    
    % Write timestamp and image
    datID = fopen(datName, 'a');
    fwrite(datID, timestamp, 'double');
    fwrite(datID, im, 'uchar');     % Force image data to uchar
    fclose(datID);
    
    timestamp = timestamp + spf;    % Increment timestamp
end

% Clean up, clean up, everybody everywhere...
if isvalid(obj)
    delete(obj);
    clear obj
end


