function StimLog = ShowFullFlash(window,vparams,sparams)

%--------------- Get Parameters ---------------%
  StimList = vparams.StimColour;
  StimList = repmat(StimList,[1,vparams.Repeats])
  NStim = size(StimList,2);
  
  %---------- Screen Parameters ----------%
  height = sparams.screenHeight;
  width = sparams.screenWidth;
  ifi = sparams.ifi;

%----- Log Stimulus ------%
  StimLog.StimulusClass = 'FullFieldFlash';
  StimLog.BeginTime = GetSecs;  
  for j = 1:5; srl_write(sparams.serialport,'0'); end 
  for i = 1:size(StimList,1)
    StimLog.Stim(i).Color = StimList(i,2); % Color
    StimLog.Stim(i).BgColor = vparams.Background; % BgColor
  end
  
  %----- Initiate Screen -----%
  Screen('FillRect', window, vparams.Background)
  ifi = Screen('GetFlipInterval', window);
  vbl = Screen('Flip', window);
		
    
    
%---------- Loop to Present Spots ----------%
for i = 1:NStim
  
  %----- Log Stimulus -----%
  StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep
  for j = 1:5; srl_write(sparams.serialport,'0'); end
  
  %----- Pre Stimulus Pause -----%	      
   WaitSecs(vparams.PreTime);            
                    
  
	%----- Draw Spot -----%  
  Screen('gluDisk', window, StimList(i), sparams.screenWidth/2, sparams.screenHeight/2,2*sparams.screenWidth);
  vbl = Screen('Flip', window, vbl + 0.5 * ifi);
	StimLog.Stim(i).TimeON = GetSecs - StimLog.BeginTime;  % TimeON    
  for j = 1:5; srl_write(sparams.serialport,'0'); end
	WaitSecs(vparams.StimTime); 
	vbl = Screen('Flip', window, vbl + 0.5 * ifi);       
  StimLog.Stim(i).TimeOFF = GetSecs - StimLog.BeginTime; % TimeOFF
  for j = 1:5; srl_write(sparams.serialport,'0'); end
  
  WaitSecs(vparams.InterStimTime); 
  Screen('FillRect', window, vparams.Background)
  StimLog.Stim(i).EndSweep = GetSecs - StimLog.BeginTime; % EndSweep
	for j = 1:5; srl_write(sparams.serialport,'0'); end
  
  %----- Post Stimulus Pause -----%
  if i == NStim
    WaitSecs(vparams.PostTime); 
    StimLog.EndTime = GetSecs - StimLog.BeginTime;
    for j = 1:5; srl_write(sparams.serialport,'0'); end
  end    
end