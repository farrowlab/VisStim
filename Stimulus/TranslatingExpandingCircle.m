% Clear the workspace
close all;
clear all;
sca;

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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xWindowCenter, yWindowCenter] = RectCenter(windowRect);


% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA')


% Degree to pixel conversion factor
d2p = screenYpixels/70;

% size parameters
startsize = (1*d2p)/2;
stopsize = (60*d2p)/2;
speedofsize = (40*d2p)/2;
% luminance parameters
startlum = 0;
stoplum = 0;
speedoflum = 0.1;

% framerate
framerate = 60;

% Inter-stimulus interval
ISI = 5;

% angle list
anglelist = [0 180 90 270 45 225 135 315 -1];
randanglelist = anglelist(randperm(size(anglelist,2))); % randomize the sequence of angle list

% number of trail
trail = 2;

%load gammaTable        
global gt
gt = load('gammatable2_n17.mat');             
Screen('LoadNormalizedGammaTable', window, gt.gammaTable2*[1 1 1]); 


% Calculate number of frames (nframes)
if (abs(stopsize-startsize) > 0) % for generating size list
  timeofstim = abs((stopsize-startsize)/speedofsize);    
  nframes = (framerate*timeofstim);
elseif (abs(stoplum-startlum) > 0) % for generating luminance list
  timeofstim = abs((stoplum-startlum)/speedoflum);    
  nframes = (framerate*timeofstim);
endif



% Generate size list
if (startsize < stopsize) % expanding
   sizelist = linspace(startsize,stopsize,nframes);
elseif (startsize > stopsize) % receding
   sizelist = linspace(startsize,stopsize,nframes);
elseif (startsize == stopsize) % the same size
   sizelist = startsize*ones(1,nframes);
endif

% Generate luminance list
if (startlum < stoplum) % brightening
   lumlist = linspace(startlum,stoplum,nframes);
elseif (startlum > stoplum) % dimming
   lumlist = linspace(startlum,stoplum,nframes);
elseif (startlum == stoplum) % the same luminance
   lumlist = startlum*ones(1,nframes);
endif





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

for k = 1:trail
  for  j = 1:size(anglelist,2) 
  
    angle = randanglelist(j);
  
    % Calculate position range for dianogal axis
    xzero = 0;
    xmax = windowRect(3);
    yzero = 0;
    ymax = windowRect(4);
    xdiff = abs(xWindowCenter - xCenter);
    ydiff = abs(yWindowCenter - yCenter);
  
    if (xCenter < xWindowCenter)
      xzero = 0 - xdiff;
      xmax = windowRect(3) - xdiff;
    elseif (xCenter > xWindowCenter)
      xzero = 0 + xdiff;
      xmax = windowRect(3) + xdiff;
    endif
  
    if (yCenter < yWindowCenter)
      yzero = 0 - ydiff;
      ymax = windowRect(4) - ydiff;
    elseif (yCenter > yWindowCenter)
      yzero = 0 + ydiff;
      ymax = windowRect(4) + ydiff;
    endif
  
  
    % Generate position list
    if  (angle == 0) % Horizontal axis, backward translation (angle 0)   
      xCenterlist = linspace(0,windowRect(3),nframes);
      yCenterlist = yCenter*ones(1,nframes);
    elseif (angle == 180) % Horizontal axis, forward translation (angle 180)
      xCenterlist = linspace(windowRect(3),0,nframes);
      yCenterlist = yCenter*ones(1,nframes);
    elseif (angle == 270) % Vertical axis, downward translation (angle 270)
      xCenterlist = xCenter*ones(1,nframes);
      yCenterlist = linspace(0,windowRect(4),nframes);
    elseif (angle == 90) % Vertical axis, upward translation (angle 90)
      xCenterlist = xCenter*ones(1,nframes);
      yCenterlist = linspace(windowRect(4),0,nframes);
    elseif  (angle == 315) % Diagonal axis, downbackward (angle 315)
      xCenterlist = linspace(xzero,xmax,nframes);
      yCenterlist = linspace(yzero,ymax,nframes);
    elseif  (angle == 135) % Diagonal axis, upforward (angle 135)
      xCenterlist = linspace(xmax,xzero,nframes);
      yCenterlist = linspace(ymax,yzero,nframes);
    elseif  (angle == 45) % Diagonal axis,  upbackward (angle 45)
      xCenterlist = linspace(xzero,xmax,nframes);
      yCenterlist = linspace(ymax,yzero,nframes);
    elseif  (angle == 225) % Diagonal axis, downforward (angle 225)
      xCenterlist = linspace(xmax,xzero,nframes);
      yCenterlist = linspace(yzero,ymax,nframes);
    elseif  (angle == -1) % Depth axis
      xCenterlist = xCenter*ones(1,nframes);
      yCenterlist = yCenter*ones(1,nframes);
    endif

  
    for  i = 1:nframes
    
      % Draw the rect to the screen
      Screen('gluDisk', window, [lumlist(i) lumlist(i) lumlist(i)], ...
      xCenterlist(i), yCenterlist(i), sizelist(i)); %Screen('gluDisk', window, lumChange, xCenter, yCenter, stopsize);

      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

      % Increment the time
      time = time + ifi;

    endfor
  
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
  
  endfor

endfor


% Clear the screen
sca;
close all;
clear all;


