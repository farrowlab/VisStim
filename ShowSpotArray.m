function StimLog = ShowSpotArray(window,vparams,sparams);

%-------------- Initiate TTLpulse---------------%
if isfield(sparams,'paralellport')
  fprintf(1,"Using the parallel Port.\n")
  TTLfunction = @(x,y)parallelTTLoutput(sparams.paralellport,x,y);

  recbit = 1;      % pin 2; duration of recording; trigger to start and stop ThorLab image recording
  stimbit = 2;     % pin 3; timestamp for the stimulus
  framebit = 4;    % pin 4; timestamp for the frame
  startbit = 8;    % pin 5; trigger to start lcg recording
  stopbit = 16;    % pin 6; trigger to stop lcg recording
  pp_data(sparams.paralellport,0);
  %Pin    2   3   4   5   6   7   8   9
  %Value   1   2   4   8   16  32  64  128
  %For example if you want to set pins 2 and 3 to logic 1 (led on) then you have to output value 1+2=3, or 3,5 and 6 then you need to output value 2+8+16=26
    
elseif isfield(sparams,'serialport')
  TTLfunction = @(x)serialTTLoutput(sparams.serialport,x);
  startbit = 0;
  stopbit = 0;
  framebit = 0;
else
  TTLfunction = @(x)0;
endif % TTLpulse initialization


%--------------- Initiate Screen ---------------%
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);


%--------------- Initiate Parameters-------------%
dim = floor(vparams.GridSize/2);
[xCenter, yCenter] = RectCenter(sparams.rect);

  %----- Log In -----%
  StimLog.StimulusClass = 'SpotArray';
  StimLog.Type = vparams.Type;
  StimLog.BeginTime = GetSecs;    

  
%--------------- Display Blank screen for BlankTime ---------------%
switch vparams.BgColour
  case 'Noise'
    BG = zeros(100,190);
    I = randperm(length(BG(:)));
    BG(I(1:length(BG(:))/2))=255;
    BGTexture = Screen('MakeTexture', window, BG);
    theRect = [0 0 1920 1024];
    NewRect = CenterRectOnPointd(theRect, screenXpixels/2,screenYpixels/2);     
    Screen('DrawTextures', window, BGTexture,[],NewRect) 
    BgColour = 128;
  otherwise  
    Screen('FillRect', window, vparams.BgColour);
    BgColour = vparams.BgColour;  
end
vbl = Screen('Flip', window);  
  
  %----- LogIn -----%    
  parallelTTLstartstop(sparams.paralellport,recbit);
  TTLfunction(startbit,recbit);
  StimLog.BlankTime = GetSecs - StimLog.BeginTime;
  WaitSecs(vparams.BlankTime); 
 
 
%--------------- Create Dot Array ---------------%
if ~isfield(vparams,'Shape')
  vparams.Shape = 'Cross';
elseif isempty(vparams.Shape);
  vparams.Shape = 'Cross';  
