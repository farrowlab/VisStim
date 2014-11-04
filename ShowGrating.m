function StimLog = ShowGrating(window, vparams, sparams)
% angle, cyclespersecond, freq, gratingsize, internalRotation
% function DriftDemo4([angle=0][, cyclespersecond=1][, freq=1/360][, gratingsize=360][, internalRotation=0])
% ___________________________________________________________________

%-------------- Initiate Paramaters ---------------%

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
                      
    %----- Log Stimuli -----%
    StimLog.StimulusClass = 'Grating';
    StimLog.Background = Background;
    StimLog.Contrast = contrast;
    StimLog.TemporalFreq = vparams.TemporalFreq;
    StimLog.SpatialFreq = vparams.Size;
    StimLog.BeginTime = GetSecs;    
    for j = 1:5; srl_write(sparams.serialport,'0'); end
    
    
%--------------- Build Texture ---------------%
phaseincrement = (cyclespersecond * 360) * ifi;       % Compute increment of phase shift per redraw:
switch vparams.Shape
  case 'Sine'
    gratingtex = CreateProceduralSineGrating(win, res(1), res(2), [.5 .5 .5 0], radius, ContrastMultiplier); % Build a procedural sine grating texture for a grating with a support of res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
  otherwise 
    disp('Needs to be Programmed');
end


%--------------- Stimulus Loop for NAngles, NSpatialFreq, NTemporalFreq, NContrastLevels, NBackgroundLevels ---------------%
Screen('FillRect', window, Background)   
  
  %---------- Make Stimulus List ----------%    
  for i = 1:size(angle,2)    
    
    if i == 1
      %---------- Show Initiatial Textture ----------%
      StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime;
      for j = 1:5; srl_write(sparams.serialport,'0'); end
      Screen('DrawTexture', win, gratingtex, [], [], angle(i), [], [], [], [], rotateMode, [phase, freq, contrast, 0]);
      vbl = Screen('Flip', win);
      WaitSecs(vparams.PreTime);  
    else
      StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; 
      for j = 1:5; srl_write(sparams.serialport,'0'); end
      Screen('DrawTexture', win, gratingtex, [], [], angle(i), [], [], [], [], rotateMode, [phase, freq, contrast, 0]);
      vbl = Screen('Flip', win);
      WaitSecs(vparams.InterStimTime); 
    end
    StimLog.Angle = angle(i);
    StimLog.Stim(i).BeginSweep = GetSecs - StimLog.BeginTime;    
    for j = 1:5; srl_write(sparams.serialport,'0'); end
    
    %---------- Animation loop: Repeats until NFrames Completed ----------%  	
    count = 0;
    while count < NFrames
        % Update some grating animation parameters:
        count = count + 1;
        % Increment phase by 1 degree:
        phase = phase + phaseincrement;
        StimLog.Stim(i).FrameTimes(count) = GetSecs - StimLog.BeginTime;
        for j = 1:5; srl_write(sparams.serialport,'0'); end
        % Draw the grating, centered on the screen, with given rotation 'angle',
        % sine grating 'phase' shift and amplitude, rotating via set
        % 'rotateMode'. Note that we pad the last argument with a 4th
        % component, which is 0. This is required, as this argument must be a
        % vector with a number of components that is an integral multiple of 4,
        % i.e. in our case it must have 4 components:
        Screen('DrawTexture', win, gratingtex, [], [], angle(i), [], [], [], [], rotateMode, [phase, freq, contrast, 0]);

        % Show it at next retrace:
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);
    end
  end
WaitSecs(vparams.PostTime); 
Screen('FillRect', window, Background)
vbl = Screen('Flip', win);
StimLog.EndTime = GetSecs - StimLog.BeginTime; 
for j = 1:5; srl_write(sparams.serialport,'0'); end
return;
