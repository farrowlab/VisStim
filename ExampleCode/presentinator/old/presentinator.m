%]] command characters:  U, I, C, F, P, O, V, B, S, L, E, D, M, T
% multirec: r, x
% logging only errors

%function presentinator()
 try 

%% init 
command = '< presentinator_init.txt'; % at first load settings

lastcommand = ''; % used in logging

% Add default arguments
lport=446;      % integer UDP port
bgcolor = 195;  % single or triple value
ratefactor = 1; % integer
Zoomimage = [1 0];
um2pixel = 3.0; % double
offset = [0 0]; % in pixel
verbose = 2;    % verbose: 0 - silent, 1 - main text, 2 - debug
bullseyeSize = 300; % in micron
waitFrames = [1 0];
polyMask = [];
parallel_codes = [hex2dec('378') 0 3 4 0 0];
triggeredStart = [hex2dec('378') 0 4 10000]; % mask value timeout
logFilename = '';
%serialTimeout = 2;
logFid = -1;

% internal parameters
txtcolor = 10; % single or triple value
info_state = 0;
bullseyeOn = 0;
mousemoveOn = 0;
mousemove_bullseye = 1; % 1-bullseye, 2.. images
pathstr_old = [];
scrOff = [];
protocol = [];
last_s_command = '';
last_l_command = '';
protocolCommands = [];
user_commands = {};
ip = '';
port = 0;

[status, Myipaddr] = system('ipconfig');
Myipaddr = regexpi(Myipaddr,'IP[\w\.\s\-]+:([\.\d \t]+)[\n\r\v]','tokens');
if isempty(Myipaddr)
    Myipaddr = '(no network!)';
    udp = -1;
else
    Myipaddr = ['or udp to: ' Myipaddr{1}{1}];
    % Open udpsocket and bind udp port address to it
    udp=pnet('udpsocket',lport);
    pnet(udp,'setreadtimeout',0); % = noblock
end

% load and clean-up rush code (remove comments and close lines)
rushloop = textread('presentinator_rush.m','%[^\n]');
for i=1:size(rushloop,1)
    rushloop{i} = [sscanf(rushloop{i},'%[^%]') ';']; %delete % comments
end

% init screen 
presentinator_scrinit;
frametime = 1/Screen(w,'FrameRate');
        
Screen('CopyWindow',scrBg,w); % clear screen
cmd_sender = 'Initialization ';

disp(['START at ' datestr(now)]);
HideCursor();

