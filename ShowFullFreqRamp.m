function StimLog = ShowFullFreqRamp(window,vparams,sparams)

%--------------- Get Parameters ---------------%

  %---------- Screen Parameters ----------%
  height = sparams.screenHeight;
  width = sparams.screenWidth;
  ifi = sparams.ifi;
  
  %---------- Stimulus Parameters ----------%
  Background = vparams.Background(1)(1);
  Contrast = vparams.StimColour;
  Amplitude = Background*Contrast;
  StimTime = vparams.StimTime;
  TempFreq = vparams.TemporalFreq;
    
  %----- Log Stimulus ------%
  StimLog.StimulusClass = 'FullFieldSine';
  StimLog.BeginTime = GetSecs;  
  for j = 1:5; srl_write(sparams.serialport,'0'); end   
  StimLog.Stim.Contrast = Contrast; % Color
  StimLog.Stim.BgColor = vparams.Background; % BgColor
  StimLog.Stim.TempFreq = vparams.TemporalFreq;
  if length(TempFreq)~2
    disp('Need to Numbers');
    return
  end
  
%--------------- Initiate Texture ---------------%
t=0:ifi:StimTime; % time vector
TF = TempFreq(1):(diff(TempFreq)/length(t)):TempFreq(2);
TimeCourse = Amplitude*sin(2*pi*TF.*t) + Background;  
assignin('base','TimeCourse',TimeCourse);

%--------------- Show Stimulus ---------------% 
 StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep
 for j = 1:5; srl_write(sparams.serialport,'0'); end
count = 0;
StimLog.BeginTime = GetSecs;  
while count < length(t);
  if count == 0
    Screen('FillRect', window, Background)  
    Screen(window,'Flip');
    WaitSecs(vparams.PreTime);
  else 
    Screen('FillRect', window, TimeCourse(count))  
    Screen(window,'Flip');   
  end     
  count = count + 1;    
end
Screen('FillRect', window, Background) 
Screen(window,'Flip');
WaitSecs(vparams.PostTime);