function [phase] = timedelay(c, spf)

%TIMEDELAY    Calculate worm movement metrics.
%   FORMAT: [phase] = timedelay(c, spf)
%      where 
%      - "c" is a matrix of worm bend angles for each bend along
%         the worm's "spine" (columns), at each time snapshot (rows).
%      - "spf" is the "seconds per frame" conversion factor (that is,
%         the time elapsed between adjacent frames (time snapshots).
%      - "phase" is a matrix containing the time delay (in seconds) 
%         between successive bends passing through the same angle 
%         at each time-snapshot.

%   C. J. Cronin 10-28-02
%   Revised 
%   $Revision: 1.01 $  $Date: 2002/10/28 xx:xx:xx $
% 
% r1.01: Spun off from contraction3_02 (yields this function
%   and contraction4_01).  Separation into a discrete function
%   better represents the independent effort of this code.



% if nargin = 1, do not do unit conversion (DO NOT scale output
%  according to spf)
if nargin == 1
   spf = 1;	
end

% get size of contractions
nbends = size(c,2);     % Number of bends (number of points minus 2)
nsamples = size(c,1);   % Number of time snapshots (frames)

%-------------------------------------------------------------------
% TIME LAG calculation

% now compute all Time Lags 
phase = NaN*zeros(nsamples, nbends-1);  % NB: Not actually phases,
                                        %   rather time lags
for i=1:nbends-1    % nbends-1 because comparing bends
    
    % Input signals (vectors of angles of adjacent bends)
    signa1 = c(:,i)'; 
    signa2 = c(:,i+1)';
    
    % Establish reference vectors
    x = [1:nsamples]; 
    xp = [1:0.1:nsamples];    
    
    % Signals interpolated with 10x data points for input to DTW
    signa1p = interp1(x, signa1, xp); 
    signa2p = interp1(x, signa2, xp);
    
%-------------------------------------------------------------------
% Per verbal communication with Dr. Mark Maimone at JPL, _dtw_ 
% correlates corresponding aspects of angle-signals from adjacent
% worm bends.  The time lag between adjacent bends passing through
% the same angle (identified by the _dtw_ calculation) defines the
% "phase," or more correctly the "time delay" property.
%-------------------------------------------------------------------
    % Dynamic Time Warp function...
    [p1, p2] = dtw(signa1p, signa2p, 40);
    
    cores = zeros(1, prod(size(xp))); 
    count = zeros(1, prod(size(xp)));
    
	for j = 1:prod(size(p1))
        cores(p1(j)) = cores(p1(j)) + xp(p2(j))-xp(p1(j));
        count(p1(j)) = count(p1(j)) + 1;  
    end
    
    cores = cores(1:10:end);
    count = count(1:10:end);
    phase(count>0,i) = cores(count>0)' ./ count(count>0)';
    phase(count>0,i) = phase(count>0,i) * spf;  % Scaled by spf
   
end

return;
