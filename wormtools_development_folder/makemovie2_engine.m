function []= makemovie2_engine(varargin)
%
%MAKEMOVIE2_engine  Makes .avi movies from  DigiRecognizer .dat files
%   FORMAT: makemovie2_engine("directory");
%      where
%       - "directory" input directory with multipule .dat file created by 
%           DigiRecognizer. Can have variable number of arguments (input
%           directories).
%
%   example1:  makemovie2_engine('/RAVI_LAB/N2_prac');
%       (saves an .avi file in the same folder as "directory" )
%
%   example2:makemovie2_engine('/RAVI_LAB/N2_prac', '/RAVI_LAB/N2_prac2');
%       (saves the .avi files in the either N2_prac or N2_prac2 depending
%         on wether the file is from N2_prac or N2_prac2)
%
%
% With each input direcotry, turns .dat  files into .avi movies. Files are 
% saved in the input directory.
%
%
%
% Christopher J. Cronin and Ravi D. Nath (9-24-2014)
% California Institute of Technology
% Sternberg Lab, Biology Department
% cjc@caltech.edu & ravi.nath@caltech.edu
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
        makemovie2([pd filesep name], .5, 'None')
       % can change compressor and scaling of makemovie2
       % see make movie 2 and change arguments here

     
    end % Ends loop through .dat files
end % Ends loop through parent directories
