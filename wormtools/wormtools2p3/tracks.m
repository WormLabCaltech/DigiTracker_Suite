function [ampt, wavelnth] = tracks(x, y, mmpp, isBkp)

%TRACKS    Calculate wormtrack wavelength and amplitude from xy data.
%   FORMAT: [ampt, wavelnth] = tracks(x, y, mmpp)
%      where 
%      - "x" and "y" are matrices of x and y coordinates.  (Rows are 
%         time, columns are data points along a worm's "spine" from
%         head to tail).
%      - "mmpp" is the ratio "millimeters per pixel" which is 
%         a function of microscope and camera optics.  For the
%         Sternberg Lab's worm tracking rig in Kerckhoff 221:
%             Magnification    mmpp (mm/pixel)
%             -------------    ---------------
%                  6x               0.017
%                 12x               0.0085
%                 25x               0.0041
%                 50x               0.0020
%      - "isBkp" is an OPTIONAL 'flag' vector (the same length 
%         as the number of rows of "x" and "y") indicating 
%         valid (1) or invalid (any value other than 1) sets of 
%         "x" and "y" coordinates.  
%         (Added for error handling for when the TRACKS function 
%         is compiled and called from another program.)
%
%      - "ampt" is a vector of instantaneous wormtrack amplitudes or, 
%         more precisely, at each "time" the width of a bounding 
%         box aligned with the worm's velocity vector (the direction 
%         the rear 2/3 of the worm is traveling at that moment).
%      - "wavelnth" is a vector of instantaneous wormtrack wavelengths.
%         Calculated by: at each time snapshot, aligning the worm's
%         velocity vector with the x-axis, performing a spatial 
%         (as opposed to temporal) fast Fourier transform (FFT) 
%         for the y-coordinates of the worm's posture (yielding 
%         cycles/pixel), inverting (to get pixels/cycle), and 
%         scaling to the desired units.

%   C. J. Cronin 11-13-02
%   Revised 
%   $Revision: 1.02 $  $Date: 2004/01/23 xx:xx:xx $
% 
% r1.03: Changes isBkp screen to look for isBkp(i)~=1.  Per 
%   Zhaoyang (John) Feng, isBkp(i) can take values of 1 (valid row 
%   of data), or 0, -1, -10,... (invalid row of data, invalid for 
%   the reason coded by the indicated value).
%
% r1.02: Adds additional (optional) input argument 'isBkp'
%   a vector indicating a valid (1) or invalid (0) set of x,y
%   coordinates.  Argument is added for error handling when 
%   TRACKS is compiled to a .dll and called from another program
%   (for example a C-language program).  The 'isBkp' vector 
%   replaces invalid 'x' and 'y' coordinates with 'NaN's.
%   Dated 01/22/2004 1:21PM.
% 
% r1.01: Initial release
%   Dated 11/13/2002 4:35PM.


% some error checking
if nargout > 2
	error('[ampt, wavelnth] = tracks(x, y, [mmpp], [isBkp])');   
end

if nargin < 3
    mmpp = 1;   % Leave calculated wavelength pixels/cycle
end

