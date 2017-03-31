dtw.c is intended to be compiled within Matlab to create a "mex" file
that can be called just like a Matlab function.  Prior to compiling a 
compatible compiler must be present on the computer and selected for
use with Matlab's mex function.  To set up mex use:
>> mex -setup


To compile dtw.c within Matlab use:
>> mex dtw.c
or 
>> mex -v dtw.c     % i.e. with the 'verbose' flag




     - C. J. Cronin  (cjc@caltech.edu)
       Sternberg Lab
       California Institute of Technology
       2010-02-25
