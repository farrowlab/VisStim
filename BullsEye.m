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

% Initial stimulus parameters for the Bulls Eye:


% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', win);

% Get and write Bullseye image to texture
BullsEyeImage = imread ('/home/farrowlab/Visual Stimuli/images/bullseye.bmp');
TextureIndex = Screen('MakeTexture', win, BullsEyeImage, 0, 0, 0, 0, 0);

% Wait for release of all keys on keyboard, then sync us to retrace:
KbReleaseWait;
vbl = Screen('Flip', win);

    %---------- Get Parameters ----------%
    if nargin < 4
      Size = 500
      X = 0;
      Y = 0;
    else
      Size = vparams.Size;
      X = sparams.screenWidth/2 - Size/2;
      Y = sparams.screenHeight/2 - Size/2;      
    end        
    
    %---------- Draw BullsEye ----------%    
    if ONOFF == 1 
    % Draw bullseye, centered on the screen, with given rotation 'angle',
        	Screen('DrawTexture', win, TextureIndex, [0 0 128 128], [X Y Size Size], [], [], [], [], [], [], []);
    else
        	%Screen('DrawTexture', win, TextureIndex, [], [0 0 250 250], [], [], [], [], [], [], []);
    end
    % Show it at next retrace:
    vbl = Screen('Flip', win, vbl + 0.5 * ifi);



return;
