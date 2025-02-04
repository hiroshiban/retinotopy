% ************************************************************
% This_is_the_stimulus_parameter_file_for_retinotopy_Checker_experiment.
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___April_01_2011
% ************************************************************

%%% stimulus parameters
sparam.nwedges     = 4;   % number of wedge subdivisions along polar angle
sparam.nrings      = 8;   % number of ring subdivisions along eccentricity angle
sparam.width       = 48;  % wedge width in deg along polar angle
sparam.phase       = 0;   % phase shift in deg
sparam.rotangle    = 12;  % rotation angle in deg
sparam.startangle  = -sparam.width/2-90;     % presentation start angle in deg, from right-horizontal meridian, ccw

sparam.maxRad      = 8; % maximum radius of  annulus (degrees)
sparam.minRad      = 0;   % minumum

sparam.dimratio    = 0.4; % luminance dim ratio for the checker-pattern change detection task

% checkerboard colors, this variable is only for c* stimulus presentation scripts (e.g. cretinotopy)
sparam.colors      = [ 128, 128, 128; % number of colors for compensating flickering checkerboard
                       255,   0,   0; % the first row is background
                         0, 255,   0; % the second to end are patch colors
                       255, 255,   0;
                         0,   0, 255;
                       255,   0, 255;
                         0, 255, 255;
                       255, 255, 255;
                         0,   0,   0;
                       255, 128,   0;
                       128,   0, 255;];

%%% RDS parameters, these are only for d* stimulus presentation scripts (e.g dretinotopy_fixtask)
sparam.RDSdepth = [ -12, 12, 5]; % binocular disparity in arcmins, [min, max, #steps(from min to max)]
sparam.RDSDense=0.5; % dot density in the RDS images to be generated (percentage)
sparam.RDSradius=0.05; % dot radius in deg
sparam.RDScolors=[255,0,128]; % dot colors in the RDS, [color1, color2, background (grayscale)]
sparam.RDSbackground=0; % 1 = with background, 0 = no background
sparam.RDStaskmagnitude=2; % ratio (x2, x3, etc against the sparam.RDSdepth([1,2])) of the depth maginitude in the change-detection task

%%% duration in msec for each cycle & repetitions
sparam.cycle_duration=60000; % msec
sparam.rest_duration =0; % msec, rest after each cycle, stimulation = cycle_duration-rest_duration
sparam.numRepeats=6;

%%% object-image presentation parameters, only for i* object-image-based retinotopy stimuli (e.g. iretinotopy_fixtask)
sparam.flip_duration=250; % msec
sparam.nimg=120; % number of images to be presented at a frame
sparam.imRatio=[0.2,0.5]; % image magnification ratio, [min, max] (0.0-1.0), the image sizes are randomly selected whithin this range
sparam.imdepth=[-12,12]; % disparities (arcmins) added to the images, effective only in a stereo mode (e.g. shutter, dual, parallel etc)

%%% set number of frames to flip the screen
% Here, I set the number as large as I can to minimize vertical cynching error.
% the final 2 is for 2 times repetitions of flicker
% Set 1 if you want to flip the display at each vertical sync, but not recommended as it uses much CPU power
%sparam.waitframes = Screen('FrameRate',0)*(sparam.cycle_duration/1000) / (360/sparam.rotangle) / ( (size(sparam.colors,1)-1)*2 );
sparam.waitframes = 60*(sparam.cycle_duration/1000) / (360/sparam.rotangle) / ( (size(sparam.colors,1)-1)*2 );
%sparam.waitframes = 1;

%%% fixation period in msec before/after presenting the target stimuli, integer
% must set a value more than 1 TR for initializing the frame counting.
sparam.initial_fixation_time=[4000,4000];

%%% fixation size & color
sparam.fixtype=1; % 1: circular, 2: rectangular, 3: concentric fixation point
sparam.fixsize=4; % radius in pixels
sparam.fixcolor=[255,255,255];

% these are the values only valid for the *_fixtask.m stimuli.
sparam.fixtaskfreq=4; % frequency of the fixation color change task. The larger the value, the less frequent the task. 4 by default.
sparam.fixtaskduration=18; % the number of frames (duration) assigned to each task. The larger the value, the longer the task duration. 18 by default.

%%% background color
sparam.bgcolor=sparam.colors(1,:); %[0,0,0];

%%% RGB for background patches
% 1x3 matrices
sparam.patch_color1=[255,255,255];
sparam.patch_color2=[0,0,0];

%%% for converting degree to pixels
run(fullfile(fileparts(mfilename('fullpath')),'sizeparams'));
%sparam.pix_per_cm=57.1429;
%sparam.vdist=65;
%sparam.ipd=6.5;
