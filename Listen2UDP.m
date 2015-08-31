stimsize=pnet(udpsock,'readpacket');
if stimsize ~= 0  	      
fdisp(stdout,['Visual Stimulus Received. Size = ' num2str(stimsize)]); 
  udpVisStim = pnet(udpsock,'read'); % command string
  [VStim vparams FileName] = ParseUDPVStim(udpVisStim);     
  vparams.Class = VStim;
  vparams.datetime = datestr(now,30);
  assignin('base','vp',vparams)
  assignin('base','VS',VStim)
else
  VStim = [];
end	  