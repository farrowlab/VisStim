function StimLog = PickNoise(window,vparams,sparams);
	
%---------- Get Parameters ----------%
StimLog = [];

%---------- Check Parameters ----------%
		
		

%---------- Initiate Screen ----------%
sparams.ifi = Screen('GetFlipInterval', window);
sparams.vbl = Screen('Flip', window);

%---------- Choose Noise Stimulus ----------%
switch vparams.Type
  case 'White CheckerBoard'   
        
    %----- Define Extra Parameters -----%
    vparams.FrameDuration = 1/vparams.FrameRate;    
    vparams.rectSize = vparams.NumberSquares; 
    vparams.Size = vparams.Scale; 
    vparams.numRects = 1;
    sparams.dontclear = 0;
    vparams.NFrames = ceil(vparams.StimTime/vparams.FrameDuration);    
    vparams.validate=1; 
    vparams.filtertype=1;     
    vparams.kwidth= 1; % vparams.FilterWidth; %round(vparams.rectSize/vparams.NumberSquares);     
    sparams.syncToVBL=1; 
    sparams.dontclear=0;     
    StimLog = ShowWhiteCheckerBoard(window, vparams, sparams);
    fdisp(stdout,'White CheckerBoard Stimulus Complete');       
    
    case {'White','Pink','Brown','Contrast Modulated'}
      
      %----- Set Parameters -----%
      vparams.FrameDuration = 1/vparams.FrameRate; 
      vparams.NFrames = ceil(vparams.StimTime/vparams.FrameDuration);             
      sparams.syncToVBL=1; 
      sparams.dontclear=0;    
      
      %----- Make and Show Movie -----%
      StimLog = makeFilteredNoiseMovie(window,vparams,sparams);           
  
  case 'WaveletNoise'
  
  case 'ContrastModulatedNoise'
  
  otherwise	
    disp('Not Programmed Correctly!!!')
end
assignin('base','vparams',vparams); 
assignin('base','sparams',sparams); 	