end
switch vparams.Shape

  case {'Grid','Cross'}
  
    %---------- Create and Scale Grid ----------%
    [x, y] = meshgrid(-dim:1:dim, -dim:1:dim);
    pixelScale = screenYpixels / 4 %(2 * (dim * 2 + 2));
    x = x .* pixelScale;
    y = y .* pixelScale;
    numDots = numel(x);      
    
      %----- Get Cross -----%
      if strmatch ("Cross", vparams.Shape)              
        mx = median(x(:))
        my = median(y(:))
        n = 0;
        for i = 1:numDots
          if x(i) == mx || y(i) == my
            n = n + 1;
            DotNums(n) = i;
          end      
        end
      
      %----- Get Grid -----%  
      else
        DotNums = 1:numDots;
      end
  
  case 'Random'
  
  otherwise
    disp('Need to Define Shape');
    StimLog.error{1} = 'Shape Not Defined => Single Spot Shown.';
    
    %---------- Create Single Dot ----------%
    [x, y] = meshgrid(1, 1);
    pixelScale = screenYpixels / 4 %(2 * (dim * 2 + 2));
    x = x .* pixelScale;
    y = y .* pixelScale;
    numDots = numel(x);
    DotNums = 1:numDots;
    
 end
    
    %----- Scale Dot Array -----%    
    dotPositionMatrix = [reshape(x, 1, numDots); reshape(y, 1, numDots)];
    dotCenter = [xCenter yCenter];
    OdotColors = zeros(3, numDots) + BgColour;
    dotColors = OdotColors;
    OdotSizes = zeros(1, numDots) + 1;
    OdotSizes = OdotSizes * sparams.pixel2deg/2;
    dotSizes = OdotSizes;         
  
    %----- Create Stimulus Matrix -----%
    [d, s, c] = meshgrid(DotNums,vparams.Sizes,vparams.ONColor);
    StimList = [d(:) s(:) c(:)]; % Create a complete stimulus List where each row is a stimulus [Dot, Size, Colour]
    StimList = repmat(StimList,[vparams.Repeats,1]);      
    order = randperm(size(StimList,1));
    StimList = StimList(order,:);      
    NStim = size(StimList,1);
    StimList(:,2) = StimList(:,2) * sparams.pixel2deg/2;
    assignin('base','StimList',StimList);
      
