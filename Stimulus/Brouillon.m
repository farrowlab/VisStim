tic()
IdxTxt = mod(i,nbTxt);
  if IdxTxt == 0
  Screen('DrawTexture', Window1, TextureSinus(nbTxt));
  else  
  Screen('DrawTexture', Window1, TextureSinus(IdxTxt));
  end
%TextureSinus = Screen(Window1, 'MakeTexture', PixVal(t(i))*ones(width,height));
%Screen('DrawTexture', Window1, TextureSinus(i));
Screen(Window1,'Flip')
A=toc()



A = pi/2+atan(sparams.screenHeight/sparams.screenWidth);

%--------------------------------------------------------------------


% initial position bar (assuming that the coordinate of the botom left corner are [0 0] and 0 degre correspond to a vertical bar at the left of the screen outside
        if AngleBar<=90 && AngleBar>=0 % initiate bar position at the bottom left corner
          baseRect = [Maxbar/2*sin(AngleBar)-barwidth*sin(AngleBar) -Maxbar/2*cos(AngleBar)-barwidth*sin(AngleBar) -Maxbar/2*sin(AngleBar) Maxbar/2*cos(AngleBar)];
        elseif AngleBar<=180 && AngleBar>90 % initiate bar position at the bottom right corner
          baseRect = [sparams.screenWidth+Maxbar/2*sin(AngleBar)-barwidth*cos(AngleBar) -Maxbar/2*cos(AngleBar)-barwidth*sin(AngleBar) sparams.screenWidth-Maxbar/2*sin(AngleBar) -Maxbar/2*cos(AngleBar)]
        elseif AngleBar<=270  && AngleBar>180 % initiate bar position at the top right corner
          baseRect = [sparams.screenWidth+Maxbar/2*sin(AngleBar)-barwidth*sin(AngleBar) sparams.screenHeight-Maxbar/2*cos(AngleBar)-barwidth*sin(AngleBar) sparams.screenWidth-Maxbar/2*sin(AngleBar) sparams.screenHeight+Maxbar/2*cos(AngleBar)]
        elseif AngleBar<360 && AngleBar> 270 % initiate bar position at the top left corner
          baseRect = [-Maxbar/2*cos(AngleBar)-barwidth*cos(AngleBar) sparams.screenHeight+Maxbar/2*sin(AngleBar)-barwidth*sin(AngleBar) -Maxbar/2*sin(AngleBar) sparams.screenHeight+Maxbar/2*cos(AngleBar)]  
        end
        

%---------------------------------------------------------------------------------------------------------------------------------------

baseRect = [0 0 400 800];

%PosX = 200


posX = sparams.screenWidth/2;
posY = sparams.screenHeight/2;


% Draw bar on screen at initial position
    
      % initial position of the center of the bar %need review
      if 0<AngleBar && AngleBar<90 % initiate bar position at the bottom left corner
        posX = -Barwidth/2*cosd(AngleBar);
        posY = Barwidth/2*sind(AngleBar)+sparams.screenHeight;      
      elseif 90<AngleBar && AngleBar<180 % initiate bar position at the bottom right corner
        posX = +sparams.screenWidth-Barwidth/2*cosd(AngleBar);
        posY = +Barwidth/2*sind(AngleBar)+sparams.screenHeight;      
      elseif 180<AngleBar && AngleBar<270 % initiate bar position at the top right corner          %PB
        posX = sparams.screenWidth-Barwidth/2*cosd(AngleBar);
        posY = +Barwidth/2*sind(AngleBar);      
      elseif 270<AngleBar && AngleBar<360 % initiate bar position at the top left corner
        posX = -Barwidth/2*cosd(AngleBar);
        posY = +Barwidth/2*sind(AngleBar);     
      end



function StimLog = ShowMovingBar(window,vparams,sparams);

%---------- Initiate ---------%
nangles = length(vparams.Angle);



  %----- Make Parameter List -----%
  [p, q, r] = meshgrid(vparams.Size,vparams.StimColor,vparams.Speed);
  StimList = [p(:) q(:) r(:)]; % Create a complete stimulus List where each row is a stimulus [Size, Colour]
  StimList = repmat(StimList,[vparams.Repeats,1]);
  NStim = size(StimList,1);

  switch vparams.Order
    case 'Forward'
      StimList = StimList;
    case 'Random'
      order = randperm(size(nanglesStimList,1));
      StimList = StimList(order,:);
    case 'Reverse'
      order = fliplr(1:size(StimList,1));
      StimList = StimList(order,:);
    otherwise
      return
  end  
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
    
%---------- Present ----------%
for a = 1:nangles
  AngleBar = vparams.Angle(a);
  for i = 1:NStim
  
    %----- Log Stimulus -----%
    StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep
    for j = 1:5; srl_write(sparams.serialport,'0'); end
                             
  	%----- Draw bar -----%   
    
        % Calculate maximum size of the bar
        
        PixelNumTraj = sparams.screenHeight/sin(AngleBar) + (sparams.screenWidth-sparams.screenHeight/tan(AngleBar))*cos(AngleBar) + Barwidth;
        
        Maxbar = 2*ceil(sparams.screenWidth/sqrt(sparams.screenHeight^2/sparams.screenWidth^2 +1));
        Maxbar = 2*(sparams.screenWidth-sparams.screenHeight/tan(AngleBar))*cos(AngleBar)*tan(AngleBar);        
        % convert bar size from degree to pixel
        Barwidth = vparams.Size * sparams.pixel2deg;
        
        % Size of the bar
        baseRect = [0 0 Barwidth Maxbar];
        

    
    %baseRect = [-xmin -ymin xmax ymax];
    %XperFrame = (screenXpixels+posX / vparams.Speed);
    %YperFrame = (screenYpixels / vparams.Speed);
    posX = (sparams.screenWidth / 2);
    posY = (sparams.screenHeight / 2);
    %nframes = screenXpixels+posX/XperFrame;
    
    % Draw bar on screen at initial position
    
      % initial position of the center of the bar
      if 0<=AngleBar<=90 % initiate bar position at the bottom left corner
        posX = -Barwidth/2*cos(AngleBar);
        posY = -Barwidth/2*sin(AngleBar);      
      elseif 90<AngleBar<=180
        posX = sparams.screenWidth-Barwidth/2*cos(AngleBar);
        posY = -Barwidth/2*sin(AngleBar);      
      elseif 180<AngleBar<=270
        posX = sparams.screenWidth-Barwidth/2*cos(AngleBar);
        posY = sparams.screenHeight-Barwidth/2*sin(AngleBar);      
      elseif 270<AngleBar<=360
        posX = -Barwidth/2*cos(AngleBar);
        posY = sparams.screenHeight-Barwidth/2*sin(AngleBar);     
      end
 
    Screen('FillRect', window, vparams.StimColor, CenterRectOnPoint(baseRect, posX, posY));
    vbl = Screen('Flip', window, vbl + 0.5 * ifi);
	  
    
    StimLog.Stim(i).TimeON = GetSecs - StimLog.BeginTime;  % TimeON    
    for j = 1:5; srl_write(sparams.serialport,'0'); end
	  WaitSecs(vparams.PreTime); 
  
    %----- Move bar -----%
    n = 0;
    posXs = posX;
    posYs = posY;
    
    while n <= nframes
      n = n + 1;
      % With this basic way of drawing we have to translate each square from
    % its screen position, to the coordinate [0 0], then rotate it, then
    % move it back to its screen position.
    % This is rather inefficient when drawing many rectangles at high
    % refresh rates. But will work just fine for simple drawing tasks.
    % For a much more efficient way of drawing rotated squares and rectangles
    % have a look at the texture tutorials
        

        % Get the current squares position and rotation angle
        posX = posXs;
        posY = posYs;
        AngleBar = angles;

        % Translate, rotate, re-tranlate and then draw our square
        Screen('glPushMatrix', window)
        Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
        Screen('glRotate', window, -AngleBar, 0, 0); % negative rotation
        Screen('glTranslate', window, -posX, -posY)
        Screen('FillRect', window, vparams.StimColor,...
            CenterRectOnPoint(baseRect, posX, posY));
        Screen('glPopMatrix', window)

        

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Increment the rotation angles of the squares now that we have drawn
    % to the screen
    posXs = posX + XperFrame;
    
    posYs = posY + YperFrame   
    
    end
  
    WaitSecs(vparams.PreTime); 
  
    %----- Stop Bar -----%
	  vbl = Screen('Flip', window, vbl + 0.5 * ifi);       
    StimLog.Stim(i).TimeOFF = GetSecs - StimLog.BeginTime; % TimeOFF
    for j = 1:5; srl_write(sparams.serialport,'0'); end
  
    WaitSecs(vparams.InterStimTime); 
    Screen('FillRect', window, vparams.Background)
    StimLog.Stim(i).EndSweep = GetSecs - StimLog.BeginTime; % EndSweep
	  for j = 1:5; srl_write(sparams.serialport,'0'); end
  
    %----- Post Stimulus Pause -----%
    if i == NStim
    WaitSecs(vparams.PostTime); 
    StimLog.EndTime = GetSecs - StimLog.BeginTime;
    for j = 1:5; srl_write(sparams.serialport,'0'); end
    else
    end
  end    

end