function [] = bendfreq(varargin)

%BENDFREQ   Calculate the mean bending frequencies for populations of worms.
%   FORMAT: bendfreq(varargin)
%      where
%      - "varargin" are the names of data folders for
%         for comparison with each other.  Each folder must
%         contain subfolders named worm* (where * is an integer),
%         which subsequently each contain a file called 'metrics'
%         which must contain a matrix called contr [bend angle data]
%         and a value called seconds_per_frame.
%
%   example:  bendfreq('C:\Chris\N2',...
%                      'C:\Chris\cat-4',...
%                      'C:\Chris\NL130');
%   (To view head-to-head comparison of 'N2', 'cat-4', and 'NL130'.)
%
% - Christopher J. Cronin  (cjc@caltech.edu)
%   California Institute of Technology
%   Sternberg Lab
%   Pasadena, CA  USA
%   August 6, 2009


% verbose = false;    % For debug; prints individual worm bend/sec data

numbends = 11;  % 13 points = 12 segments = 11 bends
bendspersec = NaN*ones(nargin, numbends, 3);
missingMetricsList = {};
originalwarningstate = warning('off', 'MATLAB:load:variableNotFound');

%---------------------------------------------------------------
% Prompt for the chart LEGEND text:
legendtext = promptforlegend(varargin{:});

% Handle case where user hits 'cancel' during legend prompt
if isnan(legendtext)
    return
end
%---------------------------------------------------------------

%---------------------------------------------------------------
%---------------------------------------------------------------

% Ask whether to show painful details of each and every worm
button = questdlg('Care to see the details of each worm?',...
    'Gory details?','Yes','No', 'Cancel','No');
if strcmp(button,'Yes')
    verbose = true;
elseif strcmp(button,'No')
    verbose = false;
else
    return
end


%---------------------------------------------------------------
%---------------------------------------------------------------

