%% parameters
clear all;
%cd /local0/scratch/michelef/light_stimulation

repetitions = 5; % repetitions
save_recording = 0;
send_parapin = 0;

color_of_the_bar = 255; % RGB
background_fixed = 0; % RGB

length_of_the_bar = 1000; % width of the bar in Microns
width_of_the_bar = 1000; % length of the bar in Microns
Speed = 1600 ; % Speed in Micrometer/Second

recording_computer_name = 'bs-dw17';



angles_for_ds = [0 180 270 90 45 225 315 135];
pause_between_repetitions = 1; % break between repetitions
FPS = 60; % FramePerSecond. This is the frequency of the projector. In Hz; You should not need to change this
Scaling = 1.75; % Scaling. Micrometer per pixel. One Pixel corresponds to 1.75 micormeter

remove_offset = 1; % if 1, the bar does not show up when idle


%% some settings for psychotoolbox

if send_parapin;parapin(0);end

whichScreen = 0;
window = Screen(whichScreen, 'OpenWindow');

%white = WhiteIndex(window); % pixel value for white
black = BlackIndex(window); % pixel value for black
Screen(window, 'FillRect', black);

ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;
vbl=Screen('Flip', window);


m = zeros(600,600, 3);
m(:,:,2) = 1;
m(:,:,3) = 1;
color=m * background_fixed;
Screen(window, 'PutImage', color);
Screen(window, 'Flip');



%% Create BARS

LARGE_IMG_DX = 1000;
LARGE_IMG_DY = 1000;
BAR_WIDTH_2 = round(length_of_the_bar/Scaling/2); % Half of the bar width ( -half until +half == width)

XRES=600;
YRES=600;

% End of Configuration Options
C(1) = round(LARGE_IMG_DX/2);
C(2) = round(LARGE_IMG_DY/2);

imagebase = zeros(LARGE_IMG_DY,LARGE_IMG_DX);
imagebase = imagebase+background_fixed/255;
imagebase((LARGE_IMG_DY/2),(C(1)-BAR_WIDTH_2:C(1)+BAR_WIDTH_2)) = (color_of_the_bar/255);

imagebase1 = zeros(LARGE_IMG_DY,LARGE_IMG_DX);
imagebase1 = imagebase1+background_fixed/255;
imagebase1(round((LARGE_IMG_DY/2)-round(width_of_the_bar/Scaling)/2):round((LARGE_IMG_DY/2)+round(width_of_the_bar/Scaling)/2),((C(1)-BAR_WIDTH_2:C(1)+BAR_WIDTH_2))) = (color_of_the_bar/255);


%% move and rotate bars

