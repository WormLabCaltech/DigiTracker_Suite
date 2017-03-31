function [legendtext] = promptforlegend(varargin)

% was originally function [legendtext] = promptforlegend_01x(varargin)

%---------------------------------------------------------------

% Prompt for the chart LEGEND text:
prompt = 'Enter chart legend information:';
dlg_title = 'Chart legend information';
num_lines= nargin;

for i = 1:num_lines
    directory = varargin{i};
    delimiter_positions = findstr(filesep, directory);
    
    if isempty(delimiter_positions)
        legend_text_line = directory;
    else
        % Trim off trailing fileseps (if any)
        while delimiter_positions(end) == length(directory)
            directory = directory(1:end-1);
            delimiter_positions = findstr(filesep, directory);
        end
        
        % Establish end of i'th line of legend text as vector
        legend_text_line = [directory(delimiter_positions(end)+1:end)];
    end
    
%     % Replace '\' with ': '
%     legend_text_line = strrep(legend_text_line, '\', ': ');

    % Replace '_' with ' '  (prevents subscripts via TexInterpreter)
    legend_text_line = strrep(legend_text_line, '_', ' ');

    % Convert vector into array
    defaulttext{i} = legend_text_line;
end

def = {str2mat(defaulttext)};   % Convert legend text array to matrix

answer  = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)      % In case user presses cancel
    legendtext = NaN;   % Return a null result and
    return;             %    abort execution
%     answer = def;       % use the default text  <---I don't like this approach anymore
end

legendtext = answer{1};
if size(legendtext, 1) < nargin
    errordlg(['ERROR:  Please enter exactly ' int2str(nargin) ' conditions for the legend']);
%     error(['ERROR:  Please enter exactly ' int2str(nargin) ' conditions for the legend']);
end
legendtext = legendtext(1:nargin,:);

%---------------------------------------------------------------
