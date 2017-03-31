function [] = mikerpmFolder(varargin)

%MIKERPMFOLDER    Run mikerpm on all worm* folders within specified parent folder(s).
%   FORMAT: mikerpmFolder('ParentFolder1', ..., 'ParentFolderX');
%      where 
%      - "ParentFolderN" is a comma-separated list of input directory names
%         containing subdirectories named worm* (where * is an integer), 
%         which subsequently each contain a files called 'data' 
%         (containing matrices of x & y coordinate data) and 'metrics'
%         (containing matricies of measures of worm behavior).
%
%   example:  mikerpmFolder(... 
%              'C:\Jane-AVD\Arsenite\cat4-0-30min',...
%              'C:\Jane-AVD\Arsenite\cat4-1.25-30min');   
%
%       NB: The '...' at the end of the lines allows the user to continue
%       input on the following line.
%
%
%   Christopher J. Cronin 06-10-2013



% some error checking
if nargout > 0
    error('FORMAT: mikerpmFolder(directory1, directory2, ....)');   
end

if nargin < 1
    error('FORMAT: mikerpmFolder(directory1, directory2, ....)');   
end


% %----------------------------------------------------------------
% % Prevent interp1:NaN in Y warnings:
% originalwarningstate = warning('off', 'MATLAB:interp1:NaNinY');   
% % 'originalwarningstate' contains previous state...

% now process data in each directory
for i=1:nargin
    
    % get contents of each directory
    pd = varargin(i);
    pd = pd{1};
    
    d = dir([pd filesep 'worm*']);
    nd = prod(size(d));
    
    % now loop over each item
    for j=1:nd       % worm directories
        
        % get name of directory
        name = d(j).name;
        
        % Only process items that are DIRECTORIES:
        if d(j).isdir
            
            % print out message to stdout
            fprintf(1, '------------------------------------\n');
            fprintf(1, 'Processing %s\n', [pd, filesep name]);

            
            [ftbCount, stbCount] = mikerpm([pd, filesep name]);
            
            fprintf(1, '\n\n');
        end
    end
    
    fprintf(1, '------------------------------------\n');
end

fprintf(1, '\n\nFin.\n\n')


% % Restore original warning state:
% warning(originalwarningstate)


return;