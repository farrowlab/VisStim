timingTest = zeros(size(protocol,1),1);

% set-up commands
flip = 255;     % flip square
Screen('CopyWindow',scrBg,scrOffline);
pout = 0;       % parallel out
so = 0;         % serial out
sync_flip = 0;

pretime = GetSecs(); 
if triggeredStart(1) && triggeredStart(2)
   if verbose
        Screen(w,'DrawText',' Wait for trigger! ');
   end
   parallel_out(890,uint32(bitset(uint8(parallel_in(890)),6))); % set to read
   p = parallel_in(triggeredStart(1));
   disp(num2str([bitand(uint8(triggeredStart(2)), p) p uint8(triggeredStart(2)) triggeredStart(3)  ]));
   while bitand(uint8(triggeredStart(2)),p) ~= triggeredStart(3) && (triggeredStart(4)/1000 > GetSecs() - pretime)
       p = uint8(parallel_in(triggeredStart(1)));
   end 
   parallel_out(890,uint32(bitset(uint8(parallel_in(890)),6,0))); % set to write
else
    for waitsync=1:10   % to make sure the command received is detected
        Screen(w,'WaitBlanking');
    end
end
    
pretime = GetSecs(); 
parallel_out(parallel_codes(1),parallel_codes(4)); % signal start

if triggeredStart(1) && triggeredStart(2) && bitand(uint8(triggeredStart(2)),p) ~= triggeredStart(3) % not triggered but time-out
    txt = ['No trigger arrived within ' num2str(triggeredStart(4)) 'ms'];
    presentinator_error;
else

  if verbose
      Screen(w,'DrawText',' Pre-record waiting...');
  end

  % present - i=1 for init first
  wait_item = 1;
  for i=2:size(protocol,1)

    scmd = 0;
    pout = 0;
    doit = true; % do until duration not zero
    while doit
        % generate next frame
        if protocol(i,1) > 0 % bmp
             if protocol(i,3) ~= 0 || protocol(i,4) ~= 0
                 srcRect = [max(screenRect(1)+protocol(i,3),0)                       max(screenRect(2)+protocol(i,4),0)                        min(screenRect(3)+protocol(i,3),screenRect(3))                        min(screenRect(4)+protocol(i,4),screenRect(4))];
                 destRect = [max(screenRect(1)-protocol(i,3),0)                        max(screenRect(2)-protocol(i,4),0)                        min(screenRect(3)-protocol(i,3),screenRect(3))                       min(screenRect(4)-protocol(i,4),screenRect(4))];
                 Screen('CopyWindow',scrBg,scrOffline); 
             else
                 srcRect = screenRect;
                 destRect = screenRect;
             end
            Screen('CopyWindow',scrOff(protocol(i,1)),scrOffline,srcRect,destRect); 

        elseif protocol(i,1) == 0 % bg -1 
            switch protocol(i,3)
            case 0 % bg color
                Screen('CopyWindow',scrBg,scrOffline); 
            case 1 % wait
            case 2 % full-field
                Screen(scrOffline,'FillRect',uint8(protocol(i,4)));
            case 3 % flip
                flip = uint8(protocol(i,4)); 
            case 4 % user
                cmd = user_commands{protocol(i,4)};
                if (verbose == 2)
                    Screen(scrOffline,'DrawText', [cmd{4} ' (' cmd{2} ' ' cmd{3} ')'], 200, 25, txtcolor);
                end

                so = str2double(cmd{2});
                if isfinite(so) % parallel port command
                    pout = so;
                    dd = parallel_in(pout);
                    cmd = eval(cmd{3});
                    so = 0; % not serial
                else
                    so = so_arr{str2num(cmd{2}(4))};
                    cmd = cmd{3};
                    if ~isempty(so) && so.status(1) == 'o'
                        if so.BytesAvailable
                            fread(so, so.BytesAvailable, 'char');
                        end
                       scmd = 1;
                    end
                end
            end
        end
        if ~isempty(polyMask)
             Screen(scrOffline,'FillPoly',bgcolor,polyMask);        
        end

        if verbose
            if verbose == 2 && protocol(i,2) % write only the last
               Screen(scrOffline,'DrawText',[protocolFileName ' step ' num2str(i-1) 'of' num2str(size(protocol,1)) ' remains ' num2str(sum(protocol(i:end,2))*frametime) 's'], 25, screenRect(4), txtcolor);
            end
            if (flip == 0) || (flip == 255)
                flip = 255-flip;        %flip square else it was user spec.
            end
            if 0 % not needed for now on Tamas setup
                Screen(scrOffline,'FillRect',flip,[0 0 25 25]);
            end
        end

        
        if protocol(i,2) || i == size(protocol,1)
            doit = false;
        else % if duration == 0 do the next line
            i = i + 1;
        end    
    end % doit while duration not zero
  
    % wait the req. time 
    for wait_i=1:protocol(wait_item,2)
        Screen(w,'WaitBlanking');
        if sync_flip
            parallel_out(parallel_codes(1),parallel_codes(4));
        else
            parallel_out(parallel_codes(1),uint32(xor(parallel_codes(4),parallel_codes(6))));
        end            
        sync_flip = ~sync_flip;
    end
    wait_item = i;
    
    % Copy to monitor.
    Screen('CopyWindow',scrOffline,w);
    
    % Do the data communications
    if pout
       parallel_out(pout, cmd);
    end
    if scmd
       fprintf(so, cmd);
    end
    
    posttime = GetSecs();
    timingTest(i) = posttime - pretime;
    pretime = posttime;
  end;

  
  parallel_out(parallel_codes(1),parallel_codes(5)); % signal end

  % wait post-time
  for wait_i=1:protocol(end,2)
    Screen(w,'WaitBlanking');
    if sync_flip
        parallel_out(parallel_codes(1),parallel_codes(5));
    else
        parallel_out(parallel_codes(1),uint32(xor(parallel_codes(5),parallel_codes(6))));
    end            
    sync_flip = ~sync_flip;
  end

end % triggered start
parallel_out(parallel_codes(1),parallel_codes(2)); % signal ready
