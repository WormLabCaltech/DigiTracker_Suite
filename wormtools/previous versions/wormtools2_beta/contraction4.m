function [frequency, amplitude, flex] = contraction4(c, spf, isBkp)

%CONTRACTION4    Calculate worm movement metrics.
%   FORMAT: [frequency, amplitude, phase, flex] = contraction3(c, spf)
%      where 
%      - "c" is a matrix of worm bend angles for each bend along
%         the worm's "spine" (columns), at each time snapshot (rows).
%      - "spf" is the "seconds per frame" conversion factor (that is,
%         the time elapsed between adjacent frames (time snapshots).
%      - "isBkp" is an OPTIONAL 'flag' vector (the same length 
%         as the number of rows of "c") indicating valid (1) or 
%         invalid (any integer other than 1) rows of "c" bend angles.
%         (Added for error handling for when the CONTRACTION* 
%         function is compiled and called from another program.)
%
%      - "frequency" is a matrix containing the instantaneous bending 
%         frequencies for each of the worm's bends at each 
%         time-snapshot of the data set.  "frequency" is calculated 
%         by a windowed discrete-time Fourier transform of the input 
%         signal (bend angles) using a sliding window.
%      - "amplitude" is a matrix containing the maximum bend angle, in 
%         radians, for a window of time-snapshots (using a sliding 
%         window) for each of the worm's bends. 
%      - "phase" is a matrix containing the time delay (in seconds) 
%         between successive bends passing through the same angle 
%         at each time-snapshot.
%      - "flex" is a matrix containing the maximum flex, that is
%         maximum minus minimum bend angle, in radians, for a window 
%         of time-snapshots (using a sliding window) for each of the 
%         worm's bends. 

%   C. J. Cronin 7-24-02
%   Revised 
%   $Revision: 4.02 $  $Date: 2004/01/22 xx:xx:xx $
% 
% r4.03: Changes isBkp screen to look for isBkp(i)~=1.  Per 
%   Zhaoyang (John) Feng, isBkp(i) can take values of 1 (valid row 
%   of data), or 0, -1, -10,... (invalid row of data, invalid for 
%   the reason coded by the indicated value).
%
% r4.02: Adds additional (optional) input argument 'isBkp'
%   a vector indicating a valid (1) or invalid (0) row of c
%   coordinates.  Argument is added for error handling when 
%   CONTRACTION* is compiled to a .dll and called from another 
%   program (for example a C-language program).  The 'isBkp' vector 
%   replaces invalid rows of 'c' with 'NaN's.
%   Dated 01/22/2004 1:21PM.
% 
% r4.01: Corrects amp calculation; adds flex calculation.  Spins off
%   time delay calculation into function TIMEDELAY_01.  Adds
%   additional comments.  Renames variable npts to nbends to reflect
%   usage.
% 
% r3.02: Adds help information.  Adds revision history.  Adds
%   comments.
%   Dated 9/03/02 5:22PM.
%
% r3.01: Streamlines code for faster / simpler processing.  Eliminates
%   unused variables; eliminates "offset" from output.  Adds
%   processing time to output for diagnostics.   
%   Dated 2/01/02 8:53PM.
%
% r2.01: Not functional.  Intended to display frame number during
%   processing for diagnostics.
%   Dated 1/18/02 11:19PM.



% if nargin = 1, do not do unit conversion (DO NOT scale output
%  according to spf)
if nargin == 1
   spf = 1;	
end


% Error handling for compiled version of CONTRACTION4 - 1/21/04
% ... in case "invalid" rows in c matrix does NOT already 
%     contain NaN's we replace the garbage content with NaN's here.
if nargin == 3      % ...if isBkp vector is provided
    if prod(size(isBkp)) ~= size(c,1)   % check vector length
        error('''isBkp'' length must match number of ''c'' rows');
    end
    
    NaNvector = NaN*zeros(1,size(c,2));     % Temporary NaN vector
    
    for i = 1:size(c,1)
%         if isBkp(i) == 0    % if invalid Bkp set
        if isBkp(i) ~= 1    % if invalid Bkp set -- Per Zhaoyang (John) 
                            % Feng, isBkp vector can have values of
                            % 1, 0, -1,  or -10... with 1 the only 
                            % value indicating an VALID row of data.
            c(i,:) = NaNvector;     % replace contents with NaN's
        end
    end
    
    clear NaNvector
end


% get size of contractions
% npts = size(c,2);           % Renaming npts to reflect usage...
nbends = size(c,2);           % Number of bends (number of points minus 2)
nsamples = size(c,1);       % Number of time snapshots (frames)

% allocate space for results
frequency = NaN*zeros(nsamples, nbends);  % Block of NaN's, size of c
amplitude = NaN*zeros(nsamples, nbends);  % Block of NaN's, size of c
% frequency = NaN*zeros(nsamples, npts);  % Renamed npts to nbends
% amplitude = NaN*zeros(nsamples, npts);  % Renamed npts to nbends

% Constants
tt = [1+15.5:1:nsamples-15.5];
nfft = [0:0.005:0.30];
windowsize = 32;
numoverlap = 31;

% now compute amplitudes, frequencies, and offsets
% for i=1:npts    % Renamed npts to nbends to reflect usage...
for i=1:nbends    % 1:(number of bends along worm's length)

   
   signa = c(:,i)';     % Complete column of angles (at all times) for
                        % bend i; transposed into a row vector.
% 	 [b, f, t] = specgram(signa, [0:0.005:0.30], 1, hanning(32), 31);  
%    [b, f, t] = specgram(signa, nfft, 1, hanning(32), 31);  simpler output
   [b, f, t] = specgram(signa, nfft, 1, hanning(windowsize), numoverlap);
%------------------------------------------------------------
% NB:
% Matrix "b" (generated by specgram) contains the relative strengths
% of the frequency content of "signa" for each evaluated time snapshot.
% According to Matlab's documentation, '...each column of B contains an 
% estimate of the short-term, time-localized frequency content of the 
% signal ["signa"].  Time [frames] increases linearly across the 
% columns of "b", from left to right.  Frequency increases linearly 
% down the rows, starting at 0 [Hz].'  (Note that "b" is a matrix of 
% Complex numbers (even though the input vector "signa" is Real).  Not
% sure why this is. - CJC 10/24/02).
% 
% Thus, the most-characteristic frequency of the input signal "signa" 
% at a given time (column) will be the frequency corresponding to
% the row with the largest absolute value.  
% 
% Vector "f" lists the frequencies corresponding to the rows of "b"
% with the f(1) being 0 Hz, the steady state factor.
%------------------------------------------------------------
   clear t;     % not used
   amp = zeros(1, size(b,2));
   fre = zeros(1, size(b,2));
   
   for j=1:size(b,2)    % 1:(nsamples - numoverlap)
%       amp(j) = 4*max(abs(b(:,j)))/(32*0.4915);    <---?????  (Old)
      amp(j) = max(abs(signa(j:j+windowsize-1)));   % Corrected: Rev6.01
      flextemp(j) = max(signa(j:j+windowsize-1)) ...
          - min(signa(j:j+windowsize-1));   % Range of bending
      
      if isnan(max(abs(b(:,j))))    % error-handling for NaN's
         fre(j) = NaN;
      else 
         maxf = 1+find(abs(b(2:end,j)) == max(abs(b(2:end,j))));    
                % ...Column indices of [multiple] maximum values;
                %    adds 1 to skip the steady state component.
         maxf = maxf(1);    % Selects the lowest frequency maximum
         fre(j) = f(maxf);  % ID's the corresponding frequency.
      end
      
   end
   
   % Interpolate results across all frames
   amplitude(:,i) = interp1(tt, amp, [1:nsamples])';
   flex(:,i) = interp1(tt, flextemp, [1:nsamples])';
   frequency(:,i) = interp1(tt, fre, [1:nsamples])';
   frequency(:,i) = frequency(:,i) / spf;   % Scale frequency to spf
   
end
clear i signa b f t amp fre j maxf;   % free up memory


% Spinning off TIME LAG calculation into timedelay.m function...
% % % %-------------------------------------------------------------------
% % % % TIME LAG calculation
% % % 
% % % 
% % % % currenttime = [int2str(hour(now)) ':' int2str(minute(now)) ':' int2str(second(now))];
% % % % % fprintf(1, ['      Beginning *phase difference* at ' currenttime '\n']);
% % % % fprintf(1,  '      Beginning *phase difference* at %s \n', currenttime);
% % % 
% % % % now compute all phase differences (time lags)
% % % phase = NaN*zeros(nsamples, npts-1);
% % % for i=1:npts-1  
% % %        
% % %     
% % %     signa1 = c(:,i)'; signa2 = c(:,i+1)';       % Input signals (vectors of angles of adjacent bends)
% % %     x = [1:nsamples]; xp = [1:0.1:nsamples];    % Reference vectors
% % %     signa1p = interp1(x, signa1, xp); signa2p = interp1(x, signa2, xp); % Signal interpolated with 10x data points
% % %     [p1, p2] = dtw(signa1p, signa2p, 40);       % Dynamic Time Warp function
% % %     cores = zeros(1, prod(size(xp))); count = zeros(1, prod(size(xp)));
% % % 	for j = 1:prod(size(p1))
% % %    	cores(p1(j)) = cores(p1(j)) + xp(p2(j))-xp(p1(j));
% % %    	count(p1(j)) = count(p1(j)) + 1;  
% % %    end
% % %    cores = cores(1:10:end);
% % %    count = count(1:10:end);
% % % 	phase(count>0,i) = cores(count>0)' ./ count(count>0)';
% % %    phase(count>0,i) = phase(count>0,i) * spf;
% % %    
% % % end

return;
