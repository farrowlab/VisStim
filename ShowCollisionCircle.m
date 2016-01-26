function StimLog = ShowCollisionCircle(window, vparams, sparams)

% ------------------------- %
% --- Initiate TTLpulse --- %
InitiateTTLPulses;



% -----------------------%
% --- Get parameters --- %
Parameters = fieldnames(vparams);

% Degree to pixel conversion factor
xd2p = 1/sparams.xdeg2pixel;
yd2p = 1/sparams.ydeg2pixel;

% luminance parameter
lum = vparams.StimLum;

% framerate
framerate = round(1/sparams.ifi);

% Inter-stimulus interval
ISI = vparams.ISI;

% number of trail
trial = vparams.Trial;

% Center position
xCenter = vparams.Xpos;
yCenter = vparams.Ypos;


% -----------------------------------------%
% --- Calculate Collision Visual Angle --- %
object = [20,40]; % in cm
velocity = [200,500]; % in m/s
time = 3;
startpoint = velocity.*time;
nframes = round(framerate*time);
% Approach angle
for objidx = 1:length(object)
    for velidx = 1:length(velocity)
        theta_approach{objidx,velidx} = atan((object(objidx)/2)./(startpoint(velidx)-velocity(velidx)*linspace(0,time,nframes)))*2/pi*180;
        app_xsizelist{objidx,velidx} = theta_approach{objidx,velidx}*xd2p;
        app_ysizelist{objidx,velidx} = theta_approach{objidx,velidx}*yd2p;
    end
end
% Reverse approach angle
for objidx = 1:length(object)
    for velidx = 1:length(velocity)
        tmp = theta_approach{objidx,velidx};
        theta_approach_rev{objidx,velidx} = fliplr(tmp);
    end
end
for objidx = 1:length(object)
    for velidx = 1:length(velocity)
        rec_xsizelist{objidx,velidx} = theta_approach_rev{objidx,velidx}*xd2p;
        rec_ysizelist{objidx,velidx} = theta_approach_rev{objidx,velidx}*yd2p;
    end
end
% Linear approach angle
for objidx = 1:length(object)
    for velidx = 1:length(velocity)
        tmp = theta_approach{objidx,velidx};
        theta_approach_lin{objidx,velidx} = linspace(tmp(1),tmp(end),nframes);
    end
end
for objidx = 1:length(object)
    for velidx = 1:length(velocity)
        linapp_xsizelist{objidx,velidx} = theta_approach_lin{objidx,velidx}*xd2p;
        linapp_ysizelist{objidx,velidx} = theta_approach_lin{objidx,velidx}*yd2p;
    end
end
adapttime = 2;


% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Collision Circle';   
StimLog.BgColor = vparams.BgColour; % BgColor
StimLog.Size = object;
StimLog.Speed = velocity;
StimLog.Time = time;
StimLog.Adapttime = adapttime;
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
for l = 1:trial
  
  for k = 1:size(velocity,2)
    
    for j = 1:size(object,2)
    
    StimLog.Stim(l).Stim(k).Stim(j).speed = velocity(k);
    StimLog.Stim(l).Stim(k).Stim(j).size = object(j);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(l).Stim(k).Stim(j).ApproachAdapt = GetSecs - StimLog.BeginTime; % Log ApproachAdapt
      
    
    % Adapt the approaching initial size (origin)
    appstart_xsizelist = app_xsizelist{j,k}(1)*ones(1,framerate*adapttime); 
    appstart_ysizelist = app_ysizelist{j,k}(1)*ones(1,framerate*adapttime);
    for i = 1:(framerate*adapttime)    
      % Draw the rect to the screen
      dstRect = [0 0 appstart_xsizelist(i) appstart_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum lum lum], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(l).Stim(k).Stim(j).ApproachON = GetSecs - StimLog.BeginTime; % Log ApproachON

    
    % Approaching (origin to eye)
    for i = 1:(nframes)    
      % Draw the rect to the screen
      dstRect = [0 0 app_xsizelist{j,k}(i) app_ysizelist{j,k}(i)];
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
    StimLog.Stim(l).Stim(k).Stim(j).ApproachOFF = GetSecs - StimLog.BeginTime; % Log ApproachOFF
    
    
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(l).Stim(k).Stim(j).RecedeAdapt = GetSecs - StimLog.BeginTime; % Log RecedeAdapt
    
    % Adapt the receding initial size (origin)
    recstart_xsizelist = rec_xsizelist{j,k}(1)*ones(1,framerate*adapttime); 
    recstart_ysizelist = rec_ysizelist{j,k}(1)*ones(1,framerate*adapttime);
    for i = 1:(framerate*adapttime)    
      % Draw the rect to the screen
      dstRect = [0 0 recstart_xsizelist(i) recstart_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum lum lum], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(l).Stim(k).Stim(j).RecedeON = GetSecs - StimLog.BeginTime; % Log RecedeON
    
    % Receding to small size (faraway to origin)
    for i = 1:(nframes)    
      % Draw the rect to the screen
      dstRect = [0 0 rec_xsizelist{j,k}(i) rec_ysizelist{j,k}(i)];
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
    StimLog.Stim(l).Stim(k).Stim(j).RecedeOFF = GetSecs - StimLog.BeginTime; % Log RecedeOFF
    
    
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(l).Stim(k).Stim(j).LinearApproachAdapt = GetSecs - StimLog.BeginTime; % Log LinearApproachAdapt
      
    % Adapt the linear approaching initial size (origin)
    linappstart_xsizelist = linapp_xsizelist{j,k}(1)*ones(1,framerate*adapttime); 
    linappstart_ysizelist = linapp_ysizelist{j,k}(1)*ones(1,framerate*adapttime);
    for i = 1:(framerate*adapttime)    
      % Draw the rect to the screen
      dstRect = [0 0 linappstart_xsizelist(i) linappstart_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum lum lum], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(l).Stim(k).Stim(j).LinearApproachON = GetSecs - StimLog.BeginTime; % Log LinearApproachON

    
    % Linear Approaching (origin to eye)
    for i = 1:(nframes)    
      % Draw the rect to the screen
      dstRect = [0 0 linapp_xsizelist{j,k}(i) linapp_ysizelist{j,k}(i)];
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
    StimLog.Stim(l).Stim(k).Stim(j).LinearApproachOFF = GetSecs - StimLog.BeginTime; % Log LinearApproachOFF
    
    
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
        
    
  endfor
  
  endfor
  
endfor

StimLog.EndTime = GetSecs - StimLog.BeginTime; % Log end time

% Stop the recording with TTL pulse
TTLfunction(stopbit,0);


