function ShowFullNoise(window,vparams,sparams)

%--------------- Get Parameters ---------------%

  %---------- Screen Parameters ----------%
  height = sparams.screenHeight;
  width = sparams.screenWidth;
  ifi = sparams.ifi;
  
  %---------- Stimulus Parameters ----------%
  Background = vparams.BgColour(1);
  Contrast = vparams.StimContrast;
  Amplitude = Background*Contrast;
  StimTime = vparams.StimTime;
  NFrames = StimTime./ifi;
  TempFreq = vparams.TemporalFreq;
  T = 1/TempFreq;
  
%--------------- Initiate Texture ---------------%
t=0:ifi:StimTime; % time vector
TimeCourse = Amplitude*randn(length(t)) + Background;  

%--------------- Show Stimulus ---------------% 
count = 0;

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