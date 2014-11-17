function ShowGeneralNoise(window, vparams, sparams); 

%---------- Stuff to Get Rid of ----------%
GreyLevel = 128;
	screenid = max(Screen('Screens')); % Choose screen with maximum id - secondary display on a dual-display.
	[window,rect] = Screen('OpenWindow', screenid, GreyLevel);
	[sparams.screenWidth, sparams.screenHeight]=Screen('WindowSize', screenid);	

%---------- Parameters ----------%
DIM = [256 256];
Beta = -2;
NFrames = 1000;

%---------- Make & Show Texture ----------%
n = 0;
while n < NFrames

  n = n + 1;
  noiseimg = 128 + (1000 * spatialPattern(DIM,Beta));
  tex=Screen('MakeTexture', window, noiseimg,[],[],0);
  Screen('DrawTexture', window, tex, [], [], [], 0);
  Screen(window, 'Flip');
  Screen('Close', tex);
end