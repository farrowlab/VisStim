if isfield(sparams,'paralellport')
     fprintf(1,"Using the parallel Port.\n")
     TTLfunction = @(x,y)parallelTTLoutput(sparams.paralellport,x,y);

     recbit = 1;      % pin 2; duration of recording; trigger to start and stop ThorLab image recording, not connected for EPHUS.
     stimbit = 2;     % pin 3; timestamp for the stimulus
     framebit = 4;    % pin 4; timestamp for the frame
     startbit = 8;    % pin 5; trigger to start lcg recording
     stopbit = 16;    % pin 6; trigger to stop lcg recording
     startca = 32;    % pin 7; trigger start of calcium imaging
  
     % Pin address:
     % Pin    2   3   4   5   6   7   8   9
     % Value   1   2   4   8   16  32  64  128
     % For example if you want to set pins 2 and 3 to logic 1 (led on) then you have to output value 1+2=3, or 3,5 and 6 then you need to output value 2+8+16=26

     pp_data(sparams.paralellport,0);
   
  elseif isfield(sparams,'serialport')
     TTLfunction = @(x)serialTTLoutput(sparams.serialport,x);
     startbit = 0;
     stopbit = 0;
     framebit = 0;
     % There's only 1 TTL output for serialport
  else
     TTLfunction = @(x)0;
  endif