KbWait;
for j=1:repetitions

    m = zeros(600,600, 3);
    m(:,:,2) = 1;
    m(:,:,3) = 1;
    color=m * background_fixed;
    Screen(window, 'PutImage', color);
    Screen(window, 'Flip');

    % KbWait;


    % save recording
    if save_recording
        hidens_startSaving(0,recording_computer_name)
        pause(0.1)
    end


    for ANGLE = angles_for_ds;
        if (remove_offset)
            offset = BAR_WIDTH_2+150;
        else
            offset = 0
        end

        Xtan=[];
        Ytan=[];
        P1=[];
        P2=[];

        angle_of_motion=ANGLE;


        % 0-44
        if (angle_of_motion>=0 & angle_of_motion<45)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 45
        if angle_of_motion==45
            Xtan=300+offset;
            Ytan=300+offset;
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 46-90
        if (angle_of_motion>45 & angle_of_motion<=90)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 91-134
        if (angle_of_motion>90 & angle_of_motion<135)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P2=[Xtan -Ytan]+300; %inverted
            P1=[-Xtan Ytan]+300; %inverted
        end

        % 135
        if angle_of_motion==135
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[-Xtan -Ytan]+300; %inverted
            P1=[Xtan Ytan]+300; %inverted
        end

        % 136-180
        if (angle_of_motion>135 & angle_of_motion<=180)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        % 181-224
        if (angle_of_motion>180 & angle_of_motion<225)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        % 225
        if angle_of_motion==(225)
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        %226-270
        if (angle_of_motion>225 & angle_of_motion<=270)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[Xtan -Ytan]+300;
            P2=[-Xtan Ytan]+300;
        end

        %271-314
        if (angle_of_motion>270 & angle_of_motion<315)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[Xtan -Ytan]+300;
            P2=[-Xtan Ytan]+300;
        end

        %315
        if angle_of_motion==315
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[Xtan Ytan]+300; %inverted
            P1=[-Xtan -Ytan]+300; %inverted
        end

        % 316-359
        if (angle_of_motion>315 & angle_of_motion<360)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[Xtan -Ytan]+300; %inverted
            P1=[-Xtan Ytan]+300; %inverted
        end


        d1 = (P1(1)+offset)-(P2(1)+offset);
        d2 = (P1(2)+offset)-(P2(2)+offset);
        distanza = round((abs((offset*2+600)-round(sqrt((d1^2) + (d2^2)))))/2);
        a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
        b = abs(round(sin(deg2rad(angle_of_motion))*distanza));

        if angle_of_motion==45
            P1(1)=P1(1)+a; P1(2)=P1(2)-a;
            P2(1)=P2(1)-b; P2(2)=P2(2)+b;
        elseif angle_of_motion==135;
            P1(1)=P1(1)-a; P1(2)=P1(2)-a;
            P2(1)=P2(1)+b; P2(2)=P2(2)+b;
        elseif angle_of_motion==225;
            P1(1)=P1(1)-a; P1(2)=P1(2)+a;
            P2(1)=P2(1)+b; P2(2)=P2(2)-b;
        elseif angle_of_motion==315;
            P1(1)=P1(1)+a; P1(2)=P1(2)+a;
            P2(1)=P2(1)-b; P2(2)=P2(2)-b;
        end

        % 1-44
        if (angle_of_motion>0 & angle_of_motion<45)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)+a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)-a;
            P2(2)=P2(2)+b;

        end

        % 46-89
        if (angle_of_motion>45 & angle_of_motion<90)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)+a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)-a;
            P2(2)=P2(2)+b;

        end

        % 91-134
        if (angle_of_motion>90 & angle_of_motion<135)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)-a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)+a;
            P2(2)=P2(2)+b;

        end

        % 136-179
        if (angle_of_motion>135 & angle_of_motion<180)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)-a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)+a;
            P2(2)=P2(2)+b;

        end

        % 181-224
        if (angle_of_motion>180 & angle_of_motion<225)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)+a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)-a;
            P1(2)=P1(2)+b;

        end


        % 226-269
        if (angle_of_motion>225 & angle_of_motion<270)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)+a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)-a;
            P1(2)=P1(2)+b;

        end

        % 271-314
        if (angle_of_motion>270 & angle_of_motion<315)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)-a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)+a;
            P1(2)=P1(2)+b;

        end

        % 316-359
        if (angle_of_motion>315 & angle_of_motion<360)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)-a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)+a;
            P1(2)=P1(2)+b;

        end
        %
        % %% plot
        % plot([P1(1),P2(1)],[P1(2),P2(2)]);hold on
        % plot(P1(1),P1(2),'.r','Markersize',20);hold on





        angle_of_rotation=ANGLE;


        % P1 = [0-offset 300]
        % P2 = [600+offset 300]
        dist = Scaling * sqrt( (P2(1)-P1(1))^2 + (P2(2)-P1(2))^2); % distance in um
        Steps = round(dist / Speed * FPS);
        Steps = Steps;
        dX = (P2(1) - P1(1))/Steps;
        dY = (P2(2) - P1(2))/Steps;
        imagerotate = imrotate(imagebase1, angle_of_rotation,'crop');
        m = zeros(LARGE_IMG_DY,LARGE_IMG_DX,3);
        m(:,:,2) = round(imagerotate*255);
        m(:,:,3) = round(imagerotate*255);
        w1(1) = Screen(window, 'MakeTexture',m);

        Steps;
        % Animation loop
        for i = 1:(Steps)
            X = (C(1)-P1(1)) - round(i*dX);
            Y = (C(2)-P1(2)) - round(i*dY);
            source_rect = [ X Y X+XRES Y+YRES];
            Screen('DrawTexture', window, w1(1), source_rect ); %, spriteRect );
            if send_parapin;parapin(6);end
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            if send_parapin;parapin(4);end
        end;
        if send_parapin;parapin(0);end
        Screen('Close', w1);
        m = zeros(600,600, 3);
        m(:,:,2) = 1;
        m(:,:,3) = 1;
        color=m * background_fixed;
        Screen(window, 'PutImage', color);
        Screen(window, 'Flip');
        imagerotate = imrotate(imagebase1,angle_of_rotation ,'crop');
        m = zeros(LARGE_IMG_DY,LARGE_IMG_DX,3);
        m(:,:,2) = round(imagerotate*255);
        m(:,:,3) = round(imagerotate*255);
        w1(1) = Screen(window, 'MakeTexture',m);
        pause(pause_between_repetitions);

    end

    % stop recording
    if save_recording
        pause(5)
        hidens_stopSaving(0,recording_computer_name)
    end

end
if send_parapin;parapin(0);end
pause(pause_between_repetitions)


KbWait;
Screen('CloseAll');%% parameters
clear all;
%cd /local0/scratch/michelef/light_stimulation

repetitions = 5; % repetitions
save_recording = 0;
send_parapin = 0;

color_of_the_bar = 255; % RGB
background_fixed = 0; % RGB

