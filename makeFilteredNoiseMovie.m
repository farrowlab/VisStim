function StimLog = makeFilteredNoiseMovie(window,vparams,sparams)

%---------- Initiate ----------%
randn("seed",3232);
StimLog = [];
count = 0;
win = window;
NP = vparams.Scale * sparams.pixel2deg;
Xpos(1) = double(sparams.screenWidth)/2 - NP/2;
Xpos(2) = Xpos(1) + NP;
Ypos(1) = double(sparams.screenHeight)/2 - NP/2;
Ypos(2) = Ypos(1) + NP;
winRect = [Xpos(1) Ypos(1) Xpos(2) Ypos(2)];
screenid = sparams.screenid;  
syncToVBL = sparams.syncToVBL;
dontclear = sparams.dontclear;
delay = vparams.FrameDuration - sparams.ifi;
if syncToVBL > 0
  asyncflag = 0;
else
  asyncflag = 2;
end
Background = vparams.BgColour;
PixperSquare = NP/vparams.NumberSquares;
SquareperPixel = vparams.NumberSquares/NP;
Contrast = vparams.StimContrast/100;
sf_c = vparams.FilterWidth(1) * sparams.pixel2deg * SquareperPixel;
sf_0 = vparams.FilterWidth(2) * sparams.pixel2deg * SquareperPixel;


  %----- Create Spatial Frequency Grid -----%
  Fxy = vparams.NumberSquares/vparams.Scale;
  [ux,uy]=freqspace(vparams.NumberSquares,'meshgrid');
  vxy = Fxy/2*sqrt(ux.^2+uy.^2);
  
%---------- Create Stimulus Log ----------%
StimLog.StimulusClass = [vparams.Type ' Noise'];  
StimLog.BeginTime = GetSecs;   
for i = 1:5; srl_write(sparams.serialport,'0'); end
    
%---------- Make Noise Movie ----------%
while count < vparams.NFrames
  
  %----- First Image -----%    
  if count < 1
    StimLog.Stim.StartSweep = GetSecs - StimLog.BeginTime; 
    for i = 1:5; srl_write(sparams.serialport,'0'); end
    Screen('FillRect', window, Background);
    Screen('Flip', window, 0, dontclear, asyncflag);
    WaitSecs(vparams.PreTime);
    StimLog.Stim.StartTime = GetSecs - StimLog.BeginTime        
    for i = 1:5; srl_write(sparams.serialport,'0'); end
  end   
    
  %----- Make Noise Image -----%
  count = count + 1;
  StimLog.Stim.FrameTimes(count) = GetSecs - StimLog.BeginTime;
  for i = 1:5; srl_write(sparams.serialport,'0'); end
  switch vparams.Type    
    case {'White','Contrast Modulated'}   
      beta = 0;      
    case 'Pink'      
      beta = -1;        
    case 'Brown'         
      beta = -2;                      
    otherwise
      disp('Program it');
  end
  
    %--- Amplitude Spectruc Space ---%
    Hxy = ((vxy+sf_c).^beta).*abs(vxy<=sf_0);
  
  %----- Make Noise Image -----%
  x = randn(vparams.NumberSquares, vparams.NumberSquares);
  X = fftshift(fftn(x));
  Y = Hxy.*X;
  y = ifftn(fftshift(Y));         

  
  %----- Normalize Noise Image -----%
  mu = mean(y(:));
  sigma = std(y(:));
  y = y - mu;
  y = y ./ sigma;
  switch vparams.Type    
    case 'Contrast Modulated'  
      y = y * sin(2 * pi * count/50);
    otherwise
  end
   
  noiseimg = ((255*Contrast) .* y) + Background(1);  
  nS = find(noiseimg > 255); noiseimg(nS) = 255;                        
  nZ = find(noiseimg < 1); noiseimg(nZ) = 0;
  noiseimg=double(noiseimg);     
    
  %----- Convert to Texture -----%
  tex=Screen('MakeTexture', window, noiseimg,[],[],0);
         
  %----- Draw Texture and Show Image -----%           
  Screen('DrawTexture', window, tex, [], winRect, [], 0);
  Screen('Close', tex);    
  Screen('Flip', window, 0, dontclear, 0);  
  
  %----- Last Image -----%    
  if count == vparams.NFrames
    Screen('FillRect', window, Background);
    Screen('Flip', window, 0, dontclear, asyncflag);
    StimLog.Stim.StopTime = GetSecs - StimLog.BeginTime;
    for i = 1:5; srl_write(sparams.serialport,'0'); end
    WaitSecs(vparams.PostTime);	
    StimLog.Stim.EndSweep = GetSecs - StimLog.BeginTime; 
    for i = 1:5; srl_write(sparams.serialport,'0'); end
  end

  %----- Control Frame Rate -----%
  WaitSecs(delay);   
end
