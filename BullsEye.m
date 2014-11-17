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
%Changed by s on 9/10/2014
% Initial stimulus parameters for the Bulls Eye:


% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', win);

% Get and write Bullseye image to texture
BullsEyeImage = imread ('/home/farrowlab/Visual Stimuli/images/bullseye.bmp');
%Make image into texture
imageTexture= Screen('MakeTexture', win, BullsEyeImage);

%Available keys to press
%KbName('UnifyKeyNames')
%escapeKey=KbName('Escape');
%upKey=KbName('UpArrow');
%downKey=KbName('DownArrow');
%leftKey=KbName('a');
%rightKey=KbName('RightArrow');

%Image center values
sx=imageX=400;
sy=imageY=300;

% Get size of the screen window
[screenXpixels, screenYpixels]=Screen('WindowSize', win);

% Set amount of image movement
pixelsPerPress=10;

%Set initial position of the mouse
SetMouse(imageX,imageY,win);

%Offset between the mouse and centre
offsetSet=0;

% Wait for release of all keys on keyboard, then sync us to retrace:
KbReleaseWait;
vbl = Screen('Flip', win);
waitframes=1;

%Maximum priority level
topPriorityLevel=MaxPriority(win);
Priority(topPriorityLevel);


    %---------- Get Parameters ----------%
    if nargin < 4
        Size = 200
      X = 400;
      Y = 300;
    else
      Size = vparams.Size;
      X = sparams.screenWidth/2 - Size/2;
      Y = sparams.screenHeight/2 - Size/2;      
    end        
    
    %---------- Draw BullsEye ----------%    
    if ONOFF == 1 
    % Draw bullseye, centered on the screen, with given rotation 'angle',
        	Screen('DrawTexture', win, imageTexture, [], [], 0);
    else
        	%Screen('DrawTexture', win, TextureIndex, [], [0 0 250 250], [], [], [], [], [], [], []);
    end
    % Show it at next retrace:
    vbl = Screen('Flip', win, vbl + 0.5 * ifi);

end

return;
