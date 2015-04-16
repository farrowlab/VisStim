function StimLog = ShowMovingBar(window,vparams,sparams);
% difference post stim and inter stim


%-------------- Initiate TTLpulse---------------%
if isfield(sparams,'paralellport')
  fprintf(1,"Using the parallel Port.\n")
  TTLfunction = @(x,y)parallelTTLoutput(sparams.paralellport,x,y);

  recbit = 1;      % pin 2; duration of recording; trigger to start and stop ThorLab image recording
  stimbit = 2;     % pin 3; timestamp for the stimulus
  framebit = 4;    % pin 4; timestamp for the frame
  startbit = 8;    % pin 5; trigger to start lcg recording
  stopbit = 16;    % pin 6; trigger to stop lcg recording
  
 %Pin    2   3   4   5   6   7   8   9
%Value   1   2   4   8   16  32  64  128
%For example if you want to set pins 2 and 3 to logic 1 (led on) then you have to output value 1+2=3, or 3,5 and 6 then you need to output value 2+8+16=26

pp_data(sparams.paralellport,0);
elseif isfield(sparams,'serialport')
  TTLfunction = @(x)serialTTLoutput(sparams.serialport,x);
  startbit = 0;
  stopbit = 0;
  framebit = 0;
else
  TTLfunction = @(x)0;
endif % TTLpulse initialization



%-------------- Initiate Parameters-------------%
nangles = length(vparams.Angle);


  %----- Make Parameter List -----%
  [p, q, r] = meshgrid(vparams.Size,vparams.StimColor,vparams.Speed);
  StimList = [p(:) q(:) r(:)]; % Create a complete stimulus List where each row is a stimulus [Size, Colour, speed]
  StimList = repmat(StimList,[vparams.Repeats,1]);
  NStim = size(StimList,1);

%  switch vparams.Order
%    case 'Forward'
%      StimList = StimList;
%    case 'Random'
%      order = randperm(size(nanglesStimList,1));
%      StimList = StimList(order,:);
%    case 'Reverse'
%      order = fliplr(1:size(StimList,1));
%      StimList = StimList(order,:);
%    otherwise
%      return
%  end  
  assignin('base','StimList',StimList)
  
  %----- Log Stimulus ------%
  StimLog.StimulusClass = 'Moving Bar';
  StimLog.BeginTime = GetSecs;  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IMPORTANT%%%%%%%%%%%
  % Do you want a pulse to be output here?
  %for j = 1:5; srl_write(sparams.serialport,'0'); end 
  for i = 1:size(StimList,1)
    %StimLog.Stim(i).Stimulus = vparams.Shape; 
    StimLog.Angle.Stim(i).Size = StimList(i,1); % Size
    StimLog.Angle.Stim(i).Color = StimList(i,2); % Color
    StimLog.Angle.Stim(i).Speed = StimList(i,3); % Speed
    StimLog.Angle.Stim(i).BgColor = vparams.BgColour; % BgColour
  end
  
  
  % ----- Display Blank screen for BlankTime-----%
  %TIME = GetSecs;
  parallelTTLstartstop(sparams.paralellport,recbit);
  TTLfunction(startbit,recbit);
  StimLog.BlankTime = GetSecs - StimLog.BeginTime;
  WaitSecs(vparams.BlankTime)
  %WaitSecs(TIME + vparams.BlankTime - GetSecs);
  %TIME = TIME + vparams.BlankTime;
  
  
  %----- Initiate Screen -----%
  Screen('FillRect', window, vparams.BgColour)
  ifi = Screen('GetFlipInterval', window);
  vbl = Screen('Flip', window);		
  


  
