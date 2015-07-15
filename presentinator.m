%-------------------- Visual Stimulation FrameWork ---------------------%
clear all
close all
clc
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
%% Initializationtion Routines
  %---------- Set Paths ----------%
%  addpath('');
%Pin     2   3   4   5   6   7   8   9
%Bit     D0  D1  D2  D3  D4  D5  D6  D7
%Value   1   2   4   8   16  32  64  128

  
	%---------- Communications ----------%
  %TTL_protocol = 'serial';
 TTL_protocol = 'parallel';
  
	[status, Myipaddr] = system('ifconfig');
	IPAddress = '10.86.1.105'
	udpIN = 1214;	
	udpsock=pnet('udpsocket', udpIN)		 
	pnet(udpsock,'setreadtimeout',0);
  
  if strcmp(TTL_protocol,'serial')
      sparams.serialport = serial('/dev/ttyS0');
  elseif strcmp(TTL_protocol,'parallel')
      pkg load instrument-control
      sparams.paralellport = parallel('/dev/parport0',0);
  else
      disp('No protocol defined for TTL pulses.');
  endif
  
			
	%---------- PTB Initialization ----------%	
	AssertOpenGL; 	% Make sure this is running on OpenGL Psychtoolbox
	
	%---------- Screen Initialization ----------%
	GreyLevel = 125;
	screenid = max(Screen('Screens')); % Choose screen with maximum id - secondary display on a dual-display.
	[window,rect]= Screen('OpenWindow', screenid, GreyLevel);
	[sparams.screenWidth, sparams.screenHeight]=Screen('WindowSize', screenid);	
	sparams.black=BlackIndex(window);
	sparams.white=WhiteIndex(window);
  sparams.rect = rect; 
  sparams.screenid = screenid; 
	sparams.ifi = Screen('GetFlipInterval', window);   
  sparams.xdeg2pixel = 125/sparams.screenWidth;           % Need to Set Independantly for Each Setup!!!!
  sparams.ydeg2pixel = 70/sparams.screenHeight;           % Need to Set Independantly for Each Setup!!!!
  sparams.pixel2deg = 1/sparams.ydeg2pixel;
  %load gammaTable        
  global gt
  gt = load('gammatable2_n17.mat');             
  Screen('LoadNormalizedGammaTable', window, gt.gammaTable2*[1 1 1]);        
        
  
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

clear('StimLog','vparams','filename')  
	%----------- Listen to Keyboard ----------%	 
	Listen2Keyboard;
	
	%---------- Listen to UDP input from 2P Machine ----------%
	  stimsize=pnet(udpsock,'readpacket');
	  if stimsize ~= 0  	      
    fdisp(stdout,['Visual Stimulus Received. Size = ' num2str(stimsize)]); 
	  	udpVisStim = pnet(udpsock,'read'); % command string
    [VStim vparams] = ParseUDPVStim(udpVisStim);
    %fdisp(stdout,udpVisStim);fflush(stdout)
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
	
		case 'Spot'
			StimLog = ShowSpot(window,vparams,sparams);		      
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/Spot']
      mkdir(file_Stim);
      
    case 'FullField'
      StimLog = ShowFull(window,vparams,sparams);  
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/FullField']
      mkdir(file_Stim);
      
		case 'Grating'      
      StimLog = ShowGrating(window,vparams,sparams);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/Grating']
      mkdir(file_Stim);
      
%      %Check if files have already been created
%      dum = dir(file_Stim);
%      if size(dum,1) > 2
%      CounterGrating = str2num(dum(end).name) +1;      
%      else
%      CounterGrating = 1;
%      end
%      filename = [file_Stim,'/',num2str(CounterGrating)];
%      CounterGrating = CounterGrating+1; 
      #save '/media/nerffs01/Data/StimLog/StimLog' StimLog;
      
		case 'Noise'
      fdisp(stdout,'Picking Noise Stimuli.');       
      sparams.dontclear = 0;
      StimLog = PickNoise(window,vparams,sparams);
%     save '/media/nerffs01/Data/StimLog/StimLog' StimLog;
      assignin('base','StimLog',StimLog);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/Noise']
      mkdir(file_Stim);
    
    case 'Moving Bar'      
      StimLog = ShowMovingBar(window,vparams,sparams); 
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/MovingBar']
      mkdir(file_Stim);
      
%      %Check if files have already been created
%      dum = dir(file_Stim);
%      if size(dum,1) > 2
%      CounterMovingBar = str2num(dum(end).name) +1;      
%      else
%      CounterMovingBar = 1;
%      end
%      filename = [file_Stim,'/',num2str(CounterMovingBar)];
%      CounterMovingBar = CounterMovingBar+1;
      %save '/media/nerffs01/Data/StimLog/StimLog' StimLog;
      %save '/media/nerffs01/Data/StimLog/StimLog' StimLog;
      
    case 'Flashing Bar'
      
      StimLog = ShowFlashingBar(window,vparams,sparams);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/FlashingBar']
      mkdir(file_Stim);
      
    
    case 'Expanding Circle'
      
      StimLog = ShowExpandingCircle(window,vparams,sparams);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/ExpandingCircle']
      mkdir(file_Stim);
      
    
    case 'Expanding Checkerboard'
      
      StimLog = ShowExpandingCheckerboard(window,vparams,sparams);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/ExpandingCheckerboard']
      mkdir(file_Stim);
    
    
    case 'Translating Expanding Circle'
      
      StimLog = ShowTranslatingExpandingCircle(window,vparams,sparams);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/TranslatingExpandingCircle']
      mkdir(file_Stim);

    
    case 'Translating Expanding Checkerboard'
      
      StimLog = ShowTranslatingExpandingCheckerboard(window,vparams,sparams);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/TranslatingExpandingCheckerboard']
      mkdir(file_Stim);
      
    
    case 'Flashing Grid Square'
      
      StimLog = ShowFlashingGridSquare(window,vparams,sparams);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/FlashingGridSquare']
      mkdir(file_Stim);
    
    
    case 'Translating Expanding Circle to Center'
      
      StimLog = ShowTranslatingExpandingCircletoCenter(window,vparams,sparams);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/TranslatingExpandingCircletoCenter']
      mkdir(file_Stim);
      
    
    case 'Translating Expanding Circle from Center'
      
      StimLog = ShowTranslatingExpandingCirclefromCenter(window,vparams,sparams);
      file_date = ['/home/farrowlab/StimLog/StimLog',datestr(now,['yyyy','mm','dd'])];
      mkdir(file_date);
      file_Stim = [file_date,'/TranslatingExpandingCirclefromCenter']
      mkdir(file_Stim);
     
     
    otherwise
	if ~isempty(VStim)
         	fdisp(stdout,'Stimulus Not Programed Correctly');
        end
      end
      try
       [~,filename] = fileparts(vparams.Filename);
       filename = [file_Stim,'/',filename,'.mat'];
       StimLog.Filename = vparams.Filename;
      end
      if exist('filename','var') & exist('StimLog','var')
         save ('-mat7-binary',filename,'StimLog');
      end
end

%% Clean up and Close Everything -- Bye Bye
Screen('CloseAll');
Screen('Preference','SuppressAllWarnings',oldEnableFlag);
return;

		
		
		
		
		 
