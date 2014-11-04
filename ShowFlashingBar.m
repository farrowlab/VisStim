function StimLog = ShowFlashingBar(window,vparams,sparams);


%----- Initiate Screen -----%
  Screen('FillRect', window, vparams.BgColour)
  ifi = Screen('GetFlipInterval', window);
  vbl = Screen('Flip', window);		


%-------------- Initiate -------------%
nangles = length(vparams.Angle);

MatStimList = [];

For a = 1:nangles
  AngleBar = vparams.Angle(a);
        if AngleBar == 0 || AngleBar==180
          PixelNumTraj = sparams.screenWidth + Barwidth;          
        elseif AngleBar==90 || AngleBar==270
          PixelNumTraj = sparams.screenHeight + Barwidth;          
        elseif 0<AngleBar && AngleBar<90
          PixelNumTraj = sparams.screenHeight*sind(AngleBar) + sparams.screenWidth*cosd(AngleBar) + Barwidth;          
        elseif 90<AngleBar && AngleBar<180
          PixelNumTraj = -sparams.screenWidth*cosd(AngleBar) + sparams.screenHeight*sind(AngleBar) + Barwidth;          
        elseif 180<AngleBar && AngleBar<270
          PixelNumTraj = -sparams.screenHeight*sind(AngleBar) - sparams.screenWidth*cosd(AngleBar) + Barwidth;          
        elseif 270<AngleBar && AngleBar<360
          PixelNumTraj = sparams.screenWidth*cosd(AngleBar) - sparams.screenHeight*sind(AngleBar) + Barwidth;          
        end

        % Grid
        NumPosBar = PixelNumTraj/(barwidth/2);
        Posgrid(:,1) = barwidth/2:barwidth/2:NumPosBar-barwidth/2;
        Posgrid(:,2) = AngleBar;
        MatStimList = [MatStimList;Posgrid];
        
end       

%---randomize matrix (perm)
order = randperm(size(MatStimList,1));
MatStimList = MatStimList(order,:);


%---- show bar for every row MatStimList
% need review (posisiton of bar)

for i=1:size(MatStimList,1)

  AngleBar = MatStimList(i,2);
  Maxbar = 2*max([abs(sparams.screenHeight*cosd(AngleBar)) abs(sparams.screenWidth*sind(AngleBar))]);
  posX = MatStimList(i,1);
  posY = Maxbar/2;
  
  
  %rotate
  Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
  Screen('glRotate', window, -AngleBar, 0, 0); % negative rotation
  Screen('glTranslate', window, -posX, -posY)
  Screen('FillRect', window, StimList(i,2) , CenterRectOnPoint(baseRect, posX, posY));
  
  %or
  %Screen('glTranslate', window, 0, 0) % translate image (but need to fillrect again) positive values go oppostie direction
  %Screen('glRotate', window, -AngleBar, 0, 0); % negative rotation
  %Screen('glTranslate', window, -0, -0)
  % and translate
  
  
  
      % Display bar
      vbl = Screen('Flip', window, vbl + 0.5 * ifi);

 





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
  for j = 1:5; srl_write(sparams.serialport,'0'); end 
  for i = 1:size(StimList,1)
    %StimLog.Stim(i).Stimulus = vparams.Shape; 
    StimLog.Stim(i).Size = StimList(i,1); % Size
    StimLog.Stim(i).Color = StimList(i,2); % Color
    StimLog.Stim(i).Speed = StimList(i,3); % Speed
    StimLog.Stim(i).BgColor = vparams.BgColour; % BgColour
  end
  
  %----- Initiate Screen -----%
  Screen('FillRect', window, vparams.BgColour)
  ifi = Screen('GetFlipInterval', window);
  vbl = Screen('Flip', window);		
    
    
    
    
%--------------Create list of stimulus--------------
% 2d matrix each row is a stimulus and 1st column is postion in the grid and 2nd column is angle
    
    
    
    
    
    
    
    
    
    
    
%---------- Present ----------%
for a = 1:nangles
  AngleBar = vparams.Angle(a);
  for i = 1:NStim
  
    %----- Log Stimulus -----%
    StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep
    for j = 1:5; srl_write(sparams.serialport,'0'); end
                             
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
        baseRect = [0 0 Barwidth Maxbar]; % baseRect = [-xmin -ymin xmax ymax];
        
        
        % Grid
        NumPosBar = PixelNumTraj/(barwidth/2);
        Posgrid = barwidth/2:barwidth/2:NumPosBar-barwidth/2;
        
        
    
    
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
      Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
      Screen('glRotate', window, -AngleBar, 0, 0); % negative rotation
      Screen('glTranslate', window, -posX, -posY)
      Screen('FillRect', window, StimList(i,2) , CenterRectOnPoint(baseRect, posX, posY));

      % Display bar
      vbl = Screen('Flip', window, vbl + 0.5 * ifi);
	  
      % Log in
      StimLog.Stim(i).TimeON = GetSecs - StimLog.BeginTime;  % TimeON    
      for j = 1:5; srl_write(sparams.serialport,'0'); end
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
    
    end
    
    
    % Put screen at initial position
    n = 0; 
    while n <= FrameNum
      n = n + 1;
      Screen('glTranslate', window, -SpeedPixPerFrames, 0);
    end
    Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
    Screen('glRotate', window, AngleBar, 0, 0); % negative rotation
    Screen('glTranslate', window, -posX, -posY)
    
    WaitSecs(vparams.InterStimTime); 
    
 end
 end 
    %----- Stop Bar -----%       % need review
    StimLog.Stim(i).TimeOFF = GetSecs - StimLog.BeginTime; % TimeOFF
    for j = 1:5; srl_write(sparams.serialport,'0'); end
      
    Screen('FillRect', window, vparams.BgColour)
    vbl = Screen('Flip', window, vbl + 0.5 * ifi);
    StimLog.Stim(i).EndSweep = GetSecs - StimLog.BeginTime; % EndSweep
	  for j = 1:5; srl_write(sparams.serialport,'0'); end
  
    %----- Post Stimulus Pause -----%
    WaitSecs(vparams.PostTime); 
    StimLog.EndTime = GetSecs - StimLog.BeginTime;
    for j = 1:5; srl_write(sparams.serialport,'0'); end

end