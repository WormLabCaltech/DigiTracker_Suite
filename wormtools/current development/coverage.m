function [] = coverage(varargin)

%COVERAGE    Function to plot data coverage chart (percent valid frames).
%   FORMAT: coverage(varargin)
%      where 
%      - "varargin" are the names of input directories containing
%         subdirectories named worm* (where * is an integer),
%         which subsequently each contain a files called 'data'
%         (containing matrices of x & y coordinate data) and 
%         'metrics' (containing matricies of velocity, amplitude,
%         time delay data).
%   For each worm* subdirectory, calls function *coverageplot* which 
%   plots diagnostic chart depicting worm position, velocity, and
%   bending frequency versus time, with blank areas showing 
%   missing data.  Displays (as a percentage) how much of the time 
%   has valid (i.e. non-missing) data.
%
%   C. J. Cronin 9-27-02
%   Revised 10-28-04 CJC
%   $Revision: 1.04 $  $Date: 2004/10/28 xx:xx:xx $
% 

% r1.04: Replaced '\' with filesep as appropriate for portability 
%   to non-Windows platforms.  
%   Dated 10-28-04 x:xxAM.
%
% r1.03: Adds help information.  Updates revision history.  Adds
%   comments.
%   Dated 9-27-02 12:25PM.


% nee coverage_02x
% 
% Based on Coverage_01x
% Object-izes code: splits off statistics calculation
% and plotting routines to allow call from Metrics
%
% Based on MetricsCoverageScriptSINGLE
% 
% Prints the number of NaN's in a set of XY Data,
% the number of NaN's in a set of Vel data,
% and the number of NaN's in a set of Amp data.
% Also prints the percentages.

% global x;
% global y;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% some error checking
if nargout > 0
	error('FORMAT: coverage(directory1, directory2, ....)');   
end

if nargin < 1
	error('FORMAT: coverage(directory1, directory2, ....)');   
end

% now process data in each directory
for i=1:nargin
   
   % get contents of each directory
   pd = varargin(i);
   pd = pd{1};
   
   d = dir([pd filesep 'worm*']);
%    d = dir([pd '\worm*']);
   nd = prod(size(d));
   
   % now loop over each item
   for j=1:nd
      
      % get name of directory
      name = d(j).name;
      
      
      % clear variables
      clear x y 
      clear amp fre phs ptvel vel
      

      directory = [pd filesep name];
%       directory = [pd '\' name];
      
      % load in the data
      load([directory filesep 'data.mat']);
      load([directory filesep 'metrics.mat']);
%       load([directory '\data.mat']);
%       load([directory '\metrics.mat']);
%       load([pd '\' name '\data.mat']);
%       load([pd '\' name '\metrics.mat']);
      
      
      % Call Statistics calculation and Plotting routine
      coverageplot(directory, x, vel, fre);

      

   end

end

return;