%% listen-up for commands
udp_loop_run = 1;
while udp_loop_run
    
    if isempty(command) % else exec command
        if udp == -1
            len = 0;
        else
            len=pnet(udp,'readpacket');
        end
            
        if len > 0
            % Read udp packet to read buffer
            command=pnet(udp,'read');
            [ip,port]=pnet(udp,'gethost');
            ip = [num2str(ip(1)) '.' num2str(ip(2)) '.' num2str(ip(3)) '.' num2str(ip(4))];
            cmd_sender = [ip ':' num2str(port) ' ' ]; 
        elseif (CharAvail)
            chr = GetChar;
            command = chr;
            port = 0;
            cmd_sender = 'Keyboard ';
        end
        if mousemoveOn && isempty(command)
            [MouseX,MouseY,MouseB] = GetMouse();
            rgb = [MouseX-screenRect(3)/2 screenRect(4)/2-MouseY];
            if any(offset ~= rgb) % position changed
                command = ' ';
                offset = rgb;
            end
            if any(MouseB)  % 1=bullseye 2...images
                mousemove_bullseye = mod(mousemove_bullseye + 1, sum(scrOff ~= 0)+1)+1;
                MouseB = '';
                while any(MouseB) % wait for release
                    [MouseX,MouseY,MouseB] = GetMouse();
                end
                GetMouse(); % wait to release
            end
        end
    end
    
    if ~isempty(command) % maybe empty
      if (verbose > 1)
            Screen(w,'FillRect',bgcolor,[25, screenRect(4), screenRect(3), screenRect(4)-25]);
            Screen(w,'DrawText',[cmd_sender '>' command(1:min(end,80))], 25, screenRect(4), txtcolor);
      end
      if (logFid ~= -1 && command(1) ~= ' ') 
          lastcommand = sprintf('%s\n  %% %s from %s\n', strrep(command,sprintf('\n'),'\n'), datestr(now), cmd_sender); 
      end
      if (logFid == -1 && verbose == 3)
          disp([datestr(now) ' ' cmd_sender ' "' command '"']);
      end
          
  
      if upper(command(1)) ~= 'I'
            info_state = 0;
      end
        
      switch upper(command(1))
      case ' ' % clear screen, draw bullseye 
       if length(protocolCommands) ~= 0 % continue command sequence 
          command = protocolCommands{1};
          cmd_sender = 'Command file ';
          protocolCommands(1) = []; %special syntax to delete cell 
          if isempty(command)
              command = ' ';
          end
          continue;
        end
        Screen('CopyWindow',scrBg,scrOffline); % clear screen
        if bullseyeOn
            delta = bullseyeSize/um2pixel/2;
            destRect = [screenRect(3)/2-delta+offset(1) screenRect(4)/2-delta-offset(2) screenRect(3)/2+delta+offset(1) screenRect(4)/2+delta-offset(2)];
            if mousemove_bullseye < 2 || ~mousemoveOn
                Screen('CopyWindow',scrBullseye,scrOffline,screenRect,destRect); 
            else
                rgb = find(scrOff ~= 0); % find mousemove_bullseye-th image 
                rgb = rgb(mousemove_bullseye - 1);
                % copied from presentinator_rush.m:
                srcRect = [max(screenRect(1)-offset(1),0)                       max(screenRect(2)+offset(2),0)                        min(screenRect(3)-offset(1),screenRect(3))                        min(screenRect(4)+offset(2),screenRect(4))];
                destRect = [max(screenRect(1)+offset(1),0)                        max(screenRect(2)-offset(2),0)                        min(screenRect(3)+offset(1),screenRect(3))                       min(screenRect(4)-offset(2),screenRect(4))];
                Screen('CopyWindow',scrOff(rgb),scrOffline,srcRect,destRect); 
            end          
        end
        if mousemoveOn
            if bullseyeOn; rgb = 'OFF';
            else rgb = 'ON';
            end 
            if (verbose)
                Screen(scrOffline,'DrawText',['Current offset ' num2str(offset) ...
                    ' Move mouse to change, press b to turn image ' rgb ', click to bmp, press o to fix.'], 25, 35, txtcolor);        
            end
        end
        Screen(w,'WaitBlanking');
        Screen('CopyWindow',scrOffline,w);

        command = ''; % finished
      case 24  % Ctrl-X
          udp_loop_run = 0; 
      case 25  % Ctrl-Y
          udp_loop_run = 0; 
      case 'I' % Info screen
        Screen('CopyWindow',scrBg,w); % clear screen
        if length(protocolCommands)
           command = ' ';
        else
           command = '';
        end            
        
        if port % if port == 0 it was keyboard event
            txt = ['Framerate= ' num2str(Screen(w,'FrameRate'))];
            pnet(udp,'write',txt);     
            pnet(udp,'writepacket',ip,port);   % Send buffer as UDP packet
            if (logFid ~= -1) 
                lastcommand = sprintf('  %% %s %s\n', datestr(now), txt); 
            end
            if (verbose == 0)
                continue;
            end
        end

        if info_state == 0  || port %write commands
            info_state = 1;
            Screen(w,'DrawText',['Valid commands from keyboard ' Myipaddr], 25, 20, txtcolor);
            Screen(w,'DrawText',[' i Info loaded bmps  ' num2str(sum(scrOff ~= 0)) ' (press to peek)' ...
                        '   [Framerate= ' num2str(Screen(w,'FrameRate')) 'Hz' ...
                        ' with ' num2str(screenRect(3)) 'x' num2str(screenRect(4)) 'pixels]'], 25, 50, txtcolor);
            Screen(w,'DrawText',[' c background Color  ' num2str(bgcolor)], 25, 65, txtcolor);
            Screen(w,'DrawText',[' w Wait [pre post]   ' num2str(waitFrames) ' frames'], 25, 80, txtcolor);
            Screen(w,'DrawText',[' f Frame rate Factor ' num2str(ratefactor)], 25, 95, txtcolor);
            Screen(w,'DrawText',[' z Zoom/rotate image ' ...
                    num2str(Zoomimage(1)) 'x ' num2str(Zoomimage(2)) '`'], 25, 110, txtcolor);            
            if mousemoveOn
                rgb = 'lock';
            else
                rgb = 'move';
            end
            Screen(w,'DrawText',[' o position Offset   ' num2str(offset) ' pixels (press to ' rgb ')'], 25, 125, txtcolor);
            Screen(w,'DrawText',[' p microns/Pixel     ' num2str(um2pixel) ], 25, 140, txtcolor);
            if bullseyeOn
                rgb = 'hide';
            else
                rgb = 'show';
            end
            Screen(w,'DrawText',[' b Bullseye size     ' num2str(bullseyeSize) ' microns (press to ' rgb ')'], 25, 155, txtcolor);
            Screen(w,'DrawText',[' u UDP network port  ' num2str(lport) ], 25, 170, txtcolor);
            rgb = [' (press to ' num2str(parallel_codes(2)) ')'];
            Screen(w,'DrawText',[' l paraLlel signals  ' num2str(parallel_codes(1)) ...
                                 ' [ok rec start end sync] ' num2str(parallel_codes(2:end)) rgb], 25, 185, txtcolor);
            if triggeredStart(2)
                rgb = 'Off';
            else
                rgb = 'On';
            end
            Screen(w,'DrawText',[' t start on Trigger  ' num2str(triggeredStart(1)) ...
                                 ' [mask val timeout] ' num2str(triggeredStart(2:end)) ...
                                 ' (press to ' rgb ')'], 25, 200, txtcolor);
            rgb = instrfind;
            switch length(rgb)
            case 0
                rgb = 'none';
            case 1
                rgb = rgb.Name;
            otherwise
                rgb = rgb.Name;
                rgb = [rgb{:}];
            end
            Screen(w,'DrawText',[' d Data ports        ' rgb ' (press to close)'], 25, 215, txtcolor);
            if isempty(polyMask)
                rgb = 'apply';
            else
                rgb = 'remove';
            end
            Screen(w,'DrawText',[' m Mask overlay      ' num2str(size(polyMask,1)) ' (press to ' rgb ')'], 25, 230, txtcolor);
            switch (verbose)
                case 0, rgb = 'Silent';
                case 1, rgb = 'Minimal';
                otherwise, rgb = 'Full';
            end
            Screen(w,'DrawText',[' v Verbosity level   ' rgb], 25, 245, txtcolor);
            if isempty(logFilename)
                rgb = '';
            else
                rgb = ' (press to flush)';
            end
            Screen(w,'DrawText',[' > logfile           ' logFilename rgb], 25, 260, txtcolor);
            if isempty(last_l_command)
                rgb = '';
            else
                rgb = ' (press to reload)';
            end
            Screen(w,'DrawText',[' < load commands     ' last_l_command rgb], 25, 275, txtcolor);
            if isempty(pathstr_old)
                rgb = '';
            else
                rgb = ' (press to replay)';
            end
            Screen(w,'DrawText',[' s Stim last path    ' pathstr_old rgb], 25, 290, txtcolor);
