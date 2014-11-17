function StimLog = ShowFullSine(window,vparams,sparams)

%--------------- Get Parameters ---------------%

  %---------- Screen Parameters ----------%
  height = sparams.screenHeight;
  width = sparams.screenWidth;
  ifi = sparams.ifi;
  
  %---------- Stimulus Parameters ----------%
  Background = vparams.Background(1);
  Contrast = vparams.StimColour;
  Amplitude = Background*Contrast;
  StimTime = vparams.StimTime;
  NFrames = StimTime./ifi;
  TempFreq = vparams.TemporalFreq;
  T = 1/TempFreq;
  
  %----- Log Stimulus ------%
  StimLog.StimulusClass = 'FullFieldSine';
  StimLog.BeginTime = GetSecs;  
  for j = 1:5; srl_write(sparams.serialport,'0'); end   
  StimLog.Stim.Contrast = Contrast; % Color
  StimLog.Stim.BgColor = vparams.Background; % BgColor
  StimLog.Stim.TempFreq = vparams.TemporalFreq;
  
%--------------- Initiate Texture ---------------%
t=0:ifi:StimTime; % time vector
TimeCourse = Amplitude*sin(2*pi*TempFreq*t) + Background;  
NStim = 1;

%--------------- Show Stimulus ---------------% 
count = 0;
StimLog.BeginTime = GetSecs;

for i = 1:NStim
  Screen('FillRect', window, Background) 
  Screen(window,'Flip');
  StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep
  for j = 1:5; srl_write(sparams.serialport,'0'); end
  WaitSecs(vparams.PreTime);  
  StimLog.Stim(i).TimeON = GetSecs - StimLog.BeginTime;  % TimeON    
  for j = 1:5; srl_write(sparams.serialport,'0'); end  
  while count < length(t);    
    count = count + 1;  
    Screen('FillRect', window, TimeCourse(count))  
    Screen(window,'Flip');           
  end   
  WaitSecs(vparams.PostTime);
  StimLog.Stim(i).TimeOFF = GetSecs - StimLog.BeginTime; % TimeOFF
  for j = 1:5; srl_write(sparams.serialport,'0'); end
  
  if i == NStim
    WaitSecs(vparams.PostTime); 
    StimLog.EndTime = GetSecs - StimLog.BeginTime;
    for j = 1:5; srl_write(sparams.serialport,'0'); end
  end  
end