function timePassed = parallelTTLoutput(parport,bit,oldbit)
  % Outputs TTL pulses to a parallel port and returns the absolute time of 
  % the frame and the output of Screen.
  % Inputs:
  %   - parport: parallel port object
  %   - bit to send when presenting frame  
  % Example:
  %     timePassed = parallelTTLoutput(serialport,1);
 pp_data(parport,oldbit);
 pulseDuration = 0.0002;
 % Output TTL
 timePulse = GetSecs();
 newbit = oldbit + bit; 
 pp_data(parport,newbit);
 WaitSecs(pulseDuration - (GetSecs - timePulse));
% Bring pulse back to baseline
 pp_data(parport,oldbit);
 return;
 
 
 
% function timePassed = parallelTTLoutput(parport,bit)
%  % Outputs TTL pulses to a parallel port and returns the absolute time of 
%  % the frame and the output of Screen.
%  % Inputs:
%  %   - parport: parallel port object
%  %   - bit to send when presenting frame  
%  % Example:
%  %     timePassed = parallelTTLoutput(serialport,1);
% pp_data(parport,0);
% pulseDuration = 0.0002;
% % Output TTL
% timePulse = GetSecs();
% pp_data(parport,bit);
% WaitSecs(pulseDuration); % - (GetSecs - timePulse));
%% Bring pulse back to baseline
% pp_data(parport,0);
% return;

