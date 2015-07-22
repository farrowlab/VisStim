function StimLog = ShowTranslatingExpandingCheckerboard(window, vparams, sparams)

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
speedofsize = vparams.Speed*yd2p; % divided by 2 for radius

% angle list
anglelist = vparams.Angle;

% number of trail
trial = vparams.Trial;

% Center position
xCenter = vparams.Xpos;
yCenter = vparams.Ypos;






% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Translating Expanding Circle';   
StimLog.BgColor = vparams.BgColour; % BgColor
StimLog.Speed = vparams.Speed;
StimLog.Angle = vparams.Angle;
StimLog.StartSize = vparams.StartSize; 
StimLog.StopSize = vparams.StopSize;
StimLog.Xcenter = vparams.Xpos;
StimLog.Ycenter = vparams.Ypos;


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



% ------------------- %
% --- Calculation --- %
% Calculate translating radius, default is the half length of diagonal axis
xtransradius = (sqrt((sparams.rect(3)/2)^2+(sparams.rect(4)/2)^2)) + (max(xstartsize,xstopsize)/2);
ytransradius = (sqrt((sparams.rect(3)/2)^2+(sparams.rect(4)/2)^2)) + (max(ystartsize,ystopsize)/2);
% Calculate number of frames (nframes)
timeofstim = ytransradius*2/speedofsize;    
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



% ------------------------ %
% --- Present stimulus --- %
for k = 1:trial
  
  randanglelist = anglelist(randperm(size(anglelist,2))); % randomize the sequence of angle list

  for  j = 1:size(randanglelist,2) 
  
    angle = randanglelist(j);
    StimLog.Stim(k).Stim(j).Angle = angle; % Log angle
    
    % Generate position list
    if  (angle == 0) % Horizontal axis, backward translation (angle 0)       
      xCenterlist = linspace((xCenter-xtransradius),(xCenter+xtransradius),nframes);
      yCenterlist = yCenter*ones(1,nframes);
    elseif (angle == 180) % Horizontal axis, forward translation (angle 180)
      xCenterlist = linspace((xCenter+xtransradius),(xCenter-xtransradius),nframes);
      yCenterlist = yCenter*ones(1,nframes);
    elseif (angle == 270) % Vertical axis, downward translation (angle 270)
      xCenterlist = xCenter*ones(1,nframes);
      yCenterlist = linspace((yCenter-ytransradius),(yCenter+ytransradius),nframes);
    elseif (angle == 90) % Vertical axis, upward translation (angle 90)
      xCenterlist = xCenter*ones(1,nframes);
      yCenterlist = linspace((yCenter+ytransradius),(yCenter-ytransradius),nframes);
    elseif  (angle == 315) % Diagonal axis, downbackward (angle 315)
      xCenterlist = linspace((xCenter-(xtransradius/sqrt(2))),(xCenter+(xtransradius/sqrt(2))),nframes);
      yCenterlist = linspace((yCenter-(ytransradius/sqrt(2))),(yCenter+(ytransradius/sqrt(2))),nframes);
    elseif  (angle == 135) % Diagonal axis, upforward (angle 135)
      xCenterlist = linspace((xCenter+(xtransradius/sqrt(2))),(xCenter-(xtransradius/sqrt(2))),nframes);
      yCenterlist = linspace((yCenter+(ytransradius/sqrt(2))),(yCenter-(ytransradius/sqrt(2))),nframes);
    elseif  (angle == 45) % Diagonal axis,  upbackward (angle 45)
      xCenterlist = linspace((xCenter-(xtransradius/sqrt(2))),(xCenter+(xtransradius/sqrt(2))),nframes);
      yCenterlist = linspace((yCenter+(ytransradius/sqrt(2))),(yCenter-(ytransradius/sqrt(2))),nframes);
    elseif  (angle == 225) % Diagonal axis, downforward (angle 225)
      xCenterlist = linspace((xCenter+(xtransradius/sqrt(2))),(xCenter-(xtransradius/sqrt(2))),nframes);
      yCenterlist = linspace((yCenter-(ytransradius/sqrt(2))),(yCenter+(ytransradius/sqrt(2))),nframes);
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
      dstRect = [0 0 xsizelist(i) ysizelist(i)];
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