length_of_the_bar = 1000; % width of the bar in Microns
width_of_the_bar = 1000; % length of the bar in Microns
Speed = 1600 ; % Speed in Micrometer/Second

recording_computer_name = 'bs-dw17';



angles_for_ds = [0 180 270 90 45 225 315 135];
pause_between_repetitions = 1; % break between repetitions
FPS = 60; % FramePerSecond. This is the frequency of the projector. In Hz; You should not need to change this
Scaling = 1.75; % Scaling. Micrometer per pixel. One Pixel corresponds to 1.75 micormeter

remove_offset = 1; % if 1, the bar does not show up when idle


%% some settings for psychotoolbox

if send_parapin;parapin(0);end

whichScreen = 0;
window = Screen(whichScreen, 'OpenWindow');

%white = WhiteIndex(window); % pixel value for white
black = BlackIndex(window); % pixel value for black
Screen(window, 'FillRect', black);

ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;
vbl=Screen('Flip', window);


m = zeros(600,600, 3);
m(:,:,2) = 1;
m(:,:,3) = 1;
color=m * background_fixed;
Screen(window, 'PutImage', color);
Screen(window, 'Flip');



%% Create BARS

LARGE_IMG_DX = 1000;
LARGE_IMG_DY = 1000;
BAR_WIDTH_2 = round(length_of_the_bar/Scaling/2); % Half of the bar width ( -half until +half == width)

XRES=600;
YRES=600;

% End of Configuration Options
C(1) = round(LARGE_IMG_DX/2);
C(2) = round(LARGE_IMG_DY/2);

imagebase = zeros(LARGE_IMG_DY,LARGE_IMG_DX);
imagebase = imagebase+background_fixed/255;
imagebase((LARGE_IMG_DY/2),(C(1)-BAR_WIDTH_2:C(1)+BAR_WIDTH_2)) = (color_of_the_bar/255);

imagebase1 = zeros(LARGE_IMG_DY,LARGE_IMG_DX);
imagebase1 = imagebase1+background_fixed/255;
imagebase1(round((LARGE_IMG_DY/2)-round(width_of_the_bar/Scaling)/2):round((LARGE_IMG_DY/2)+round(width_of_the_bar/Scaling)/2),((C(1)-BAR_WIDTH_2:C(1)+BAR_WIDTH_2))) = (color_of_the_bar/255);


%% move and rotate bars

