function [] = printem(figurenums)

% PRINTEM: Prints specified figures to the default printer.
%   Format:  printem(figurenumbers)
%       as in
%   printem(1:6)    or    printem([1 4 7])
%

% Christopher J. Cronin
% California Institute of Technology
% Sternberg Lab, Biology Department
% cjc@caltech.edu
% 
% Developed: 11/22/2004
% Revised: 3/06/2009


for i = figurenums
    if ispc
        print(['-f' int2str(i)], '-dwinc','-r300')
    elseif ismac || isunix
        print(['-f' int2str(i)], '-dpsc2','-r300')
    else
        error('Sorry, can''t handle this architecture.')
    end
        
end