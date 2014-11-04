function ShowNoise(window,vparams,sparams);
	
%---------- Get Parameters ----------%


%---------- Check Parameters ----------%
		
		

%---------- Initiate Screen ----------%
sparams.ifi = Screen('GetFlipInterval', window);
sparams.vbl = Screen('Flip', window);

%---------- Choose Noise Stimulus ----------%
switch vparams.Type
  case 'White'    
        fdisp(stdout,'Making White Noise Stimuli.');       

    %----- Define Extra Parameters -----%
    vparams.numRects = 1;
    sparams.dontclear = 0;
    vparams.NFrames = ceil(vparams.StimTime/sparams.ifi);
    ShowWhiteNoise;
    
  case 'PinkNoise'
  
  case 'WaveletNoise'
  
  case 'ContrastModulatedNoise'
  otherwise	
    disp('Not Programmed Correctly!!!')
end
	