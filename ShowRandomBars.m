function StimLog = ShowRandomBars(window,vparams,sparams);
	
%---------- Initiate ---------%
StimLog = [];
bWidth = round(vparams.Size * sparams.pixel2deg);    % Define Bar width in pixels.
nAngles = vparams.nAngles;
angles = round(0:180/(nAngles):179);
rangles =  (angles .* pi)./180;
NP = round(sqrt(2*1920^2)); %for i = 1:nAngles; if rangles(i) ~= pi/2; NP(i) = 1920/cos(rangles(i)); else; NP(i) = 1920/sin(rangles(i)); endend
Nbars = floor(NP/(bWidth/2));
srect = Screen('MakeTexture',window,vparams.StimColour);
 
%----------- Set Stimulus Sequence ----------%
rect = [-NP/2 -bWidth/2 NP/2 bWidth/2];
StimRect = zeros(5,Nbars);              
StimRect(1,:) = rect(1):bWidth/2:rect(3);  
StimRect(2,:) = rect(2);
StimRect(3,:) = rect(3):bWidth/2:rect(3)+NP;
StimRect(4,:) = rect(2);   
StimRect = repmat(StimRect,[1,nAngles]);              
for i = 1:nAngles  
  index = (1:Nbars) + ((i - 1) * Nbars)
  StimRect(5,index) = angles(i);
end
NStim = size(StimRect,2);
StimOrder = randperm(NStim);
StimRect = StimRect(:,StimOrder);    
  
%--------- Initiate Screen ---------%
Screen('FillRect', window, vparams.Background)
ifi = Screen('GetFlipInterval', window);
vbl = Screen('Flip', window);
    
%---------- Loop to Present Spots ----------%
for i = 1:NStim
                              
	%----- Draw Bar -----%  
  Screen('DrawTexture',window,srect,[],StimRect(1:4,i),StimRect(5,i));  
  vbl = Screen('Flip', window, vbl + 0.5 * ifi);
	
  
  WaitSecs(vparams.StimTime); 
	vbl = Screen('Flip', window, vbl + 0.5 * ifi);       

  
  WaitSecs(vparams.InterStimTime); 
 
  
end
	