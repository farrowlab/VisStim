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
StimTime = 7; % Duration of the stimulus in seconds
t0MaxPixVal = 160; % Amplitude max of the sinusoide at stimulus onset
t0MinPixVal = 140; % Amplitude min of the sinusoide at stimulus onset
EndMaxPixVal = 250; % Amplitude max of the sinusoide at the end stimulus
EndMinPixVal = 20; % Amplitude min of the sinusoide at the end stimulus
T = 0.5; % Period of the sinusoide in seconds
%T0 = 0; % Phase of the sinusoide at stimulus onset [0 T]


%------------------------------------------------------------
%----------------------Initialisation------------------------

Window1 = Screen(DisplayScreen,'OpenWindow');

TextureBaseline = Screen(Window1, 'MakeTexture', BaselinePixVal*ones(width,height));

% Amplitude function (linear)
MaxPixVal = @(t) (EndMaxPixVal-t0MaxPixVal)/StimTime*t + t0MaxPixVal % Amplitude Max of the sinusoide at t
MinPixVal = @(t) (EndMinPixVal-t0MinPixVal)/StimTime*t + t0MinPixVal % AmplitudeMin of the sinusoide at t

% Sinus function. Pixel value for each time point
PixVal = @(t) 0.5*(MaxPixVal(t) + MinPixVal(t) + (MaxPixVal(t)-MinPixVal(t))*sin(2*pi/T*t));

t=0:1/60:StimTime; % time vector

% Load texture
TextureSinus = nan(length(i),1);
for i=1:length(t)
TextureSinus(i) = Screen(Window1, 'MakeTexture', PixVal(t(i))*ones(width,height));
end


%------------------------------------------------------------
%---------------------Begin presentation---------------------

% Baseline
Screen('DrawTexture', Window1, TextureBaseline);
Screen(Window1,'Flip');
WaitSecs(PreStimTime)

% Sinus
for i=1:length(t)
%TextureSinus = Screen(Window1, 'MakeTexture', PixVal(t(i))*ones(width,height));
Screen('DrawTexture', Window1, TextureSinus(i));
Screen(Window1,'Flip')
end

% PostStim
Screen('DrawTexture', Window1, TextureBaseline);
Screen(Window1,'Flip');
WaitSecs(PostStimTime);