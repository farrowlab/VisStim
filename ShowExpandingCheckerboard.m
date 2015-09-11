function StimLog = ShowExpandingCheckerboard(window, vparams, sparams)

% ------------------------- %
% --- Initiate TTLpulse --- %
InitiateTTLPulses;



% -----------------------%
% --- Get parameters --- %
Parameters = fieldnames(vparams);

% Degree to pixel conversion factor
xd2p = 1/sparams.xdeg2pixel;
yd2p = 1/sparams.ydeg2pixel;

% size parameters
xstartsize = (vparams.StartSize*xd2p);
ystartsize = (vparams.StartSize*yd2p);
xstopsize = (vparams.StopSize*xd2p);
ystopsize = (vparams.StopSize*yd2p);

% framerate
framerate = 1/sparams.ifi;

% Inter-stimulus interval
ISI = vparams.ISI;

% speed list
speedlist = vparams.Speed*yd2p;

% number of trail
trial = vparams.Trial;

% Center position
xCenter = vparams.Xpos;
yCenter = vparams.Ypos;



% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Expanding Checkerboard';   
StimLog.BgColor = vparams.BgColour; % BgColor
StimLog.Speed = vparams.Speed;
StimLog.StartSize = vparams.StartSize; 
StimLog.StopSize = vparams.StopSize;
StimLog.Xpos = vparams.Xpos;
StimLog.Ypos = vparams.Ypos;
StimLog.ISI = vparams.ISI;
StimLog.Trail = vparams.Trial;


% ----------------------- %
% --- Initiate Screen --- %
% Get the centre coordinate of the window
[xWindowCenter, yWindowCenter] = RectCenter(sparams.rect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

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

vbl = Screen('Flip', window);
WaitSecs(ISI);

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);



% ------------------------ %
% --- Present stimulus --- %
for k = 1:trial
  
  %randspeedlist = speedlist(randperm(size(speedlist,2))); % randomize the sequence of speed list
  randspeedlist = speedlist; 

  % Calculate number of frames (nframes)
  for j = 1:size(randspeedlist,2)
    
    speed = randspeedlist(j);
    StimLog.Stim(k).Stim(j).Speed = speed/yd2p; % Log speed
    
    timeofstim = abs((ystopsize-ystartsize)/speed);    
    nframes = (framerate*timeofstim);
  
    % Generate size list
    if (ystartsize < ystopsize) % expanding
      xsizelist = linspace(xstartsize,xstopsize,nframes);
      ysizelist = linspace(ystartsize,ystopsize,nframes);
    elseif (ystartsize > ystopsize) % receding
      xsizelist = linspace(xstartsize,xstopsize,nframes);
      ysizelist = linspace(ystartsize,ystopsize,nframes);
    elseif (ystartsize == ystopsize) % the same size
      xsizelist = xstartsize*ones(1,nframes);
      ysizelist = ystartsize*ones(1,nframes);
    endif
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    TTLfunction(framebit,recbit);
    StimLog.Stim(k).Stim(j).TimeON = GetSecs - StimLog.BeginTime;  % Log TimeON     
    
      
    for i = 1:nframes           
      % Center checkerboard
      dstRect = [0 0 xsizelist(i) ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);   
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
