close all;
clear all;
sca;

%Default setup
PsychDefaultSetup(2);

% Get screen number
screens=Screen('Screens');
screenNumber=max(screens);

%Define black, grey,white
black=BlackIndex(screenNumber);
white=WhiteIndex(screenNumber);
grey=white/2;

%Open screen and color it
[window, windowRect]=PsychImaging('OpenWindow',screenNumber,grey);

% Get the size of the screen in pixels
[screenXpixels, screenYpixels]= Screen('WindowSize', window);

%Get the centre coordinate of the window
[xCenter, yCenter]=RectCenter(windowRect)

%Set the initial position of the image
imageX=xCenter;
imageY=yCenter;
%Get interframe interval
ifi=Screen('GetFlipInterval',window);

% Get priority number
topPriorityLevel=MaxPriority(window);

% Time length for each draw
numSecs=100;
numFrames=round(numSecs/ifi);

% Sine wave function
amplitude= 360;
frequency=0.25; %
angFreq=2*pi*frequency;
startPhase=0
time=0;
%Number of frames to wait
waitframes=1;

 %Specify times
Priority(topPriorityLevel);
vbl=Screen('Flip',window);

for frame=1:numFrames/4

% Define position on screen
Pos=amplitude*sin(angFreq*time+startPhase); 
  %Color screen grey with black dot
Screen('FillRect',window,[0.5 0.5 0.5]);
Screen('DrawDots',window,[imageX+Pos; imageY],22,[1 1 1],[0 0],2)
% %Flip to screen
 vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
 % Time increment
 time=time+ifi;
 end
 for frame=numFrames/4:numFrames/2

% Define position on screen
Pos=amplitude*sin(angFreq*time+startPhase); 
  %Color screen grey with black dot
Screen('FillRect',window,[0.5 0.5 0.5]);
Screen('DrawDots',window,[imageX-Pos; imageY+Pos],22,[1 1 1],[0 0],2)
% %Flip to screen
 vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
 % Time increment
 time=time+ifi;
 end
  for frame=numFrames/2:3*(numFrames/4)

% Define position on screen
Pos=amplitude*sin(angFreq*time+startPhase); 
  %Color screen grey with black dot
Screen('FillRect',window,[0.5 0.5 0.5]);
Screen('DrawDots',window,[imageX; imageY+Pos],22,[1 1 1],[0 0],2)
% %Flip to screen
 vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
 % Time increment
 time=time+ifi;
 end
 for frame=3*(numFrames/4):numFrames

% Define position on screen
Pos=amplitude*sin(angFreq*time+startPhase); 
  %Color screen grey with black dot
Screen('FillRect',window,[0.5 0.5 0.5]);
Screen('DrawDots',window,[imageX+Pos; imageY+Pos],22,[1 1 1],[0 0],2)
% %Flip to screen
 vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
 % Time increment
 time=time+ifi;
 end
 %for frame=numFrames/2:numFrames
 % Define position on screen
Pos=amplitude*sin(angFreq*time+startPhase); 
 %Color screen grey with white dot
%Screen('FillRect',window,[0.5 0.5 0.5]);
%Screen('DrawDots',window,[imageX; imageY+Pos],22,[1 1 1],[0 0],2)
 %Flip to screen
%vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
 % Time increment
% time=time+ifi;
%end

%end

 Priority(0)
  %Wait for a keyboard button to end
%KbStrokeWait;
% Clear screen
sca;