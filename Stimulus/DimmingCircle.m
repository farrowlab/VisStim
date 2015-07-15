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


% fixed size parameters for nframes calculation
startsize = (1*d2p)/2;
stopsize = (60*d2p)/2;
% fixed speed list for nframes calculation
speedlist = [10 20 40 80 160]*d2p/2;
randspeedlist = speedlist(randperm(size(speedlist,2))); % randomize the sequence of speed list


% luminance parameters
startlum = 1;
stoplum = 0;
size = (60*d2p)/2;

% framerate
framerate = 60;

% Inter-stimulus interval
ISI = 5;

% number of trail
trail = 1;


%load gammaTable        
global gt
gt = load('gammatable2_n17.mat');             
Screen('LoadNormalizedGammaTable', window, gt.gammaTable2*[1 1 1]); 



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


% Presenting stimulus
for k = 1:trail
  
  % Calculate number of frames (nframes)
  for j = 1:size(randspeedlist,2)      
    speed = randspeedlist(j);
    timeofstim = abs((stopsize-startsize)/speed);    
    nframes = (framerate*timeofstim);
  
    % Generate luminance list
    if (startlum < stoplum) % brightening
      lumlist = linspace(startlum,stoplum,nframes);
    elseif (startlum > stoplum) % dimming
      lumlist = linspace(startlum,stoplum,nframes);
    elseif (startlum == stoplum) % the same luminance
      lumlist = startlum*ones(1,nframes);
    endif
    
    
    for i = 1:nframes    
      % Draw the rect to the screen
      Screen('gluDisk', window, [lumlist(i) lumlist(i) lumlist(i)], xCenter, yCenter, size);
      %Screen('gluDisk', window, lumChange, xCenter, yCenter, stopsize);
      
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


