function [] = fngrprnt(varargin)

% FNGRPRNT      Creates fingerprint.mat file used to record wormtool file revision levels.
%   FORMAT: fngrprnt('Repository_URL')
%      where 
%      - 'Repository_URL' is the URL of the Subversion repository to be
%         fingerprinted.  
%
%   example:  fngrprnt('svn://wormware.caltech.edu/TrackerSuiteRepository/wormtools/trunk');
%   (To generate fingerprint.mat file for .)
%
%   Function uses Subversion's svn list tool to generate a list of the
%   files located at the repository URL with their revision number, save
%   date, size and name of the last author committing changes to each.
%   
% - C J Cronin   09/26/2008
%   cjc@caltech.edu
%   Sternberg Lab
%   California Institute of Technology
%


%--------------------------------------------------------------------------
% Mise en Place

% If no URL is specified, prompt for one.  Otherwise use URL provided.
if nargin ~= 1
    % Prompt for the Repository URL:
    prompt = 'Enter URL of Subversion repository:';
    dlg_title = 'Repository URL';
    num_lines= 1;

    answer  = inputdlg(prompt,dlg_title,num_lines);
    if isempty(answer)     % In case user presses cancel
        return;             % abort execution
    else
        repoURL = answer{1};
    end
else
    repoURL = varargin{1};
end     % if nargin ~= 1

%----------------------------------------------------------------
% Establish whether we Want to Definitely save for Matlab v6.x readability:
FORCE_to_v6 = 1;   % 1 = true, we want to save for v6 readability.
% Check for Matlab version
matlabversion = getmatlabversion;

%----------------------------------------------------------------

% while ~isletter(repoURL(end))
%     repoURL = repoURL(1:end-1);  % remove slash from end of directory name if present
% end

% Generate filename for the temporary fingerprint file
tempFileName = [tempname '.txt'];


%--------------------------------------------------------------------------
% The Main Course

% Fill tempFileName with the rpintout from "svn list --verbose" which lists
% the file names, revision numbers within the repository, save date, last
% author and file size:
eval(['!svn list --verbose "' repoURL '" > "' tempFileName '"'])

% Load in the temporary file line by line, assembling into an array of
% character arrays
c = {};
linecount = 1;
fid=fopen(tempFileName);
while 1
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end
    c{linecount} = tline;
    linecount = linecount + 1;
end
fclose(fid);

% Convert (and pad) array into a matrix that Matlab can read
fingerprint = strvcat(c);

% Prompt for where to save fingerprint file
[FileName,PathName,FilterIndex] = uiputfile('*.mat','Choose fingerprint file location', 'fingerprint.mat');

if ~strcmp(FileName, 'fingerprint.mat')
    warndlg({['Warning: Saving file as "' FileName '",']; 'instead of the expected "fingerprint.mat"'} ,'File Name', 'modal')
end

% Save fingerprint in file "fingerprint.mat" in desired format
if ( FORCE_to_v6 & (matlabversion >= 7.0) )   % Add '-v6' flag to force
    save([PathName filesep FileName], 'fingerprint', '-v6');
else
    save([PathName filesep FileName], 'fingerprint');
end


%--------------------------------------------------------------------------
% Clearing the table

% "Clean up after ya'self!"
delete(tempFileName);

% That's all!

return

