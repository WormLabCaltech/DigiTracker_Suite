function []= makemovie3_engine(varargin)
%
%MAKEMOVIE3_engine  Makes .avi movies from DigiRecognizer ".dat" files 
%                   using the VideoWriter-based makemovie3.m
%   FORMAT: makemovie3_engine('directory(ies)');
%      where
%       - "directory" input directory with multiple .dat file created by 
%           DigiRecognizer. Can specify an arbitrary number of input directories.
%
%   example1:  makemovie3_engine('D:\Chris\N2');
%       (saves .avi files in the 'D:\Chris\N2\' folder)
%
%   example2:makemovie3_engine('/RAVI_LAB/N2_prac', '/RAVI_LAB/N2_prac2');
%       (saves the .avi files in the either N2_prac or N2_prac2 depending
%         on whether the file is from N2_prac or N2_prac2)
%
%
% With each input directory, turns .dat  files into .avi movies. Files are 
% saved back to the input directory.
%

%
% Christopher J. Cronin and Katie Brugman (2017-01-11)
% updated: 2017-02-17
% California Institute of Technology
% Sternberg Lab, Biology Department
% cjc@caltech.edu 
% Developed: 2014/09/24


for i=1:nargin        % because now three non-variable inputs
    % for i=1:nargin-2      % Directories containing worm-directories.
    
    % get contents of each directory
    pd = varargin(i);
    pd = pd{1};
    
    d = dir([pd filesep '*.dat']);
    nd = prod(size(d));
    
    % now loop over each item
    for j=1:nd       % worm directories
        
        % get name of directory
        name = d(j).name;
        disp(['processing  ' pd filesep name])
        
        % Here's the action step:
        makemovie3([pd filesep name], .5, 'Motion JPEG AVI');   % Motion JPEG AVI is the only one that plays for Katie Brugman
%         makemovie2([pd filesep name], .5, 'None')     % was...
       % NOTE: We can change profile and scaling of movies...
       %    See makemovie3.m and change arguments here ^^^

     
    end % Ends loop through .dat files
end % Ends loop through parent directories
