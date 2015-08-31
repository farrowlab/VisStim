lastcommand = sprintf('  %% %s %s', datestr(now), strrep(txt,sprintf('\n'),'\n')); 

if port % if port == 0 it was keyboard event
    pnet(udp,'write', txt);     
    pnet(udp,'writepacket',ip,port);   % Send buffer as UDP packet
end

if verbose == 3
    if (logFid ~= -1) 
        fprintf(logFid, '%s\n', lastcommand); 
    end
    disp([datestr(now) ' ' txt]);
end
