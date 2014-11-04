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

% Retrieve pixel values
%white = WhiteIndex(Window1); % pixel value for white
%black = BlackIndex(Window1); % pixel value for black
%gray = (white+black)/2;


%-----------------------------------------------------------
%-----------------------Parameters--------------------------

PreStimTime = 1; % Baseline duration before stimulus in seconds
PostStimTime = 1; % Baseline duration after stimulus in seconds
BaselinePixVal = 150; 

StimTime = 2; % Duration of the stimulus in seconds
PixValFlash = 250;


%------------------------------------------------------------
%----------------------Initialisation------------------------

Window1 = Screen(DisplayScreen,'OpenWindow');
%DispScreenFrameRate=Screen('NominalFrameRate', Window1);

TextureBaseline = Screen(Window1, 'MakeTexture', BaselinePixVal*ones(width,height));
TextureFlash = Screen(Window1, 'MakeTexture', PixValFlash*ones(width,height));


%------------------------------------------------------------
%-----------------------Presentation-------------------------

% PreStim
Screen('DrawTexture', Window1, TextureBaseline);
Screen(Window1,'Flip')
WaitSecs(PreStimTime);

% Stimulus
Screen('DrawTexture', Window1, TextureFlash);
Screen(Window1,'Flip');
WaitSecs(StimTime);

% PostStim
Screen('DrawTexture', Window1, TextureBaseline);
Screen(Window1,'Flip');
WaitSecs(PostStimTime);


