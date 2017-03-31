function [Change, TotTimeF, TotTimeB]=changebf_4(A,threshold)
% Function for counting how many times the worm changes from Forward to
% Backward and from Backward to Forward and the duration of movement
%
% Vector A indicates direction of travel:
%    1 = Forward
%   -1 = Backward
%
% The 'threshold' value indicates the minimum number of frames of forward
% or backward movement that are to be considered real movement.  That is,
% we are set up to ignore short stuff like jitter.

% Initialising Variables:
Tc = diff(A);         % +2 or -2 indicates places where the worm changes direction
% Ta = A(1:end-1);    % vector A without its the last value
% Tb = A(2:end);      % vector A starting from the second value
% Tc = Tb-Ta;         % +2 or -2 indicates places where the worm changes direction -- same as diff
ChgF = [];
ChgB = [];

Chgf = find(Tc==2 )+1;      % Indices where the worms start moving Forward
Chgb = find(Tc== -2)+1;     % Indices where the worms start moving Backward

% Check direction the worm starts out and add index 1 to that direction
if A(1) == 1
    Chgf = [1 Chgf];
elseif A(1) == -1
    Chgb = [1 Chgb];
end

%----------------------------------------------------------

% Find how long the worm moves in forward direction; how many 1's are there 
% after each other in the mode file and put the length of ones in a matrix
% with the places where the worm moves forward. 
for k = 1:length(Chgf)
    Countf = 0;
    i=Chgf(k);
    while A(i) == 1 && (i) < length(A)
        Countf = Countf + 1 ;
        i=i+1;
    end
    ChgF = [ChgF Countf];       % New matrix ChgF not the same as Chgf !!
                                % This matrix has the places where the worms
                                % move forward with in the second row how
                                % many values (ones) it moves forward
end

% Find how long the worm moves in backward direction; how many -1's are there 
% after each other in the mode file . (Same as above but now for backward)
for j = 1:length(Chgb)
    Countb = 0;
    i=Chgb(j);
    while A(i) == -1 && (i) < length(A)
        Countb = Countb +1 ;
        i=i+1;
    end
    ChgB = [ChgB Countb];
end

%----------------------------------------------------------

% Remove any Backward movement that is shorter than the threshold and make
% the values in original matrix A zero where the movement duration is below
% the threshold.  These values are stored in Back

% We seem to need some values (even nulls) in ChgB for the find(ChgB) test,
% so...
if numel(ChgB) < 1
    ChgB = NaN;
    Chgb = NaN;
end
RemB = [Chgb;ChgB];
RemerB = find(ChgB(1,:) < threshold);
TimerB = find(ChgB(1,:) >= threshold);   % Get values where the threshold is reached to calculate average time backward motion
TimeB = RemB(:,TimerB);
TotTimeB = sum(TimeB(2,:));  % total number of units in backward motion.
RemB = RemB(:,RemerB);
Back=A;
for r = 1:length(RemerB)
    for q = 1:RemB(2,r)
      p=q-1;
        Back(RemB(1,r)+p)=0;
    end
end


% Remove any Forward movement that is shorter than the threshold and make
% the values zero in matrix Back (renamed to Forw) where the forward motion
% duration fis below the threshold value.

% ...And the same error-proofing for worms that don't move forward:
if numel(ChgF) < 1
    ChgF = NaN;
    Chgf = NaN;
end
RemF = [Chgf;ChgF];
RemerF = find(ChgF(1,:) < threshold);
TimerF = find(ChgF(1,:) >= threshold);   % Get values where the threshold is reached to calculate average time backward motion
TimeF = RemF(:,TimerF);
TotTimeF = sum(TimeF(2,:));  % total number of units in forward motion. 
RemF = RemF(:,RemerF);
Forw=Back;
for r = 1:length(RemerF)
    for q = 1:RemF(2,r)
      p=q-1;
        Forw(RemF(1,r)+p)=0;
    end
end
Forwr = find(Forw == 0);
% Now the zero values are deleted from the matrix leaving only the changes
% in motion where the change is longer than the threshold value.
Forw(Forwr) =[];

%----------------------------------------------------------



% Calculate the movement changes from here.
Forwc = diff(Forw);
Forwa = Forw(1:end-1);
Forwb = Forw(2:end);
Forwc = Forwb-Forwa;
Change = length(find(Forwc == 2 | Forwc == -2));


