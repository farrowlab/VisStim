function StimLog = ShowTranslatingBar(window, vparams, sparams)

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
xsizelist = (vparams.Size*xd2p);
ysize = (sparams.screenWidth*3);

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
StimLog.StimulusClass = 'Translating Bar';   
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


%% Make a square
square = vparams.StimLum;

assignin('base','square',square)


%% Make the chekerboard into a texture
squareTexture = Screen('MakeTexture', window, square);

% Switch filter mode to simple nearest neighbour
filterMode = 0;






% ------------------------ %
% --- Present stimulus --- %
for k = 1:trial
  
  %randanglelist = anglelist(randperm(size(anglelist,2))); % randomize the sequence of angle list
  randanglelist = anglelist; 
  
  for l = 1:size(xsizelist,2)
      
     xsize = xsizelist(l);

     % Calculate translating path, default is the half length of diagonal axis
     diaglength = (sqrt((sparams.screenWidth)^2+(sparams.screenHeight)^2))/2;
     verticallength = sparams.screenHeight;
     horizontallength = sparams.screenWidth;
     dxtranspath = diaglength + (xsize/2);
     dytranspath = diaglength + (xsize/2);
     vxtranspath = diaglength + (xsize/2);
     vytranspath = diaglength + (xsize/2);
     hxtranspath = diaglength + (xsize/2);
     hytranspath = diaglength + (xsize/2);
     % Calculate number of frames (nframes)
     timeofstim = dytranspath*2/speed;  % if speed is 30 deg/s, time is 5.7352 s  
     nframes = (framerate*timeofstim);
    
    for  j = 1:size(randanglelist,2) 
  
      angle = randanglelist(j);
      StimLog.Stim(k).Stim(l).Stim(j).Size = xsize/xd2p; % Log angle
      StimLog.Stim(k).Stim(l).Stim(j).Angle = angle; % Log angle   
    
      % Generate position list
      if  (angle == 0) % Horizontal axis, backward translation (angle 0)       
        xCenterlist = linspace((xCenter-hxtranspath),(xCenter+hxtranspath),nframes);
        yCenterlist = yCenter*ones(1,nframes);
      elseif (angle == 180) % Horizontal axis, forward translation (angle 180)
        xCenterlist = linspace((xCenter+hxtranspath),(xCenter-hxtranspath),nframes);
        yCenterlist = yCenter*ones(1,nframes);
      elseif (angle == 270) % Vertical axis, downward translation (angle 270)
        xCenterlist = xCenter*ones(1,nframes);
        yCenterlist = linspace((yCenter-vytranspath),(yCenter+vytranspath),nframes);
      elseif (angle == 90) % Vertical axis, upward translation (angle 90)
        xCenterlist = xCenter*ones(1,nframes);
        yCenterlist = linspace((yCenter+vytranspath),(yCenter-vytranspath),nframes);
      elseif  (angle == 315) % Diagonal axis, downbackward (angle 315)
        xCenterlist = linspace((xCenter-(dxtranspath/sqrt(2))),(xCenter+(dxtranspath/sqrt(2))),nframes);
        yCenterlist = linspace((yCenter-(dytranspath/sqrt(2))),(yCenter+(dytranspath/sqrt(2))),nframes);
      elseif  (angle == 135) % Diagonal axis, upforward (angle 135)
        xCenterlist = linspace((xCenter+(dxtranspath/sqrt(2))),(xCenter-(dxtranspath/sqrt(2))),nframes);
        yCenterlist = linspace((yCenter+(dytranspath/sqrt(2))),(yCenter-(dytranspath/sqrt(2))),nframes);
      elseif  (angle == 45) % Diagonal axis,  upbackward (angle 45)
        xCenterlist = linspace((xCenter-(dxtranspath/sqrt(2))),(xCenter+(dxtranspath/sqrt(2))),nframes);
        yCenterlist = linspace((yCenter+(dytranspath/sqrt(2))),(yCenter-(dytranspath/sqrt(2))),nframes);
      elseif  (angle == 225) % Diagonal axis, downforward (angle 225)
        xCenterlist = linspace((xCenter+(dxtranspath/sqrt(2))),(xCenter-(dxtranspath/sqrt(2))),nframes);
        yCenterlist = linspace((yCenter-(dytranspath/sqrt(2))),(yCenter+(dytranspath/sqrt(2))),nframes);
      endif
       
      % Send TTL pulse timestamp
        TTLfunction(stimbit,recbit);
        TTLfunction(framebit,recbit);
        StimLog.Stim(k).Stim(l).Stim(j).TimeON = GetSecs - StimLog.BeginTime;  % Log TimeON
      
 
      for  i = 1:nframes    
        % Draw the rect to the screen
        dstRect = [0 0 xsize ysize];
        dstRect = CenterRectOnPointd(dstRect, xCenterlist(i), yCenterlist(i));
        % Rotation angle of bar
        if  (angle == 0 || angle == 90 || angle == 180 || angle == 270)
        rotangle = angle;
        elseif  (angle == 45 || angle == 135 || angle == 225  || angle == 315) % Diagonal axis
        rotangle = angle + 90;
        endif
      
        % Draw the checkerboard texture to the screen.
        Screen('DrawTexture', window, squareTexture, [], dstRect, rotangle, filterMode);

        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);

        % Increment the time
        time = time + sparams.ifi;
      
        % Send TTL pulse timestamp
        TTLfunction(framebit,recbit);

      endfor
  
      % Send TTL pulse timestamp
      TTLfunction(stimbit,recbit);
      StimLog.Stim(k).Stim(l).Stim(j).TimeOFF = GetSecs - StimLog.BeginTime; % Log TimeOFF
    
      vbl = Screen('Flip', window);
      WaitSecs(ISI);
    
  
    endfor
    
  endfor
    

endfor


StimLog.EndTime = GetSecs - StimLog.BeginTime; % Log end time

% Stop the recording with TTL pulse and send timestamp
TTLfunction(stopbit,0);

