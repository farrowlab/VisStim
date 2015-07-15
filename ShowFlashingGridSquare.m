function StimLog = ShowFlashingGridSquare(window, vparams, sparams)

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

% number of trail
trial = vparams.Trial;

% Center position
xCenter = vparams.Xpos;
yCenter = vparams.Ypos;

% Calculate number of frames (nframes)
timeofstim = vparams.Duration;
nframes = (framerate*timeofstim);

% Generate position list
xGrid = (sparams.rect(3)/xsize);
yGrid = (sparams.rect(4)/ysize);
xCenterlist = linspace(0+(xsize/2),sparams.rect(3)-(xsize/2),xGrid+1);
yCenterlist = linspace(0+(ysize/2),sparams.rect(4)-(ysize/2),yGrid+1);



% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Flashing Grid Square';   
StimLog.BgColor = 125; % BgColor
StimLog.Duration = vparams.Duration;
StimLog.Size = vparams.Size;
StimLog.StimLum = vparams.StimLum;



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
    for k = 1:length(yCenterlist)
      yCenterGrid = yCenterlist(k);
        for j = 1:length(xCenterlist)
          xCenterGrid = xCenterlist(j);
          
          % Send TTL pulse timestamp
          TTLfunction(stimbit,recbit);
          TTLfunction(framebit,recbit);
          StimLog.Stim(l).Stim(k).Stim(j).TimeON = GetSecs - StimLog.BeginTime;  % Log TimeON
          StimLog.Stim(l).Stim(k).Stim(j).Xpos = xCenterGrid; % Log Xposition
          StimLog.Stim(l).Stim(k).Stim(j).Ypos = yCenterGrid; % Log Yposition

          
          for i = 1:nframes     
            % Center square
            dstRect = [0 0 xsize ysize];
            dstRect = CenterRectOnPointd(dstRect, xCenterGrid, yCenterGrid);
            % Draw the rect to the screen
            Screen('FillRect', window, [lum lum lum], dstRect);
            
            % Flip to the screen
            vbl  = Screen('Flip', window, vbl + 0.5 * sparams.ifi);

            % Increment the time
            time = time + sparams.ifi;
      
            % Send TTL pulse timestamp
            TTLfunction(framebit,recbit);         
          
          endfor

        % Send TTL pulse timestamp
        TTLfunction(stimbit,recbit);
        StimLog.Stim(l).Stim(k).Stim(j).TimeOFF = GetSecs - StimLog.BeginTime; % Log TimeOFF
    
        vbl = Screen('Flip', window);
        WaitSecs(ISI);
  
        endfor
    endfor
endfor


StimLog.EndTime = GetSecs - StimLog.BeginTime; % Log end time

% Stop the recording with TTL pulse and send timestamp
TTLfunction(stopbit,0);

