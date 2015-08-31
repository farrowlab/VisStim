function saveStimLog(vparams,sparams,savedir,StimLog,FileName)
cd(savedir)
d = datestr(date,30)
fn = [FileName '_' vparams.Class '_' 'StimLog' vparams.datetime '.mat'];
save('-mat7-binary',fn,'StimLog')
umask(777)    
system(['chmod 777 ',fn]);
cd('/home/farrowlab/VisualStimuli/');
