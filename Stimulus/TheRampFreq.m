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
StimTime = 10; % Duration of the stimulus in seconds
MaxPixVal = 200; % AmplitudeMax of the sinusoide
MinPixVal = 100; % AmplitudeMin 

% Frequency (linear)
f0 = 0.1; % Frequency (Hz) at t=0
td = 2; % Time (s) after the frequency is doubled


%------------------------------------------------------------
%----------------------Initialisation------------------------

Window1 = Screen(DisplayScreen,'OpenWindow');

TextureBaseline = Screen(Window1, 'MakeTexture', BaselinePixVal*ones(width,height));

% Frequency function (linear)
FreqSinus = @(t) f0/td*t+f0; 

% Frequency function (exponential)
%FreqSinus = @(t) f0*exp(log10(2)/td*t;

% Sinus function. Pixel value for each time point
PixVal = @(t) 0.5*(MaxPixVal + MinPixVal + (MaxPixVal-MinPixVal)*sin(2*pi*FreqSinus(t).*t));  

t=0:1/60:StimTime; % time vector

% Load texture
TextureSinus = nan(length(t),1);
for i=1:length(t)
TextureSinus(i) = Screen(Window1, 'MakeTexture', PixVal(t(i))*ones(width,height));
end


%------------------------------------------------------------
%---------------------Begin presentation---------------------

% Baseline
Screen('DrawTexture', Window1, TextureBaseline);
Screen(Window1,'Flip');
WaitSecs(PreStimTime);

% Sinus
%tic()
for i=1:length(t)
Screen('DrawTexture', Window1, TextureSinus(i));
Screen(Window1,'Flip');
end
%a=toc()

% PostStim
Screen('DrawTexture', Window1, TextureBaseline);
Screen(Window1,'Flip');
WaitSecs(PostStimTime);