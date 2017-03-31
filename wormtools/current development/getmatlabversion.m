function [matlabversion] = getmatlabversion()

%GETMATLABVERSION   Returns a numeric equivalaent of ver('MATLAB')
%   FORMAT: MatlabVersion = getmatlabversion
%
%   Function designed to return a numeric value for Matlab's version
%   number, specifically to handle the case where Mathworks uses a
%   sub-revision like 6.5.1.  This function returns that version as 6.0501
%   Similarly, v 7.6 returns as 7.0600
%   
% - C J Cronin   09/26/2008
%   cjc@caltech.edu
%   Sternberg Lab
%   California Institute of Technology
%

% Check for character array version of Matlab version
matlabversion = ver('MATLAB');
matlabversion = matlabversion.Version;

% NB: Had to change the single str2num... line into the mess below to
% handle cases where The Mathworks, in their infinite wisdom, decides to
% issue yet another manifestation of their version numbering system.  In 
% this case, version 6.5.1 (breaking the pattern of v6.0, v6.5, v7.0,
% v7.1, ...), stopped  
%         matlabversion = str2num(matlabversion.Version); 
% from working.  Grrrrrr.

% matlabversion = str2num(matlabversion.Version);

% Find location of decimal points
p = findstr('.', matlabversion);

if numel(p)>0   % if there's at least one decimal point...
    
    % Ensure that segments of version number don't exceed 2 digits
    % (Assuming that there won't be more than 100 sub-versions ever
    % released...)
    versionlengths = [diff(p) numel(matlabversion)+1-p(end)]-1;
    if any(versionlengths > 2)  
        % Otherwise throw error and hope that somebody can re-code the 
        % next block...
        error('I can''t believe this broke too.  Matlab''s version numbering system is really MADDENING!!!')
    end
    
    integerpart = matlabversion(1 : p(1)-1);
    fractionalpart = matlabversion(p(1) : end);
    
    % set up for loop
    fractionalstr = [];
    p = findstr('.', fractionalpart);
    
    while (numel(p)>0)
        endpart = fractionalpart(p(end)+1:end);     % digits after last decimal point
        endsize = numel(endpart);   % number of digits
        tempstr = '00';     % temporary string
        tempsize = numel(tempstr);  % temporary string's length
        tempstr( (tempsize-endsize+1) : end ) = endpart;    % last digits added to temporary string
        fractionalstr = [tempstr fractionalstr];    % temporary string appended to end of fractional string
        
        % Preparation for next pass through while loop
        fractionalpart = fractionalpart(1:p(end)-1);
        p = findstr('.', fractionalpart);
    end %while (numel...)
    
    % Then piece together integer and fraction strings 
    matlabversion = [integerpart '.' fractionalstr];
    
end

% ...and, FINALLY, convert to number
matlabversion = str2num(matlabversion);
