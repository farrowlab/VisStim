function serialTTLoutput(serialport,bit)
  % Outputs TTL pulses to a serial port and returns the time passed
  % Inputs:
  %   - serialport: serial port object
  %   - bit to send
  % Example:
  %     timePassed = serialTTLoutput(serialport,0);
  % Time passed has been removed from the output, added if needed.
  % The initial goal was to make that the time of the Parallel port
  % was comparable to the serial port outputs.
  
 tt = tic;
 for j = 1:5; 
   srl_write(serialport,bit); 
 endfor
  
 timePassed = toc(tt);
  return