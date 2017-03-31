function [] = saveem(basicname, figurenums)

% Function format:
% SAVEEM( ~basicFileName~, ~listOfFigureNumbers~ );
%
% Saves the specified figure(s) as 
%   - .eps
%   - .fig, AND
%   - .pdf
% files.
%
% Examples:
% saveem('D:\Experiment_4\Condition_3', 2);
%   saves Figure #2 yielding files
%       D:\Experiment_4\Condition_3_Figure_2.eps
%       D:\Experiment_4\Condition_3_Figure_2.fig
%       D:\Experiment_4\Condition_3_Figure_2.pdf
%
%   Or specifying multiple figures with:
% saveem('D:\TEST\wildtype', [3 7]);
%   yields files
%       D:\TEST\wildtype_Figure_3.eps
%       D:\TEST\wildtype_Figure_3.fig
%       D:\TEST\wildtype_Figure_3.pdf
%   AND
%       D:\TEST\wildtype_Figure_7.eps
%       D:\TEST\wildtype_Figure_7.fig
%       D:\TEST\wildtype_Figure_7.pdf
%

% Christopher J. Cronin
% cjc@caltech.edu
% Sternberg Lab, Caltech
% updated 2017-02-17


% Loop thru figures
for i = figurenums
    figname = get(i, 'Name');
    if ~isempty(figname)
        fseps = findstr(filesep, figname);
        if ~isempty(fseps)
            figname(fseps) = ' ';
        end
        figname = [ ' [' figname '] '];
    else
        figname = '';
    end
    
% Save
    saveas(i,[basicname '_Figure_' int2str(i) figname '.eps'], 'epsc2');    % saves as .eps (color, level 2)
    saveas(i,[basicname '_Figure_' int2str(i) figname '.pdf'], 'pdf');      % saves as .pdf
    saveas(i,[basicname '_Figure_' int2str(i) figname '.fig'], 'fig');      % saves as .fig
end