%---------- Present ----------%
for a = 1:nangles
  AngleBar = vparams.Angle(a);
  for i = 1:NStim
  
    %----- Log Stimulus -----%
    TTLfunction(stimbit,recbit);
    StimLog.Angle(a).Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep
    %for j = 1:5; srl_write(sparams.serialport,'0'); end
                             
  	%------ Draw bar ------%   
    
        % Calculate maximum size of the bar        
        
                
        % convert bar size from degree to pixel
        Barwidth = StimList(i,1) * sparams.pixel2deg;
        SpeedPixPerFrames = StimList(i,3) * sparams.pixel2deg * sparams.ifi;

        
        
        % cardinal direction
        if AngleBar == 0 || AngleBar==180
          PixelNumTraj = sparams.screenWidth + Barwidth;          
          posX = -Barwidth/2 + AngleBar/180*(sparams.screenWidth+Barwidth);
          posY = sparams.screenHeight/2;
        elseif AngleBar==90 || AngleBar==270
          PixelNumTraj = sparams.screenHeight + Barwidth;          
          posX = sparams.screenWidth/2;
          posY = -Barwidth/2-(sparams.screenHeight+Barwidth)*(AngleBar-270)/180;
        elseif 0<AngleBar && AngleBar<90
          PixelNumTraj = sparams.screenHeight*sind(AngleBar) + sparams.screenWidth*cosd(AngleBar) + Barwidth;          
          posX = -Barwidth/2*cosd(AngleBar);
          posY = Barwidth/2*sind(AngleBar)+sparams.screenHeight;
        elseif 90<AngleBar && AngleBar<180
          PixelNumTraj = -sparams.screenWidth*cosd(AngleBar) + sparams.screenHeight*sind(AngleBar) + Barwidth;          
          posX = +sparams.screenWidth-Barwidth/2*cosd(AngleBar);
          posY = +Barwidth/2*sind(AngleBar)+sparams.screenHeight;
        elseif 180<AngleBar && AngleBar<270
          PixelNumTraj = -sparams.screenHeight*sind(AngleBar) - sparams.screenWidth*cosd(AngleBar) + Barwidth;          
          posX = sparams.screenWidth-Barwidth/2*cosd(AngleBar);
          posY = +Barwidth/2*sind(AngleBar);
        elseif 270<AngleBar && AngleBar<360
          PixelNumTraj = sparams.screenWidth*cosd(AngleBar) - sparams.screenHeight*sind(AngleBar) + Barwidth;          
          posX = -Barwidth/2*cosd(AngleBar);
          posY = +Barwidth/2*sind(AngleBar);   
        end
        FrameNum = PixelNumTraj/SpeedPixPerFrames;
        Maxbar = 2*max([abs(sparams.screenHeight*cosd(AngleBar)) abs(sparams.screenWidth*sind(AngleBar))]);

        % Size of the bar
        %baseRect = [0 0 Barwidth sparams.screenHeight]; 
        baseRect = [0 0 Barwidth Maxbar]; % baseRect = [-xmin -ymin xmax ymax];
    
    
      % Rotate bar
      % With this basic way of drawing we have to translate each square from
      % its screen position, to the coordinate [0 0], then rotate it, then
      % move it back to its screen position.
      % This is rather inefficient when drawing many rectangles at high
      % refresh rates. But will work just fine for simple drawing tasks.
      % For a much more efficient way of drawing rotated squares and rectangles
      % have a look at the texture tutorials
      %Screen('FillRect', window, vparams.StimColor, CenterRectOnPoint(baseRect, posX, posY));
      %vbl = Screen('Flip', window, vbl + 0.5 * ifi);
      %Screen('FillRect', window, StimList(i,2) , CenterRectOnPoint(baseRect, posX, posY));
      Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
      Screen('glRotate', window, -AngleBar, 0, 0); % negative rotation
      Screen('glTranslate', window, -posX, -posY)
      Screen('FillRect', window, StimList(i,2) , CenterRectOnPoint(baseRect, posX, posY));

      % Display bar
      vbl = Screen('Flip', window, vbl + 0.5 * ifi);
	  
      % Log in
      TTLfunction(stimbit,recbit);
      TTLfunction(framebit,recbit);
      StimLog.Angle(a).Stim(i).PreTime = GetSecs - StimLog.BeginTime;  % TimeON    
%      for j = 1:5; srl_write(sparams.serialport,'0'); end
	    WaitSecs(vparams.PreTime); 
  
    
    %----- Move bar -----%
    n = 0;   
        
    
    while n <= FrameNum
      n = n + 1;           
        
      % Translate the bar % take less time than a time frame
      Screen('glTranslate', window, SpeedPixPerFrames, 0) % translate image (but need to fillrect again) positive values go oppostie direction        
      Screen('FillRect', window, StimList(i,2), CenterRectOnPoint(baseRect, posX, posY));
      %Screen('glPopMatrix', window)
        
      % Flip to the screen
      vbl  = Screen('Flip', window, vbl + 0.5 * ifi); %(waitframes - 0.5)
      
      if (n == 1)
          TTLfunction(stimbit,recbit);
          TTLfunction(framebit,recbit);
          StimLog.Angle(a).Stim(i).TimeON(i) = GetSecs - StimLog.BeginTime;
          StimLog.Angle(a).Stim(i).Angle = AngleBar;
          %StimLog.Angle(a).Stim(i).Pos(n) = SpeedPixPerFrames;
      elseif  (n == FrameNum+1)        
          TTLfunction(stimbit,recbit);
          TTLfunction(framebit,recbit);
          StimLog.Angle(a).Stim(i).TimeOFF = GetSecs - StimLog.BeginTime;
          %StimLog.Angle(a).Stim(i).Pos(n) = n*SpeedPixPerFrames;
      else
          TTLfunction(framebit,recbit);
          %StimLog.Angle(a).Stim(i).Pos(n) = n*SpeedPixPerFrames;
      end
        
    end
    
    
    tic;
    % Put screen at initial position
    n = 0; 
    while n <= FrameNum
      n = n + 1;
      Screen('glTranslate', window, -SpeedPixPerFrames, 0);
      
            
    end
    Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
    Screen('glRotate', window, AngleBar, 0, 0); % negative rotation
    Screen('glTranslate', window, -posX, -posY)
    
    dum=toc;
    if i < NStim
      WaitSecs(vparams.InterStimTime-dum);
    end 
    
 end
 end 
    %----- Stop Bar -----%       % need review
    TTLfunction(stimbit,recbit);
    StimLog.Stim.StimOFF = GetSecs - StimLog.BeginTime; % TimeOFF
    %for j = 1:5; srl_write(sparams.serialport,'0'); end
      
    Screen('FillRect', window, vparams.BgColour)
    vbl = Screen('Flip', window, vbl + 0.5 * ifi);
    TTLfunction(stimbit,recbit);
    StimLog.Stim.EndSweep = GetSecs - StimLog.BeginTime; % EndSweep
%	  for j = 1:5; srl_write(sparams.serialport,'0'); end
  
    %----- Post Stimulus Pause -----%
    WaitSecs(vparams.PostTime); 
    TTLfunction(stimbit,recbit);
    StimLog.EndTime = GetSecs - StimLog.BeginTime;
    WaitSecs(vparams.BlankTime);
    TTLfunction(stopbit,0);
%    for j = 1:5; srl_write(sparams.serialport,'0'); end

end