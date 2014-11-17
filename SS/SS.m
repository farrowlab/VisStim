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
numSecs=4;
numFrames=round(numSecs/ifi);

%Number of frames to wait
waitframes=1;

 %Specify times
Priority(topPriorityLevel);
vbl=Screen('Flip',window);
for frame=1:25
for frame=1:numFrames/2
 
  %Color screen grey with black dot
Screen('FillRect',window,[0.5 0.5 0.5]);
Screen('DrawDots',window,[imageX; imageY],22,[0 0 0],[0 0],2)
% %Flip to screen
 vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
 end
 for frame=numFrames/2:numFrames
 %Color screen grey with white dot
Screen('FillRect',window,[0.5 0.5 0.5]);
Screen('DrawDots',window,[imageX; imageY],22,[1 1 1],[0 0],2)
 %Flip to screen
 vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
 end

 end

 Priority(0)
  %Wait for a keyboard button to end
%KbStrokeWait;
% Clear screen
sca;
