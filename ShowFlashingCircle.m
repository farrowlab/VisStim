function StimLog = ShowFlashingCircle(window, vparams, sparams)

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




% ---------------------- %
% --- Log parameters --- %
StimLog.StimulusClass = 'Flashing Circle';   
StimLog.BgColor = 125; % BgColor
StimLog.Duration = vparams.Duration;
StimLog.Size = vparams.Size;
StimLog.StimLum = vparams.StimLum;
StimLog.Xcenter = vparams.Xpos;
StimLog.Ycenter = vparams.Ypos;


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
          StimLog.Stim(j).TimeON = GetSecs - StimLog.BeginTime;  % Log TimeON

          
          for i = 1:nframes     
            % Center square
            dstRect = [0 0 xsize ysize];
            dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);
            % Draw the rect to the screen
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
        StimLog.Stim(j).TimeOFF = GetSecs - StimLog.BeginTime; % Log TimeOFF
    
        vbl = Screen('Flip', window);
        WaitSecs(ISI);

endfor


StimLog.EndTime = GetSecs - StimLog.BeginTime; % Log end time

% Stop the recording with TTL pulse and send timestamp
TTLfunction(stopbit,0);

