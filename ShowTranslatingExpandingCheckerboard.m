function StimLog = ShowTranslatingExpandingCheckerboard(window, vparams, sparams)

% ------------------------- %
% --- Initiate TTLpulse --- %
InitiateTTLPulses;



% -----------------------%
% --- Get parameters --- %
Parameters = fieldnames(vparams);

% Degree to pixel conversion factor
d2p = 1/sparams.deg2pixel;

% size parameters
startsize = (vparams.StartSize*d2p);
stopsize = (vparams.StopSize*d2p);

% framerate
framerate = 1/sparams.ifi;

% Inter-stimulus interval
ISI = vparams.ISI;

% speed list
speedofsize = vparams.Speed*d2p; % divided by 2 for radius

% angle list
anglelist = vparams.Angle;

% number of trail
trial = vparams.Trial;

% Center position
xCenter = vparams.Xpos;
yCenter = vparams.Ypos;

% Calculate number of frames (nframes)
timeofstim = abs((stopsize-startsize)/speedofsize);    
nframes = (framerate*timeofstim);

% Generate size list
if (startsize < stopsize) % expanding
   sizelist = linspace(startsize,stopsize,nframes);
elseif (startsize > stopsize) % receding
   sizelist = linspace(startsize,stopsize,nframes);
elseif (startsize == stopsize) % the same size
   sizelist = startsize*ones(1,nframes);
endif



% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Translating Expanding Circle';   
StimLog.BgColor = 125; % BgColor
StimLog.Speed = vparams.Speed;
StimLog.Angle = vparams.Angle;
StimLog.StartSize = vparams.StartSize; 
StimLog.StopSize = vparams.StopSize;



% ----------------------- %
% --- Initiate Screen --- %
% Get the centre coordinate of the window
[xWindowCenter, yWindowCenter] = RectCenter(sparams.rect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA')

%% Make a checkerboard in circle
rmax = 100;
[n1,n2] = ndgrid(-rmax:rmax);
[THETA,r]=cart2pol(n1,n2);
FB = (-1).^(floor(n1/40)+floor(n2/40));
gp = find(r>rmax);
FB = FB * 255;
FB(gp) = 125;
checkerboard = FB;

assignin('base','checkerboard',checkerboard)

%% Make the chekerboard into a texture
checkerTexture = Screen('MakeTexture', window, checkerboard);

% Switch filter mode to simple nearest neighbour
filterMode = 0;

% Start the recording with TTL pulse and send timestamp
parallelTTLstartstop(sparams.paralellport,recbit);  
TTLfunction(startbit,recbit); WaitSecs(.1);
TTLfunction(stimbit,recbit);
StimLog.BeginTime = GetSecs; %Log Begin Time

% Sync us and get a time stamp
vbl = Screen('Flip', window);
WaitSecs(ISI);

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);



% ------------------------ %
% --- Present stimulus --- %
for k = 1:trial
  
  randanglelist = anglelist(randperm(size(anglelist,2))); % randomize the sequence of angle list

  for  j = 1:size(randanglelist,2) 
  
    angle = randanglelist(j);
    StimLog.Stim(k).Stim(j).Angle = angle; % Log angle
  
    % Calculate position range for dianogal axis
    xzero = 0;
    xmax = sparams.rect(3);
    yzero = 0;
    ymax = sparams.rect(4);
    xdiff = abs(xWindowCenter - xCenter);
    ydiff = abs(yWindowCenter - yCenter);
  
    if (xCenter < xWindowCenter)
      xzero = 0 - xdiff;
      xmax = sparams.rect(3) - xdiff;
    elseif (xCenter > xWindowCenter)
      xzero = 0 + xdiff;
      xmax = sparams.rect(3) + xdiff;
    endif
  
    if (yCenter < yWindowCenter)
      yzero = 0 - ydiff;
      ymax = sparams.rect(4) - ydiff;
    elseif (yCenter > yWindowCenter)
      yzero = 0 + ydiff;
      ymax = sparams.rect(4) + ydiff;
    endif  
  
    % Generate position list
    if  (angle == 0) % Horizontal axis, backward translation (angle 0)   
      xCenterlist = linspace(0,sparams.rect(3),nframes);
      yCenterlist = yCenter*ones(1,nframes);
    elseif (angle == 180) % Horizontal axis, forward translation (angle 180)
      xCenterlist = linspace(sparams.rect(3),0,nframes);
      yCenterlist = yCenter*ones(1,nframes);
    elseif (angle == 270) % Vertical axis, downward translation (angle 270)
      xCenterlist = xCenter*ones(1,nframes);
      yCenterlist = linspace(0,sparams.rect(4),nframes);
    elseif (angle == 90) % Vertical axis, upward translation (angle 90)
      xCenterlist = xCenter*ones(1,nframes);
      yCenterlist = linspace(sparams.rect(4),0,nframes);
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
       
    % Send TTL pulse timestamp
      TTLfunction(stimbit,recbit);
      TTLfunction(framebit,recbit);
      StimLog.Stim(k).Stim(j).TimeON = GetSecs - StimLog.BeginTime;  % Log TimeON
      
 
    for  i = 1:nframes    
      % Center checkerboard
      dstRect = [0 0 sizelist(i) sizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, xCenterlist(i), yCenterlist(i));   
      % Draw the checkerboard texture to the screen.
      Screen('DrawTexture', window, checkerTexture, [], dstRect, [], filterMode);

      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);

      % Increment the time
      time = time + sparams.ifi;
      
      % Send TTL pulse timestamp
      TTLfunction(framebit,recbit);

    endfor
  
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(k).Stim(j).TimeOFF = GetSecs - StimLog.BeginTime; % Log TimeOFF
    
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
  
  endfor

endfor


StimLog.EndTime = GetSecs - StimLog.BeginTime; % Log end time

% Stop the recording with TTL pulse and send timestamp
TTLfunction(stopbit,0);

