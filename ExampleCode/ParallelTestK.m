#####################################################################
# Settings
#####################################################################
 
# Channels to capture
#channels = [0, 1, 2, 3, 4, 5, 6, 7];
channels = [2, 1, 0];
 
# Channel labels
#channel = {"CH0"; "CH1"; "CH2"; "CH3"; "CH4"; "CH5"; "CH6"; "CH7"};
channel = {"SO"; "SCK"; "!CS"};
 
# Trigger channel
triggerCh = 0;
 
# When to trigger
trigger = 0; # Capture on low. For high - 1
 
#####################################################################
 
samplesTime = [];
samplesValue = [];
 
#pp_close(pp);
pp = parallel("/dev/parport0", 1);
 
printf("Waiting for trigger...\n");
fflush(stdout);
 
data = pp_data(pp);
while (bitget(data, triggerCh + 1) != trigger)
    oldData = data;
    data = pp_data(pp);
endwhile
 
printf("Capturing...\n");
fflush(stdout);
 
startTime = time();
samplesTime(end + 1) = 0;
samplesValue(end + 1) = oldData;
 
while (bitget(data, triggerCh + 1) == trigger)
    data = pp_data(pp);
    samplesTime(end + 1) = time() - startTime;
    samplesValue(end + 1) = data;
endwhile
 
# Statistics
printf("Average sample rate: %f kHz\n", size(samplesValue)(2) / samplesTime(end) / 1000.0);
 
pp_close(pp);
 
# Plotting
 
figure;
for p = 1:size(channels)(2)
    subplot (size(channels)(2), 1, p)
    plot(samplesTime, bitget(samplesValue, channels(p) + 1))
 
    ylabel(channel{p});
    axis([-0.01, samplesTime(end)+ 0.01, -1, 2], "manual");
    set(gca(), 'ytick', -1:2);
    set(gca(), 'yticklabel', {''; '0'; '1'; ''});
endfor
xlabel ("t");