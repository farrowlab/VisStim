function ShowFullAmpRamp(window,vparams,sparams)

%--------------- Get Parameters ---------------%

  %---------- Screen Parameters ----------%
  height = sparams.screenHeight;
  width = sparams.screenWidth;
  ifi = sparams.ifi;
  
  %---------- Stimulus Parameters ----------%
  Background = vparams.BgColour(1);
  Contrast = [0 vparams.StimContrast];
  A = Background*Contrast;  
  StimTime = vparams.StimTime;
  TempFreq = vparams.TemporalFreq;
    
%--------------- Initiate Texture ---------------%
t=0:ifi:StimTime; % time vector
S = (A(2) - A(1))/(t(end)-t(1)); 
TimeCourse = (S.*t).*sin(2*pi*TempFreq.*t) + Background;  

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