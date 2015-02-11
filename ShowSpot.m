function StimLog = ShowSpot(window,vparams,sparams);
	
  %-----------------  Initiate TTLpulse  -----------------%
  if isfield(sparams,'paralellport')
     fprintf(1,"Using the parallel Port.\n")
     TTLfunction = @(x,y)parallelTTLoutput(sparams.paralellport,x,y);

     recbit = 1;      % pin 2; duration of recording; trigger to start and stop ThorLab image recording
     stimbit = 2;     % pin 3; timestamp for the stimulus
     framebit = 4;    % pin 4; timestamp for the frame
     startbit = 8;    % pin 5; trigger to start lcg recording
     stopbit = 16;    % pin 6; trigger to stop lcg recording
  
     % Pin address:
     % Pin    2   3   4   5   6   7   8   9
     % Value   1   2   4   8   16  32  64  128
     % For example if you want to set pins 2 and 3 to logic 1 (led on) then you have to output value 1+2=3, or 3,5 and 6 then you need to output value 2+8+16=26

     pp_data(sparams.paralellport,0);
   
  elseif isfield(sparams,'serialport')
     TTLfunction = @(x)serialTTLoutput(sparams.serialport,x);
     startbit = 0;
     stopbit = 0;
     framebit = 0;
     % There's only 1 TTL output for serialport
  else
     TTLfunction = @(x)0;
  endif

    
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
	