%            Screen(w,'DrawText', ' e Eval expression   ', 25, 305, txtcolor);
            Screen(w,'DrawText', '   exit              Ctrl-X ', 25, 320, txtcolor);

            Screen(w,'DrawText', ' + user commands:    ' , 25, 350, txtcolor);
            Screen(w,'DrawText', '   bg:0 wait:1 color:2 flip:3 user:4', 25, 365, txtcolor);
            row = 350;
            for i=1:size(user_commands,2)
                cmd = user_commands{i};
                if ~isempty(cmd)
                    Screen(w,'DrawText',[cmd{1} ' ' cmd{4} ' (' cmd{2} ' >' cmd{3} ')'], 400, row, txtcolor);
                    row = row+15;
                end
            end
            
        else   %plot bmps
            info_state = 0;
            Screen(scrOffline,'FillRect',txtcolor,screenRect);
            % Screen('CopyWindow',scrBg,scrOffline); 
            gridsize = ceil(sqrt(sum(scrOff ~= 0)+1));
            if ~isempty(polyMask)
                Screen(scrOffline,'FillPoly',bgcolor,polyMask/gridsize); 
                Screen(scrOffline,'DrawText','Mask', 5, 10, txtcolor);            
            else
                Screen('CopyWindow',scrBullseye,scrOffline,screenRect, floor(screenRect / gridsize));
            end
            
            imgid = 1;
            for i=1:size(scrOff,2)
                if scrOff(i)
                    destRect(1:2) = [mod(imgid,gridsize)*screenRect(3) floor(imgid/gridsize)*screenRect(4)];
                    destRect(3:4) = [(1+mod(imgid,gridsize))*screenRect(3) (floor(imgid/gridsize)+1)*screenRect(4)];
                    destRect = floor(destRect / gridsize);
                    destRect(3:4) = destRect(3:4)-1;
                    Screen('CopyWindow',scrOff(i),scrOffline,screenRect,destRect);
                    Screen(scrOffline,'DrawText',num2str(i), destRect(1)+5, destRect(2)+10, txtcolor);            
                    imgid = imgid + 1;
                end
            end
            
            Screen('CopyWindow',scrOffline,w);
        end
    
      case 'B' % bullseye
        rgb = sscanf(command(2:end),'%d',1);
        if isempty(rgb)
            bullseyeOn = 1 - bullseyeOn; % toggle bullseye-view
        elseif rgb > 0 % show
            bullseyeSize = rgb;
            bullseyeOn = 1;
        else
            bullseyeOn = 0;
        end
        command = ' ';
        txt = ['b ' num2str(bullseyeOn* bullseyeSize)];
        presentinator_log;
        
      case 'C' % bgcolor
        rgb = sscanf(command(2:end),'%d',3);
        if isempty(rgb)
            if bgcolor == 0
                rgb = 195;
            elseif bgcolor == 195
                rgb = 255;
            else
                rgb = 0;
            end
        end
        switch length(rgb)
        case 1
            bgcolor = rgb;
            if bgcolor < 160
                txtcolor = 250; 
            else
                txtcolor = 70; 
            end
        case 2
            bgcolor  = rgb(1);
            txtcolor = rgb(2);
        case 3    
            bgcolor  = rgb';
            txtcolor = [rgb(2) rgb(3) rgb(1)];
        otherwise
            txt = ['Unknown color settings ' num2str(rgb')...
                ' use [bg] [bg text] or [color]'];
            presentinator_error;                               
        end    
        scrOff = [];
        mousemove_bullseye = 1;
        Screen(scrBg,'FillRect',bgcolor,screenRect);
        command = ' ';       
        txt = ['c ' num2str(bgcolor) ' ' num2str(txtcolor)];
        presentinator_log;
        
      case 'Z' % Zoomimage
        rgb = sscanf(command(2:end),'%f',2);
        if isempty(rgb)
            switch Zoomimage(1)
                case 1;    Zoomimage(1) = 2;
                case 2;    Zoomimage(1) = 0.5;
                otherwise; Zoomimage(1) = 1;
            end
        elseif rgb(1) > 0
            if length(rgb) == 1
                Zoomimage(1) = rgb;
            else
                Zoomimage = rgb';
            end
        else
            txt = ['Zoom out:(0,1) in:(1,inf) not:' num2str(rgb)];
            presentinator_error;               
        end
        scrOff = []; % reset images
        mousemove_bullseye = 1;
        command = ' '; % delete command buffer
        txt = ['z ' num2str(Zoomimage)];
        presentinator_log;
        
      case 'W' % waitFrames
        rgb = sscanf(command(2:end),'%d', 2);
        if isempty(rgb)
           waitFrames = waitFrames+1;
        elseif any(rgb < 0)
            txt = ['waitFrames must be positive, not ' num2str(rgb')];
            presentinator_error;               
        else
           waitFrames = rgb';
        end
        command = ' '; 
        txt = ['w ' num2str(waitFrames)];
        presentinator_log;

      case 'F' % rateFactor
        rgb = sscanf(command(2:end),'%f',1);
        if isempty(rgb)
            switch ratefactor
            case 1;    ratefactor = 2;
            case 2;    ratefactor = 0.5;
            otherwise; ratefactor = 1;
            end                   
        elseif rgb > 0
            ratefactor = rgb;
        else
            txt = ['rateFactor slower:(0,1) faster:(1,inf) not:' num2str(rgb)];
            presentinator_error;               
        end
        command = ' '; % delete command buffer
        txt = ['f ' num2str(ratefactor)];
        presentinator_log;
       
      case 'P' % um2pixel
        rgb = sscanf(command(2:end),'%f',1);
        if isempty(rgb)
            um2pixel = 1;
        elseif rgb > 0
            um2pixel = rgb;
        else
            txt = ['um2pixel must be positive, not:' num2str(rgb)];
            presentinator_error;               
        end
        command = ' '; 
        txt = ['p ' num2str(um2pixel)];
        presentinator_log;

      case 'O' % offset
        rgb = sscanf(command(2:end),'%f',2)';
        if isempty(rgb)
            if (port == 0)
                mousemoveOn  = ~mousemoveOn; %invert mousemoveOn
            end
        else
            if length(rgb) == 2
                offset = rgb;
            else
                txt = ['Both offset must be presented [x y], not:' num2str(rgb)];
                presentinator_error;
            end
        end
        command = ' '; 
        txt = ['o ' num2str(offset)];
        presentinator_log;
       
      case 'V' % verbose
        rgb = sscanf(command(2:end),'%d',1);
        if isempty(rgb)
            verbose = mod(verbose+1,3);
        else
            verbose = rgb;
        end
        command = ' '; % delete command buffer
        txt = ['v ' num2str(verbose)];
        presentinator_log;

      case 'M' % mask
        rgb = sscanf(command(2:end),'%d');
        if isempty(rgb)
            if size(polyMask,1)
                rgb = 0;
            else
                rgb = bullseyeSize;
            end
        end

        if length(rgb) == 1
            % compute mask poligon
            radius = rgb/um2pixel;
            polyMask = [];
            if rgb > 1 
                for t=-pi:pi/36:pi
                    polyMask = [polyMask; floor(screenRect(3)/2+offset(1)+radius*cos(t)), ...
                                      floor(screenRect(4)/2-offset(2)+radius*sin(t)) ];
                end
            elseif rgb < -1
                polyMask = [floor(screenRect(3)/2+offset(1)-radius), floor(screenRect(4)/2-offset(2)+radius); ...
                    floor(screenRect(3)/2+offset(1)-radius), floor(screenRect(4)/2-offset(2)-radius); ...
                    floor(screenRect(3)/2+offset(1)+radius), floor(screenRect(4)/2-offset(2)-radius); ...
                    floor(screenRect(3)/2+offset(1)+radius), floor(screenRect(4)/2-offset(2)+radius); ...
                    floor(screenRect(3)/2+offset(1)-radius), floor(screenRect(4)/2-offset(2)+radius); ...
                    ];
            else
                rgb = 0;
            end
            if ~isempty(polyMask)
              polyMask = [0,0; 0,screenRect(4); screenRect(3),screenRect(4); screenRect(3),0; 0,0; polyMask];
            end

        else %!! do better
            polyMask = rgb/um2pixel;
            polyMask = reshape(polyMask,2,size(polyMask)/2);
        end
        command = ' '; % delete command buffer
        txt = ['m ' num2str(rgb)];
        presentinator_log;
        
      case 'L' % parallel port 
        rgb = sscanf(command(2:end),'%d');
        switch length(rgb)
        case 0
            parallel_out(parallel_codes(1),15);
        case 1
            parallel_codes(1) = rgb;
        case 4
            parallel_codes(2:5) = rgb';
        case 5
            parallel_codes(2:6) = rgb';
        case 6
            parallel_codes(1:6) = rgb';
        otherwise
            txt = ['Unknown parallel settings ' num2str(rgb')...
                ' use [port] or [ok rec start end sync]'];
            presentinator_error;               
        end
        parallel_out(parallel_codes(1),parallel_codes(2));
        command = ' '; % delete command buffer
        txt = ['l ' num2str(parallel_codes)];
        presentinator_log;

      case 'T' % trigger to start
        rgb = sscanf(command(2:end),'%f');
        switch length(rgb)
            case 0
                if triggeredStart(2)
                    triggeredStart(2) = 0;
                else
                    triggeredStart(2) = triggeredStart(3);
                end
            case 1
                triggeredStart(1) = rgb(1);
            case 3
                triggeredStart(2) = rgb(1);
                triggeredStart(3) = rgb(2);
                triggeredStart(4) = rgb(3);
            case 4
                triggeredStart = rgb';
            otherwise
            txt = ['Unknown trigger settings ' num2str(rgb')...
                ' use [port] or [mask val timeout]'];
            presentinator_error;               
        end
        command = ' '; % delete command buffer
        txt = ['t ' num2str(triggeredStart)];
        presentinator_log;        
        
      case 'U' % udp port reset
        rgb = sscanf(command(2:end),'%d');
        if ~isempty(rgb)
            lport = rgb;
        end
        if (verbose)
          Screen('CopyWindow',scrBg,w); % clear screen
          txt = ['Reset UDP port to ' num2str(lport)];
          Screen(w,'DrawText', txt, 200, 20, txtcolor);
        end
        pnet(udp,'close');
        for waitt=1:30
            Screen(w,'WaitBlanking');
        end       
        udp=pnet('udpsocket',lport);
        pnet(udp,'setreadtimeout',0);
        command = ' '; % delete command buffer
        txt = ['u ' num2str(lport)];
        presentinator_log;        
        
      case 'D' % serial port handle 
        if length(command) < 4
            rgb = instrfind;
            if ~isempty(rgb)
                fclose(rgb);
                if (logFid ~= -1) 
                    for i=1:size(rgb,2)
                        txt = rgb(1,i).Port; 
                        presentinator_log;
                    end
                end
                delete(txt);
            end
            command = ' '; % delete command buffer
            txt = 'd';
            presentinator_log;        
        else
            if command(3) == '>' % old style
                command = ['+ 0 COM1 ' command(4:end)];
                cmd_sender = 'Compatibility ';
                continue;
            elseif command(3) == '3'
                command = ['+ 0 COM3 ' command(4:end)];
                cmd_sender = 'Compatibility ';
                continue;
            end

            rgb = regexpi(command,'d\s+(\w+)\s+(.*)','tokens');
            command = ' ';
            
            if length(rgb) ~= 1 || length(rgb{1}) ~= 2 || rgb{1}{1}(1) ~= 'C'
                txt = 'Unknown command, use: [d COM baud data stop timeout]';
                presentinator_error;
                continue;
            end
            s_port = rgb{1}{1};
           
            rgb = sscanf(rgb{1}{2},'%d');
            if length(rgb) < 3 || length(rgb) > 4
                txt = 'Unknown parameters, use: [d COM baud data stop timeout]';
                presentinator_error;
                continue;                
            end
                
            so = instrfind('Port',s_port);
            if ~isempty(so)
                 fclose(so);
                 delete(so);
            end
            so = serial(s_port); 

            so.Baudrate = rgb(1);      % Set the baud rate at the specific value
            set(so, 'Parity', 'none') ;     % Set parity as none
            set(so, 'Databits', rgb(2)) ;        % set the number of data bits
            set(so, 'StopBits', rgb(3)) ;        % set number of stop bits 
            set(so, 'Terminator', 'CR') ;   % set the terminator value to newline
            set(so, 'OutputBufferSize', 16) ;  % Buffer for write operation, default it is 512
            stopasync(so);
            if (length(rgb) > 3)
                 set(so, 'Timeout', rgb(4)) ;
            else
                 set(so, 'Timeout', 0.5/Screen(w,'FrameRate'));  
            end
                
            try fopen(so); 
            catch
                [txt, rgb] = lasterr;
                presentinator_error;
            end;
            if (logFid ~= -1) 
                lastcommand = sprintf('  %% %s %s is %s\n', datestr(now), so.Port, so.status); 
            end
            if so.status(1) ~= 'c' %closed
                txt = ['d ' s_port ' ' num2str(rgb')];
                presentinator_log;        
            end

        end
        
      case 'E' % eval (e.g. call other .mat file)
        if length(command(3:end) > 1)
            Screen('CloseAll');

            rgb = instrfind;
            if ~isempty(rgb)
                fclose(rgb);
                if (logFid ~= -1) 
                    for i=1:size(rgb,2)
                        lastcommand = sprintf('  %% %s %s is closed\n', datestr(now), rgb(1,i).Port); 
                    end
                end
            end

            try
            [val resp] = eval(sscanf(command(3:end),'%c'));
            catch
                val = 0;
                [txt, rgb] = lasterr;
                presentinator_error;
                resp = {txt};
            end

            presentinator_scrinit;
        
            if port % if port == 0 it was keyboard event
               val = sprintf(' Filenum=%d;Framerate=%d;Response=''%s'';', ...
                                val, Screen(w,'FrameRate'), resp{1});
               pnet(udp,'write', val);
               pnet(udp,'writepacket',ip,port); 
                if (logFid ~= -1) 
                    txt = val;
                    presentinator_log;
                end
            end
            if ~isempty(rgb)
                fopen(rgb);
                if (logFid ~= -1) 
                    for i=1:size(rgb,2)
                        lastcommand = sprintf('  %% %s %s is opened again\n', datestr(now), rgb(1,i).Port); 
                    end
                end
            end
      
            Screen('CopyWindow',scrBg,w); % clear screen
        else
            txt = ['Empty e command received ' command];
            presentinator_error;
        end
        command = ' '; % delete command buffer
        txt = ['e ' command(3:end)];
        presentinator_log;

      case '>' % log file if keyboard flush out
        if logFid ~= -1
           fclose(logFid);
        end
        if ~isempty(command(3:end))
            logFilename = command(3:end);
        end
        
        [logFid, txt] = fopen(logFilename,'at');
        if logFid == -1
            presentinator_error;
        else
            fprintf(logFid, '%%%%%% %s Start log Presentinator_mat [D. Balya @ Roska Lab, FMI 2007]\n',datestr(now));
        end
        command = ' '; % delete command buffer
        txt = ['> ' logFilename];
        presentinator_log;
  
      case '<' % command sequence file or command!
        command = strrep(command,'\r',sprintf('\n'));

        if isempty(command(3:end))
            protocolFileName = last_l_command;
        else
            protocolFileName = command(3:end);
        end
        last_l_command = protocolFileName;
        
        command = ' '; % delete command buffer
        if isempty(protocolFileName)
            continue;
        end
        oldprotocolCommands = protocolCommands;

        rgb = find(protocolFileName == sprintf('\n'),1);
        if isempty(rgb)
            if 0 == exist(protocolFileName,'file')
                txt = ['Missing file ' protocolFileName];
                presentinator_error;
                continue;
            end
            protocolCommands = textread(protocolFileName,'%[^\n]');
        else
            % chop to cell array
            protocolCommands = regexp(protocolFileName(rgb+1:end),'[^\n]*','match');
        end
        
        for i=1:size(protocolCommands,1)
            protocolCommands{i} = sscanf(protocolCommands{i},'%[^%]');
        end
        if ~isempty(oldprotocolCommands)
            for j=1:size(oldprotocolCommands,1)
                protocolCommands{i+j} = oldprotocolCommands{j};
            end
        end
        
        command = ' '; % ' ' evals protocol list
        txt = '< \r';
        for i=1:size(protocolCommands,1)
            txt = [txt protocolCommands{i} '\r'];
        end
        presentinator_log;
        
      case '+' % define new stimulus number
        if ~isempty(command(3:end))      % id         com      command \t comment
            rgb = regexp(command(3:end),'([+-]*\d+)\s+(\w+)\s+([^\t]+)\t*(.*)','tokens');
            command = ' ';
            if isempty(rgb)
                txt = 'Unknown parameters, use: [+ id COM/LPT command \t comment]';
                presentinator_error;
                continue;
            end
            
            cmd = rgb{1};
            rgb = str2double(cmd{1});
            if strcmpi(cmd{2},'LPT1')
                cmd{2} = num2str(hex2dec('378'));
            elseif strcmpi(cmd{2},'LPT2')
                cmd{2} = num2str(hex2dec('278'));
            end
            
            if rgb > 0 
                %check exisiting open COM?
                user_commands{rgb} = cmd;
            elseif rgb == 0 && ~isempty(cmd)
                so = str2double(cmd{2});
                if isfinite(so) % parallel port command
                    dd = parallel_in(so);
                    txt = eval(cmd{3});
                    parallel_out(so, txt);
                else
                    so = instrfind('Port',cmd{2});
                    so = so(1); %last occurence

                    if isempty(so) 
                        txt = ['Invalid serial port ' cmd{2}];
                        presentinator_error;
                        continue;
                    end
                    if so.status(1) == 'c' %closed
                        txt = ['Serial port ' cmd{2} ' is closed'];
                        
                        presentinator_error;
                        continue;
                    end
                    
                    if so.BytesAvailable
                        fread(so, so.BytesAvailable, 'char');
                    end
                    txt = cmd{3};
                    fprintf(so, txt);
                end
            else
                txt = ['Invalid user command ' ...
                                        cmd{1} ' ' cmd{4} ' (' cmd{2} ' >' cmd{3} ')'];
                presentinator_error;
                continue;
            end
            txt = ['+ ' cmd{1} ' ' cmd{2} ' ' cmd{3} sprintf('\t') cmd{4}];
            presentinator_log;
        end
        command = ' '; % delete command buffer
    
      case 'S' % stimulus: [action frames posX um posY um]
          presentinator_s

      case '%' % comment
        command = ' '; % delete command buffer
        
      otherwise % user command
        rgb = floor(real(str2double(command)));
        if isreal(rgb) && rgb > 0 && ...
                length(user_commands) >= rgb && ...
                ~isempty(user_commands{rgb})
            cmd = user_commands{rgb};        
            command = ['+ 0 ' cmd{2} ' ' cmd{3}];
            cmd_sender = 'Translation ';
        else
            txt = ['Unknown command ' command];
            presentinator_error;
            cmd_sender = 'Helper ';
            command = 'I';
        end
      end % end commands switch

    end
    Screen(w,'DrawText','.', 0, screenRect(4), txtcolor);

end % end udp_loop_run

disp(['EXIT  at ' datestr(now)]);

% the end
catch
     disp(['CRASHED at ' datestr(now)]);
     rgb = lasterror;
     txt = sprintf('  %% %s\n', rgb.message); 
     presentinator_error;
     disp(txt);
end


ShowCursor();
Screen('CloseAll');
pnet(udp,'close');

if logFid ~= -1
   fclose(logFid);
end

so = instrfind();
if ~isempty(so)
    fclose(so);
    delete(so);
end