% Error handling for compiled version of TRACKS - 1/21/04
% ... in case "invalid" rows in x and y matrices do NOT already 
%     contain NaN's we replace the garbage content with NaN's here.
if nargin == 4      % ...if isBkp vector is provided
    if prod(size(isBkp)) ~= size(x,1)   % check vector length
        error('''isBkp'' length must match number of ''x'' rows');
    end
    
    NaNvector = NaN*zeros(1,size(x,2));     % Temporary NaN vector
    
    for i = 1:size(x,1)
%         if isBkp(i) == 0    % if invalid Bkp set
        if isBkp(i) ~= 1    % if invalid Bkp set -- Per Zhaoyang (John) 
                            % Feng, isBkp vector can have values of
                            % 1, 0, -1,  or -10... with 1 the only 
                            % value indicating an VALID row of data.
            x(i,:) = NaNvector;     % replace contents with NaN's
            y(i,:) = NaNvector;     % replace contents with NaN's
        end
    end
    
    clear NaNvector
end




% Establishes worm centerline based on instantaneous velocity vector 

% Calculate direction vector
cx = diff(mean(x(:,5:end)'));   % Vectors of mean position coordinates
cy = diff(mean(y(:,5:end)'));   %   for rear ~2/3 of worm.
phi = atan2(cy, cx);      % Vector of travel directions (angles)

% Mean Length
len = sum(sqrt(diff(x').^2 + diff(y').^2));
meanlen = mean(len(~isnan(len)));

% Establish some references
nworms = size(x,1);
npts = size(x,2);
nintervals = npts - 1;


ampt = [];
wavelnth = [];
    
for i = 1:nworms    % Repeat for each "worm" (each time snapshot)
    
    % Velocity direction for i'th worm
    if i < nworms
        theta = phi(i);
    else
        theta = phi(i-1);
    end
    
    % Find width of bounding box
    if isnan(theta)     % To prevent warning for singular matrix
        ampt(i) = NaN;  % resulting from NaN velocity angle
        wavelnth(i) = NaN;
    else
        xx = x(i,:);    % Establish x&y coordinate vectors
        yy = y(i,:);
    
        w = [xx; yy];   % Matrix of x's & y's
        w(3,:) = 1;     % Bottom row of 1's
    
 
%----TRACK AMPLITUDE--------------------------------------
        % Establish velocity direction as centerline
        midptx = mean(xx);      % Reference point at ~middle of worm
        midpty = mean(yy);
    
        endptxa = midptx + len*cos(theta);  % 1st CL endpoint
        endptya = midpty + len*sin(theta);

        endptxb = midptx - len*cos(theta);  % 2nd CL endpoint
        endptyb = midpty - len*sin(theta);

        CLx = [endptxa endptxb];    % x&y coordinate vectors
        CLy = [endptya endptyb];
    
        CL = [CLx; CLy];    % Matrix of CL x's & y's
        CL(3,:) = 1;        % Bottom row of 1's
        
        
        % Translation transform
        A = [1   0   -midptx;
             0   1   -midpty;
             0   0    1];
    
        % Rotation transform
        B = [cos(-theta)  -sin(-theta)   0;   
             sin(-theta)   cos(-theta)   0;
             0            0            1];
    
        % Combined transform
        C = B*A;
    
        % Inverse of Combined transform - for use later...
        invC = inv(C);
    
    
        % Do the transformations
        ww = C*w;
        CLtransformed = C*CL;
    
        % Parse transformed worm-coordinate matrix 
        wwx = ww(1,:);  % x&y coordinate vectors
        wwy = ww(2,:);
    
% %---------------------------------------------------------
% % FOR DISPLAY
%     % Locate bounding box coordinates (for display)
%     bboxtransformed = ...
%         [min(wwx)   max(wwx)   max(wwx)   min(wwx);
%          min(wwy)   min(wwy)   max(wwy)   max(wwy)];
% 
%     bboxtransformed(3,:) = 1;    % Bottom row of 1's to allow 
%                                  %   bounding box to be transformed
%                                  %   back with worm to original
%                                  %   worm position.
%     
%     % Repeat first column of bounding box as last column
%     %   to create a "closed" rectangle
%     bboxtransformed = [bboxtransformed, bboxtransformed(:,1)];
%
%     % SANITY CHECK SANITY CHECK SANITY CHECK SANITY CHECK 
%     % Plots worm and bounding box with velocity vector 
%     %   aligned with X-axis
%     plot(ww(1,:),ww(2,:),'b-')
%     hold on;
%     plot(CLtransformed(1,:),CLtransformed(2,:), 'r-')
%     plot(bboxtransformed(1,:), bboxtransformed(2,:), 'g-');
%     hold off;
%     axis equal;
% %---------------------------------------------------------
    
        % Calculate track amplitude 
        ampt(i) = max(wwy) - min(wwy);  % Width of bounding box
                                        %   aligned with x-axis
                                        %   (in pixels)
                                        
        ampt(i) = ampt(i) * mmpp;   % Converted into mm
        
        
        
%---------------------------------------------------------
%----TRACK WAVELENGTH-------------------------------------
        % Calculate track wavelength:
    
        % Ignore worms where ends are curled back on self
        if abs( max(wwx)-min(wwx) ) ~= abs( wwx(1)-wwx(end) )
            wavelnth(i) = NaN;      % for curled worm
                % Ignore the rare case where there two adjacent data points
                % are EXACTLY above each other
        elseif any(diff(wwx)==0)
            wavelnth(i) = NaN;
        else    % for non-curled worms, can measure wavelength
        
            % Interpolate signal to position vertices equally
            %   distributed along X-axis...
            % (NOTE: Using signal as a factor of X-position, NOT TIME!
            %   Hence, references of "frequency" are "spatial frequency,"
            %   not temporal frequency.)
        
            % Reference vector of equally distributed X-positions
            iwwx = [wwx(1) : (wwx(end)-wwx(1))/nintervals : wwx(end)];
        
            % Signal interpolated to reference vector
            iwwy = interp1(wwx, wwy, iwwx); 
        
            % Calculate spatial frequency of signal (cycles/PIXEL)
            iY = fft(iwwy,512);
            iPyy = iY.* conj(iY) / 512; % Power of constitutive 
                                        %   "frequency" components
                                        %   (From Matlab online 
                                        %   documentation for _fft [1]_)
        
            xlength = max(iwwx) - min(iwwx);    % Worm length (pixels)
        
            
            % Vector of "frequencies" (cycles/pixel), from 0 (steady 
            %   state factor) to Nyquist frequency (i.e. 0.5*sampling 
            %   frequency).  (In our case sampling frequency is 
            %   typically 12 samples per worm).  
            % (Nyquist frequency is the theoretical highest frequency
            %   that can be accurately detected for a given sampling 
            %   frequency.)
            f = (nintervals/xlength)*(0:256)/512;
        
    
            % Find index(es) of maximum power measurement (for look-up 
            %   in frequency vector)
            indx = find( iPyy(1:257) == max(iPyy(1:257)) );
   
            % In case there are two or more indices corresponding to 
            %   equal maximum powers, need to select one, otherwise 
            %   the wavelnth(i) = 1/f(indx(1))  assignment will choke
            %   on the resulting mismatched matrix sizes.
            if ( prod(size(indx)) == 1 ) & ( f(indx(1)) == 0 )
                wavelnth(i) = NaN;     % Disregard the (expected-to-be- 
                                    %   rare) case where 0 Hz is the
                                    %   only maximum-power frequency
            else
                if f(indx(1)) == 0  % If the first element yields 0 Hz,
                    indx = indx(2:end); % take the next element
                end
            
                % Calculate wormtrack wavelength (finally...)
                wavelnth(i) = 1/f(indx(1));     % In pixels/cycle
                
                wavelnth(i) = wavelnth(i) * mmpp;   % Convert 
                                                    %   wavelength 
                                                    %   into mm/cycle
                
            end
        
            
        end     % if abs( max(wwx)-min(wwx) ) ~= ...
        
        

% %---------------------------------------------------------
% % FOR DISPLAY
%     % Un-transform bounding box
%     bbox = invC*bboxtransformed;
%     bbox = [bbox, bbox(:,1)];       % Close the bounding box loop
%     bbox = bbox(1:2,:);             % Trim off bottom row of 1's
% 
% % % % %     % Parse matrices
% % % % %     CLx = CL(1,:);
% % % % %     CLy = CL(2,:);
%     
%     % Plot worm with CL and bounding box
%     plot(xx,yy,'b-')
%     hold on;
%     plot(CLx,CLy, 'r-')
%     plot(bbox(1,:), bbox(2,:), 'g-');
%     hold off  
%     axis equal;
%     
%     pause(0.2);
% %---------------------------------------------------------
    
    end     % if isnan(theta)

    
end     % for i = 1:nworms

return