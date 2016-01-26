function StimLog = ShowCollisionTranslatingCircle(window, vparams, sparams)

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
object = [40]; % in cm
velocity = [200]; % in m/s
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
% Recede angle
for objidx = 1:length(object)
    for velidx = 1:length(velocity)
        theta_recede{objidx,velidx} = atan((object(objidx)/2)./(startpoint(velidx)+velocity(velidx)*linspace(0,time,nframes)))*2/pi*180;
        rec_xsizelist{objidx,velidx} = theta_recede{objidx,velidx}*xd2p;
        rec_ysizelist{objidx,velidx} = theta_recede{objidx,velidx}*yd2p;
    end
end
adapttime = 2;


% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Collision Translating Circle';   
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

    
    % Approaching (origin to eye, Z+)
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
    
    % Receding to small size (origin to faraway, z-)
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
    StimLog.Stim(l).Stim(k).Stim(j).RightAdapt = GetSecs - StimLog.BeginTime; % Log RightAdapt
    
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
    StimLog.Stim(l).Stim(k).Stim(j).RightON = GetSecs - StimLog.BeginTime; % Log RightON

    
    % Translating (origin to right)
    appstart_xsizelist = app_xsizelist{j,k}(1)*ones(1,nframes); 
    appstart_ysizelist = app_ysizelist{j,k}(1)*ones(1,nframes);
    % Calculate translating path, default is the half length of diagonal axis
    diaglength = (sqrt((sparams.screenWidth)^2+(sparams.screenHeight)^2))/2;
    xtranspath = diaglength + (appstart_xsizelist(1)/2);
    ytranspath = diaglength + (appstart_ysizelist(1)/2);
    % Generate position list
    % Horizontal axis, backward translation (angle 0)       
    angle0xCenterlist = linspace((xCenter),(xCenter+xtranspath),nframes);
    angle0yCenterlist = yCenter*ones(1,nframes);
    for i = 1:(nframes)    
      % Draw the rect to the screen
      dstRect = [0 0 appstart_xsizelist(i) appstart_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, angle0xCenterlist(i), angle0yCenterlist(i));
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
    StimLog.Stim(l).Stim(k).Stim(j).RightOFF = GetSecs - StimLog.BeginTime; % Log RightOFF
    
        
    vbl = Screen('Flip', window);
    WaitSecs(ISI);  
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(l).Stim(k).Stim(j).LeftAdapt = GetSecs - StimLog.BeginTime; % Log LeftAdapt
    
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
    StimLog.Stim(l).Stim(k).Stim(j).LeftON = GetSecs - StimLog.BeginTime; % Log LeftON

    
    % Translating (origin to left)
    appstart_xsizelist = app_xsizelist{j,k}(1)*ones(1,nframes); 
    appstart_ysizelist = app_ysizelist{j,k}(1)*ones(1,nframes);
    % Calculate translating path, default is the half length of diagonal axis
    diaglength = (sqrt((sparams.screenWidth)^2+(sparams.screenHeight)^2))/2;
    xtranspath = diaglength + (appstart_xsizelist(1)/2);
    ytranspath = diaglength + (appstart_ysizelist(1)/2);
    % Generate position list
    % Horizontal axis, forward translation (angle 180)
    angle180xCenterlist = linspace((xCenter),(xCenter-xtranspath),nframes);
    angle180yCenterlist = yCenter*ones(1,nframes);
    for i = 1:(nframes)    
      % Draw the rect to the screen
      dstRect = [0 0 appstart_xsizelist(i) appstart_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, angle180xCenterlist(i), angle180yCenterlist(i));
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
    StimLog.Stim(l).Stim(k).Stim(j).LeftOFF = GetSecs - StimLog.BeginTime; % Log LeftOFF
    
        
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(l).Stim(k).Stim(j).UpAdapt = GetSecs - StimLog.BeginTime; % Log UpAdapt
    
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
    StimLog.Stim(l).Stim(k).Stim(j).UpON = GetSecs - StimLog.BeginTime; % Log UpON

    
    % Translating (origin to Up)
    appstart_xsizelist = app_xsizelist{j,k}(1)*ones(1,nframes); 
    appstart_ysizelist = app_ysizelist{j,k}(1)*ones(1,nframes);
    % Calculate translating path, default is the half length of diagonal axis
    diaglength = (sqrt((sparams.screenWidth)^2+(sparams.screenHeight)^2))/2;
    xtranspath = diaglength + (appstart_xsizelist(1)/2);
    ytranspath = diaglength + (appstart_xsizelist(1)/2);
    % Generate position list
    % Vertical axis, upward translation (angle 90)
    angle90xCenterlist = xCenter*ones(1,nframes);
    angle90yCenterlist = linspace((yCenter),(yCenter-ytranspath),nframes);
    for i = 1:(nframes)    
      % Draw the rect to the screen
      dstRect = [0 0 appstart_xsizelist(i) appstart_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, angle90xCenterlist(i), angle90yCenterlist(i));
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
    StimLog.Stim(l).Stim(k).Stim(j).UpOFF = GetSecs - StimLog.BeginTime; % Log UpOFF
    
        
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(l).Stim(k).Stim(j).DownAdapt = GetSecs - StimLog.BeginTime; % Log DownAdapt
    
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
    StimLog.Stim(l).Stim(k).Stim(j).DownON = GetSecs - StimLog.BeginTime; % Log DownON

    
    % Translating (origin to Down)
    appstart_xsizelist = app_xsizelist{j,k}(1)*ones(1,nframes); 
    appstart_ysizelist = app_ysizelist{j,k}(1)*ones(1,nframes);
    % Calculate translating path, default is the half length of diagonal axis
    diaglength = (sqrt((sparams.screenWidth)^2+(sparams.screenHeight)^2))/2;
    xtranspath = diaglength + (appstart_xsizelist(1)/2);
    ytranspath = diaglength + (appstart_ysizelist(1)/2);
    % Generate position list
    % Vertical axis, downward translation (angle 270)
    angle270xCenterlist = xCenter*ones(1,nframes);
    angle270yCenterlist = linspace((yCenter),(yCenter+ytranspath),nframes);

    for i = 1:(nframes)    
      % Draw the rect to the screen
      dstRect = [0 0 appstart_xsizelist(i) appstart_ysizelist(i)];
      dstRect = CenterRectOnPointd(dstRect, angle270xCenterlist(i), angle270yCenterlist(i));
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
    StimLog.Stim(l).Stim(k).Stim(j).DownOFF = GetSecs - StimLog.BeginTime; % Log DownOFF
    
        
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
  endfor
  
  endfor
  
endfor

StimLog.EndTime = GetSecs - StimLog.BeginTime; % Log end time

% Stop the recording with TTL pulse
TTLfunction(stopbit,0);


