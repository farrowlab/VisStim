function StimLog = ShowDimmingCircle(window, vparams, sparams)

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
xsize = (vparams.Size*xd2p);
ysize = (vparams.Size*yd2p);
% fixed size parameters for nframes calculation
xstartsize = (1*xd2p);
ystartsize = (1*yd2p);
xstopsize = (60*xd2p);
ystopsize = (60*yd2p);

% luminance parameter
startlum = vparams.StartLum;
stoplum = vparams.StopLum;

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
StimLog.StimulusClass = 'Dimming Circle';   
StimLog.BgColor = vparams.BgColour; % BgColor
StimLog.Speed = vparams.Speed;
StimLog.Size = vparams.Size; 
StimLog.StartLum = vparams.StartLum;
StimLog.StopLum = vparams.StopLum;
StimLog.Xcenter = vparams.Xpos;
StimLog.Ycenter = vparams.Ypos;
StimLog.ISI = vparams.ISI;
StimLog.Trial = vparams.Trial;


% ----------------------- %
% --- Initiate Screen --- %
% Get the centre coordinate of the window
[xWindowCenter, yWindowCenter] = RectCenter(sparams.rect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA')

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
  
  %randspeedlist = speedlist(randperm(size(speedlist,2))); % randomize the sequence of speed list
  randspeedlist = speedlist; 
  
  % Calculate number of frames (nframes)
  for j = 1:size(randspeedlist,2)
    
    speed = randspeedlist(j);
    StimLog.Stim(k).Stim(j).StimSpeed = speed/yd2p; % Log speed
        
    timeofstim = abs((ystopsize-ystartsize)/speed);    
    nframes = (framerate*timeofstim);
    assignin('base','timeofstim',timeofstim)
    assignin('base','nframes',nframes);
    
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
    
    % Generate luminance list
    if (startlum < stoplum) % brightening
      lumlist = linspace(startlum,stoplum,nframes);
    elseif (startlum > stoplum) % dimming
      lumlist = linspace(startlum,stoplum,nframes);
    elseif (startlum == stoplum) % the same luminance
      lumlist = startlum*ones(1,nframes);
    endif
      
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    TTLfunction(framebit,recbit);
    StimLog.Stim(k).Stim(j).TimeON = GetSecs - StimLog.BeginTime;  % Log TimeON
      
    for i = 1:nframes    
      % Draw the rect to the screen
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lumlist(i) lumlist(i) lumlist(i)], dstRect);
      
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

% Stop the recording with TTL pulse
TTLfunction(stopbit,0);


