  %-------------------- Visual Stimulation FrameWork ---------------------%
clear all
close all
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
%% Initializationtion Routines

	%---------- Load Packages ----------%
	pkg load instrument-control

	%---------- Communications ----------%	
	[status, Myipaddr] = system('ifconfig');
	IPAddress = '10.86.1.63';           % BScopeIP = 10.86.1.87; RetinaIP = 10.86.1.63
	udpIN = 1214;	
	udpsock=pnet('udpsocket', udpIN)		 
	pnet(udpsock,'setreadtimeout',0);	
	sparams.serialport = serial('/dev/ttyS0');
			
	%---------- PTB Initialization ----------%	
	AssertOpenGL; 	% Make sure this is running on OpenGL Psychtoolbox
	
	%---------- Screen Initialization ----------%
	GreyLevel = 128;
	screenid = max(Screen('Screens')); % Choose screen with maximum id - secondary display on a dual-display.
	[window,rect] = Screen('OpenWindow', screenid, GreyLevel);
	[sparams.screenWidth, sparams.screenHeight]=Screen('WindowSize', screenid);	
	sparams.black=BlackIndex(window);
	sparams.white=WhiteIndex(window);
  sparams.rect = rect; 
  sparams.screenid = screenid; 
	sparams.ifi = Screen('GetFlipInterval', window);   
  sparams.deg2pixel = 1/9;           % For Retina this deg = um. Need to Set Independantly for Each Setup!!!!, 60/1080 before
  sparams.pixel2deg = 1/sparams.deg2pixel;

	%---------- KeyBoard Inputs ----------%
	kc_q = KbName('q');	% Quit
	kc_b = KbName('b');	% Toggle Bullseye 
	kc_v = KbName('v');	% Search Stimulus
  kv_z = KbName('z'); % Make BlackScreen
  kv_g = KbName('g'); % Grey Screen
	BullsEyeON = 0;
			
%% Main Loop
main_loop_run = 1; 
KBState = 'Run';
disp(['Keyboard State: ' KBState]);
fdisp(stdout, 'Waiting for orders.')
while main_loop_run	

	%----------- Listen to Keyboard ----------%	 
	Listen2Keyboard;
	
	%---------- Listen to UDP input from 2P Machine ----------%
	  stimsize=pnet(udpsock,'readpacket');
	  if stimsize ~= 0  	      
    fdisp(stdout,['Visual Stimulus Received. Size = ' num2str(stimsize)]); 
	  	udpVisStim = pnet(udpsock,'read');
	  	[VStim vparams] = ParseUDPVStim(udpVisStim);     
      assignin('base','vp',vparams)
	  else
	  	VStim = [];
	  end	  
		
	switch VStim
		case 'No Stim'
		
		case 'BullsEye'
      switch BullsEyeON
       		case 0	       			
      			BullsEyeON = 1
       		  KBState = 'BullsEye ON';	       		  	
       		  BullsEye(BullsEyeON,window,sparams,vparams);
       		case 1
      			BullsEyeON = 0;
       			KBState = 'BullsEye OFF';
       			BullsEye(BullsEyeON,window,sparams,vparams);  
      end 
		  pause(.1);  
      
	  case 'BullsEye'
    StimLog= ShowBullsEye(ONOFF,win,sparams,vparams)
		case 'Spot'
      vparams.Size = vparams.Size/2 * sparams.deg2pixel;
			StimLog = ShowSpot(window,vparams,sparams);		      
      save '/media/NERFFS01/Data/StimLog/StimLog' StimLog;
      
    case 'FullField'
      StimLog = ShowFull(window,vparams,sparams);  
      save '/media/NERFFS01/Data/StimLog/StimLog' StimLog;
      
		case 'Grating'      
      StimLog = ShowGrating(window,vparams,sparams); 
      save '/media/NERFFS01/Data/StimLog/StimLog' StimLog;
      
		case 'Noise'
    fdisp(stdout,'Picking Noise Stimuli.');       
    sparams.dontclear = 0;
    StimLog = PickNoise(window,vparams,sparams);
    save '/media/NERFFS01/Data/StimLog/StimLog' StimLog;
    assignin('base','StimLog',StimLog);
    
		otherwise
			if ~isempty(VStim)
				fdisp(stdout,'Stimulus Not Programed Correctly');
			else
			end
	end
  
		                	
end
%% Clean up and Close Everything -- Bye Bye
Screen('CloseAll');
Screen('Preference','SuppressAllWarnings',oldEnableFlag);
return;

		
		
		
		
		 
