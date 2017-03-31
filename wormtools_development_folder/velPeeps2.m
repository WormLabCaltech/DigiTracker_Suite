function [] = velPeeps2(indir, varargin)

% VELPEEPS2:  Provides basic velocity statistics for subsets of worms in a folder
%
% Syntax:  [] = velPeeps2(inputDirectory, 'ListOf', 'folderName', 'prefixes')
%    where:
% 'inputDirectory' = single folder containing a collection of worm data
%           formatted such that the folders in 'inputDirectory' are named,
%           for example,   
%               'N2_2007_01_04'
%               'N2_2007_01_05'
%               'N2_2007_01_08'
%               'N2_2007_01_12'
%               'plc-3_2007_01_14'
%               'plc-3_2007_01_17'
%               'sy12_2007_01_06'
%               'sy12_2007_01_11'
%               'sy12_2007_01_13'
%               ...
%
%           Each of the folders within 'inputDirectory' shall in turn
%           contain a single folder named 'worm1' with a file called
%           'veldata.mat' therein. 
%
% 'ListOf','FolderName','Prefixes' = a comma-separated list of
%           apostrophe-enclosed folder name prefixes represented in
%           'inputDirectory'.  For example, from the list above these might
%           include:
%               'N2_', 'sy12', 'plc-3'
%           refering to folders with names starting with those prefixes,
%           respectively.
%
%
% Example:
%       velPeeps2(...
%           'D:\Cheryl\4hrlethtracks',...
%           'N2_', 'ALA-', 'plc-3_');
%
%
% ...another quality software product of the Sternberg Lab(R)
% - Christopher J. Cronin  
%   cjc@caltech.edu  
%   (from velPeeps) April 17, 2007

% Based (veeeery loosly) on: metrics6(mmpp, scnds, fpt, varargin)


fprintf(1,'\n');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %   HARD CODED FOR CHERYL'S WORMS...
%    pd = 'D:\Cheryl\L4 tracks';
    pd = indir;     % directory of interest
% % 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% fprintf(1, 'Mean Forward Centroid Velocities:\n');
fprintf(1, 'Mean Centroid Velocities:\n');
fprintf(1,'(Within directory %s)...\n\n', pd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

group = {}; % placeholder for list of condition
X = [];     % placeholder for list of mean forward velc's
Y = [];     % placeholder for list of mean backward velc's

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
if nargin<2
    error('Input the directory of interest, then the list of prefixes')
end



for i = 1:nargin-1    % cycling through input conditions
    % define group
    groupname = varargin{i};
    fprintf(1, '   %s\n', groupname);
   
    % get contents of each directory
    d = dir([pd filesep groupname '*']);
    nd = prod(size(d));

    MeanVelcFwd = NaN*(ones(nd,1));
    MeanVelcBkwd = NaN*(ones(nd,1));

    if nd > 0   % ?Any instances of groupname in directory?
        for j = 1:nd    %cycle through each directory matching groupname
            % get name of directory
            name = d(j).name;

            % clear variables
            clear velc
      
            % load in the data
            load([pd filesep name filesep 'worm1' filesep 'veldata.mat'], 'velc');

            % Calculate means
            MeanVelcFwd(j) = mean(velc(velc>0));
            MeanVelcBkwd(j) = mean(velc(velc<0));
        
            % Set up for ANOVA
            group{end+1} = groupname;
            X = [X; MeanVelcFwd(j)];
            Y = [Y; MeanVelcBkwd(j)];

            % print out message to stdout
            fprintf(1, '%s \t %7.5f mm/sec (Fwd) \t %7.5f mm/sec (Bkwd)\n', [pd, filesep name], MeanVelcFwd(j), MeanVelcBkwd(j) );
%             fprintf(1, '%s \t %7.5f mm/sec\n', [pd, filesep name], MeanVelcFwd(j));
       
        end  % for j = 1:nd
    
    fprintf(1,'\n');        
    fprintf(1,' Forward\n');
    fprintf(1,'\t Mean of Means: \t\t %7.5f mm/sec\n', mean(MeanVelcFwd));
    fprintf(1,'\t Standard Deviation: \t %f\n', std(MeanVelcFwd));
    fprintf(1,'\t Population Size: \t\t %d animals\n\n', nd);

    fprintf(1,' Backward\n');
    fprintf(1,'\t Mean of Means: \t\t %7.5f mm/sec\n', mean(MeanVelcBkwd));
    fprintf(1,'\t Standard Deviation: \t %f\n', std(MeanVelcBkwd));
    fprintf(1,'\t Population Size: \t\t %d animals\n\n\n', nd);

    else
        fprintf(1,'--> No %s* directories in %s <--\n\n\n', groupname, pd);
    end %nd > 0

end % for i = 1:nargin-1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate 'p' values (if appropriate)
%
if (nargin>2) & (numel(group)>2)     % i.e. more than one condition for testing, since 'p' 
                % doesn't make much sense for a single condition.  (Doesn't
                % check for case where no representatives of condition group...) 
                
                
    % Check whether all elements of group are same:
    same = NaN*ones(numel(group),1);
    for i = 1:numel(group)
        same(i) = strcmp(group{1}, group{i});
    end
    
    if ~all(same)
        
        fprintf(1,'Testing Null Hypothesis (''All means the same...''):\n');

        % Forward
        [p,table,stats] = anova1(X, group);
        fprintf(1,'  Forward Motion: \n');
        fprintf(1,'\t Parametric (ANOVA): \t\t\t\t p= %f\n', p);

        p = kruskalwallis(X,group);
        fprintf(1,'\t Non-Parametric (Kruskal-Wallis): \t p= %f\n\n', p);

        % Backward
        [p,table,stats] = anova1(Y, group);
        fprintf(1,'  Backward Motion: \n');
        fprintf(1,'\t Parametric (ANOVA): \t\t\t\t p= %f\n', p);

        p = kruskalwallis(X,group);
        fprintf(1,'\t Non-Parametric (Kruskal-Wallis): \t p= %f\n\n', p);
    end     % if all(same)
    
end     % if nargin>2




return   
   
