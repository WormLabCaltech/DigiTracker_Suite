function [x, y] = autoproc3(directory)

%AUTOPROC3    Orients and prescreens worm data
%   [x, y] = AUTOPROC3(directory) 
%      where 
%      - "x" and "y" are matrices of x and y coordinates.  
%      - "directory" is the name of a directory containing a file 
%         called 'points' (generated by RECOGNIZER*), and a series
%         of corresponding image files called 'file.*' (also 
%         generated by RECOGNIZER*), where * represents a frame 
%         number (e.g. 1, 101, 201, 301, ...).
%   Note: x and y matrices are passed back in memory, not saved 
%   to disk.
%
%   AUTOPROC* displays a skeleton worm superimposed over 
%   its corresponding 'grabbed' video image.  User is prompted
%   for whether skeletons are correctly oriented (that is, head 
%   depicted at the head-end).  AUTOPROC then cleans up x-y
%   data, reversing backward worms and eliminating invalid
%   data points, and interpolates over single missing frames.

%   C. J. Cronin 10-26-01
%   Revised 7-17-02 CJC.
%   $Revision: 3.02 $  $Date: 2002/09/03 xx:xx:xx $
%
%
% r3.02: Revises help information.  Fills in revision history.  
% (Help info created 10-26-01.)
% 
% r3.01: Adds interpolation across single missing frames; positions 
%   GUI at upper right corner of any size monitor.  Displays 
%   directory name in window title bar.  Dated 6-07-02 5:00PM.
% 
% r2.01: Revises table motion correction based on email correspondence
%   with Saleem.  Also renames variables to better reflect their 
%   function (e.g. wormnum-->movenum) (for readability).  Dated 
%   2-15-02 12:48PM.
% 
% r1.05: Begins implementation of Saleem's comments.  Dated 2-12-02 
%   9:37AM.
% 
% r1.04: Cleans up comments, deletes unnecessary code.  Dated
%   2-05-02 2:53PM.
% 
% r1.03: Corrects length calculation.  Dated 11-28-01 5:28PM.
% 
% r1.02: Adds comments.  Adds error handling to UI.  Dated 9-24-01 
%   9:12AM


% %%%%%%%%%%%%%%%%%%%%%%%%%%
% argument checking
% %%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin ~= 1
   error('invalid number of input arguments');
end   

 if nargout ~= 2
    error('invalid number of output arguments');	
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize variables
% %%%%%%%%%%%%%%%%%%%%%%%%%%
load([directory '\points']);
x = points(1:2:end,:);      % x-data in odd rows of points
y = points(2:2:end,:);      % y-data in even rows of points

nworms = size(x,1);     % number of time snapshots
points = [];

accel_threshold = 10;         % Acceleration threshold (pixels/frame/frame)
% threshold = 10;         % Acceleration threshold (pixels/frame/frame)

beep on;

