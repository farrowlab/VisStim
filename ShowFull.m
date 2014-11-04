function ShowFull(window,vparams,sparams);
	
%---------- Choose Stimulus ----------%
switch vparams.Type
  case 'Flash'
    ShowFullFlash(window,vparams,sparams);   
  case 'Noise'
    ShowFullNoise(window,vparams,sparams);   
  case 'Sine'
    ShowFullSine(window,vparams,sparams);   
  case 'FreqRamp'
    ShowFullFreqRamp(window,vparams,sparams);   
  case 'AmpRamp'
    ShowFullAmpRamp(window,vparams,sparams);   
  otherwise
     disp('Need to Program'); 
  end
    
	