% Loop thru the list of population folders
for i=1:nargin
    
    % get contents of each directory
    pd = varargin{i};
    
    d = dir([pd filesep 'worm*']);
    nd = numel(d);
    
    bps = NaN*ones(nd,11);
    
    % Now loop thru each worm* folder in the i'th population folder
    for j=1:nd
        % get name of directory
        name = d(j).name;
        
        % clear variables
        clear contr seconds_per_frame x y
        
        % load in the data
        load([pd filesep name filesep 'metrics.mat'], 'contr', 'seconds_per_frame');
        
        % Handle case where contr and/or seconds_per_frame are/is missing
        if (exist('contr','var') ~= 1) || (exist('seconds_per_frame','var') ~= 1)
            
            % Case where contr doesn't exist:
            if (exist('contr','var') ~= 1)  % i.e. data that needs to be run through modern metrics
                % Try to load in the data.mat file to try to calculate contr from x & y matrices
                load([pd filesep name filesep 'data.mat'], 'x', 'y');
                if (exist('x','var') == 1) && (exist('y','var') == 1)   % If we *can*
                    % Calculate matrix of bend angles
                    contr = cont(x, y, 0);
                end
            end
            
            % Case where seconds_per_frame doesn't exist:
            if (exist('seconds_per_frame','var') ~= 1)  % i.e. data that needs to be run through modern metrics
                % Assume 240 second data set and calculate spf:
                seconds_per_frame = 240/size(contr,1);
                fprintf(1,'\t---> Assuming %s is a 240 second long data set...\n', [pd filesep name]);
            end
            
            % Add worm to 'baddie' list
            missingMetricsList{numel(missingMetricsList)+1} = [pd filesep name];
        end
        
        % Now do the bend frequency calculation if possible
        if (exist('contr','var') == 1) && (exist('seconds_per_frame','var') == 1)
            
            % Find zero crossing points
            a  = contr(1:end -1,:);
            b  = contr(2:end,   :);
            c1 = (a >= 0) & (b <  0);
            % c2 = (a <  0) & (b >= 0);   % Available if we want negative-to-positive zero-crossing.
            
            if verbose
                fprintf(1,'\n%s\n', [pd filesep name])
            end
            
            % Loop thru all bends along the worm
            for k = 1:numbends    % i.e. 1:11 bends
                zerocrossings1 = find(c1(:,k) == 1);
                if numel(zerocrossings1) > 1
                    validIntervals = ones(1, numel(zerocrossings1)-1);    % Initially flag all intervals as valid
                    
                    % Check for data continuity between zero-crossings
                    for m = 1:numel(zerocrossings1)-1
                        %                   fprintf(1, '%4d\t%5d : %5d\t%1d\n', m, zerocrossings1(m), zerocrossings1(m+1), any( isnan( contr( zerocrossings1(m):zerocrossings1(m+1),k) ) ));
                        
                        % Take away valid flag from intervals with holes (i.e. NaNs)
                        if any(isnan(contr(zerocrossings1(m):zerocrossings1(m+1),k)))
                            validIntervals(m) = 0;
                        end
                        
                    end
                    
                    % Calculate bends per second (bps) from primatives
                    intervalLengths = diff(zerocrossings1);
                    
                    numValidBends = sum(validIntervals);
                    validBendFrames = sum(intervalLengths(logical(validIntervals)));
                    bps(j,k) = numValidBends/(validBendFrames * seconds_per_frame);     % Bending frequency!
                    
                    if verbose
                        % Individual worm output (for reference):
                        fprintf(1, 'Bend %2d:  %4d intervals /%4d valid, %5.1f sec valid, %5.2f bends-per-second (valid)\n', ...
                            k, ...
                            numel(validIntervals), ...
                            sum(validIntervals), ...
                            sum(intervalLengths(logical(validIntervals))*seconds_per_frame), ...
                            bps(j,k));
                    end
                end
            end
            
            % ...but if we can't do the calculation b/c of missing info:
        else    % that is, if contr and/or seconds_per_frame aren't available as variables, throw warning...
            
            [msgstr, msgid] = lastwarn;
            warning(msgid, 'File ''%s'' \ndoes not contain variables ''contr'' and/or ''seconds_per_frame''.\n  ---> Re-run metrics6 on this data.\n', [pd filesep name filesep 'metrics.mat']);
        end
        
        
        if verbose
            fprintf(1, '%s\n', repmat('-', 1,70));
        end
        
    end
    
    if verbose
        fprintf(1, '%s\n', repmat('-', 1,70));
    end
    
    % Assemble output matrix
    if nd > 1
        bendspersec(i,:,1) = nanmean(bps);      % 1st layer: Mean bending frequency
        bendspersec(i,:,2) = nanstd(bps);       % 2nd layer: Standard deviation
        bendspersec(i,:,3) = sum(~isnan(bps));  % 3rd layer: Population size
    else
        bendspersec(i,:,1) = bps;               % 1st layer: Mean bending frequency
        bendspersec(i,:,2) = zeros(1,numbends); % 2nd layer: Standard deviation
        bendspersec(i,:,3) =  ones(1,numbends); % 3rd layer: Population size
    end
    
end

if verbose
    fprintf(1, '%s\n', repmat('-', 1,70));
    fprintf(1, '\n   ...and in the final analysis...\n')
end

% Print out
for i = 1:nargin
    fprintf(1, '%s:\n', strtrim(legendtext(i,:)))
    fprintf(1, '        Bends/sec\t  SEM \t  n\t\t\t  STD \n')
    for j = 1:11
        fprintf(1, 'Bend# %2d  %5.2f  \t%6.3f\t%3d\t\t\t%6.3f\n', j, bendspersec(i,j,1), bendspersec(i,j,2)/sqrt(bendspersec(i,j,3)), bendspersec(i,j,3), bendspersec(i,j,2))
    end
    fprintf(1, '\n')
end

if numel(missingMetricsList)>0
    % And list the worms that should have been re-run through a modern version
    % of metrics:
    fprintf(1,'\n\n');
    fprintf(1,'\t==== THE FOLLOWING WORMS SHOULD BE RE-RUN THROUGH METRICS  ====\n');
    fprintf(1,'\t(THEY ARE MISSING THE VARIABLES contr AND/OR seconds_per_frame)\n');
    disp(char(missingMetricsList));
    fprintf(1,'\n\n');
end

% Restore original warning state
warning(originalwarningstate);

