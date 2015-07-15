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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xWindowCenter, yWindowCenter] = RectCenter(windowRect);


% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA')

% Make a simple checkerboard
checkerboard = repmat(eye(2), 2, 2);

% Make the chekerboard into a texture
checkerTexture = Screen('MakeTexture', window, checkerboard);


% Degree to pixel conversion factor
d2p = screenYpixels/70;

% size parameters
startsize = (1*d2p);
stopsize = (60*d2p);

% framerate
framerate = 60;

% Inter-stimulus interval
ISI = 5;

% speed list
speedlist = [10 20 40 80 160]*d2p;
randspeedlist = speedlist(randperm(size(speedlist,2))); % randomize the sequence of speed list

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

% Switch filter mode to simple nearest neighbour
filterMode = 0;

% ColorModulation
colorMod = [1 1 1];

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
  
    % Generate size list
    if (startsize < stopsize) % expanding
      sizelist = linspace(startsize,stopsize,nframes);
    elseif (startsize > stopsize) % receding
      sizelist = linspace(startsize,stopsize,nframes);
    elseif (startsize == stopsize) % the same size
      sizelist = startsize*ones(1,nframes);
    endif

    for i = 1:nframes
      % Center checkerboard
      dstRect = [0 0 sizelist(i) sizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);   
      % Draw the checkerboard texture to the screen.
      Screen('DrawTextures', window, checkerTexture, [], dstRect, 0, filterMode, 0, []); %colorMod);

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