KbWait;
for j=1:repetitions

    m = zeros(600,600, 3);
    m(:,:,2) = 1;
    m(:,:,3) = 1;
    color=m * background_fixed;
    Screen(window, 'PutImage', color);
    Screen(window, 'Flip');

    % KbWait;


    % save recording
    if save_recording
        hidens_startSaving(0,recording_computer_name)
        pause(0.1)
    end


    for ANGLE = angles_for_ds;
        if (remove_offset)
            offset = BAR_WIDTH_2+150;
        else
            offset = 0
        end

        Xtan=[];
        Ytan=[];
        P1=[];
        P2=[];

        angle_of_motion=ANGLE;


        % 0-44
        if (angle_of_motion>=0 & angle_of_motion<45)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 45
        if angle_of_motion==45
            Xtan=300+offset;
            Ytan=300+offset;
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 46-90
        if (angle_of_motion>45 & angle_of_motion<=90)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 91-134
        if (angle_of_motion>90 & angle_of_motion<135)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P2=[Xtan -Ytan]+300; %inverted
            P1=[-Xtan Ytan]+300; %inverted
        end

        % 135
        if angle_of_motion==135
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[-Xtan -Ytan]+300; %inverted
            P1=[Xtan Ytan]+300; %inverted
        end

        % 136-180
        if (angle_of_motion>135 & angle_of_motion<=180)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        % 181-224
        if (angle_of_motion>180 & angle_of_motion<225)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        % 225
        if angle_of_motion==(225)
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        %226-270
        if (angle_of_motion>225 & angle_of_motion<=270)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[Xtan -Ytan]+300;
            P2=[-Xtan Ytan]+300;
        end

        %271-314
        if (angle_of_motion>270 & angle_of_motion<315)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[Xtan -Ytan]+300;
            P2=[-Xtan Ytan]+300;
        end

        %315
        if angle_of_motion==315
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[Xtan Ytan]+300; %inverted
            P1=[-Xtan -Ytan]+300; %inverted
        end

        % 316-359
        if (angle_of_motion>315 & angle_of_motion<360)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[Xtan -Ytan]+300; %inverted
            P1=[-Xtan Ytan]+300; %inverted
        end


        d1 = (P1(1)+offset)-(P2(1)+offset);
        d2 = (P1(2)+offset)-(P2(2)+offset);
        distanza = round((abs((offset*2+600)-round(sqrt((d1^2) + (d2^2)))))/2);
        a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
        b = abs(round(sin(deg2rad(angle_of_motion))*distanza));

        if angle_of_motion==45
            P1(1)=P1(1)+a; P1(2)=P1(2)-a;
            P2(1)=P2(1)-b; P2(2)=P2(2)+b;
        elseif angle_of_motion==135;
            P1(1)=P1(1)-a; P1(2)=P1(2)-a;
            P2(1)=P2(1)+b; P2(2)=P2(2)+b;
        elseif angle_of_motion==225;
            P1(1)=P1(1)-a; P1(2)=P1(2)+a;
            P2(1)=P2(1)+b; P2(2)=P2(2)-b;
        elseif angle_of_motion==315;
            P1(1)=P1(1)+a; P1(2)=P1(2)+a;
            P2(1)=P2(1)-b; P2(2)=P2(2)-b;
        end

        % 1-44
        if (angle_of_motion>0 & angle_of_motion<45)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)+a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)-a;
            P2(2)=P2(2)+b;

        end

        % 46-89
        if (angle_of_motion>45 & angle_of_motion<90)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)+a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)-a;
            P2(2)=P2(2)+b;

        end

        % 91-134
        if (angle_of_motion>90 & angle_of_motion<135)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)-a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)+a;
            P2(2)=P2(2)+b;

        end

        % 136-179
        if (angle_of_motion>135 & angle_of_motion<180)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)-a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)+a;
            P2(2)=P2(2)+b;

        end

        % 181-224
        if (angle_of_motion>180 & angle_of_motion<225)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)+a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)-a;
            P1(2)=P1(2)+b;

        end


        % 226-269
        if (angle_of_motion>225 & angle_of_motion<270)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)+a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)-a;
            P1(2)=P1(2)+b;

        end

        % 271-314
        if (angle_of_motion>270 & angle_of_motion<315)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)-a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)+a;
            P1(2)=P1(2)+b;

        end

        % 316-359
        if (angle_of_motion>315 & angle_of_motion<360)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)-a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)+a;
            P1(2)=P1(2)+b;

        end
        %
        % %% plot
        % plot([P1(1),P2(1)],[P1(2),P2(2)]);hold on
        % plot(P1(1),P1(2),'.r','Markersize',20);hold on





        angle_of_rotation=ANGLE;


        % P1 = [0-offset 300]
        % P2 = [600+offset 300]
        dist = Scaling * sqrt( (P2(1)-P1(1))^2 + (P2(2)-P1(2))^2); % distance in um
        Steps = round(dist / Speed * FPS);
        Steps = Steps;
        dX = (P2(1) - P1(1))/Steps;
        dY = (P2(2) - P1(2))/Steps;
        imagerotate = imrotate(imagebase1, angle_of_rotation,'crop');
        m = zeros(LARGE_IMG_DY,LARGE_IMG_DX,3);
        m(:,:,2) = round(imagerotate*255);
        m(:,:,3) = round(imagerotate*255);
        w1(1) = Screen(window, 'MakeTexture',m);

        Steps;
        % Animation loop
        for i = 1:(Steps)
            X = (C(1)-P1(1)) - round(i*dX);
            Y = (C(2)-P1(2)) - round(i*dY);
            source_rect = [ X Y X+XRES Y+YRES];
            Screen('DrawTexture', window, w1(1), source_rect ); %, spriteRect );
            if send_parapin;parapin(6);end
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            if send_parapin;parapin(4);end
        end;
        if send_parapin;parapin(0);end
        Screen('Close', w1);
        m = zeros(600,600, 3);
        m(:,:,2) = 1;
        m(:,:,3) = 1;
        color=m * background_fixed;
        Screen(window, 'PutImage', color);
        Screen(window, 'Flip');
        imagerotate = imrotate(imagebase1,angle_of_rotation ,'crop');
        m = zeros(LARGE_IMG_DY,LARGE_IMG_DX,3);
        m(:,:,2) = round(imagerotate*255);
        m(:,:,3) = round(imagerotate*255);
        w1(1) = Screen(window, 'MakeTexture',m);
        pause(pause_between_repetitions);

    end

    % stop recording
    if save_recording
        pause(5)
        hidens_stopSaving(0,recording_computer_name)
    end

end
if send_parapin;parapin(0);end
pause(pause_between_repetitions)


KbWait;
Screen('CloseAll');%% parameters
clear all;
%cd /local0/scratch/michelef/light_stimulation

repetitions = 5; % repetitions
save_recording = 0;
send_parapin = 0;

color_of_the_bar = 255; % RGB
background_fixed = 0; % RGB

length_of_the_bar = 1000; % width of the bar in Microns
width_of_the_bar = 1000; % length of the bar in Microns
Speed = 1600 ; % Speed in Micrometer/Second

recording_computer_name = 'bs-dw17';



