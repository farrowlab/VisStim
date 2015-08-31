pathstr_old = [];
scrOff = [];
      
% init screen 
[w, screenRect] = Screen(0,'OpenWindow',[],[],32); % get screen size
Screen(w,'DrawText','Initialisation ', 25, 25, txtcolor);
scrOffline = Screen(w, 'OpenOffscreenWindow',bgcolor, screenRect);
scrBg = Screen(w, 'OpenOffscreenWindow',bgcolor, screenRect);
srcRect = zeros(1,4);
destRect = zeros(1,4);

% load bullseye
imageArray = imread('bullseye.bmp');
scrBullseye  = Screen(w, 'OpenOffscreenWindow',0, screenRect);
Screen(scrBullseye,'PutImage',imageArray,screenRect);
HideCursor();
