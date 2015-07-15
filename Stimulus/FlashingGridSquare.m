% Clear the workspace
close all;
clear all;
sca;
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% Open an on screen window
[window, windowRect]=PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xWindowCenter, yWindowCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA')

%load gammaTable        
global gt
gt = load('gammatable2_n17.mat');             
Screen('LoadNormalizedGammaTable', window, gt.gammaTable2*[1 1 1]); 



% --- Initiate TTLpulse --- %
%pkg load instrument-control;
%sparams.paralellport= parallel('/dev/parport0',0);
%InitiateTTLPulses;



% --- Get parameters --- %
% Degree to pixel conversion factor
xd2p = screenXpixels/125;
yd2p = screenYpixels/70;

% size parameters
xsize = 5*xd2p;
ysize = 5*yd2p;

% luminance parameters
lum = 255;

% framerate
framerate = 60;

% Inter-stimulus interval
ISI = 1;

% Calculate number of frames (nframes)
timeofstim = 0.5;    
nframes = (framerate*timeofstim);


% number of trail
trail = 1;



% --- Initiate Screen --- %
% Start the recording with TTL pulse and send timestamp

%parallelTTLstartstop(sparams.paralellport,recbit);  
%TTLfunction(startbit,recbit); WaitSecs(.1);




% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;
WaitSecs(ISI);

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Center position
xCenter = 640;
yCenter = 512;

% Generate position list
xGrid = (windowRect(3)/xsize);
yGrid = (windowRect(4)/ysize);
xCenterlist = linspace(0+(xsize/2),windowRect(3)-(xsize/2),xGrid+1);
yCenterlist = linspace(0+(ysize/2),windowRect(4)-(ysize/2),yGrid+1);


% --- Presenting stimulus ---%
for l = 1:trail
    
    for k = 1:length(yCenterlist)
     yCenterGrid = yCenterlist(k);
     for j = 1:length(xCenterlist)
      xCenterGrid = xCenterlist(j);
%    % Send TTL pulse timestamp
%%      TTLfunction(stimbit,recbit);
%%      TTLfunction(framebit,recbit);
      
      for i = 1:nframes
      
      % Center square
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenterGrid, yCenterGrid);
      % Draw the rect to the screen
      Screen('FillRect', window, [lum lum lum], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
       
      % Increment the time
      time = time + ifi;
      
      % Send TTL pulse timestamp
%      TTLfunction(framebit,recbit);
     
    endfor
    
  vbl = Screen('Flip', window);
  WaitSecs(ISI);
  
  endfor
  endfor

endfor

% Stop the recording with TTL pulse and send timestamp
%TTLfunction(stopbit,0);

% Clear the screen
sca;
close all;
clear all;


