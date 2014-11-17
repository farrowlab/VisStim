function BullsEye(ONOFF,win,sparams,vparams)
% ___________________________________________________________________
%
% Display a bullseye bitmap Screen('DrawTexture') command.
% This can turn the bitmap on or off and reports state.

% Optional Parameters:
% 'angle' = Shall the rectangular image patch be rotated
% (default), or the grating within the rectangular patch?
% patchsize = Size of 2D grating patch in pixels.


% History:
% 20140121 kf  Written.
% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% Initial stimulus parameters for the Bulls Eye:
close all;
clear all;
sca

%Call default settings
PsychDefaultSetup(2);

%Select screen
screenid = max(Screen('Screens'));
% Define white, black and grey
white=WhiteIndex(screenid);
black=BlackIndex(screenid);
grey=white/2;
inc=white-grey;

% Open a fullscreen onscreen window on that display, choose a background
% color of 128 = gray, i.e. 50% max intensity:
[win,windowRect] = PsychImaging('OpenWindow', screenid, grey);

%Get size of screen window
[screenXpixels, screenYpixels]=Screen('WindowSize', win);

%Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', win);

% Determine the refresh rate of our screen. inter frame interval= 1/hertz
hertz=FrameRate(win);


%Load Image
BullsEyeImage = imread ('/home/farrowlab/Visual Stimuli/images/bullseye.bmp');

% Get picture size
[s1, s2, s3]=size(BullsEyeImage);

%Make image into texture
imageTexture= Screen('MakeTexture', win, BullsEyeImage);
%Available keys to press
escapeKey=KbName('Escape');
upKey=KbName('UpArrow');
downKey=KbName('DownArrow');
leftKey=KbName('LeftArrow');
rightKey=KbName('RightArrow');

%Get the centre coordinate of the window
[xCenter, yCenter]=RectCenter(windowRect)

%Set the initial position of the image
imageX=xCenter;
imageY=yCenter;

% Set amount of image movement
pixelsPerPress=10;

% Wait for release of all keys on keyboard, then sync us to retrace:
%KbPressWait;
vbl = Screen('Flip', win);
waitframes=1;

%Maximum priority level
topPriorityLevel=MaxPriority(win);
Priority(topPriorityLevel);

%cue to exit
exitDemo=false;

% cue to exit
while exitDemo == false

% Check keyboard
[keyIsDown,secs, keyCode]=KbCheck;

%Move the position of image or exit demo
if keyCode(escapeKey)

   
    %---------- Draw BullsEye ----------%    
        %Draw bullseye, centered on the screen
        Screen('DrawTexture', win, imageTexture, [], [], 0);
   
    % Show it at next retrace:
    vbl = Screen('Flip', win, vbl + 0.5 * ifi);
WaitSecs(5);
%KbReleaseWait;
%Now fill the creen grey
Screen('FillRect',win,grey);
% Flip to screen
Screen('Flip',win);


% Goodbye
return;