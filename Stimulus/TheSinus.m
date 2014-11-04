clear all
close all
clear Screen

% Get the display screen number 
screenNumbers=Screen('Screens');
if length(screenNumbers) <= 1
error('Only one the main screen detected')
end
DisplayScreen = screenNumbers(2);

% get resolution used by the display screen
ResolutionDisplayScreen=Screen('Resolution', DisplayScreen);
height = ResolutionDisplayScreen.width;
width = ResolutionDisplayScreen.height;


%-----------------------------------------------------------
%-----------------------Parameters--------------------------

PreStimTime = 1; % Baseline duration before stimulus in seconds
PostStimTime = 1; % Baseline duration after stimulus in seconds
BaselinePixVal = 150; 

% Stimulus
StimTime = 4; % Duration of the stimulus in seconds
MaxPixVal = 200; % AmplitudeMax of the sinusoide
MinPixVal = 100; % AmplitudeMin 
T = 0.5; % Period of the sinusoide in seconds
%T0 = 0; % Phase of the sinusoide at stimulus onset [0 T]


%------------------------------------------------------------
%----------------------Initialisation------------------------

Window1 = Screen(DisplayScreen,'OpenWindow');

TextureBaseline = Screen(Window1, 'MakeTexture', BaselinePixVal*ones(width,height));

% Sinus function. Pixel value for each time point
PixVal = @(t) 0.5*(MaxPixVal + MinPixVal) + (MaxPixVal-MinPixVal)*sin(2*pi/T*t)); % add a brackets (t+T0) for considering the phase

t=0:1/60:StimTime; % time vector

%Loading texture sinus
nbTxt = T*60; % Number of different texture
TextureSinus = nan(nbTxt,1);
for i=1:nbTxt
TextureSinus(i) = Screen(Window1, 'MakeTexture', PixVal(t(i))*ones(width,height));
end


%------------------------------------------------------------
%------------------------Presentation------------------------

% PreStim
Screen('DrawTexture', Window1, TextureBaseline);
Screen(Window1,'Flip');
WaitSecs(PreStimTime);

% Stimulus
%tic()
for i=1:length(t)
IdxTxt = mod(i,nbTxt);
  if IdxTxt == 0
  Screen('DrawTexture', Window1, TextureSinus(nbTxt));
  else  
  Screen('DrawTexture', Window1, TextureSinus(IdxTxt));
  end
Screen(Window1,'Flip');
end
%a=toc()

% PostStim
Screen('DrawTexture', Window1, TextureBaseline);
Screen(Window1,'Flip');
WaitSecs(PostStimTime);