angles_for_ds = [0 180 270 90 45 225 315 135];
pause_between_repetitions = 1; % break between repetitions
FPS = 60; % FramePerSecond. This is the frequency of the projector. In Hz; You should not need to change this
Scaling = 1.75; % Scaling. Micrometer per pixel. One Pixel corresponds to 1.75 micormeter

remove_offset = 1; % if 1, the bar does not show up when idle


%% some settings for psychotoolbox

if send_parapin;parapin(0);end

whichScreen = 0;
window = Screen(whichScreen, 'OpenWindow');

%white = WhiteIndex(window); % pixel value for white
black = BlackIndex(window); % pixel value for black
Screen(window, 'FillRect', black);

ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;
vbl=Screen('Flip', window);


m = zeros(600,600, 3);
m(:,:,2) = 1;
m(:,:,3) = 1;
color=m * background_fixed;
Screen(window, 'PutImage', color);
Screen(window, 'Flip');



%% Create BARS

LARGE_IMG_DX = 1000;
LARGE_IMG_DY = 1000;
BAR_WIDTH_2 = round(length_of_the_bar/Scaling/2); % Half of the bar width ( -half until +half == width)

XRES=600;
YRES=600;

% End of Configuration Options
C(1) = round(LARGE_IMG_DX/2);
C(2) = round(LARGE_IMG_DY/2);

imagebase = zeros(LARGE_IMG_DY,LARGE_IMG_DX);
imagebase = imagebase+background_fixed/255;
imagebase((LARGE_IMG_DY/2),(C(1)-BAR_WIDTH_2:C(1)+BAR_WIDTH_2)) = (color_of_the_bar/255);

imagebase1 = zeros(LARGE_IMG_DY,LARGE_IMG_DX);
imagebase1 = imagebase1+background_fixed/255;
imagebase1(round((LARGE_IMG_DY/2)-round(width_of_the_bar/Scaling)/2):round((LARGE_IMG_DY/2)+round(width_of_the_bar/Scaling)/2),((C(1)-BAR_WIDTH_2:C(1)+BAR_WIDTH_2))) = (color_of_the_bar/255);


%% move and rotate bars

