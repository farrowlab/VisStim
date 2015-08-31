function StimLog = ShowExpandingCircle(window, vparams, sparams)

% ------------------------- %
% --- Initiate TTLpulse --- %
InitiateTTLPulses;



% -----------------------%
% --- Get parameters --- %
Parameters = fieldnames(vparams);

% Degree to pixel conversion factor
d2p = 1/sparams.deg2pixel;

% size parameters
startsize = (vparams.StartSize*d2p)/2; % divided by 2 for radius
stopsize = (vparams.StopSize*d2p)/2; % divided by 2 for radius

% luminance parameter
lum = vparams.ONColor;

% framerate
framerate = 1/sparams.ifi;

% Inter-stimulus interval
ISI = vparams.PreTime+vparams.PostTime;

% speed list
speedlist = vparams.Speeds*d2p/2; % divided by 2 for radius

% number of trail
trial = vparams.Repeats;

% Center position
xCenter = sparams.screenWidth/2;
yCenter = sparams.screenHeight/2;



% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Expanding Circle';   
StimLog.BgColor = 125; % BgColor
StimLog.Speed = vparams.Speeds;
StimLog.StartSize = vparams.StartSize; 
StimLog.StopSize = vparams.StopSize;
StimLog.ONColor = vparams.ONColor;



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
  
  randspeedlist = speedlist(randperm(size(speedlist,2))); % randomize the sequence of speed list
  
  % Calculate number of frames (nframes)
  for j = 1:size(randspeedlist,2)
    
    speed = randspeedlist(j);
    StimLog.Stim(k).Stim(j).StimSpeed = speed/d2p*2; % Log speed
        
    timeofstim = abs((stopsize-startsize)/speed);    
    nframes = (framerate*timeofstim);
    assignin('base','timeofstim',timeofstim)
    assignin('base','nframes',nframes);
    
    % Generate size list
    if (startsize < stopsize) % expanding
      sizelist = linspace(startsize,stopsize,nframes);
    elseif (startsize > stopsize) % receding
      sizelist = linspace(startsize,stopsize,nframes);
    elseif (startsize == stopsize) % the same size
      sizelist = startsize*ones(1,nframes);
    endif
      
    % Send TTL pulse timestamp
    TTLfunction(stimbit,recbit);
    TTLfunction(framebit,recbit);
    StimLog.Stim(k).Stim(j).TimeON = GetSecs - StimLog.BeginTime;  % Log TimeON
      
    for i = 1:nframes    
      % Draw the rect to the screen
      Screen('gluDisk', window, [lum lum lum], xCenter, yCenter, sizelist(i));
      %Screen('gluDisk', window, lumChange, xCenter, yCenter, stopsize);
      
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


