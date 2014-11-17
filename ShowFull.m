function StimLog = ShowFull(window,vparams,sparams);
	
%---------- Choose Stimulus ----------%
switch vparams.Type
  case 'Flash'
    StimLog = ShowFullFlash(window,vparams,sparams);   
  case 'Noise'
    StimLog = ShowFullNoise(window,vparams,sparams);   
  case 'Sine'
    StimLog = ShowFullSine(window,vparams,sparams);   
  case 'FreqRamp'
    StimLog = ShowFullFreqRamp(window,vparams,sparams);   
  case 'AmpRamp'
    StimLog = ShowFullAmpRamp(window,vparams,sparams);   
  otherwise
     disp('Need to Program'); 
  end
    
	