KbWait;
for j=1:repetitions

    m = zeros(600,600, 3);
    m(:,:,2) = 1;
    m(:,:,3) = 1;
    color=m * background_fixed;
    Screen(window, 'PutImage', color);
    Screen(window, 'Flip');

    % KbWait;


    % save recording
    if save_recording
        hidens_startSaving(0,recording_computer_name)
        pause(0.1)
    end


    for ANGLE = angles_for_ds;
        if (remove_offset)
            offset = BAR_WIDTH_2+150;
        else
            offset = 0
        end

        Xtan=[];
        Ytan=[];
        P1=[];
        P2=[];

        angle_of_motion=ANGLE;


        % 0-44
        if (angle_of_motion>=0 & angle_of_motion<45)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 45
        if angle_of_motion==45
            Xtan=300+offset;
            Ytan=300+offset;
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 46-90
        if (angle_of_motion>45 & angle_of_motion<=90)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 91-134
        if (angle_of_motion>90 & angle_of_motion<135)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P2=[Xtan -Ytan]+300; %inverted
            P1=[-Xtan Ytan]+300; %inverted
        end

        % 135
        if angle_of_motion==135
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[-Xtan -Ytan]+300; %inverted
            P1=[Xtan Ytan]+300; %inverted
        end

        % 136-180
        if (angle_of_motion>135 & angle_of_motion<=180)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        % 181-224
        if (angle_of_motion>180 & angle_of_motion<225)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        % 225
        if angle_of_motion==(225)
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        %226-270
        if (angle_of_motion>225 & angle_of_motion<=270)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[Xtan -Ytan]+300;
            P2=[-Xtan Ytan]+300;
        end

        %271-314
        if (angle_of_motion>270 & angle_of_motion<315)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[Xtan -Ytan]+300;
            P2=[-Xtan Ytan]+300;
        end

        %315
        if angle_of_motion==315
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[Xtan Ytan]+300; %inverted
            P1=[-Xtan -Ytan]+300; %inverted
        end

        % 316-359
        if (angle_of_motion>315 & angle_of_motion<360)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[Xtan -Ytan]+300; %inverted
            P1=[-Xtan Ytan]+300; %inverted
        end


        d1 = (P1(1)+offset)-(P2(1)+offset);
        d2 = (P1(2)+offset)-(P2(2)+offset);
        distanza = round((abs((offset*2+600)-round(sqrt((d1^2) + (d2^2)))))/2);
        a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
        b = abs(round(sin(deg2rad(angle_of_motion))*distanza));

        if angle_of_motion==45
            P1(1)=P1(1)+a; P1(2)=P1(2)-a;
            P2(1)=P2(1)-b; P2(2)=P2(2)+b;
        elseif angle_of_motion==135;
            P1(1)=P1(1)-a; P1(2)=P1(2)-a;
            P2(1)=P2(1)+b; P2(2)=P2(2)+b;
        elseif angle_of_motion==225;
            P1(1)=P1(1)-a; P1(2)=P1(2)+a;
            P2(1)=P2(1)+b; P2(2)=P2(2)-b;
        elseif angle_of_motion==315;
            P1(1)=P1(1)+a; P1(2)=P1(2)+a;
            P2(1)=P2(1)-b; P2(2)=P2(2)-b;
        end

        % 1-44
        if (angle_of_motion>0 & angle_of_motion<45)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)+a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)-a;
            P2(2)=P2(2)+b;

        end

        % 46-89
        if (angle_of_motion>45 & angle_of_motion<90)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)+a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)-a;
            P2(2)=P2(2)+b;

        end

        % 91-134
        if (angle_of_motion>90 & angle_of_motion<135)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)-a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)+a;
            P2(2)=P2(2)+b;

        end

        % 136-179
        if (angle_of_motion>135 & angle_of_motion<180)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)-a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)+a;
            P2(2)=P2(2)+b;

        end

        % 181-224
        if (angle_of_motion>180 & angle_of_motion<225)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)+a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)-a;
            P1(2)=P1(2)+b;

        end


        % 226-269
        if (angle_of_motion>225 & angle_of_motion<270)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)+a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)-a;
            P1(2)=P1(2)+b;

        end

        % 271-314
        if (angle_of_motion>270 & angle_of_motion<315)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)-a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)+a;
            P1(2)=P1(2)+b;

        end

        % 316-359
        if (angle_of_motion>315 & angle_of_motion<360)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)-a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)+a;
            P1(2)=P1(2)+b;

        end
        %
        % %% plot
        % plot([P1(1),P2(1)],[P1(2),P2(2)]);hold on
        % plot(P1(1),P1(2),'.r','Markersize',20);hold on





        angle_of_rotation=ANGLE;


        % P1 = [0-offset 300]
        % P2 = [600+offset 300]
        dist = Scaling * sqrt( (P2(1)-P1(1))^2 + (P2(2)-P1(2))^2); % distance in um
        Steps = round(dist / Speed * FPS);
        Steps = Steps;
        dX = (P2(1) - P1(1))/Steps;
        dY = (P2(2) - P1(2))/Steps;
        imagerotate = imrotate(imagebase1, angle_of_rotation,'crop');
        m = zeros(LARGE_IMG_DY,LARGE_IMG_DX,3);
        m(:,:,2) = round(imagerotate*255);
        m(:,:,3) = round(imagerotate*255);
        w1(1) = Screen(window, 'MakeTexture',m);

        Steps;
        % Animation loop
        for i = 1:(Steps)
            X = (C(1)-P1(1)) - round(i*dX);
            Y = (C(2)-P1(2)) - round(i*dY);
            source_rect = [ X Y X+XRES Y+YRES];
            Screen('DrawTexture', window, w1(1), source_rect ); %, spriteRect );
            if send_parapin;parapin(6);end
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            if send_parapin;parapin(4);end
        end;
        if send_parapin;parapin(0);end
        Screen('Close', w1);
        m = zeros(600,600, 3);
        m(:,:,2) = 1;
        m(:,:,3) = 1;
        color=m * background_fixed;
        Screen(window, 'PutImage', color);
        Screen(window, 'Flip');
        imagerotate = imrotate(imagebase1,angle_of_rotation ,'crop');
        m = zeros(LARGE_IMG_DY,LARGE_IMG_DX,3);
        m(:,:,2) = round(imagerotate*255);
        m(:,:,3) = round(imagerotate*255);
        w1(1) = Screen(window, 'MakeTexture',m);
        pause(pause_between_repetitions);

    end

    % stop recording
    if save_recording
        pause(5)
        hidens_stopSaving(0,recording_computer_name)
    end

end
if send_parapin;parapin(0);end
pause(pause_between_repetitions)


KbWait;
Screen('CloseAll');%% parameters
clear all;
%cd /local0/scratch/michelef/light_stimulation

repetitions = 5; % repetitions
save_recording = 0;
send_parapin = 0;

color_of_the_bar = 255; % RGB
background_fixed = 0; % RGB

length_of_the_bar = 1000; % width of the bar in Microns
width_of_the_bar = 1000; % length of the bar in Microns
Speed = 1600 ; % Speed in Micrometer/Second

recording_computer_name = 'bs-dw17';



angles_for_ds = [0 180 270 90 45 225 315 135];
pause_between_repetitions = 1; % break between repetitions
FPS = 60; % FramePerSecond. This is the frequency of the projector. In Hz; You should not need to change this
Scaling = 1.75; % Scaling. Micrometer per pixel. One Pixel corresponds to 1.75 micormeter