%--------------- Draw and Manipulate Dots ---------------%        
switch vparams.Type
  case 'fSpot'    
          %----- Make Texture -----%
          [screenXpixels, screenYpixels] = Screen('WindowSize', window);
          [xCenter, yCenter] = RectCenter(sparams.rect);
          
          %----- Run Loop -----%
          for st = 1:NStim       
            d = StimList(st,1);
            s = StimList(st,2);    
            c = [StimList(st,3) StimList(st,3) StimList(st,3)];
            startPhase = 0;
            time = 0;
            freq = (2 * pi)/vparams.StimTime; 
                       
            
            %----- Draw Array -----%            
            theRect = [0 0 0 0];
            NewRect = CenterRectOnPointd(theRect, (screenXpixels/2)+dotPositionMatrix(1,d),(screenYpixels/2)-dotPositionMatrix(2,d));     
            Screen('FillOval', window, c, NewRect);               
            vbl = Screen('Flip', window);
              
              %---  Log In  ---%
              StimLog.Stim(i).Position = dotPositionMatrix(1:2,d);
              StimLog.Stim(i).Size = s;
              StimLog.Stim(i).Color = c;
              StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep 
              TTLfunction(startbit,recbit);
              WaitSecs(vparams.PreTime);
            
              
            
            %----- Manipulate Array -----%
            theRect = [0 0 s s];                                                                 
            NewRect = CenterRectOnPointd(theRect, (screenXpixels/2)+dotPositionMatrix(1,d),(screenYpixels/2)-dotPositionMatrix(2,d));                  
            Screen('FillOval', window, c, NewRect);  
            vbl = Screen('Flip', window); 
            
              %---  Log In  ---%
              StimLog.Stim(i).TimeON = GetSecs - StimLog.BeginTime;
              TTLfunction(startbit,recbit);
              WaitSecs(vparams.StimTime);                        
            
            %----- Put Original Array Back -----%                
            theRect = [0 0 0 0];              
            NewRect = CenterRectOnPointd(theRect, (screenXpixels/2)+dotPositionMatrix(1,d),(screenYpixels/2)-dotPositionMatrix(2,d));     
            Screen('FillOval', window, c, NewRect);              
            vbl = Screen('Flip', window); 
            
              %--- Log In ---%
              StimLog.Stim(i).TimeOFF = GetSecs - StimLog.BeginTime;
              TTLfunction(startbit,recbit);
              WaitSecs(vparams.PostTime);
              StimLog.Stim(i).EndSweep = GetSecs - StimLog.BeginTime;
              TTLfunction(startbit,recbit);
          end                                                   
    
  case 'eDisk'
         
          %----- Make Texture -----%
          [screenXpixels, screenYpixels] = Screen('WindowSize', window);
          [xCenter, yCenter] = RectCenter(sparams.rect);          
          
          %----- Run Loop -----%
          for st = 1:NStim       
            d = StimList(st,1);
            s = StimList(st,2);     
            c = [StimList(st,3) StimList(st,3) StimList(st,3)];
            startPhase = 0;
            time = 0;
            freq = (2 * pi)/vparams.StimTime; 
                       
            
            %----- Draw Array -----%                  
            theRect = [0 0 0 0];
            NewRect = CenterRectOnPointd(theRect, (screenXpixels/2)+dotPositionMatrix(1,d),(screenYpixels/2)-dotPositionMatrix(2,d));     
            Screen('FillOval', window, c, NewRect);   
            vbl = Screen('Flip', window); 
              
              %---  Log In  ---%
              StimLog.Stim(i).Position = dotPositionMatrix(1:2,d);
              StimLog.Stim(i).Size = s;
              StimLog.Stim(i).Color = c;
              StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep 
              TTLfunction(startbit,recbit);
              WaitSecs(vparams.PreTime);
            
            %----- Manipulate Array -----%
            phase = 100 * freq * time + startPhase;
              
              %---  Log In  ---%
              StimLog.Stim(i).TimeON = GetSecs - StimLog.BeginTime;
              TTLfunction(startbit,recbit);              
                
            while round(phase) ~= 314                                 
              theRect = [0 0 (s * sin(freq * time + startPhase)) (s * sin(freq * time + startPhase))];
              NewRect = CenterRectOnPointd(theRect, (screenXpixels/2)+dotPositionMatrix(1,d),(screenYpixels/2)-dotPositionMatrix(2,d));                  
              Screen('FillOval', window, c, NewRect);              
              vbl = Screen('Flip', window); 
              time = time + sparams.ifi;
              phase = 100 * freq * time + startPhase;                                                
            end
            
            %----- Put Original Array Back -----%                 
            theRect = [0 0 0 0];
            NewRect = CenterRectOnPointd(theRect, (screenXpixels/2)+dotPositionMatrix(1,d),(screenYpixels/2)-dotPositionMatrix(2,d));     
            Screen('FillOval', window, c, NewRect);                          
            vbl = Screen('Flip', window);             
              
              %--- Log In ---%
              StimLog.Stim(i).TimeOFF = GetSecs - StimLog.BeginTime;
              TTLfunction(startbit,recbit);
              WaitSecs(vparams.PostTime);
              StimLog.Stim(i).EndSweep = GetSecs - StimLog.BeginTime;
              TTLfunction(startbit,recbit);
          end
     
  case 'Football'
          
          %----- Make Texture -----%
          pattern = 'Noise'; %'Checkerboard'; %'Spokes' 'Noise'
          [screenXpixels, screenYpixels] = Screen('WindowSize', window);
          [xCenter, yCenter] = RectCenter(sparams.rect);
          switch pattern
            case 'Checkerboard'
              rmax = 100;
              [n1, n2] = ndgrid(-rmax:rmax);
              [THETA,r] = cart2pol(n1,n2);
              FB = (-1).^(floor(n1/20) + floor(n2/20));                        
              gp = find(r>rmax);
              FB = FB * 255;
              FB(gp) = BgColour;
              
            case 'Noise'
              rmax = 100;
              [n1, n2] = ndgrid(-rmax:rmax);
              [THETA,r] = cart2pol(n1,n2);              
              gp = find(r>rmax);
              i = randperm(numel(n1));
              FB = zeros(numel(n1));
              FB(i(1:round(numel(n1)/2))) = 1;       
              FB = FB * 255;       
              FB(gp) = BgColour;
              
              
              
              
            case 'Spokes'
              sigma=4;
              spokes=6;
              SUP=500; % This parameter controls the resolution
              hsup=(SUP-1)/2;
              [x,y]=meshgrid([-hsup:hsup]);
              [THETA,r] = cart2pol(x,y);
              r=(r./(SUP/2))*pi;
              %r(r<0.5)=0; % uncomment to put a dot at the centre.              
              %r(r>(pi+0.01))=nan; %inf; % uncomment if you want to get exact circle

              f=sin(r*sigma);         % 1st concentric filter
              f1=sin(THETA*spokes);   % 1st radial filter
              f1=f1>=0;               % binarize
              f11=f.*f1;              % point-wise multiply
              f=sin(r*sigma+pi);      % 2nd concentric filter shifted by pi
              f1=sin(THETA*spokes+pi);% 2nd radial filter shifted by pi
              f1=f1>=0;               % binarize
              f12 = f.*f1;            % point-wise multiply
              f=(f11+f12)>=0;         % add the two filters and threshold
              f_inv=(f11+f12)<=0;     % add the two filters and threshold               
              FB = f*255;              
            end
            FBPointer = Screen('MakeTexture', window, FB);
              
          %----- Run Loop -----%
          for st = 1:NStim       
            d = StimList(st,1);
            s = StimList(st,2);            
            startPhase = 0;
            time = 0;
            freq = (2 * pi)/vparams.StimTime;                                        
            
            %----- Draw Array -----%
            for i = 1:numDots        
              theRect = [0 0 0 0];
              NewRect = CenterRectOnPointd(theRect, (screenXpixels/2)+dotPositionMatrix(1,i),(screenYpixels/2)-dotPositionMatrix(2,i));     
              Screen('DrawTextures', window, FBPointer,[],NewRect) 
            end
            vbl = Screen('Flip', window); 
            
              %---  Log In  ---%
              StimLog.Stim(i).Position = dotPositionMatrix(1:2,d);
              StimLog.Stim(i).Size = s;              
              StimLog.Stim(i).StartSweep = GetSecs - StimLog.BeginTime; % Start of sweep 
              TTLfunction(startbit,recbit);
              WaitSecs(vparams.PreTime);
            
            
            %----- Manipulate Array -----%
            phase = 100 * freq * time + startPhase;
            
              %---  Log In  ---%
              StimLog.Stim(i).TimeON = GetSecs - StimLog.BeginTime;
              TTLfunction(startbit,recbit); 
              
            while round(phase) ~= 314                                 
              theRect = [0 0 (s * sin(freq * time + startPhase)) (s * sin(freq * time + startPhase))];
              NewRect = CenterRectOnPointd(theRect, (screenXpixels/2)+dotPositionMatrix(1,d),(screenYpixels/2)-dotPositionMatrix(2,d));     
              Screen('DrawTextures', window, FBPointer,[],NewRect) 
              vbl = Screen('Flip', window); 
              time = time + sparams.ifi;
              phase = 100 * freq * time + startPhase;                                                
            end
            
            %----- Put Original Array Back -----%
            for i = 1:numDots        
              theRect = [0 0 0 0];
              NewRect = CenterRectOnPointd(theRect, (screenXpixels/2)+dotPositionMatrix(1,i),(screenYpixels/2)-dotPositionMatrix(2,i));     
              Screen('DrawTextures', window, FBPointer,[],NewRect) 
            end
            vbl = Screen('Flip', window); 
            
              %--- Log In ---%
              StimLog.Stim(i).TimeOFF = GetSecs - StimLog.BeginTime;
              TTLfunction(startbit,recbit);
              WaitSecs(vparams.PostTime);
              StimLog.Stim(i).EndSweep = GetSecs - StimLog.BeginTime;
              TTLfunction(startbit,recbit);
          end

  case 'Dots'
    
  otherwise
 end
 
 
%--------------- Clean up and Finish ---------------%
Screen('FillRect', window, BgColour)
vbl = Screen('Flip', window);
WaitSecs(vparams.BlankTime);
StimLog.EndTime = vbl;
 
 
 
    



