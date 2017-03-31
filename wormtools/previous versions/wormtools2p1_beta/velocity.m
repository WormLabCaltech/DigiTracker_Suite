function [] = velocity(varargin)

%VELOCITY    Function to plot data coverage chart (percent valid frames).
%   FORMAT: velocity(varargin)
%      where 
%      - "varargin" are the names of input directories containing
%         subdirectories named worm* (where * is an integer),
%         which subsequently each contain a files called 'metrics' 
%         (containing a vector of velocity data).
%   For each worm* subdirectory, calls function *velocityplot* which 
%   plots a chart depicting worm velocity versus time, with blank 
%   areas showing missing data.  Displays (as a percentage) how much 
%   of the time has valid (i.e. non-missing) data.
%
%   Based on coverage_03
%
%   C. J. Cronin 2-24-02
%   Revised CJC
%   $Revision: 1.02 $  $Date: 2004/10/28 xx:xx:xx $
% 

% r1.02: Replaced '\' with filesep as appropriate for portability 
%   to non-Windows platforms.  
%   Dated 10-28-04 x:xxAM.
%
% r1.01: Initial release.  Developed for Shawn Xu and 
%   Cori Bargmann.  Function based on coverage_03
%   Dated 2-24-03 12:47PM.



% some error checking
if nargout > 0
	error('FORMAT: coverage(directory1, directory2, ....)');   
end

if nargin < 1
	error('FORMAT: coverage(directory1, directory2, ....)');   
end

% now process data in each directory (each input folder)
for i=1:nargin
   
   % get contents of each directory
   pd = varargin(i);
   pd = pd{1};
   
   d = dir([pd filesep 'worm*']);  % Structure containing names of worm* folders
%    d = dir([pd '\worm*']);  % Structure containing names of worm* folders
   nd = prod(size(d));      % Number of worm* folders in i'th input folder
   
   % now loop over each worm* folder in
   for j=1:nd   
      
      % get name of directory
      name = d(j).name;

      % clear variables
      clear vel

      directory = [pd filesep name];
%       directory = [pd '\' name];
      
      % load in the data
      load([directory filesep 'metrics.mat'], 'vel');  % Load 'vel'
%       load([directory '\metrics.mat'], 'vel');  % Load 'vel'

      % Call Statistics calculation and Plotting routine
      velocityplot(directory, vel);

   end  % for 

end

return;