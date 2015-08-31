function [parfile ppath] = hlp_look4par(verbose);
% INPUT:
% verbose - if set to 1, some info will be written to the screen. 
% OUTPUT:
% parfile - String containing one filename matching the username, hostname
%           and projectcode.

% This script handles parameter files according to the hostname.

%look for files starting with your username. Machines on dhcp servers may change hostname often.
%determine the name of the machine we are running on and read setting file
% for the host. If it does not exist, use default setting file.
try 
    [dummy hostname] = system('set userdomain'); % win32
    hname = hostname(12:14);
catch
	[dummy hostname] = system('hostname'); 
    hname = hostname(1:3);
end
% look up table for hostname - experimenter person's name
hosts = {''};
persons = {'jens','tim','thomas','david','volki','sandra'};

% match current hostname to known hostnames
chind = find(hname, hosts);

% look for par file
parfiles = whichx([uname,'_',hname,'_',projectcode,'par.m']);
if isempty(parfilesuh) % no username-hostname par file
    if isempty(parfilesu) % no username par file either, use default
        parfile = [projectcode,'_par'];
        fprintf(['[WARNING] Using default par file. I suggest you make a copy\n and adjust parameters in that file.\n']);
        fprintf('Do you want me to create a par file for you? (y/n). Just hit ENTER to say yes.\n');
        reply = input('   (y/n)>>','s');
        if isempty(reply) == 1
            reply = 'y';
        end
        if strcmpi(reply,'y') % find most recent par file and copy it
            anyparfile = whichx(['*',projectcode,'par.m']);
            if isempty(anyparfile)
                error('No par file found. Maybe par files'' directory is not in Matlab path?');
            end
            for i = 1 : length(anyparfile)
                datenums(i) = datenum(anyparfile(i).date,0);
            end
            recent = find(datenums == max(datenums));
            tpath = find(anyparfile(recent(1)).path == filesep);
            [s mes] = system(['copy ',anyparfile(recent(1)).path, ' ', anyparfile(recent(1)).path(1:tpath(end)),...
                    uname,'_',hname,'_',projectcode,'par.m']);
            if s ~= 0
                 % linux
                system(['cp ',anyparfile(recent(1)).path, ' ', anyparfile(recent(1)).path(1:tpath(end)),...
                    uname,'_',hname,'_',projectcode,'par.m']);
            end
            fprintf(['[INFO] Your par file ', uname,'_',hname,'_',projectcode,...
                'par.m',' was created.\n If your machine is on a DHCP domain then rename it to:',...
                uname,'_',projectcode,'par.m\n']);
        end
    else
        parfile = [uname,'_',projectcode,'par'];
        ppath = parfilesu.path;
    end
else
    parfile =[uname,'_',hname,'_',projectcode,'par'];
    ppath = parfilesuh.path;
end
fprintf(['[INFO] Using par file ', parfile,'\n']);
fprintf(['[INFO] Your username is: ',username, 'hostname is: ', hostname,'\n']);
