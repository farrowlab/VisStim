function StimLog = ShowGrating(window, vparams, sparams)
  % angle, cyclespersecond, freq, gratingsize, internalRotation
  % function DriftDemo4([angle=0][, cyclespersecond=1][, freq=1/360][, gratingsize=360][, internalRotation=0])
  % ___________________________________________________________________

  %-----------------  Initiate TTLpulse  -----------------%
  InitiateTTLPulses

  
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
    BgColour = vparams.BgColour;  
    Contrast = vparams.StimContrast; 
    cyclespersecond = vparams.TemporalFreq;
    cpd = vparams.SpatFreq * sparams.deg2pixel;   % Frequency of the grating in cycles per pixel.   sparams.pixel2deg
    
    %--- Change Between Sweeps ---%
    angle = vparams.Direction; 
                      


%--------------- Build Texture ---------------%
phaseincrement = (cyclespersecond * 360) * ifi;       % Compute increment of phase shift per redraw:
switch vparams.Shape
  case 'Sine'
    gratingtex = CreateProceduralSineGrating(win, sparams.screenWidth, sparams.screenHeight, [.5 .5 .5 .5], radius, ContrastMultiplier); % Build a procedural sine grating texture for a grating with a support of res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
  case 'Square'    
    disp('Needs to be Programmed');
  otherwise 
    disp('Needs to be Programmed');
end

%-----------------  Make Parameter List  ---------------%
  [p, q, r] = meshgrid(angle,phaseincrement,cpd);
  StimList = [p(:) q(:) r(:)]; % Create a complete stimulus List where each row is a stimulus [Size, Colour]
  StimList = repmat(StimList,[vparams.Repeats,1]);
  NStim = size(StimList,1);

  switch vparams.Order
    case 'Forward'
      StimList = StimList;
    case 'Random'
      order = randperm(size(StimList,1));
      StimList = StimList(order,:);
    case 'Reverse'
      order = fliplr(1:size(StimList,1));
      StimList = StimList(order,:);
    otherwise
      StimList = StimList;
  end  
  assignin('base','StimList',StimList)
  
  
%----- Log Stimuli -----%
 
StimLog.StimulusClass = 'Grating';
StimLog.BgColour = BgColour;
StimLog.Contrast = Contrast;
StimLog.TFreq = vparams.TempFreq;
StimLog.SFreq = vparams.SpatFreq;

%--------------- Stimulus Loop for NAngles, NSpatialFreq, NTemporalFreq, NContrastLevels, NBackgroundLevels ---------------%
parallelTTLstartstop(sparams.paralellport,recbit);
TTLfunction(startca,recbit); WaitSecs(.1);
TTLfunction(startbit,recbit); WaitSecs(.1);
StimLog.BeginTime = GetSecs; 

% ----- Display Blank screen for BlankTime-----%
Screen('FillRect', win, BgColour)
vbl = Screen('Flip', win);
StimLog.BlankTime = GetSecs - StimLog.BeginTime;
WaitSecs(vparams.BlankTime)

  %---------- Make Stimulus List ----------%    
%  for i = 1:size(angle,2)    
    for n = 1:size(StimList,1)
    
      if n == 1
        %---------- Show Initiatial Textture ----------%
        Screen('FillRect', win, 0)
        vbl = Screen('Flip', win);
        Screen('DrawTexture', win, gratingtex, [], [], StimList(n,1), [], [], [], [], rotateMode, [0, StimList(n,3), Contrast, 0]);
        % ----- Log Grating on screen -----%
        vbl = Screen('Flip', win);
        TTLfunction(stimbit,recbit)                
        StimLog.Stim(n).GratingON = GetSecs - StimLog.BeginTime; 
        WaitSecs(vparams.PreTime);

      else
        Screen('DrawTexture', win, gratingtex, [], [], StimList(n,1), [], [], [], [], rotateMode, [0, StimList(n,3), Contrast, 0]);        
        vbl = Screen('Flip', win);
        TTLfunction(stimbit,recbit)     
        StimLog.Stim(n).GratingON = GetSecs - StimLog.BeginTime;
        WaitSecs(vparams.PreTime);
      end
      StimLog.Stim(n).Angle = StimList(n,1);     
      StimLog.Stim(n).TF = StimList(n,2); 
      StimLog.Stim(n).SF = StimList(n,3); 
      
      %---------- Animation loop: Repeats until NFrames Completed ----------%  	
      count = 0;
      while count < NFrames
          % Update some grating animation parameters:
          count = count + 1;
          % Increment phase by 1 degree:
          phase = phase + StimList(n,2);
          % Draw the grating, centered on the screen, with given rotation 'angle',
          % sine grating 'phase' shift and amplitude, rotating via set
          % 'rotateMode'. Note that we pad the last argument with a 4th
          % component, which is 0. This is required, as this argument must be a
          % vector with a number of components that is an integral multiple of 4,
          % i.e. in our case it must have 4 components:
          Screen('DrawTexture', win, gratingtex, [], [], StimList(n,1), [], [], [], [], rotateMode, [phase, StimList(n,3), Contrast, 0]);
          
          
          vbl = Screen('Flip', win, vbl + 0.5 * ifi);

          if (count == 1)
            TTLfunction(stimbit,recbit);
            StimLog.Stim(n).StartMoveGrating = GetSecs - StimLog.BeginTime;  
          elseif (count == NFrames) 
            TTLfunction(stimbit,recbit);
            StimLog.Stim(n).StopMoveGrating = GetSecs - StimLog.BeginTime;            
            WaitSecs(vparams.PostTime);
          else
            TTLfunction(framebit,recbit);
            StimLog.Stim(n).FrameTimes(count) = GetSecs - StimLog.BeginTime;
          end
                              
      end   
      WaitSecs(vparams.PostTime);
      TTLfunction(stimbit,recbit);
      StimLog.Stim(n).GratingOFF = GetSecs - StimLog.BeginTime;
    
           
  end
  Screen('FillRect', win, BgColour)
  vbl = Screen('Flip', win);
  WaitSecs(vparams.BlankTime); 
  TTLfunction(stimbit,recbit);
  StimLog.EndTime = GetSecs - StimLog.BeginTime;
  WaitSecs(vparams.BlankTime);
  TTLfunction(stopbit,0);
return;
