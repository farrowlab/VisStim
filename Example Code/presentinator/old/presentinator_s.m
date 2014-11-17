%      case 'S' % stimulus: [action frames posX um posY um]
        command = strrep(command,'\n',sprintf('\n'));
        Screen('CopyWindow',scrBg,w); % clear screen
        bullseyeOn = 0;
        if isempty(command(3:end))           % use last command
            command = last_s_command;
        end
        last_s_command = command;

        if isempty(command(3:end))
           command = ' '; % delete command buffer
           continue;
        end

        rgb = regexp(command(2:end),'[ \f\r\t\v]*([^\n])*[\n]*(.*)','tokens');
        command = rgb{1}{2};
        protocolFileName = rgb{1}{1};
        if isempty(command)
            command = ' '; % delete command buffer
            protocol = [];
            if ~exist(protocolFileName,'file')
                txt = ['Missing file ' protocolFileName];
                presentinator_error;
                continue;  
            else
                % load protocol: protocolFileName
                if (verbose > 1)
                    Screen(w,'DrawText',['Load ' protocolFileName], 25, 35, txtcolor);
                end
                protocol = dlmread(protocolFileName,'\t',2,0);
            end
        else
            if (verbose > 1)
                Screen(w,'DrawText',['Skip ' protocolFileName], 25, 35, txtcolor);
            end
            protocol = textscan(command,'%f%f%f%f', -1, 'delimiter', sprintf(' \t'), 'multipleDelimsAsOne', 1); % 'headerlines',1
            command = ' '; % delete command buffer
            if isempty(protocol)
                txt = ['Missing command ' command];
                presentinator_error;
                continue;  
            end
            protocol = [protocol{:}];
        end
                %signal command received
        parallel_out(parallel_codes(1),parallel_codes(3)); % signal received: 011
        
        if size(protocol,2) == 2 % old style file
            protocol(:,3) = 0;
            protocol(:,4) = 0;
        end
        % empty line can make NaN
        protocol = protocol(~isnan(protocol(:,1)),:);
        protocol = protocol(isfinite(protocol(:,2)),:);
        
        % first line for init
        protocol = [-1 waitFrames(1) 0 0; protocol]; % wait 1 blink at first
        if length(waitFrames) > 1
            protocol = [protocol; -1 waitFrames(2) 0 0];
        end
        % bmp id 1 based
        protocol(:,1) = floor(protocol(:,1) + 1);
        
        % duration in blankings *frametime!!!!!!!
        protocol(:,2) = floor(protocol(:,2)*ratefactor);
        
        % offset in pixel
        bmplines = find(protocol(:,1) > 0);
        protocol(bmplines,3) = protocol(bmplines,3)/um2pixel;
        protocol(bmplines,4) = protocol(bmplines,4)/um2pixel;
        % external offset
        protocol(bmplines,3) = floor(-protocol(bmplines,3)-offset(1));
        protocol(bmplines,4) = floor(-protocol(bmplines,4)+offset(2));

        % check user command exist
        so = instrfind();
        for i=1:size(so,2)
            so_arr{str2num(so(i).Port(4))} = so(i);
        end
        bmplines = find(protocol(:,1) == 0 & protocol(:,3) == 4);      
        for i=1:size(bmplines)
            if protocol(bmplines(i),4) < 1 || ...
                    protocol(bmplines(i),4) > length(user_commands)  || ...
                    isempty(user_commands{protocol(bmplines(i),4)})
                txt = ['Unknown user command in stimulus ' num2str(protocol(bmplines(i),4))];
                presentinator_error;
                protocol(bmplines(i),1) = -3;
            end
        end
       
        % load imgs
        if (verbose > 1)
            Screen(w,'DrawText',' Load bitmaps');
        end

        [pathstr, name, ext, versn] = fileparts(protocolFileName);

        % if new directory
        if ~strcmp(pathstr_old,pathstr) || isempty(scrOff)
            % sort filenames
            bmpfiles = dir([pathstr , '\\*.bmp']);
            bmpfiles = sort({bmpfiles.name});
            pngfiles = dir([pathstr , '\\*.png']);
            pngfiles = sort({pngfiles.name});
            bmpfiles = [bmpfiles pngfiles];
            
            % clear old bitmaps
            pathstr_old = pathstr;
            scrOff = zeros(1,size(bmpfiles,2));
        end
                                                          % 2:end    
        usedbmps = unique(protocol(find(protocol(2:end,1) > 0)+1,1))';
        for i=usedbmps
            if i < length(scrOff) && scrOff(i)    % already loaded
                continue;
            end
            if i > length(bmpfiles)
                txt = ['Missing bmp in stimulus id ' num2str(i)];
                presentinator_error;
                protocol((protocol(:,1) == i),1) = -3;
                continue;
            end
                
            [imageArray map] = imread(fullfile(pathstr,bmpfiles{i}));
            imageInfo = imfinfo(fullfile(pathstr,bmpfiles{i}));
            
            if size(map,1) > 0
               if (isfield(imageInfo,'SimpleTransparencyData'))    
                  tp = logical(1-imageInfo.SimpleTransparencyData);
                  map(tp,:) = repmat(bgcolor/255, size(map(tp,1)), 4-size(bgcolor,2)); 
               end
               imageArray = ind2gray(imageArray, map); % resolve indexed file
            end
            if Zoomimage(2) ~= 0
                imageArray = double(imageArray);
                
                imageArray = imrotate(imageArray+3, -1*abs(Zoomimage(2))); % rotate (3 is arbitrary shift)
                imageArray = (imageArray==0)*(bgcolor+3) + imageArray - 3;    % correct bgcolor
                if Zoomimage(2) < 0 % flip
                    imageArray = fliplr(imageArray);
                end
                
                imageArray = uint8(imageArray);
            end
          
            scrOff(i)  = Screen(w, 'OpenOffscreenWindow', 0, screenRect);
            Screen(scrOff(i),'FillRect',bgcolor,screenRect);    
            destRect = 0.5*[screenRect(3)-Zoomimage(1)*size(imageArray,2) screenRect(4)-Zoomimage(1)*size(imageArray,1) screenRect(3)+Zoomimage(1)*size(imageArray,2) screenRect(4)+Zoomimage(1)*size(imageArray,1)];
            destRect = [max(destRect(1),0) max(destRect(2),0) min(destRect(3),screenRect(3)) min(destRect(4),screenRect(4))];

            Screen(scrOff(i),'PutImage',imageArray,destRect);
        end

        txt = mat2str(protocol);
        txt = sprintf(['s Processed %s\n' strrep(txt(2:end-1),';','\n')], protocolFileName);
        presentinator_log;
        
        % start 
        Rush(rushloop,2);
        % presentinator_rush; 
            
        Screen('CopyWindow',scrBg,w); % clear screen

        if max(protocol(2:end-1,2)*frametime - timingTest(3:end)) >=2* frametime
            txt = 'Timing error! ';
            presentinator_error;
            display([timingTest protocol(:,2)*frametime timingTest/frametime-protocol(:,2)]);
        end
        protocol = [];
        txt = 'done'; 
        presentinator_log;
        command = ' '; % delete command buffer
