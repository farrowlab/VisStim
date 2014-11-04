
fileroot = 'C:\Documents and Settings\SNLC\Desktop\calibration\calibration5-1-10';

PR701 = serial('COM1','BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','hardware','InputBufferSize',4096);
fopen(PR701)

fprintf(PR701,['PR701'])   %initiate Remote control
pause(5)

%clear the input buffer
n = get(PR701,'BytesAvailable');
if n > 0
    bout = fread(PR701,n); 
else
    bout = ''
end 
sprintf('%c',bout)

fprintf(PR701,'S,,,,,1000,0,1,0,0,1')  
pause(2)

%clear the input buffer
n = get(PR701,'BytesAvailable');
if n > 0
    bout = fread(PR701,n); 
else
    bout = '';
end 
sprintf('%c',bout)

%%

%res=[800 600];  %pixel size of the screen
screenNum=0;
ptr = Screen('OpenWindow',screenNum,0);
dom =0:5:255;

fid = fopen([fileroot '\luminance_LCD'],'w');
for i=1:3
    for k=1:length(dom)
        
        Echk = ' 4996';
        %while ~strcmp(Echk(2:5),'0000')  %Check for bad comm; its fucking finicky
            j = dom(k);
            RGB = [0 0 0];
            RGB(i) = j;
            Screen('FillRect',ptr,RGB);  %Call Psychtoolbox
            Screen('Flip',ptr);
            pause(2);

            sprintf('Measuring Gun #%d = %d\n',i,j)

            fprintf(PR701,['M1' 13]);  %Make measurement

            n = 0;
            while n == 0
                n = get(PR701,'BytesAvailable');
            end
            pause(4) %let it get the rest of the string
            %
            n = get(PR701,'BytesAvailable');
            bout = fread(PR701,n);
            sprintf('%c',bout)
            
            Echk = sprintf('%c',bout)
            if strcmp(Echk(1:5),'-4996')
               
                'Too much light!!!'
                
            end
                
        %end
            
        
        %sprintf('%c',bout)
        fprintf(fid,'%c',bout);

    end
end
fclose(fid)
Screen('CloseAll')

%%

%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%Now spectral measurements%%%%%%%%%%%%%%%

%input buffer needs to be about 4000 for this!!!!!!!!!

%%Red gun spectrum

fprintf(PR701,'S,,,,,0,0,1,0,0,1')  
pause(2)
n = get(PR701,'BytesAvailable');
if n > 0
    bout = fread(PR701,n); 
else
    bout = ''
end 
sprintf('%c',bout)

ptr = Screen('OpenWindow',screenNum,0);

fid = fopen([fileroot '\spectrum_red_LCD'],'w');   %now measure spectrum
Screen('FillRect',ptr,[128 0 0]);  %Call Psychtoolbox
Screen('Flip',ptr);

pause(3)
fprintf(PR701, ['M5' 13]);

n = 0;
while n == 0
    n = get(PR701,'BytesAvailable');
end
pause(12) %let it get the rest of the string (Takes a while for some reason)
n = get(PR701,'BytesAvailable');
bout = fread(PR701,n);

sprintf('%c',bout)
fprintf(fid,'%c',bout);
fclose(fid);
Screen('CloseAll')


%%Green gun spectrum

fprintf(PR701,'S,,,,,0,0,1,0,0,1')  
pause(2)
n = get(PR701,'BytesAvailable');
if n > 0
    bout = fread(PR701,n); 
else
    bout = ''
end 
sprintf('%c',bout)

ptr = Screen('OpenWindow',screenNum,0);

fid = fopen([fileroot '\spectrum_green_LCD'],'w');   %now measure spectrum
Screen('FillRect',ptr,[0 128 0]);  %Call Psychtoolbox
Screen('Flip',ptr);

pause(3)
fprintf(PR701, ['M5' 13]);

n = 0;
while n == 0
    n = get(PR701,'BytesAvailable');
end
pause(12) %let it get the rest of the string (takes awhile)
n = get(PR701,'BytesAvailable');
bout = fread(PR701,n);

sprintf('%c',bout)
fprintf(fid,'%c',bout);
fclose(fid);
Screen('CloseAll')



%%Blue gun spectrum

fprintf(PR701,'S,,,,,0,0,1,0,0,1')  
pause(2)
n = get(PR701,'BytesAvailable');
if n > 0
    bout = fread(PR701,n); 
else
    bout = ''
end 
sprintf('%c',bout)

ptr = Screen('OpenWindow',screenNum,0);

fid = fopen([fileroot '\spectrum_blue_LCD'],'w');   %now measure spectrum
Screen('FillRect',ptr,[0 0 128]);  %Call Psychtoolbox
Screen('Flip',ptr);

pause(3)
fprintf(PR701, ['M5' 13]);

n = 0;
while n == 0
    n = get(PR701,'BytesAvailable');
end
pause(12) %let it get the rest of the string (this takes awhile for some reason)
n = get(PR701,'BytesAvailable');
bout = fread(PR701,n);

sprintf('%c',bout)
fprintf(fid,'%c',bout);
fclose(fid);
Screen('CloseAll')


Screen('CloseAll')
fclose(PR701);
delete(PR701);
clear PR701

