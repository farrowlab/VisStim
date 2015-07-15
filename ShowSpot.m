function StimLog = ShowSpot(window,vparams,sparams);
	
  %-----------------  Initiate TTLpulse  -----------------%
  InitiateTTLPulses;

    
  %-----------------  Initiate  --------------------------%
  %-----------------  Get Parameters  --------------------%
  Parameters = fieldnames(vparams);  

  
  %-----------------  Make Parameter List  ---------------%
  [p, q] = meshgrid(vparams.Size,vparams.StimColour);
  StimList = [p(:) q(:)]; % Create a complete stimulus List where each row is a stimulus [Size, Colour]
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
      return
  end  
  assignin('base','StimList',StimList)

  
  %-----------------  Log Stimulus  ----------------------%
  StimLog.StimulusClass = 'Spot';
  StimLog.BeginTime = GetSecs;  
  %for j = 1:5; srl_write(sparams.serialport,'0'); end 
  for i = 1:size(StimList,1)
    StimLog.Stim(i).Stimulus = vparams.Shape; 
    StimLog.Stim(i).Size = StimList(i,1); % Size
    StimLog.Stim(i).Color = StimList(i,2); % Color
    StimLog.Stim(i).BgColor = vparams.Background; % BgColor
  end

  
  %----- Initiate Screen -----%
  Screen('FillRect', window, vparams.Background)
  ifi = Screen('GetFlipInterval', window);
  vbl = Screen('Flip', window);
		
 
  %-----------------  Display Blank screen  -------------%
  %TIME = GetSecs;
  parallelTTLstartstop(sparams.paralellport,recbit);
  TTLfunction(startbit,recbit);
  StimLog.BlankTime = GetSecs;
  WaitSecs(vparams.BlankTime)
  %WaitSecs(TIME + vparams.BlankTime - GetSecs);
  %TIME = TIME + vparams.BlankTime;
    
    
  %-----------------  Loop to Present Spots  ------------%
  for i = 1:NStim

  
  %-----------------  Log Stimulus  ---------------------%
  StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep
  %for j = 1:5; srl_write(sparams.serialport,'0'); end
 
 
  %-----------------  Pre Stimulus Pause  ---------------%	      
  WaitSecs(vparams.PreTime);            
  TTLfunction(stimbit,recbit);
  TTLfunction(framebit,recbit);                 
 
 
  %-----------------  Draw Spot  ------------------------%  
  Screen('gluDisk', window, StimList(i,2), sparams.screenWidth/2, sparams.screenHeight/2,StimList(i,1)* sparams.pixel2deg);
  vbl = Screen('Flip', window, vbl + 0.5 * ifi);
  TTLfunction(stimbit,recbit);
  TTLfunction(framebit,recbit);
  StimLog.Stim(i).TimeON = GetSecs - StimLog.BeginTime;  % TimeON    
  %for j = 1:5; srl_write(sparams.serialport,'0'); end
	WaitSecs(vparams.StimTime); 
	vbl = Screen('Flip', window, vbl + 0.5 * ifi);
  TTLfunction(stimbit,recbit);
  TTLfunction(framebit,recbit);  
  StimLog.Stim(i).TimeOFF = GetSecs - StimLog.BeginTime; % TimeOFF
  %for j = 1:5; srl_write(sparams.serialport,'0'); end
  
  WaitSecs(vparams.InterStimTime); 
  Screen('FillRect', window, vparams.Background)
  StimLog.Stim(i).EndSweep = GetSecs - StimLog.BeginTime; % EndSweep
  %for j = 1:5; srl_write(sparams.serialport,'0'); end
  
  
  %------------------  Post Stimulus Pause  --------------%
   if i == NStim
      WaitSecs(vparams.PostTime);
      TTLfunction(stimbit,recbit);
      TTLfunction(framebit,recbit); 
      StimLog.EndTime = GetSecs - StimLog.BeginTime;
      %for j = 1:5; srl_write(sparams.serialport,'0'); end
   end
    
      WaitSecs(vparams.BlankTime);
      TTLfunction(stopbit,0);  
  end
	