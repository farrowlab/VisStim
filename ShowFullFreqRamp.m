function ShowFullFreqRamp(window,vparams,sparams)

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
  TempFreq = vparams.TemporalFreq;
    
%--------------- Initiate Texture ---------------%
t=0:ifi:StimTime; % time vector
S = (TempFreq)/(t(end)-t(1)); 
TF = S*t;
assignin('base','TF',TF)
TimeCourse = Amplitude*sin(2*pi*TF.*t) + Background;  

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