if (logFid ~= -1)
    fprintf(logFid, '%s  %% %s ERROR %s\n', lastcommand, datestr(now), strrep(txt,sprintf('\n'),'\n')); 
end

try %maybe there is no window anymore
    if verbose || logFid == -1
        Screen('CopyWindow',scrBg,w);
        Screen(w,'DrawText', txt, 200, 40, txtcolor);
    end

    if verbose == 3
        Screen(w,'DrawText', 'Press any key to continue!', 200, 60, txtcolor);
        while ~(CharAvail)
        end
        chr = GetChar;
    end
catch
end

if verbose == 3 || port == 0
    disp([datestr(now) ' ERROR ' txt]);
end

if port % if port == 0 it was keyboard event
    pnet(udp,'write', [' ERROR ' txt]);     
    pnet(udp,'writepacket',ip,port);   % Send buffer as UDP packet
end

command = ' ';
