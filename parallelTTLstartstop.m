function timePassed = parallelTTLstartstop(parport,bit)
  % Outputs TTL pulses to a parallel port and returns the absolute time of 
  % the frame and the output of Screen.
  % Inputs:
  %   - parport: parallel port object
  %   - bit to send when presenting frame  
  % Example:
  %     timePassed = parallelTTLoutput(serialport,1);

 pulseDuration = 0.0002;
 % Output TTL
 timePulse = GetSecs();
 pp_data(parport,bit);
 WaitSecs(pulseDuration - (GetSecs - timePulse));

 
 return;