function StimLog = ShowWhiteCheckerBoard(window, vparams, sparams); 
% (validate, filtertype, rectSize, kwidth, scale, syncToVBL, dontclear)
% FastFilteredNoiseDemo([validate=1][, filtertype=1][, rectSize=128][, kwidth=5][, scale=1][, syncToVBL=1][, dontclear=0])
%--------------- Collect Parameters ---------------%
StimLog = [];
  %---------- Screen ----------%
  win = window;
  winRect = sparams.rect;
  screenid = sparams.screenid;  
  syncToVBL = sparams.syncToVBL;
  dontclear = sparams.dontclear;
  if syncToVBL > 0
    asyncflag = 0;
  else
    asyncflag = 2;
  end
  
  %--------- Stimulus ---------%  
  numRects = vparams.numRects;
  dontclear = sparams.dontclear;
  NFrames = vparams.NFrames;
  validate = vparams.validate;
  filtertype = vparams.filtertype; 
  rectSize = vparams.rectSize; 
  kwidth = vparams.kwidth;   
  Background = vparams.BgColour(1);
  Contrast = vparams.StimContrast;
  totalsize = sparams.pixel2deg*vparams.Size;  
  scale = totalsize/rectSize; 
  delay = vparams.FrameDuration - sparams.ifi;

  %---------- Assign default values for unspecified parameters ----------%
  if nargin < 3
    fdisp(stdout,'Not Enough Inputs!');
    return
  end

%--------------- Make and Display Stimulus -------------%

    %--------- Initialize ----------%
    
      %----- Initialize OpenGL -----%
      InitializeMatlabOpenGL([], [], 1);
    
      %----- Build Filter Kernal -----%
      stddev = kwidth / 2;            
      kernel = fspecial('gaussian', kwidth, stddev);         
      stype = 2;
      channels = 1;

        if filtertype > 0
          % Build shader from kernel:
          convoperator = CreateGLOperator(win, kPsychNeed32BPCFloat);
          if filtertype~=5
              Add2DConvolutionToGLOperator(convoperator, kernel, [], channels, 1, 4, stype);
          else
              Add2DSeparableConvolutionToGLOperator(convoperator, kernel1, kernel2, [], channels, 1, 4, stype);
          end
          %        Add2DConvolutionToGLOperator(convoperator, kernel, [], channels, 1, 4, stype);
        end
        glFinish;
    
      %----- Compute, Arrange and Scale Rectangle locations -----%      
      objRect = SetRect(0,0, rectSize, rectSize);                 % 'objRect' is a rectangle of the size 'rectSize' by 'rectSize' pixels of our Matlab noise image matrix:
      dstRect = ArrangeRects(numRects, objRect, winRect);         % ArrangeRects creates 'numRects' copies of 'objRect', all nicely arranged / distributed in our window of size 'winRect':    
      for i=1:numRects                                            % Now we rescale all rects: They are scaled in size by a factor 'scale':          
        [xc, yc] = RectCenter(dstRect(i,:));                      % Compute center position [xc,yc] of the i'th rectangle:
        dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);  % Create a new rectange, centered at the same position, but 'scale' times the size of our pixel noise matrix 'objRect':
    end
      
      %----- Init framecounter to zero and take initial timestamp -----%
      count = 0; 
      glFinish;
      tstart = GetSecs;
      endtime = tstart + 5;
      xtex = 0;
    
    %---------- Run Noise Loop ----------%
    Screen('FillRect', window, Background)
    WaitSecs(vparams.PreTime); 	
    while count < NFrames
      WaitSecs(delay); 
      if count == 0
        Screen('FillRect', window, Background);
        Screen('Flip', win, 0, dontclear, asyncflag);
        WaitSecs(vparams.PreTime); delay	
      end
        % Increase our frame counter:
        count = count + 1;

        % Generate and draw 'numRects' noise images:
        for i=1:numRects
            % Compute noiseimg noise image matrix with Matlab:
            % Normally distributed noise with mean 128 and stddev. 50, each
            % pixel computed independently:
            noiseimg=(Contrast*randn(rectSize, rectSize) + Background);
            nZ = find(noiseimg < 1); noiseimg(nZ) = 0;
            nS = find(noiseimg > 255); noiseimg(nS) = 255;                        
            noiseimg=uint8(noiseimg); noiseimg=double(noiseimg);            
            assignin('base','noiseimg',noiseimg  );
            % Convert it to a texture 'tex':
            tex=Screen('MakeTexture', win, noiseimg,[],[],0);
            
            % Draw the texture into the screen location defined by the
            % destination rectangle 'dstRect(i,:)'. If dstRect is bigger
            % than our noise image 'noiseimg', PTB will automatically
            % up-scale the noise image. We set the 'filterMode' flag for
            % drawing of the noise image to zero: This way the bilinear
            % filter gets disabled and replaced by standard nearest
            % neighbour filtering. This is important to preserve the
            % statistical independence of the noise pixels in the noise
            % texture! The default bilinear filtering would introduce local
            % correlations:
%           
            % Apply filter and make texture
            xtex = Screen('TransformTexture', tex, convoperator, [], xtex);
            Screen('DrawTexture', win, xtex, [], dstRect(i,:), [], 0);
            Screen('Close', tex);
        end
        
        % Done with drawing the noise patches to the backbuffer: Initiate
        % buffer-swap. If 'asyncflag' is zero, buffer swap will be
        % synchronized to vertical retrace. If 'asyncflag' is 2, bufferswap
        % will happen immediately -- Only useful for benchmarking!
        Screen('Flip', win, 0, dontclear, asyncflag);  
    end   
    Screen('FillRect', window, Background)
    Screen('Flip', win, 0, dontclear, asyncflag);
    WaitSecs(vparams.PostTime); 	 

    % We're done: Output average framerate:
    glFinish;
    telapsed = GetSecs - tstart;
    updaterate = count / telapsed;
   

