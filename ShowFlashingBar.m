function StimLog = ShowFlashingBar(window,vparams,sparams);

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


%----- Make Parameter List -----%
  [p, q] = meshgrid(vparams.Size,vparams.StimColor);
  StimList = [p(:) q(:)]; % Create a complete stimulus List where each row is a stimulus [Size, Colour]
  StimList = repmat(StimList,[vparams.Repeats,1]);
  NStim = size(StimList,1);
  
  assignin('base','StimList',StimList)



%----- Initiate Screen -----%
  Screen('FillRect', window, vparams.BgColour)
  ifi = Screen('GetFlipInterval', window);
  vbl = Screen('Flip', window);		

  
%----- Log Stimulus ------%
  StimLog.StimulusClass = 'Moving Bar';
  StimLog.BeginTime = GetSecs;  
  %for j = 1:5; srl_write(sparams.serialport,'0'); end 
  for i = 1:size(StimList,1)
    %StimLog.Stim(i).Stimulus = vparams.Shape; 
    StimLog.Stim(i).Size = StimList(i,1); % Size
    StimLog.Stim(i).Color = StimList(i,2); % Color    
    StimLog.Stim(i).BgColor = vparams.BgColour; % BgColour
  end 
 

%-------------- Initiate -------------%
nangles = length(vparams.Angle);

% ----- Display Blank screen for BlankTime-----%
%TIME = GetSecs;
parallelTTLstartstop(sparams.paralellport,recbit);
TTLfunction(startbit,recbit);
StimLog.BlankTime = GetSecs;
WaitSecs(vparams.BlankTime)
%WaitSecs(TIME + vparams.BlankTime - GetSecs);
%TIME = TIME + vparams.BlankTime;

for k = 1:NStim
Barwidth = StimList(k,1) * sparams.pixel2deg;
MatStimList = [];

for a = 1:nangles
  AngleBar = vparams.Angle(a);
        if AngleBar == 0 || AngleBar==180
          PixelNumTraj = sparams.screenWidth - Barwidth; 
          posX = -Barwidth/2 + AngleBar/180*(sparams.screenWidth+Barwidth);
          posY = sparams.screenHeight/2;         
        elseif AngleBar==90 || AngleBar==270
          PixelNumTraj = sparams.screenHeight - Barwidth;
          posX = sparams.screenWidth/2;
          posY = -Barwidth/2-(sparams.screenHeight+Barwidth)*(AngleBar-270)/180;          
        elseif 0<AngleBar && AngleBar<90
          PixelNumTraj = sparams.screenHeight*sind(AngleBar) + sparams.screenWidth*cosd(AngleBar) - Barwidth;
          posX = -Barwidth/2*cosd(AngleBar);
          posY = Barwidth/2*sind(AngleBar)+sparams.screenHeight;          
        elseif 90<AngleBar && AngleBar<180
          PixelNumTraj = -sparams.screenWidth*cosd(AngleBar) + sparams.screenHeight*sind(AngleBar) - Barwidth;
          posX = +sparams.screenWidth-Barwidth/2*cosd(AngleBar);
          posY = +Barwidth/2*sind(AngleBar)+sparams.screenHeight;          
        elseif 180<AngleBar && AngleBar<270
          PixelNumTraj = -sparams.screenHeight*sind(AngleBar) - sparams.screenWidth*cosd(AngleBar) - Barwidth;
          posX = sparams.screenWidth-Barwidth/2*cosd(AngleBar);
          posY = +Barwidth/2*sind(AngleBar);          
        elseif 270<AngleBar && AngleBar<360
          PixelNumTraj = sparams.screenWidth*cosd(AngleBar) - sparams.screenHeight*sind(AngleBar) - Barwidth;
          posX = -Barwidth/2*cosd(AngleBar);
          posY = +Barwidth/2*sind(AngleBar);           
        end

        % Grid 
        NumPosBar = PixelNumTraj/(Barwidth/2);        
        Posgrid = nan(NumPosBar+1,4);
        Posgrid(:,1) = Barwidth/2:Barwidth/2:(NumPosBar+1)*Barwidth/2;
        Posgrid(:,2) = AngleBar;
        Posgrid(:,3) = posX; %intial position of the bar
        Posgrid(:,4) = posY;
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
  posX = MatStimList(i,3);
  posY = MatStimList(i,4);
  baseRect = [0 0 Barwidth Maxbar];
  
  %rotate and put the bar at the edge of the screen
  Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
  Screen('glRotate', window, -AngleBar, 0, 0); % negative rotation
  Screen('glTranslate', window, -posX, -posY)
  Screen('FillRect', window, StimList(k,2) , CenterRectOnPoint(baseRect, posX, posY));
  
  
  % Translate bar
  Screen('glTranslate', window, MatStimList(i,1)+Barwidth/2, 0) % translate image (but need to fillrect again) positive values go oppostie direction        
  Screen('FillRect', window, StimList(k,2), CenterRectOnPoint(baseRect, posX, posY));
  
  
  % Flip to the screen
  TTLfunction(stimbit,recbit);
  TTLfunction(framebit,recbit);
  vbl  = Screen('Flip', window, vbl + 0.5 * ifi); %(waitframes - 0.5)
  
  WaitSecs(vparams.StimTime); 
  
  % translate back
  Screen('glTranslate', window, -MatStimList(i,1)-Barwidth/2, 0);
  
  % rotate back screen
  Screen('glTranslate', window, posX, posY) % translate image (but need to fillrect again) positive values go oppostie direction
  Screen('glRotate', window, AngleBar, 0, 0); % negative rotation
  Screen('glTranslate', window, -posX, -posY)
  
  Screen('FillRect', window, vparams.BgColour)
  TTLfunction(stimbit,recbit);
  TTLfunction(framebit,recbit);
  vbl = Screen('Flip', window, vbl + 0.5 * ifi);
  
  
  % Log in
  StimLog.Stim(i).TimeON = GetSecs - StimLog.BeginTime;  % TimeON    
  %for j = 1:5; srl_write(sparams.serialport,'0'); end
	WaitSecs(vparams.PreTime); 
  
  WaitSecs(vparams.InterStimTime); 
  
end
end
    StimLog.Stim(i).TimeOFF = GetSecs - StimLog.BeginTime; % TimeOFF
    %for j = 1:5; srl_write(sparams.serialport,'0'); end
    
    Screen('FillRect', window, vparams.BgColour)
    TTLfunction(stimbit,recbit);
    TTLfunction(framebit,recbit);
    vbl = Screen('Flip', window, vbl + 0.5 * ifi);
    StimLog.Stim(i).EndSweep = GetSecs - StimLog.BeginTime; % EndSweep
	  %for j = 1:5; srl_write(sparams.serialport,'0'); end
 
%----- Post Stimulus Pause -----%
    WaitSecs(vparams.PostTime);
    TTLfunction(stimbit,recbit);
    TTLfunction(framebit,recbit); 
    StimLog.EndTime = GetSecs - StimLog.BeginTime;
    %for j = 1:5; srl_write(sparams.serialport,'0'); end
    WaitSecs(vparams.BlankTime);
    TTLfunction(stopbit,0);

end