remove_offset = 1; % if 1, the bar does not show up when idle


%% some settings for psychotoolbox

if send_parapin;parapin(0);end

whichScreen = 0;
window = Screen(whichScreen, 'OpenWindow');

%white = WhiteIndex(window); % pixel value for white
black = BlackIndex(window); % pixel value for black
Screen(window, 'FillRect', black);

ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;
vbl=Screen('Flip', window);


m = zeros(600,600, 3);
m(:,:,2) = 1;
m(:,:,3) = 1;
color=m * background_fixed;
Screen(window, 'PutImage', color);
Screen(window, 'Flip');



%% Create BARS

LARGE_IMG_DX = 1000;
LARGE_IMG_DY = 1000;
BAR_WIDTH_2 = round(length_of_the_bar/Scaling/2); % Half of the bar width ( -half until +half == width)

XRES=600;
YRES=600;

% End of Configuration Options
C(1) = round(LARGE_IMG_DX/2);
C(2) = round(LARGE_IMG_DY/2);

imagebase = zeros(LARGE_IMG_DY,LARGE_IMG_DX);
imagebase = imagebase+background_fixed/255;
imagebase((LARGE_IMG_DY/2),(C(1)-BAR_WIDTH_2:C(1)+BAR_WIDTH_2)) = (color_of_the_bar/255);

imagebase1 = zeros(LARGE_IMG_DY,LARGE_IMG_DX);
imagebase1 = imagebase1+background_fixed/255;
imagebase1(round((LARGE_IMG_DY/2)-round(width_of_the_bar/Scaling)/2):round((LARGE_IMG_DY/2)+round(width_of_the_bar/Scaling)/2),((C(1)-BAR_WIDTH_2:C(1)+BAR_WIDTH_2))) = (color_of_the_bar/255);


%% move and rotate bars

