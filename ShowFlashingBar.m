function StimLog = ShowFlashingBar(window,vparams,sparams);
  %-----------------  Initiate TTLpulse  -----------------%
  InitiateTTLPulses
  vparams.Repeats = 1;

  %-----------------  Make Parameter List  ---------------%
  [p, q] = meshgrid(vparams.BarWidths,vparams.ONColor);
  StimList = [p(:) q(:)]; % Create a complete stimulus List where each row is a stimulus [Size, Colour]
  StimList = repmat(StimList,[vparams.Repeats,1]);
  NStim = size(StimList,1);  
  assignin('base','StimList',StimList)

  %-----------------  Initiate Screen  -------------------%
  parallelTTLstartstop(sparams.paralellport,recbit);
  TTLfunction(startbit,recbit); WaitSecs(.1); 
  StimLog.BeginTime = GetSecs; 
  Screen('FillRect', window, vparams.BgColour)
  ifi = Screen('GetFlipInterval', window);
  vbl = Screen('Flip', window);		

  %-----------------  Log Stimulus  ----------------------%
  StimLog.StimulusClass = 'Flashing Bar';   
   
  %-----------------  Initiate ---------------------------%
  nangles = vparams.NAngles;
  dangle = round(180/nangles);
  vparams.NAngles = 0:dangle:179;
  
  %-----------------  Display Blank screen----------------%  
  StimLog.BlankTime(1) = GetSecs - StimLog.BeginTime;
  WaitSecs(vparams.BlankTime)

      %----- Calculate Positions -----%
      Barwidth = StimList(1,1) * sparams.pixel2deg;
      MatStimList = [];
      for a = 1:nangles
          AngleBar = vparams.NAngles(a);          
          if AngleBar == 0 || AngleBar==180
              PixelNumTraj = sparams.screenWidth; %- Barwidth; 
              posX = -Barwidth/2 + AngleBar/180*(sparams.screenWidth+Barwidth);
              posY = sparams.screenHeight/2;         
          elseif AngleBar==90 || AngleBar==270
              PixelNumTraj = sparams.screenHeight; % - Barwidth;
              posX = sparams.screenWidth/2;
              posY = -Barwidth/2-(sparams.screenHeight+Barwidth)*(AngleBar-270)/180;          
          elseif 0<AngleBar && AngleBar<90
              PixelNumTraj = sparams.screenHeight*sind(AngleBar) + sparams.screenWidth*cosd(AngleBar); % - Barwidth;
              posX = -Barwidth/2*cosd(AngleBar);
              posY = Barwidth/2*sind(AngleBar)+sparams.screenHeight;          
          elseif 90<AngleBar && AngleBar<180
              PixelNumTraj = -sparams.screenWidth*cosd(AngleBar) + sparams.screenHeight*sind(AngleBar); % - Barwidth;
              posX = +sparams.screenWidth-Barwidth/2*cosd(AngleBar);
              posY = +Barwidth/2*sind(AngleBar)+sparams.screenHeight;          
          elseif 180<AngleBar && AngleBar<270
              PixelNumTraj = -sparams.screenHeight*sind(AngleBar) - sparams.screenWidth*cosd(AngleBar); % - Barwidth;
              posX = sparams.screenWidth-Barwidth/2*cosd(AngleBar);
              posY = +Barwidth/2*sind(AngleBar);          
          elseif 270<AngleBar && AngleBar<360
              PixelNumTraj = sparams.screenWidth*cosd(AngleBar) - sparams.screenHeight*sind(AngleBar); % - Barwidth;
              posX = -Barwidth/2*cosd(AngleBar);
              posY = +Barwidth/2*sind(AngleBar);           
          end

          %----- Make Grid -----%
          NumPosBar = ceil(PixelNumTraj/(Barwidth/2));        
          Posgrid = nan(NumPosBar+1,4);
          Posgrid(:,1) = 0:Barwidth/2:(NumPosBar)*Barwidth/2;
          Posgrid(:,2) = AngleBar;
          Posgrid(:,3) = posX; % intial position of the bar
          Posgrid(:,4) = posY;
          MatStimList = [MatStimList;Posgrid];        
      end       
      
  %-----------------  randomize matrix (perm)  -----------%
      order = randperm(size(MatStimList,1));
      MatStimList = MatStimList(order,:);


  %-----------------  show bar for every row MatStimList  --%
  % need review (posisiton of bar)                  
      StimLog.BarWidths = StimList(1,1); % BarWidths
      StimLog.BgColor = vparams.BgColour; % BgColour                
      for n=1:2*size(MatStimList,1)
          
          % Alternate Color & Position
          if n <= size(MatStimList,1)
            i = n
            if (rem (i, 2) == 0)
              c = 1;
            else 
              c = 2;
            end
            
          else
            i = n - size(MatStimList,1) 
            if (rem (i, 2) == 0)
              c = 2;
            else 
              c = 1;
            end
            
          end
          
          
          
          
          AngleBar = MatStimList(i,2);
          Maxbar = 2*max([abs(sparams.screenHeight*cosd(AngleBar)) abs(sparams.screenWidth*sind(AngleBar))]);
          posX = MatStimList(i,3);
          posY = MatStimList(i,4);
          baseRect = [0 0 Barwidth Maxbar];          
  
          %rotate and put the bar at the edge of the screen
          Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
          Screen('glRotate', window, -AngleBar, 0, 0); % negative rotation
          Screen('glTranslate', window, -posX, -posY)
          Screen('FillRect', window, StimList(c,2) , CenterRectOnPoint(baseRect, posX, posY));
  
          % Translate bar
          Screen('glTranslate', window, MatStimList(i,1)+Barwidth/2, 0) % translate image (but need to fillrect again) positive values go oppostie direction        
          Screen('FillRect', window, StimList(c,2), CenterRectOnPoint(baseRect, posX, posY));
    
          % Flip to the screen
          vbl  = Screen('Flip', window, vbl + 0.5 * ifi);
          TTLfunction(stimbit,recbit);
          
          % Log in
          StimLog.Stim(n).NAngles = AngleBar;
          StimLog.Stim(n).Pos = MatStimList(i,1)+Barwidth/2;            
          StimLog.Stim(n).Color = StimList(c,2); % Color    
          StimLog.Stim(n).TimeON = GetSecs - StimLog.BeginTime;                                  
          WaitSecs(vparams.TimeON);  
  
          % translate back
          Screen('glTranslate', window, -MatStimList(i,1)-Barwidth/2, 0);
  
          % rotate back screen
          Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
          Screen('glRotate', window, AngleBar, 0, 0); % negative rotation
          Screen('glTranslate', window, -posX, -posY)
          Screen('FillRect', window, vparams.BgColour)
          vbl = Screen('Flip', window, vbl + 0.5 * ifi);
  
  
          % Log in
          StimLog.Stim(n).TimeOFF = GetSecs - StimLog.BeginTime;  % TimeON    
          TTLfunction(stimbit,recbit);
          WaitSecs(vparams.TimeOFF); 
  
      end          
  
% Screen already in background color  
  TTLfunction(stimbit,recbit);
  StimLog.EndSweep = GetSecs - StimLog.BeginTime; % EndSweep 
 
  %-----------------  Post Stimulus Pause  ---------------% 
  WaitSecs(vparams.BlankTime);
  TTLfunction(stimbit,recbit);
  StimLog.EndTime = GetSecs - StimLog.BeginTime;

