% Parse udp message about Vstim
function [VStim P] = ParseUDPVStim(udp);

%---------- Get Stimulus ----------%
	
  %----- Unwrap Stimulus Instructions -----%
  % Class:Spot;Type:Single;Size:_100_200_400_;Shape:Spot;Order:Forward;Repeats:1;PreTime:5;PostTime:5;StimTime:2;InterStimTime:5;!!!
	colons = strfind(udp,':');
	sc = strfind(udp,';');
  assignin('base','sc',sc)
  for i = 2:length(sc)-1    
    Parameters{i-1} = udp(sc(i)+1:colons(i+1)-1);    
  end
  assignin('base','Parameters',Parameters);
  
  %---------- Basics ----------%
	Class = udp(colons(1)+1:sc(1)-1);
	Type = udp(colons(2)+1:sc(2)-1);
	
  %---------- Get Stimulus and Parameters ----------%
  switch Class
    %----- BullsEye -----% 
    case 'BullsEye'
      VStim = Type;
      P.Size = str2num(udp(colons(3)+1:sc(3)-1));  
    %----- Spot Stimuli -----%      
    case 'Spot'
      VStim = 'Spot'
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	    S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'Shape'
            S = regexp(udp, ';Shape:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Shape = udp(S:E);
          case 'Order'
            S = regexp(udp, ';Order:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Order = udp(S:E);
          case 'Repeats'
            S = regexp(udp, ';Repeats:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Repeats = str2num(udp(S:E));
          case 'BlankTime'
            % Time to blank display blank stimuli before (and after) stimulus presentation
            % This is independent of PreTime.
            S = regexp(udp, ';BlankTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.BlankTime = str2num(udp(S:E));
          case 'PreTime'
            S = regexp(udp, ';PreTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PreTime = str2num(udp(S:E));
          case 'PostTime'
            S = regexp(udp, ';PostTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PostTime = str2num(udp(S:E));
          case 'StimTime'
            S = regexp(udp, ';StimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimTime = str2num(udp(S:E));          
          case 'InterStimTime'
            S = regexp(udp, ';InterStimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.InterStimTime = str2num(udp(S:E));
          case 'Size'
            S = regexp(udp, ';Size:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;   
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Size = str2num(SS);      
          case 'Angle'
            S = regexp(udp, ';Angle:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;   
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Angle = str2num(SS);       
          case 'StimColour'
            S = regexp(udp, ';StimColour:','end')+1;
            E = sc(find(sc > S,1,'first'))-1; 
            P.StimColour = str2num(udp(S:E));
          case 'BgColour'
            S = regexp(udp, ';BgColour:','end')+1;
            E = sc(find(sc > S,1,'first'))-1; 
            P.Background = str2num(udp(S:E));  
          otherwise
            disp('Program it!!!!');
          end                  
        end
    %----- Noise Stimuli -----%    
    case 'Noise'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter       
          case 'Filename'
	    S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'Scale'
            S = regexp(udp, ';Scale:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Scale = str2num(udp(S:E));
          case 'NumberSquares'
            S = regexp(udp, ';NumberSquares:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.NumberSquares = str2num(udp(S:E));
          case 'FilterWidth'
            S = regexp(udp, ';FilterWidth:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.FilterWidth = str2num(udp(S:E));
          case 'Order'
            S = regexp(udp, ';Order:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Order = udp(S:E); 
          case 'Repeats'
            S = regexp(udp, ';Repeats:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Repeats = str2num(udp(S:E));   
          case 'PreTime'
            S = regexp(udp, ';PreTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PreTime = str2num(udp(S:E));    
          case 'PostTime'
            S = regexp(udp, ';PostTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PostTime = str2num(udp(S:E));     
          case 'StimTime'
            S = regexp(udp, ';StimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimTime = str2num(udp(S:E));  
          case 'FrameRate'
            S = regexp(udp, ';FrameRate:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.FrameRate = str2num(udp(S:E));   
          case 'StimContrast'
            S = regexp(udp, ';StimContrast:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimContrast = str2num(udp(S:E));  
          case 'BgColour'
            S = regexp(udp, ';BgColour:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.BgColour = str2num(udp(S:E));                                    
          otherwise
        end
      end
      
      %----- Grating Stimuli -----%    
    case 'Grating'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter 
          case 'Filename'
	    S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'Size'
            S = regexp(udp, ';Size:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Size = str2num(SS); 
          case 'Shape'
            S = regexp(udp, ';Shape:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Shape = udp(S:E);
          case 'Angle'
            S = regexp(udp, ';Angle:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;   
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Angle = str2num(SS);
          case 'TemporalFreq'
            S = regexp(udp, ';TemporalFreq:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.TemporalFreq = str2num(udp(S:E));
          case 'Order'
            S = regexp(udp, ';Order:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Order = udp(S:E); 
          case 'Repeats'
            S = regexp(udp, ';Repeats:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Repeats = str2num(udp(S:E));   
          case 'BlankTime'
            % Time to blank display blank stimuli before (and after) stimulus presentation
            % This is independent of PreTime.
            S = regexp(udp, ';BlankTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.BlankTime = str2num(udp(S:E));    
          case 'PreTime'
            S = regexp(udp, ';PreTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PreTime = str2num(udp(S:E));    
          case 'PostTime'
            S = regexp(udp, ';PostTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PostTime = str2num(udp(S:E));     
          case 'StimTime'
            S = regexp(udp, ';StimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimTime = str2num(udp(S:E)); 
          case 'InterStimTime'
            S = regexp(udp, ';InterStimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.InterStimTime = str2num(udp(S:E)); 
          case 'FrameRate'
            S = regexp(udp, ';FrameRate:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.FrameRate = str2num(udp(S:E));   
          case 'StimContrast'
            S = regexp(udp, ';StimContrast:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimContrast = str2num(udp(S:E));  
          case 'BgColour'
            S = regexp(udp, ';BgColour:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.BgColour = str2num(udp(S:E));                                    
          otherwise
        end
      end
      
    %----- FullField Stimuli -----%    
    case 'FullField'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter     
          case 'Filename'
	    S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                      
          case 'Size'
            S = regexp(udp, ';Size:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.TemporalFreq = str2num(SS); 
          case 'Shape'
            S = regexp(udp, ';Shape:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Shape = udp(S:E);
          case 'TemporalFreq'
            S = regexp(udp, ';TemporalFreq:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.TemporalFreq = str2num(udp(S:E));
          case 'Order'
            S = regexp(udp, ';Order:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Order = udp(S:E); 
          case 'Repeats'
            S = regexp(udp, ';Repeats:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Repeats = str2num(udp(S:E));   
          case 'PreTime'
            S = regexp(udp, ';PreTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PreTime = str2num(udp(S:E));    
          case 'PostTime'
            S = regexp(udp, ';PostTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PostTime = str2num(udp(S:E));     
          case 'StimTime'
            S = regexp(udp, ';StimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimTime = str2num(udp(S:E)); 
          case 'InterStimTime'
            S = regexp(udp, ';InterStimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.InterStimTime = str2num(udp(S:E)); 
          case 'FrameRate'
            S = regexp(udp, ';FrameRate:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.FrameRate = str2num(udp(S:E));   
          case 'StimContrast'
            S = regexp(udp, ';StimContrast:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimContrast = str2num(udp(S:E));  
          case 'BgColour'
            S = regexp(udp, ';BgColour:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.BgColour = str2num(udp(S:E));                                    
          otherwise
        end
      end
      
    %----- Moving Bar Stimuli -----%    
    case 'Moving Bar'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	    S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'Size'
            S = regexp(udp, ';Size:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Size = str2num(SS); 
%          case 'Shape'
%            S = regexp(udp, ';Shape:','end')+1;
%            E = sc(find(sc > S,1,'first'))-1;            
%            P.Shape = udp(S:E);
          case 'Angle'
            S = regexp(udp, ';Angle:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;   
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Angle = str2num(SS);
          case 'Speed'
            S = regexp(udp, ';Speed:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Speed = str2num(udp(S:E));
          case 'Order'
            S = regexp(udp, ';Order:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Order = udp(S:E); 
          case 'Repeats'
            S = regexp(udp, ';Repeats:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Repeats = str2num(udp(S:E));   
          case 'BlankTime'
            % Time to blank display blank stimuli before (and after) stimulus presentation
            % This is independent of PreTime.
            S = regexp(udp, ';BlankTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.BlankTime = str2num(udp(S:E));
          case 'PreTime'
            S = regexp(udp, ';PreTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PreTime = str2num(udp(S:E));    
          case 'PostTime'
            S = regexp(udp, ';PostTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PostTime = str2num(udp(S:E));     
          case 'StimTime'
            S = regexp(udp, ';StimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimTime = str2num(udp(S:E)); 
          case 'InterStimTime'
            S = regexp(udp, ';InterStimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.InterStimTime = str2num(udp(S:E)); 
          case 'FrameRate'
            S = regexp(udp, ';FrameRate:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.FrameRate = str2num(udp(S:E));   
          case 'StimColor'
            S = regexp(udp, ';StimColor:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimColor = str2num(udp(S:E));  
          case 'BgColour'
            S = regexp(udp, ';BgColour:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.BgColour = str2num(udp(S:E));                                    
          otherwise
        end
      end  
    
    
    case 'Flashing Bar'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	          S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'Size'
            S = regexp(udp, ';Size:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Size = str2num(SS); 
%          case 'Shape'
%            S = regexp(udp, ';Shape:','end')+1;
%            E = sc(find(sc > S,1,'first'))-1;            
%            P.Shape = udp(S:E);
          case 'Angle'
            S = regexp(udp, ';Angle:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;   
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Angle = str2num(SS);
          case 'Speed'
            S = regexp(udp, ';Speed:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Speed = str2num(udp(S:E));
          case 'Order'
            S = regexp(udp, ';Order:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Order = udp(S:E); 
          case 'Repeats'
            S = regexp(udp, ';Repeats:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Repeats = str2num(udp(S:E));   
          case 'BlankTime'
            % Time to blank display blank stimuli before (and after) stimulus presentation
            % This is independent of PreTime.
            S = regexp(udp, ';BlankTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.BlankTime = str2num(udp(S:E));  
          case 'PreTime'
            S = regexp(udp, ';PreTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PreTime = str2num(udp(S:E));    
          case 'PostTime'
            S = regexp(udp, ';PostTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.PostTime = str2num(udp(S:E));     
          case 'StimTime'
            S = regexp(udp, ';StimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimTime = str2num(udp(S:E)); 
          case 'InterStimTime'
            S = regexp(udp, ';InterStimTime:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.InterStimTime = str2num(udp(S:E)); 
          case 'FrameRate'
            S = regexp(udp, ';FrameRate:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.FrameRate = str2num(udp(S:E));   
          case 'StimColor'
            S = regexp(udp, ';StimColor:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimColor = str2num(udp(S:E));  
          case 'BgColour'
            S = regexp(udp, ';BgColour:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.BgColour = str2num(udp(S:E));                                    
          otherwise
        end
      end  
  
        
    case 'Expanding Circle'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	          S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'StartSize'
            S = regexp(udp, ';StartSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StartSize = str2num(SS);
          case 'StopSize'
            S = regexp(udp, ';StopSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StopSize = str2num(SS);  
          case 'Trial'
            S = regexp(udp, ';Trial:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Trial = str2num(udp(S:E));
          case 'Speed'
            S = regexp(udp, ';Speed:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Speed = str2num(SS);           
          case 'ISI'
            S = regexp(udp, ';ISI:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.ISI = str2num(udp(S:E)); 
          case 'StimLum'
            S = regexp(udp, ';StimLum:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimLum = str2num(udp(S:E));                                      
          case 'Xpos'
            S = regexp(udp, ';Xpos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Xpos = str2num(SS);
          case 'Ypos'
            S = regexp(udp, ';Ypos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Ypos = str2num(SS);
          otherwise
        end
      end
      
    
    case 'Expanding Checkerboard'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	          S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'StartSize'
            S = regexp(udp, ';StartSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StartSize = str2num(SS);
          case 'StopSize'
            S = regexp(udp, ';StopSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StopSize = str2num(SS);  
          case 'Trial'
            S = regexp(udp, ';Trial:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Trial = str2num(udp(S:E));
          case 'Speed'
            S = regexp(udp, ';Speed:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Speed = str2num(SS);           
          case 'ISI'
            S = regexp(udp, ';ISI:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.ISI = str2num(udp(S:E));                                   
          case 'Xpos'
            S = regexp(udp, ';Xpos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Xpos = str2num(SS);
          case 'Ypos'
            S = regexp(udp, ';Ypos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Ypos = str2num(SS);
          otherwise
        end
      end
      
      
    case 'Translating Expanding Circle'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	          S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'StartSize'
            S = regexp(udp, ';StartSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StartSize = str2num(SS);
          case 'StopSize'
            S = regexp(udp, ';StopSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StopSize = str2num(SS);  
          case 'Trial'
            S = regexp(udp, ';Trial:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Trial = str2num(udp(S:E));
          case 'Speed'
            S = regexp(udp, ';Speed:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Speed = str2num(SS);
          case 'Angle'
            S = regexp(udp, ';Angle:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Angle = str2num(SS);           
          case 'ISI'
            S = regexp(udp, ';ISI:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.ISI = str2num(udp(S:E)); 
          case 'StimLum'
            S = regexp(udp, ';StimLum:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimLum = str2num(udp(S:E));                                      
          case 'Xpos'
            S = regexp(udp, ';Xpos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Xpos = str2num(SS);
          case 'Ypos'
            S = regexp(udp, ';Ypos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Ypos = str2num(SS);
          otherwise
        end
      end
    
    
    
    case 'Translating Expanding Checkerboard'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	          S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'StartSize'
            S = regexp(udp, ';StartSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StartSize = str2num(SS);
          case 'StopSize'
            S = regexp(udp, ';StopSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StopSize = str2num(SS);  
          case 'Trial'
            S = regexp(udp, ';Trial:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Trial = str2num(udp(S:E));
          case 'Speed'
            S = regexp(udp, ';Speed:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Speed = str2num(SS);
          case 'Angle'
            S = regexp(udp, ';Angle:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Angle = str2num(SS);           
          case 'ISI'
            S = regexp(udp, ';ISI:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.ISI = str2num(udp(S:E));                                     
          case 'Xpos'
            S = regexp(udp, ';Xpos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Xpos = str2num(SS);
          case 'Ypos'
            S = regexp(udp, ';Ypos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Ypos = str2num(SS);
          otherwise
        end
      end
  
  
    case 'Flashing Grid Square'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	          S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'Size'
            S = regexp(udp, ';Size:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Size = str2num(SS);
          case 'Trial'
            S = regexp(udp, ';Trial:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Trial = str2num(udp(S:E));
          case 'Duration'
            S = regexp(udp, ';Duration:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Duration = str2num(SS);
          case 'ISI'
            S = regexp(udp, ';ISI:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.ISI = str2num(udp(S:E));
          case 'StimLum'
            S = regexp(udp, ';StimLum:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimLum = str2num(udp(S:E));            
          case 'Xpos'
            S = regexp(udp, ';Xpos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Xpos = str2num(SS);
          case 'Ypos'
            S = regexp(udp, ';Ypos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Ypos = str2num(SS);
          otherwise
        end
      end
      
      
    case 'Translating Expanding Circle to Center'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	          S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'StartSize'
            S = regexp(udp, ';StartSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StartSize = str2num(SS);
          case 'StopSize'
            S = regexp(udp, ';StopSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StopSize = str2num(SS);  
          case 'Trial'
            S = regexp(udp, ';Trial:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Trial = str2num(udp(S:E));
          case 'Speed'
            S = regexp(udp, ';Speed:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Speed = str2num(SS);
          case 'Angle'
            S = regexp(udp, ';Angle:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Angle = str2num(SS);           
          case 'ISI'
            S = regexp(udp, ';ISI:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.ISI = str2num(udp(S:E)); 
          case 'StimLum'
            S = regexp(udp, ';StimLum:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimLum = str2num(udp(S:E));                                      
          case 'Xpos'
            S = regexp(udp, ';Xpos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Xpos = str2num(SS);
          case 'Ypos'
            S = regexp(udp, ';Ypos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Ypos = str2num(SS);
          otherwise
        end
      end
      
      
    
    case 'Translating Expanding Circle from Center'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	          S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'StartSize'
            S = regexp(udp, ';StartSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StartSize = str2num(SS);
          case 'StopSize'
            S = regexp(udp, ';StopSize:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.StopSize = str2num(SS);  
          case 'Trial'
            S = regexp(udp, ';Trial:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Trial = str2num(udp(S:E));
          case 'Speed'
            S = regexp(udp, ';Speed:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Speed = str2num(SS);
          case 'Angle'
            S = regexp(udp, ';Angle:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Angle = str2num(SS);           
          case 'ISI'
            S = regexp(udp, ';ISI:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.ISI = str2num(udp(S:E)); 
          case 'StimLum'
            S = regexp(udp, ';StimLum:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimLum = str2num(udp(S:E));                                      
          case 'Xpos'
            S = regexp(udp, ';Xpos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Xpos = str2num(SS);
          case 'Ypos'
            S = regexp(udp, ';Ypos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Ypos = str2num(SS);
          otherwise
        end
      end
      
    
    case 'Flashing Circle'
      VStim = Class;
      P.Type = Type;
      for i = 1:length(Parameters)      
        Parameter = Parameters{i};        
        switch Parameter
          case 'Filename'
	          S = regexp(udp, ';Filename:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Filename = udp(S:E);                                    
          case 'Size'
            S = regexp(udp, ';Size:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Size = str2num(SS);
          case 'Trial'
            S = regexp(udp, ';Trial:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.Trial = str2num(udp(S:E));
          case 'Duration'
            S = regexp(udp, ';Duration:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Duration = str2num(SS);
          case 'ISI'
            S = regexp(udp, ';ISI:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.ISI = str2num(udp(S:E));
          case 'StimLum'
            S = regexp(udp, ';StimLum:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            P.StimLum = str2num(udp(S:E));            
          case 'Xpos'
            S = regexp(udp, ';Xpos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Xpos = str2num(SS);
          case 'Ypos'
            S = regexp(udp, ';Ypos:','end')+1;
            E = sc(find(sc > S,1,'first'))-1;            
            SS = udp(S:E)
            idx = regexp(SS,'_')
            SS(idx) = ' ';            
            P.Ypos = str2num(SS);
          otherwise
        end
      end  
    
    
    otherwise
      VStim = 1;
      vparam = 2; 
    end
    assignin('base','P',P)  
