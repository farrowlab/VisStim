function StimLog = ShowGrating(window, vparams, sparams)
% angle, cyclespersecond, freq, gratingsize, internalRotation
% function DriftDemo4([angle=0][, cyclespersecond=1][, freq=1/360][, gratingsize=360][, internalRotation=0])
% ___________________________________________________________________

%-------------- Initiate Paramaters ---------------%
if isfield(sparams,'paralellport')
  fprintf(1,"Using the parallel Port.\n")
  TTLfunction = @(x)parallelTTLoutput(sparams.paralellport,x);
  startbit = 2^2;
  stopbit = ;
  pulsebit = 2^0;
  stimbit = 2^1 + 2^0;
elseif isfield(sparams,'serialport')
  TTLfunction = @(x)serialTTLoutput(sparams.serialport,x);
  startbit = 0;
  stopbit = 0;
  pulsebit = 0;
else
  TTLfunction = @(x)0;
endif % TTLpulse initialization

  %----- Screen -----%
  screenid = sparams.screenid;
  win = window; 
  AssertGLSL;
  ifi = sparams.ifi;
  rotateMode = kPsychUseTextureMatrixForRotation;
  
  %----- Stimulus -----%  
  
    %--- Same Between Sweeps ---%
    res = [sparams.screenWidth sparams.screenHeight];                    % width and height of grating in pixels.   
    phase = 0;                                          % Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
    ContrastMultiplier = 0.5;
    radius=inf;
    NFrames = ceil(vparams.StimTime/ifi);
    Background = vparams.BgColour;  
    contrast = vparams.StimContrast; 
    cyclespersecond = vparams.TemporalFreq;
    freq = vparams.Size / sparams.pixel2deg;    % Frequency of the grating in cycles per pixel.  
    
    %--- Change Between Sweeps ---%
    angle = vparams.Angle; 
                      


%--------------- Build Texture ---------------%
phaseincrement = (cyclespersecond * 360) * ifi;       % Compute increment of phase shift per redraw:
switch vparams.Shape
  case 'Sine'
    gratingtex = CreateProceduralSineGrating(win, res(1), res(2), [.5 .5 .5 0], radius, ContrastMultiplier); % Build a procedural sine grating texture for a grating with a support of res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
  otherwise 
    disp('Needs to be Programmed');
end


%----- Log Stimuli -----%
StimLog.StimulusClass = 'Grating';
StimLog.Background = Background;
StimLog.Contrast = contrast;
StimLog.TemporalFreq = vparams.TemporalFreq;
StimLog.SpatialFreq = vparams.Size;

%--------------- Stimulus Loop for NAngles, NSpatialFreq, NTemporalFreq, NContrastLevels, NBackgroundLevels ---------------%
Screen('FillRect', window, Background)   

% ----- Display Blank screen for BlankTime-----%
%TIME = GetSecs;
TTLfunction(startbit);
StimLog.BlankTime = GetSecs;
WaitSecs(vparams.BlankTime)
%WaitSecs(TIME + vparams.BlankTime - GetSecs);
%TIME = TIME + vparams.BlankTime;
  %---------- Make Stimulus List ----------%    
  for i = 1:size(angle,2)    
    if i == 1
      %---------- Show Initiatial Textture ----------%
      Screen('DrawTexture', win, gratingtex, [], [], angle(i), [], [], [], [], rotateMode, [phase, freq, contrast, 0]);
      % ----- Log Grating on screen -----%
      vbl = Screen('Flip', win);
      TTLfunction(pulsebit)
      StimLog.BeginTime = vbl;

      StimLog.BlankTime = StimLog.BeginTime - StimLog.BlankTime; 
      StimLog.Stim(i).StartSweep = StimLog.BeginTime; 

      WaitSecs(vparams.PreTime);
%      WaitSecs(TIME + vparams.PreTime - GetSecs);
%      TIME = TIME + vparams.PreTime;
    else
      Screen('DrawTexture', win, gratingtex, [], [], angle(i), [], [], [], [], rotateMode, [phase, freq, contrast, 0]);
      
      vbl = Screen('Flip', win);
      TTLfunction(pulsebit)
      WaitSecs(vparams.InterStimTime);
      StimLog.Stim(i).StartSweep = vbl - StimLog.BeginTime;
      %WaitSecs(TIME + vparams.InterStimTime - GetSecs);
      %TIME = TIME + vparams.InterStimTime;
    end
    StimLog.Angle = angle(i);
    StimLog.Stim(i).BeginSweep = GetSecs - StimLog.BeginTime;    

    %TTLfunction(0)    
    %---------- Animation loop: Repeats until NFrames Completed ----------%  	
    count = 0;
    while count < NFrames
        % Update some grating animation parameters:
        count = count + 1;
        % Increment phase by 1 degree:
        phase = phase + phaseincrement;
        % Draw the grating, centered on the screen, with given rotation 'angle',
        % sine grating 'phase' shift and amplitude, rotating via set
        % 'rotateMode'. Note that we pad the last argument with a 4th
        % component, which is 0. This is required, as this argument must be a
        % vector with a number of components that is an integral multiple of 4,
        % i.e. in our case it must have 4 components:
        Screen('DrawTexture', win, gratingtex, [], [], angle(i), [], [], [], [], rotateMode, [phase, freq, contrast, 0]);
        
        
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);
        
        if (count == 1) || (count == NFrames)
          TTLfunction(stimbit);
        else
          TTLfunction(pulsebit);
        endif
        StimLog.Stim(i).FrameTimes(count) = GetSecs - StimLog.BeginTime;
        
        % Show it at next retrace:
    end
  end
Screen('FillRect', window, Background)
WaitSecs(vparams.PostTime);
vbl = Screen('Flip', win);
TTLfunction(stimbit);
StimLog.EndTime = vbl - StimLog.BeginTime;
WaitSecs(vparams.BlankTime);
TTLfunction(stopbit);
return;
