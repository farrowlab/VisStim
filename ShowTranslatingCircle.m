function StimLog = ShowTranslatingCircle(window, vparams, sparams)

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

% luminance parameters
lum = vparams.StimLum;

% framerate
framerate = 1/sparams.ifi;

% Inter-stimulus interval
ISI = vparams.ISI;

% speed list
speed = vparams.Speed*yd2p;

% angle list
anglelist = vparams.Angle;

% number of trail
trial = vparams.Trial;

% Center position
xCenter = vparams.Xpos;
yCenter = vparams.Ypos;



% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Translating Circle';   
StimLog.BgColor = vparams.BgColour; % BgColor
StimLog.Speed = vparams.Speed;
StimLog.Angle = vparams.Angle;
StimLog.Size = vparams.Size;
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


% ------------------- %
% --- Calculation --- %
% Calculate translating path, default is the half length of diagonal axis
diaglength = (sqrt((sparams.screenWidth)^2+(sparams.screenHeight)^2))/2;
xtranspath = diaglength + (xsize/2);
ytranspath = diaglength + (ysize/2);
% Calculate number of frames (nframes)
timeofstim = ytranspath*2/speed;  % if speed is 30 deg/s, time is 5.7352 s  
nframes = (framerate*timeofstim);



% ------------------------ %
% --- Present stimulus --- %
for k = 1:trial
  
  %randanglelist = anglelist(randperm(size(anglelist,2))); % randomize the sequence of angle list
  randanglelist = anglelist; 

  for  j = 1:size(randanglelist,2) 
  
    angle = randanglelist(j);
    StimLog.Stim(k).Stim(j).Angle = angle; % Log angle   
    
    % Generate position list
    if  (angle == 0) % Horizontal axis, backward translation (angle 0)       
      xCenterlist = linspace((xCenter-xtranspath),(xCenter+xtranspath),nframes);
      yCenterlist = yCenter*ones(1,nframes);
    elseif (angle == 180) % Horizontal axis, forward translation (angle 180)
      xCenterlist = linspace((xCenter+xtranspath),(xCenter-xtranspath),nframes);
      yCenterlist = yCenter*ones(1,nframes);
    elseif (angle == 270) % Vertical axis, downward translation (angle 270)
      xCenterlist = xCenter*ones(1,nframes);
      yCenterlist = linspace((yCenter-ytranspath),(yCenter+ytranspath),nframes);
    elseif (angle == 90) % Vertical axis, upward translation (angle 90)
      xCenterlist = xCenter*ones(1,nframes);
      yCenterlist = linspace((yCenter+ytranspath),(yCenter-ytranspath),nframes);
    elseif  (angle == 315) % Diagonal axis, downbackward (angle 315)
      xCenterlist = linspace((xCenter-(xtranspath/sqrt(2))),(xCenter+(xtranspath/sqrt(2))),nframes);
      yCenterlist = linspace((yCenter-(ytranspath/sqrt(2))),(yCenter+(ytranspath/sqrt(2))),nframes);
    elseif  (angle == 135) % Diagonal axis, upforward (angle 135)
      xCenterlist = linspace((xCenter+(xtranspath/sqrt(2))),(xCenter-(xtranspath/sqrt(2))),nframes);
      yCenterlist = linspace((yCenter+(ytranspath/sqrt(2))),(yCenter-(ytranspath/sqrt(2))),nframes);
    elseif  (angle == 45) % Diagonal axis,  upbackward (angle 45)
      xCenterlist = linspace((xCenter-(xtranspath/sqrt(2))),(xCenter+(xtranspath/sqrt(2))),nframes);
      yCenterlist = linspace((yCenter+(ytranspath/sqrt(2))),(yCenter-(ytranspath/sqrt(2))),nframes);
    elseif  (angle == 225) % Diagonal axis, downforward (angle 225)
      xCenterlist = linspace((xCenter+(xtranspath/sqrt(2))),(xCenter-(xtranspath/sqrt(2))),nframes);
      yCenterlist = linspace((yCenter-(ytranspath/sqrt(2))),(yCenter+(ytranspath/sqrt(2))),nframes);
    endif
       
    % Send TTL pulse timestamp
      TTLfunction(stimbit,recbit);
      TTLfunction(framebit,recbit);
      StimLog.Stim(k).Stim(j).TimeON = GetSecs - StimLog.BeginTime;  % Log TimeON
      
 
    for  i = 1:nframes    
      % Draw the rect to the screen
      dstRect = [0 0 xsize ysize];
      dstRect = CenterRectOnPointd(dstRect, xCenterlist(i), yCenterlist(i));
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

% Stop the recording with TTL pulse and send timestamp
TTLfunction(stopbit,0);

