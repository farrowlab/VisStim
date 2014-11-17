function DSS(angle, cyclespersecond, freq, gratingsize, internalRotation)
%function DSS([angle=0][, cyclespersecond=1][, freq=1/360][, gratingsize=360][, internalRotation=0])
% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% Initial stimulus parameters for the grating patch:

if nargin < 5 || isempty(internalRotation)
    internalRotation = 0;
end

if internalRotation
    rotateMode = kPsychUseTextureMatrixForRotation;
else
    rotateMode = [];
end

if nargin < 4 || isempty(gratingsize)
    gratingsize = 360;
end

% res is the total size of the patch in x- and y- direction, i.e., the
% width and height of the mathematical support:
res = [gratingsize gratingsize];

if nargin < 3 || isempty(freq)
    % Frequency of the grating in cycles per pixel: Here 0.01 cycles per pixel:
    freq = 1/360;
end

if nargin < 2 || isempty(cyclespersecond)
    cyclespersecond = 1;
end

if nargin < 1 || isempty(angle)
    % Tilt angle of the grating:
    angle = 0;
end

% Amplitude of the grating in units of absolute display intensity range: A
% setting of 0.5 means that the grating will extend over a range from -0.5
% up to 0.5, i.e., it will cover a total range of 1.0 == 100% of the total
% displayable range. As we select a background color and offset for the
% grating of 0.5 (== 50% nominal intensity == a nice neutral gray), this
% will extend the sinewaves values from 0 = total black in the minima of
% the sine wave up to 1 = maximum white in the maxima. Amplitudes of more
% than 0.5 don't make sense, as parts of the grating would lie outside the
% displayable range for your computers displays:
amplitude = 0.5;

% Choose screen with maximum id - the secondary display on a dual-display
% setup for display:
screenid = max(Screen('Screens'));

% Open a fullscreen onscreen window on that display, choose a background
% color of 128 = gray, i.e. 50% max intensity:
win = Screen('OpenWindow', screenid, 128);

% Make sure the GLSL shading language is supported:
AssertGLSL;

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', win);

% Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
phase = 0;

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;

% Build a procedural sine grating texture for a grating with a support of
% res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
gratingtex = CreateProceduralSineGrating(win, res(1), res(2), [0.5 0.5 0.5 0.0],[11]);

% Wait for release of all keys on keyboard, then sync us to retrace:
KbReleaseWait;
vbl = Screen('Flip', win);

% Animation loop: Repeats until keypress...
while ~KbCheck
    % Update some grating animation parameters:
    
    % Increment phase by 1 degree:
    phase = phase + phaseincrement;
    
    % Draw the grating, centered on the screen, with given rotation 'angle',
    % sine grating 'phase' shift and amplitude, rotating via set
    % 'rotateMode'. Note that we pad the last argument with a 4th
    % component, which is 0. This is required, as this argument must be a
    % vector with a number of components that is an integral multiple of 4,
    % i.e. in our case it must have 4 components:
    Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);

    % Show it at next retrace:
    vbl = Screen('Flip', win, vbl + 0.5 * ifi);
end

% We're done. Close the window. This will also release all other ressources:
Screen('CloseAll');

% Bye bye!
return;
% Get screen number
%screens=Screen('Screens');
%screenNumber=max(screens);

%Define black, grey,white
%black=BlackIndex(screenNumber);
%white=WhiteIndex(screenNumber);
%grey=white/2;

%Open screen and color it
%[window, windowRect]=Screen('OpenWindow',screenNumber,grey);

% Make sure the GLSL shading language is supported:
%AssertGLSL;

% Get the size of the screen in pixels
%[screenXpixels, screenYpixels]= Screen('WindowSize', window);

%Get the centre coordinate of the window
%[xCenter, yCenter]=RectCenter(windowRect)

%Set the initial position of the image
%imageX=xCenter;
%imageY=yCenter;
%Get interframe interval
%ifi=Screen('GetFlipInterval',window);

% Get priority number
%topPriorityLevel=MaxPriority(window);

% Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
%phase = 0;

% Cycles per second
%cyclespersecond = 1;
 
% Tilt angle of the grating:
% angle = 0;
 
 % Compute increment of phase shift per redraw:
%phaseincrement = (cyclespersecond * 360) * ifi;
 
% Define resolution in pixels
%res = [360 360];
    
% Build a procedural sine grating texture for a grating with a support of
% res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
%gratingtex = CreateProceduralSineGrating(window, res(1), res(2), [0.5 0.5 0.5 0.0]);



% Time length for each draw
%numSecs=10;
%numFrames=round(numSecs/ifi);

%Number of frames to wait
%waitframes=1;

 %Specify times
%Priority(topPriorityLevel);
%vbl=Screen('Flip',window);
%for frame=1:numFrames
% % Increment phase by 1 degree:
%    phase = phase + phaseincrement;
%  %Color screen grey with black dot
%Screen('FillRect',window,[0.5 0.5 0.5]);
%Screen('DrawTexture', window, gratingtex);
%Screen('DrawDots',window,[imageX; imageY],22,[0 0 0],[0 0],2)
 %Flip to screen
% vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
 %end


 %Priority(0)
  %Wait for a keyboard button to end
%KbStrokeWait;
% Clear screen
%sca;
