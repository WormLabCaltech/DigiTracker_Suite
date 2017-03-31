function [shortcutoff, longcutoff] = lengthplotCheryl2(len, directory)

% [shortcutoff, longcutoff] = lengthplotCheryl2(len, directory)
%   v2: reversed output order.  WAS: [longcutoff, shortcutoff] = ...

if nargin <2
    directory = 'Length Plot';
end

scrsz = get(0,'ScreenSize');
lenfig = figure('Name', directory, 'Position',[scrsz(3)/2 scrsz(4)/3 scrsz(3)/2 scrsz(4)/2]);
plot(len,'b.');
grid on;

% Titles
title('Worm Length vs Time', 'FontWeight', 'bold');
xlabel('Frame number', 'FontWeight', 'bold');
ylabel('Length (pixels)', 'FontWeight', 'bold');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Prompt for the band-pass information:
dlg_title = 'Length band-pass bounds';
num_lines = 1;  

firstpromptprefix = [];
firstprompt = ['Enter upper and lower worm length cutoff values based on the length plot:     ';...
               '     HINT: Choose values that capture the bulk of the calculated worm lengths,';...
               '            not the little fingers that extend above or below.                ';...
               '                                                                              ';...
               '                                                                              ';...
               'Upper length cutoff:  [pixels]                                                '];

secondprompt = 'Lower length cutoff:  [pixels]';

def = {num2str(ceil(max(len))),num2str(floor(min(len)))};
    
 promptNOTOK = 1;
while promptNOTOK
    prompt = {[firstpromptprefix; firstprompt]; secondprompt};
    figure(lenfig);
    options.WindowStyle = 'normal';
    answer = inputdlg(prompt,dlg_title,num_lines,def, options);
    if isempty(answer)      % In case user presses cancel
        return
%     answer = def;       % use the default text
    end

    longcutoff = str2num(answer{1});
    shortcutoff = str2num(answer{2});
    
    if ~isempty(longcutoff) && ~isempty(shortcutoff)
        
        if isnumeric(longcutoff) && isnumeric(shortcutoff)
            if longcutoff > shortcutoff
                promptNOTOK = 0;
            else
                firstpromptprefix = ['PLEASE MAKE SURE UPPER CUTOFF IS GREATER THAN LOWER CUTOFF!                   ';...
                                     '                                                                              '];
            end     % longcutoff > shortcutoff
        else
            firstpromptprefix = ['PLEASE ENTER ONLY NUMERIC VALUES!                                             ';...
                                 '                                                                              '];
        end     % if isnumeric
    else
        firstpromptprefix = ['PLEASE ENTER ONLY NUMERIC VALUES!                                             ';...
                             '                                                                              '];
    end     % ~isempty
end     % while
            
        
        

close(lenfig);
return
