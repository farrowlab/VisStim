[keyIsDown ctime keycodes] = KbCheck();	
oldKBState =  KBState;
if keycodes(kc_q) 		% Quit Presentinator 
	KBState = 'Quit';
 	main_loop_run = 0;
  pnet(udpsock,'close');
elseif keycodes(kc_b)		% Toggle BullsEye 
  switch BullsEyeON        
    case 0	       			
      BullsEyeON = 1; 
      KBState = 'BullsEye ON';	       		  	
      BullsEye(BullsEyeON,window);
     case 1
      BullsEyeON = 0;
      KBState = 'BullsEye OFF';
      BullsEye(BullsEyeON,window);  
  end 
  pause(.25);      			
  
elseif keycodes(kc_v)	       	% Show Test Stimulus 			       	
    	 	
elseif keycodes(kv_z)
  Screen('FillRect', window, 0)
  vbl = Screen('Flip', window)

elseif  keycodes(kv_g)
  Screen('FillRect', window, 128)
  vbl = Screen('Flip', window)
else       			
end	

if ~strcmp(oldKBState,KBState);
	disp(['Keyboard State: ' KBState]);
end