KbWait;
for j=1:repetitions

    m = zeros(600,600, 3);
    m(:,:,2) = 1;
    m(:,:,3) = 1;
    color=m * background_fixed;
    Screen(window, 'PutImage', color);
    Screen(window, 'Flip');

    % KbWait;


    % save recording
    if save_recording
        hidens_startSaving(0,recording_computer_name)
        pause(0.1)
    end


    for ANGLE = angles_for_ds;
        if (remove_offset)
            offset = BAR_WIDTH_2+150;
        else
            offset = 0
        end

        Xtan=[];
        Ytan=[];
        P1=[];
        P2=[];

        angle_of_motion=ANGLE;


        % 0-44
        if (angle_of_motion>=0 & angle_of_motion<45)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 45
        if angle_of_motion==45
            Xtan=300+offset;
            Ytan=300+offset;
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 46-90
        if (angle_of_motion>45 & angle_of_motion<=90)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[-Xtan Ytan]+300;
            P2=[Xtan -Ytan]+300;
        end

        % 91-134
        if (angle_of_motion>90 & angle_of_motion<135)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P2=[Xtan -Ytan]+300; %inverted
            P1=[-Xtan Ytan]+300; %inverted
        end

        % 135
        if angle_of_motion==135
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[-Xtan -Ytan]+300; %inverted
            P1=[Xtan Ytan]+300; %inverted
        end

        % 136-180
        if (angle_of_motion>135 & angle_of_motion<=180)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        % 181-224
        if (angle_of_motion>180 & angle_of_motion<225)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        % 225
        if angle_of_motion==(225)
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[-Xtan Ytan]+300; %inverted
            P1=[Xtan -Ytan]+300; %inverted
        end

        %226-270
        if (angle_of_motion>225 & angle_of_motion<=270)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[Xtan -Ytan]+300;
            P2=[-Xtan Ytan]+300;
        end

        %271-314
        if (angle_of_motion>270 & angle_of_motion<315)
            Ytan=300+offset;
            Xtan=Ytan/tan(deg2rad(angle_of_motion));
            P1=[Xtan -Ytan]+300;
            P2=[-Xtan Ytan]+300;
        end

        %315
        if angle_of_motion==315
            Xtan=300+offset;
            Ytan=300+offset;
            P2=[Xtan Ytan]+300; %inverted
            P1=[-Xtan -Ytan]+300; %inverted
        end

        % 316-359
        if (angle_of_motion>315 & angle_of_motion<360)
            Xtan=300+offset;
            Ytan=tan(deg2rad(angle_of_motion))*Xtan;
            P2=[Xtan -Ytan]+300; %inverted
            P1=[-Xtan Ytan]+300; %inverted
        end


        d1 = (P1(1)+offset)-(P2(1)+offset);
        d2 = (P1(2)+offset)-(P2(2)+offset);
        distanza = round((abs((offset*2+600)-round(sqrt((d1^2) + (d2^2)))))/2);
        a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
        b = abs(round(sin(deg2rad(angle_of_motion))*distanza));

        if angle_of_motion==45
            P1(1)=P1(1)+a; P1(2)=P1(2)-a;
            P2(1)=P2(1)-b; P2(2)=P2(2)+b;
        elseif angle_of_motion==135;
            P1(1)=P1(1)-a; P1(2)=P1(2)-a;
            P2(1)=P2(1)+b; P2(2)=P2(2)+b;
        elseif angle_of_motion==225;
            P1(1)=P1(1)-a; P1(2)=P1(2)+a;
            P2(1)=P2(1)+b; P2(2)=P2(2)-b;
        elseif angle_of_motion==315;
            P1(1)=P1(1)+a; P1(2)=P1(2)+a;
            P2(1)=P2(1)-b; P2(2)=P2(2)-b;
        end

        % 1-44
        if (angle_of_motion>0 & angle_of_motion<45)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)+a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)-a;
            P2(2)=P2(2)+b;

        end

        % 46-89
        if (angle_of_motion>45 & angle_of_motion<90)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)+a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)-a;
            P2(2)=P2(2)+b;

        end

        % 91-134
        if (angle_of_motion>90 & angle_of_motion<135)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)-a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)+a;
            P2(2)=P2(2)+b;

        end

        % 136-179
        if (angle_of_motion>135 & angle_of_motion<180)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P1(1)=P1(1)-a; P1(2)=P1(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P2(1)=P2(1)+a;
            P2(2)=P2(2)+b;

        end

        % 181-224
        if (angle_of_motion>180 & angle_of_motion<225)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)+a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)-a;
            P1(2)=P1(2)+b;

        end


        % 226-269
        if (angle_of_motion>225 & angle_of_motion<270)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)+a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)-a;
            P1(2)=P1(2)+b;

        end

        % 271-314
        if (angle_of_motion>270 & angle_of_motion<315)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)-a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)+a;
            P1(2)=P1(2)+b;

        end

        % 316-359
        if (angle_of_motion>315 & angle_of_motion<360)

            a = abs(round(cos(deg2rad(angle_of_motion))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion))*distanza));
            P2(1)=P2(1)-a; P2(2)=P2(2)-b;

            a = abs(round(cos(deg2rad(angle_of_motion+180))*distanza));
            b = abs(round(sin(deg2rad(angle_of_motion+180))*distanza));
            P1(1)=P1(1)+a;
            P1(2)=P1(2)+b;

        end
        %
        % %% plot
        % plot([P1(1),P2(1)],[P1(2),P2(2)]);hold on
        % plot(P1(1),P1(2),'.r','Markersize',20);hold on





        angle_of_rotation=ANGLE;


        % P1 = [0-offset 300]
        % P2 = [600+offset 300]
        dist = Scaling * sqrt( (P2(1)-P1(1))^2 + (P2(2)-P1(2))^2); % distance in um
        Steps = round(dist / Speed * FPS);
        Steps = Steps;
        dX = (P2(1) - P1(1))/Steps;
        dY = (P2(2) - P1(2))/Steps;
        imagerotate = imrotate(imagebase1, angle_of_rotation,'crop');
        m = zeros(LARGE_IMG_DY,LARGE_IMG_DX,3);
        m(:,:,2) = round(imagerotate*255);
        m(:,:,3) = round(imagerotate*255);
        w1(1) = Screen(window, 'MakeTexture',m);

        Steps;
        % Animation loop
        for i = 1:(Steps)
            X = (C(1)-P1(1)) - round(i*dX);
            Y = (C(2)-P1(2)) - round(i*dY);
            source_rect = [ X Y X+XRES Y+YRES];
            Screen('DrawTexture', window, w1(1), source_rect ); %, spriteRect );
            if send_parapin;parapin(6);end
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            if send_parapin;parapin(4);end
        end;
        if send_parapin;parapin(0);end
        Screen('Close', w1);
        m = zeros(600,600, 3);
        m(:,:,2) = 1;
        m(:,:,3) = 1;
        color=m * background_fixed;
        Screen(window, 'PutImage', color);
        Screen(window, 'Flip');
        imagerotate = imrotate(imagebase1,angle_of_rotation ,'crop');
        m = zeros(LARGE_IMG_DY,LARGE_IMG_DX,3);
        m(:,:,2) = round(imagerotate*255);
        m(:,:,3) = round(imagerotate*255);
        w1(1) = Screen(window, 'MakeTexture',m);
        pause(pause_between_repetitions);

    end

    % stop recording
    if save_recording
        pause(5)
        hidens_stopSaving(0,recording_computer_name)
    end

end
if send_parapin;parapin(0);end
pause(pause_between_repetitions)


KbWait;
Screen('CloseAll');