% Parse bottom two directory names from directory string for figure title
delimiter_positions = findstr('\', directory);
if size(delimiter_positions, 2) > 1
    figure_name = ['...' directory(delimiter_positions(end-1):end)];
else
    figure_name = directory;
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%
% pop a new figure
% %%%%%%%%%%%%%%%%%%%%%%%%%%
scrnsz = get(0,'ScreenSize');
figwidth = 490;
figheight = 470;
% figure('position', ...
%     [scrnsz(3)-figwidth-10 , scrnsz(4)-figheight-80, figwidth, figheight]);
figure('Name', figure_name, 'position', ...
    [scrnsz(3)-figwidth-10 , scrnsz(4)-figheight-80, figwidth, figheight]);
                                                % Locate new GUI window in 
                                                %  upper right corner of 
                                                %  screen 
% figure('position', [530 230 490 470]);  % Figure in upper-right corner
drawnow

% Instruction for user:
fprintf(1,'\n---> BLUE DOT INDICATES HEAD-END...\n');

for frameno = 1:nworms
   imagename = [directory '\File.' int2str(frameno) '.bmp'];
   if exist(imagename, 'file') == 2
      
      % load in the image
      im = imread(imagename);
      
      % draw image and plot worm	
      clf;          % Clear Current Figure - deletes any image in current 
                    % figure

      imagesc(im);  % Paints worm image, color scaled to use all 
                    % available colors... Yields red background,
                    % and blue worm with yellow edges.
      hold on;
      grid;
      colormap(gray);   % Converts to grayscale image
      title(['Frame Number = ' int2str(frameno)]);
      caxis([0 255]);   % Limits how dark whites - more than
                        % 255 yields grayed whites.
      plot(x(frameno,:), y(frameno,:));
      plot(x(frameno,:), y(frameno,:), 'r.');
      plot(x(frameno,1), y(frameno,1), 'c.');
      axis equal;       % Use equal scaling for x & y axes; also yields 
                        % square plot
      drawnow;
  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


      % correct head position
      InvalidInput = 1;     % Flag to verify valid input
      while InvalidInput
         resp = input(['Frame #' int2str(frameno) '- (c) correct (i) incorrect? '], 's');
         if(( prod(size(resp)) == 1 ) & (XOR((resp == 'i') , (resp =='c')))) 
             points = [points frameno];     % Builds 'points' vector for 
                                            % use in reordering worms
             if resp == 'i'     % If head position is incorrect, reverse 
                                % point order
                x(frameno,:) = x(frameno,end:-1:1);
                y(frameno,:) = y(frameno,end:-1:1);
             end
             InvalidInput = 0;  % Set flag to False (i.e. NOT INvalid 
                                % input) to exit loop
         else
             beep
             fprintf(1, '     ---> Please enter ''c'' or ''i'' only...\n'); % Warning for bad input
         end
      end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% close the window
%%%%%%%%%%%%%%%%%%%%%%%%%%
close

%%%%%%%%%%%%%%%%%%%%%%%%%%
% now filter the data on length
%%%%%%%%%%%%%%%%%%%%%%%%%%
len = sum(sqrt(diff(x').^2 + diff(y').^2)); % Vector of worm lengths
                                            % at each time snapshot
valid = (len>35);   % Vector of 1,0's indicating valid/invalid
                    % based on length

%%%%%%%%%%%%%%%%%%%%%%%%%%
% reorder worms (based on user input of in-/correct orientation)
%%%%%%%%%%%%%%%%%%%%%%%%%%
nintervals = prod(size(points)) - 1;
for interval = 1:nintervals     % Indexes intervals (1,2,3,4,...)
                                % for frames (1, 101, 201, 301,...)
                                
   sframe = points(interval);   % Starting frame| Established as 
   eframe = points(interval+1); % Ending frame  | correct by user input
   
   
   lerrors = 0;     % Left-side errors |
   rerrors = 0;     % Right-size errors|
   
   lframe = sframe+1;   % Left frame in question
   rframe = eframe-1;   % Right...
   
   vlframe = sframe;    % Most recent left-/right-side frame known
   vrframe = eframe;    % to be correct... Important when software
                        % encounters & skips invalid (NaN) frames
   
   while lframe <= rframe   % Looks at interval between e.g. frames
                            % 2-->100, 102-->200
      
      if lerrors == rerrors
         
         if valid(lframe)
            if flip( x(lframe,:), y(lframe,:), ...  % Queries whether worm
                     x(vlframe,:), y(vlframe,:) )   % needs reversed
                x(lframe,:) = x(lframe,end:-1:1);   % Reverses order
                y(lframe,:) = y(lframe,end:-1:1);   % of worm
            end      
            vlframe = lframe;   % Re-establishes most recent left-
                                % side frame known correct
         else
            lerrors = lerrors + 1;
         end	
         lframe = lframe + 1;
         
         if valid(rframe)
            if flip( x(rframe,:), y(rframe,:), ... 
                     x(vrframe,:), y(vrframe,:) )
                x(rframe,:) = x(rframe,end:-1:1);
                y(rframe,:) = y(rframe,end:-1:1);  
            end      
            vrframe = rframe;
         else
            rerrors = rerrors + 1;
         end	
         rframe = rframe - 1;
         
      elseif lerrors < rerrors
         
         if valid(lframe)
            if flip( x(lframe,:), y(lframe,:), ... 
                     x(vlframe,:), y(vlframe,:) )
                x(lframe,:) = x(lframe,end:-1:1);
                y(lframe,:) = y(lframe,end:-1:1);  
            end      
            vlframe = lframe;
         else
            lerrors = lerrors + 1;
         end	
         lframe = lframe + 1;
         
      elseif rerrors < lerrors
         
         if valid(rframe)
            if flip( x(rframe,:), y(rframe,:), ... 
                     x(vrframe,:), y(vrframe,:) )
                x(rframe,:) = x(rframe,end:-1:1);
                y(rframe,:) = y(rframe,end:-1:1);  
            end      
            vrframe = rframe;
         else
            rerrors = rerrors + 1;
         end	
         rframe = rframe - 1;
                  
      end

	end
   
end

vlframe = points(end);
for lframe = points(end)+1:nworms
   
   if valid(lframe)
      if flip( x(lframe,:), y(lframe,:), ... 
               x(vlframe,:), y(vlframe,:) )
         x(lframe,:) = x(lframe,end:-1:1);
         y(lframe,:) = y(lframe,end:-1:1);  
      end      
      vlframe = lframe;
   end
      
end

% take out the trash...
x(logical(~valid),:) = NaN; % Adds NaN in place of invalid 
y(logical(~valid),:) = NaN; % data points...
                            % It looks like we try to filter 
                            % the NaN's out later (by interp1'ing)
                            % the mean data, but then we go
                            % back to x and y...
                            

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Here's where the fun begins...  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
% now compensate for table motion  
cx = mean(x')';     % Vector - Center of worm for each frame
cy = mean(y')';     % (length = #frames) ("Relative" center positions)
        
cxp = diff(cx);     % Vector - Movement between adjacent frames
cyp = diff(cy);     % (length = #frames - 1)
        
disp = sqrt(cxp.^2 + cyp.^2);   % Vector - Absolute value of movement 
                                % between adjacent frames
                                % (length = #frame - 1)

accx = diff(cxp);   % Acceleration = delta(velocities)
accy = diff(cyp);   %   (where velocity = displacement/frame)
                    %   so, Accel'n = rate of change of displacements

accx = [0; accx];   % Add 0th element to accelerations to line up 
accy = [0; accy];   % i'th element of acc* with i'th element of c*p.

val = (disp<30) & (~isnan(disp)) & ...
    (abs(accx) < accel_threshold) & (abs(accy) < accel_threshold);
                                    % Vector (l=#frames-1)
                                    % indicating valid for
                                    % movement less than 30 and
                                    % ~NaN (i.e. long-enough worms)
                                    % and no wild accelerations 
                                    % (i.e. microscope stage moves)
% val = (disp<30) & (~isnan(disp));   % Vector (l=#frames-1)
%                                     % indicating valid for
%                                     % movement less than 30 and
%                                     % ~NaN (i.e. long-enough worms)

nmoves = prod(size(val));       % Scalar  nmoves = #frames-1
% (WAS:)
% nworms = prod(size(val));       % Scalar  nworms = #frames-1
%                                 % Effectively, # moves


% % % %-------------Reject in favor of simplicity... ---------------------------
% % % %-------------START Acceleration Screen-----------------------------------
% % % accx = diff(cxp);   % Acceleration = delta(velocities)
% % % accy = diff(cyp);   %   (where velocity = displacement/frame)
% % %                     %   so, Accel'n = rate of change of displacements
% % %                     
% % % % Three cases for consideration:
% % % % I.
% % % %   |accel(i)|  >  threshold
% % % %     (but)
% % % %   |accel(i-1)|  <= threshold
% % % %         Interpret as: Microscope stage shift, isolated acceleration. 
% % % %         Action:  Reject validity of move (i+1).
% % % % 
% % % % II.
% % % %   |accel(i)|  >  threshold
% % % %     (AND)
% % % %   |accel(i-1)|  > threshold
% % % %   Yields two sub-cases:
% % % %     A. accel(i) and accel(i-1) are in same direction (have same sign)
% % % %         Interpret as: Continuation of previous acceleration. 
% % % %         Action:  Reject validity of move (i+1).
% % % %     B. accel(i) and accel(i-1) are in different directions (opposite signs)
% % % %         Interpret as: Reaction to previous acceleration (end of move)
% % % %         Action:  Don't change validity of move (i+1)
% % %         
% % % for i = 2:(nmoves - 1)  % One less acceleration than move
% % %     
% % %     if (abs(accx(i)) > threshold) | (abs(accy(i)) > threshold)  % Case I or II
% % %         
% % %         if (abs(accx(i-1)) > threshold) | (abs(accy(i-1)) > threshold)  % Case II
% % %             
% % %             if ((accx(i-1) * accx(i)) > 0)  % Case II(A)
% % %                 
% % %                 val(i+1) = logical(0);
% % %                 
% % %             end         % If Case II(B), do nothing
% % %             
% % %             if ((accy(i-1) * accy(i)) > 0) % Case II(A)
% % %                 
% % %                 val(i+1) = logical(0);
% % %                 
% % %             end         % If Case II(B), do nothing
% % %             
% % %         else            % Case I
% % %             
% % %             val(i+1) = logical(0);
% % %             
% % %         end
% % %         
% % %     end
% % %     
% % % end     % end of For
% % % 
% % % %---------------END Acceleration Screen-----------------------------------



movenum = [1:nmoves];           % Index of moves 1 for move 1-->2,...
% (WAS:)
% wormnum = [1:nworms];           % Index of moves 1 for move 1-->2,...
        
cxp = cxp(logical(val),:);      % Eliminates all garbage (NaN's and
cyp = cyp(logical(val),:);      % big movements) from movement vectors...
        
movenum = movenum(logical(val));    % ...and also eliminates the 
                                    % corresponding index numbers...
% (WAS:)
% wormnum = wormnum(logical(val));    % ...and also eliminates the 
%                                     % corresponding index numbers...
        
nmoves = max(movenum) - min(movenum) + 1;   % ...and sets us up to trim off
                                            % invalid data at the beginning
                                            % and end of the data set 
                                            % (frames)...
% (WAS:)
% nworms = max(wormnum) - min(wormnum) + 1;   % ...and sets us up to trim off
%                                             % invalid data at the beginning
%                                             % and end of the data set 
%                                             % (frames)...

        
                        % ...Now interpolates between missing (removed)
                        % moves...
cxp = interp1(movenum, cxp, [min(movenum):max(movenum)], 'linear');
cyp = interp1(movenum, cyp, [min(movenum):max(movenum)], 'linear');
% (WAS:)
% cxp = interp1(wormnum, cxp, [min(wormnum):max(wormnum)], 'linear');
% cyp = interp1(wormnum, cyp, [min(wormnum):max(wormnum)], 'linear');
        
cxn = [0 cumsum(cxp)];  % ...and sets up a new pair of vectors that 
cyn = [0 cumsum(cyp)];  % should re-create the original x & y center 
                        % positions, (i.e. "virtual global" center x&y's)
                        % but without the garbage at the beginning and 
                        % end, and with the invalid data points in the 
                        % middle filled in...
        
nworms = nmoves + 1;    % The number of frames, WITHOUT the invalid
                        % frames at the beginning and end...
                                % Includes the interpolated frames in
                                % the middle
% (WAS:)
% nworms = nworms + 1;    % The number of frames, WITHOUT the invalid
%                         % frames at the beginning and end...
%                                 % Includes the interpolated frames in
%                                 % the middle
        
cxn = (cxn - mean(cxn))';   % This centers the new "virtual global" center
cyn = (cyn - mean(cyn))';   % x & y position vectors about their means
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This is the part that I was confused on.....  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
cx = cx(min(movenum):(max(movenum)+1),:);   % Takes the valid range of
cy = cy(min(movenum):(max(movenum)+1),:);   % (uncorrected) "Relative" x&y 
                                            % center positions (eliminating 
                                            % the garbage at the beginning  
                                            % and end) 
% (WAS:)
% cx = cx(1:nworms,:);    % Takes the FIRST nworms of cx & cy data...
% cy = cy(1:nworms,:);    % but it looked like we tried to eliminate 
%                         % the invalid data at the beginning
%                         % going from [min(wormnum):max(wormnum)]...
%                         % Now we take back the garbage at the beginning
%                         % AND the garbage in the middle too!
% % Should this be something like 
%         % cx = cx(min(wormnum):max(wormnum)); ?

                        
offx = cxn - cx;        % (Virtual global center positions) minus 
offy = cyn - cy;        % (Relative x&y center positions) =
                        % (Offsets necessary to convert Relative x&y 
                        % positions into Virtual Global positions)

% now do the correction (from Relative positions into Virtual Global 
%  positions)
x = x(min(movenum):(max(movenum)+1), :) + offx*ones(1,13); 
y = y(min(movenum):(max(movenum)+1), :) + offy*ones(1,13); 
% (WAS:)
% x = x(1:nworms,:) + offx*ones(1,13);    % ...or this
% y = y(1:nworms,:) + offy*ones(1,13);    % ...same question of the using the first *nworms*
%                                         % as opposed to the min(wormnum):max(wormnum)...

% But x & y still contain NaN's in the middle...  So,
% Interpolate over SINGLE NaN's:
for i = 2:(size(x,1)-1)
    if isnan(x(i,1))
        x(i,:) = interp1([i-1 ; i+1], [x(i-1,:) ; x(i+1,:)], i, 'linear');
        y(i,:) = interp1([i-1 ; i+1], [y(i-1,:) ; y(i+1,:)], i, 'linear');
    end
end

return;

