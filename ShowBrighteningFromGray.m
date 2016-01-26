function StimLog = ShowBrighteningFromGray(window, vparams, sparams)

% ------------------------- %
% --- Initiate TTLpulse --- %
InitiateTTLPulses;



% -----------------------%
% --- Get parameters --- %
Parameters = fieldnames(vparams);

% Degree to pixel conversion factor
xd2p = 1/sparams.xdeg2pixel;
yd2p = 1/sparams.ydeg2pixel;

% Size
xsize = sparams.screenWidth*1.5;
ysize = sparams.screenHeight*1.5;

% Luminance parameter
darklum = 0;
whitelum = 255;
graylum = 125;


% framerate
framerate = round(1/sparams.ifi);

% Inter-stimulus interval
ISI = vparams.ISI;


% number of trail
trial = vparams.Trial;

% Center position
xCenter = vparams.Xpos;
yCenter = vparams.Ypos;


% ------------------------------- %
% --- Generate luminance list --- %
time = 3;
nframes = round(framerate*time);
bin = 1./framerate;
% brightening from gray
lum_graybri_lin = linspace(graylum,whitelum,length(0:bin:time));
lum_graybri_lin_24end = [graylum*ones(1,length(0:bin:2.4)),linspace(graylum,whitelum,length(2.4+bin:bin:time))];
lum_graybri_lin_25end = [graylum*ones(1,length(0:bin:2.5)),linspace(graylum,whitelum,length(2.5+bin:bin:time))];
lum_graybri_lin_26end = [graylum*ones(1,length(0:bin:2.6)),linspace(graylum,whitelum,length(2.6+bin:bin:time))];
lum_graybri_lin_27end = [graylum*ones(1,length(0:bin:2.7)),linspace(graylum,whitelum,length(2.7+bin:bin:time))];
lum_graybri_lin_28end = [graylum*ones(1,length(0:bin:2.8)),linspace(graylum,whitelum,length(2.8+bin:bin:time))];
lum_graybri_lin_29end = [graylum*ones(1,length(0:bin:2.9)),linspace(graylum,whitelum,length(2.9+bin:bin:time))];
% dimming from gray
lum_graydim_lin = linspace(graylum,darklum,length(0:bin:time));
lum_graydim_lin_24end = [graylum*ones(1,length(0:bin:2.4)),linspace(graylum,darklum,length(2.4+bin:bin:time))];
lum_graydim_lin_25end = [graylum*ones(1,length(0:bin:2.5)),linspace(graylum,darklum,length(2.5+bin:bin:time))];
lum_graydim_lin_26end = [graylum*ones(1,length(0:bin:2.6)),linspace(graylum,darklum,length(2.6+bin:bin:time))];
lum_graydim_lin_27end = [graylum*ones(1,length(0:bin:2.7)),linspace(graylum,darklum,length(2.7+bin:bin:time))];
lum_graydim_lin_28end = [graylum*ones(1,length(0:bin:2.8)),linspace(graylum,darklum,length(2.8+bin:bin:time))];
lum_graydim_lin_29end = [graylum*ones(1,length(0:bin:2.9)),linspace(graylum,darklum,length(2.9+bin:bin:time))];
% brightening from dark
lum_darkbri_lin = linspace(darklum,graylum,length(0:bin:time));
lum_darkbri_lin_24end = [darklum*ones(1,length(0:bin:2.4)),linspace(darklum,graylum,length(2.4+bin:bin:time))];
lum_darkbri_lin_25end = [darklum*ones(1,length(0:bin:2.5)),linspace(darklum,graylum,length(2.5+bin:bin:time))];
lum_darkbri_lin_26end = [darklum*ones(1,length(0:bin:2.6)),linspace(darklum,graylum,length(2.6+bin:bin:time))];
lum_darkbri_lin_27end = [darklum*ones(1,length(0:bin:2.7)),linspace(darklum,graylum,length(2.7+bin:bin:time))];
lum_darkbri_lin_28end = [darklum*ones(1,length(0:bin:2.8)),linspace(darklum,graylum,length(2.8+bin:bin:time))];
lum_darkbri_lin_29end = [darklum*ones(1,length(0:bin:2.9)),linspace(darklum,graylum,length(2.9+bin:bin:time))];
% dimming from white
lum_whitedim_lin = linspace(whitelum,graylum,length(0:bin:time));
lum_whitedim_lin_24end = [whitelum*ones(1,length(0:bin:2.4)),linspace(whitelum,graylum,length(2.4+bin:bin:time))];
lum_whitedim_lin_25end = [whitelum*ones(1,length(0:bin:2.5)),linspace(whitelum,graylum,length(2.5+bin:bin:time))];
lum_whitedim_lin_26end = [whitelum*ones(1,length(0:bin:2.6)),linspace(whitelum,graylum,length(2.6+bin:bin:time))];
lum_whitedim_lin_27end = [whitelum*ones(1,length(0:bin:2.7)),linspace(whitelum,graylum,length(2.7+bin:bin:time))];
lum_whitedim_lin_28end = [whitelum*ones(1,length(0:bin:2.8)),linspace(whitelum,graylum,length(2.8+bin:bin:time))];
lum_whitedim_lin_29end = [whitelum*ones(1,length(0:bin:2.9)),linspace(whitelum,graylum,length(2.9+bin:bin:time))];



% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Brightening From Gray';   
StimLog.BgColor = vparams.BgColour; % BgColor
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
for j = 1:trial
  
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    TTLfunction(framebit,recbit);
    StimLog.Stim(j).DimLinON = GetSecs - StimLog.BeginTime;  % Log DimLinON
    
    % Linear brightening from gray starting at 0s  
    for i = 1:(nframes)     
      % Draw the rect to the screen
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum_graybri_lin(i) lum_graybri_lin(i) lum_graybri_lin(i)], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;
      
      % Send TTL pulse timestamp
      TTLfunction(framebit,recbit);     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLinOFF = GetSecs - StimLog.BeginTime; % Log DimLinOFF
    
    
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin24endON = GetSecs - StimLog.BeginTime; % Log DimLin24endON
    
    
    % Linear brightening from gray starting at 2.4s  
    for i = 1:(nframes)     
      % Draw the rect to the screen
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum_graybri_lin_24end(i) lum_graybri_lin_24end(i) lum_graybri_lin_24end(i)], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;
      
      % Send TTL pulse timestamp
      TTLfunction(framebit,recbit);     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin24endOFF = GetSecs - StimLog.BeginTime; % Log DimLin24endOFF
      
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin25endON = GetSecs - StimLog.BeginTime; % Log DimLin25endON
  
    % Linear brightening from gray starting at 2.5s  
    for i = 1:(nframes)     
      % Draw the rect to the screen
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum_graybri_lin_25end(i) lum_graybri_lin_25end(i) lum_graybri_lin_25end(i)], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;
      
      % Send TTL pulse timestamp
      TTLfunction(framebit,recbit);     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin25endOFF = GetSecs - StimLog.BeginTime; % Log DimLin25endOFF
      
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin26endON = GetSecs - StimLog.BeginTime; % Log DimLin26endON
    
    % Linear brightening from gray starting at 2.6s  
    for i = 1:(nframes)     
      % Draw the rect to the screen
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum_graybri_lin_26end(i) lum_graybri_lin_26end(i) lum_graybri_lin_26end(i)], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;
      
      % Send TTL pulse timestamp
      TTLfunction(framebit,recbit);     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin26endOFF = GetSecs - StimLog.BeginTime; % Log DimLin26endOFF
      
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin27endON = GetSecs - StimLog.BeginTime; % Log DimLin27endON
    
    
    % Linear brightening from gray starting at 2.7s  
    for i = 1:(nframes)     
      % Draw the rect to the screen
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum_graybri_lin_27end(i) lum_graybri_lin_27end(i) lum_graybri_lin_27end(i)], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;
      
      % Send TTL pulse timestamp
      TTLfunction(framebit,recbit);     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin27endOFF = GetSecs - StimLog.BeginTime; % Log DimLin27endOFF
      
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin28endON = GetSecs - StimLog.BeginTime; % Log DimLin28endON
    
    
    % Linear brightening from gray starting at 2.8s  
    for i = 1:(nframes)     
      % Draw the rect to the screen
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum_graybri_lin_28end(i) lum_graybri_lin_28end(i) lum_graybri_lin_28end(i)], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;
      
      % Send TTL pulse timestamp
      TTLfunction(framebit,recbit);     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin28endOFF = GetSecs - StimLog.BeginTime; % Log DimLin28endOFF
      
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin29endON = GetSecs - StimLog.BeginTime; % Log DimLin29endON
    
    
    % Linear brightening from gray starting at 2.9s  
    for i = 1:(nframes)     
      % Draw the rect to the screen
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
      Screen('FillOval', window, [lum_graybri_lin_29end(i) lum_graybri_lin_29end(i) lum_graybri_lin_29end(i)], dstRect);
      
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);
       
      % Increment the time
      time = time + sparams.ifi;
      
      % Send TTL pulse timestamp
      TTLfunction(framebit,recbit);     
    endfor
    
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    StimLog.Stim(j).DimLin29endOFF = GetSecs - StimLog.BeginTime; % Log DimLin29endOFF
      
    vbl = Screen('Flip', window);
    WaitSecs(ISI);
  
endfor

StimLog.EndTime = GetSecs - StimLog.BeginTime; % Log end time

% Stop the recording with TTL pulse
TTLfunction(stopbit,0);


