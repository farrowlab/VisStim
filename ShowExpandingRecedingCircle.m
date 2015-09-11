function StimLog = ShowExpandingRecedingCircle(window, vparams, sparams)

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
xsmallsize = (vparams.SmallSize*xd2p);
ysmallsize = (vparams.SmallSize*yd2p);
xbigsize = (vparams.BigSize*xd2p);
ybigsize = (vparams.BigSize*yd2p);

% luminance parameter
lum = vparams.StimLum;

% framerate
framerate = round(1/sparams.ifi);

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
StimLog.StimulusClass = 'Expanding Receding Circle';   
StimLog.BgColor = vparams.BgColour; % BgColor
StimLog.Speed = vparams.Speed;
StimLog.SmallSize = vparams.SmallSize; 
StimLog.BigSize = vparams.BigSize;
StimLog.StimLum = vparams.StimLum;
StimLog.Xpos = vparams.Xpos;
StimLog.Ypos = vparams.Ypos;
StimLog.ISI = vparams.ISI;
StimLog.Trail = vparams.Trial;


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
  
  % Calculate number of frames (nframes)
  for j = 1:size(speedlist,2)
    
    speed = speedlist(j);
    StimLog.Stim(k).Stim(j).StimSpeed = speed/yd2p; % Log speed
        
    timeofstim = abs((ybigsize-ysmallsize)/speed);    
    nframes = round(framerate*timeofstim);
    assignin('base','timeofstim',timeofstim)
    assignin('base','nframes',nframes);
    
    % Generate size list
    % Expanding to bigsize
    exp_xsizelist = linspace(xsmallsize,xbigsize,nframes);
    exp_ysizelist = linspace(ysmallsize,ybigsize,nframes);
    % Receding to small size
    rec_xsizelist = linspace(xbigsize,xsmallsize,nframes);
    rec_ysizelist = linspace(ybigsize,ysmallsize,nframes);
    % Stay in bigsize
    big_xsizelist = xbigsize*ones(1,framerate*5); % stay for 5 sec
    big_ysizelist = ybigsize*ones(1,framerate*5); % stay for 5 sec
      
      
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    TTLfunction(framebit,recbit);
    StimLog.Stim(k).Stim(j).TimeON = GetSecs - StimLog.BeginTime;  % Log TimeON
      
    % Expanding to bigsize
    for i = 1:(nframes)    
      % Draw the rect to the screen
      dstRect = [0 0 exp_xsizelist(i) exp_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum lum lum], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;
      
      % Send TTL pulse timestamp
      TTLfunction(framebit,recbit);
      
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(k).Stim(j).Transition1 = GetSecs - StimLog.BeginTime; % Log Transition1
    
    % Stay in bigsize
    for i = 1:(framerate*5)    
      % Draw the rect to the screen
      dstRect = [0 0 big_xsizelist(i) big_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum lum lum], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;
      
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(k).Stim(j).Transition2 = GetSecs - StimLog.BeginTime; % Log Transition2
    
    % Receding to small size
    for i = 1:(nframes)    
      % Draw the rect to the screen
      dstRect = [0 0 rec_xsizelist(i) rec_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum lum lum], dstRect);
      
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


