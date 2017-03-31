function cjcopy(source, destination, varargin)

% FORMAT: function cjcopy('SourceDirectory', 'DestinationDirectory', 'exclude1', 'exclude2', 'excludeN')
%   cjcopy is based on Jeroen Mueller's modification of xcopy.  Objective
%   is to copy files and directories from SOURCE to DESTINATION, except NOT
%   copying files or directories matching the string(s) specified in the
%   function call.  From the DOS help: specifying '\obj\' excludes the
%   \obj\ directory and contents; '.obj' excludes files or directories
%   containing the string .obj
% 
%   example:
%       cjcopy('c:\Chris\fromDir', 'c:\Chris\toDir\', '.bmp', 'data.mat')
%
%       will copy everything in c:\Chris\fromDir to the directory called
%       c:\Chris\toDir EXCEPT files called *.bmp or data.mat
%
%   NOTE: For best results, ensure that you will not be overwriting
%   existing files.  If you try to, you may get stuck in an exit-less loop
%   of the operating system asking whether you want to overwrite...
%
%   Details: cjcopy generates a temporary file in the Matlab root directory
%   into which is printed the list of "exclude" strings.  cjcopy then calls
%   xcopy using the  source and destination specified, and exclude the
%   strings (in the temporary file).  Finally, cjcopy deletes the temporary
%   file and restores control to the command line.
% 
%        - CJCronin  4-18-06


%--------------------------------------------------------------------------
% Mise en Place

% Generate filename for the "exclude" list
% excludefilename = ['C:\Chris\bogus.txt'];
rootdir = matlabroot;
sep = find(rootdir==filesep,1,'first');
rootdir = rootdir(1:sep);
excludefilename = [rootdir 'deleteme_' num2str(now,'%14.6f') '.txt'];

% Verify there's a string to exclude from the copy operation
if nargin < 3   
%     error('Enter ''Source'', ''Destination'', ''exclude1'', ''exclude2'',... ''excludeN''')
    source = uigetdir('','Copy from...');
    if source==0
        return
    end
    
    destination = uigetdir(source,'Copy to...');
    if destination==0
        return
    else
        % Make sure destination "looks" like a folder...
        if(destination(end)~=filesep)
            destination = [destination filesep];
        end
    end
    
    % Gather list of items to be excluded
    exList = {'', '.bmp', '.jpg', '.dat', '.m', '.mat', 'points', 'data.mat', 'metrics.mat'};
    [Selection,ok] = listdlg('ListString',exList,...
                             'Name', 'Exclude...',...
                             'PromptString', 'Select items to exclude');
    if ok==0
        return
    end
    
    % Print the list of "exclude" strings into the exclude file
    fid = fopen(excludefilename, 'w+');
    for n = 1:numel(Selection)
        fprintf(fid, '%s\n', exList{Selection(n)});
    end
    fclose(fid);

else
    % Make sure destination "looks" like a folder...
    if(destination(end)~=filesep)
        destination = [destination filesep];
    end

    % Print the list of "exclude" strings into the exclude file
    fid = fopen(excludefilename, 'w+');
    for n = 1:nargin-2
        fprintf(fid, '%s\n', varargin{n});
    end
    fclose(fid);

end     %if nargin < 3   


% % For some reason, interaction with the system via the Matlab command line
% % has trouble understanding single character responses and sometimes goes
% % unstable.  So instruct the dear user..... 
% fprintf(1, '(Note: if asked for input, type the full word response.  \nFor example, fully type out No, Yes, All, file or directory.  \nAnnoying? You bet!  Necessary? Unless you''ve got a better solution, unfortunately yes.)\n\n');
% % fprintf(1, '(Note: if asked about overwriting, type the full word \nresponse.  For example, fully type out No, Yes or All.  \nAnnoying? You bet!  Necessary? Unfortunately, at least for now.)\n\n');


%--------------------------------------------------------------------------
% The Main Course

% Perform the xcopy operation - i.e. copy source, EXCEPT exclude ...
eval(['!xcopy "' source '" "' destination '" /E /EXCLUDE:' excludefilename])


%--------------------------------------------------------------------------
% Clearing the table

% "Clean up after ya'self!"
delete(excludefilename);

fprintf(1,'\n')     % get a bit o' whitespace on the screen


return
