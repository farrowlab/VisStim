object = [20,40,80]; % in cm
velocity = [200,500]; % in m/s
time = 3;
startpoint = velocity.*time;
bin = 0.01;

subplot(3,1,1)
for objidx = 1:length(object)
    for velidx = 1:length(velocity)
        theta{objidx,velidx} = atan((object(objidx)/2)./(startpoint(velidx)-velocity(velidx)*(0:bin:time)))*2/pi*180;
        plot((0:bin:time),theta{objidx,velidx},'b'); hold on;
%         legend([num2str(object(objidx)),'cm',num2str(velocity(velidx)./1000),'m/s'])
    end
end
title('Approaching')
xlabel('Time (s)')
ylabel('Visual angle (degree)')
axis tight



subplot(3,1,2)
for objidx = 1:length(object)
    for velidx = 1:length(velocity)
        theta{objidx,velidx} = atan((object(objidx)/2)./(startpoint(velidx)+velocity(velidx)*(0:bin:time)))*2/pi*180;
        plot((0:bin:time),theta{objidx,velidx},'b'); hold on;
%         legend([num2str(object(objidx)),'cm',num2str(velocity(velidx)./1000),'m/s'])
    end
end
title('Receding')
xlabel('Time (s)')
ylabel('Visual angle (degree)')
axis tight

subplot(3,1,3)
for objidx = 1:length(object)
    for velidx = 1:length(velocity)
        obj2vel(objidx,velidx) = sqrt(object(objidx)/velocity(velidx));        
%         legend([num2str(object(objidx)),'cm',num2str(velocity(velidx)./1000),'m/s'])
    scatter(obj2vel(objidx,velidx), object(objidx),'b'); hold on;
    end
    
end
% scatter(repmat(object',1,2)',obj2vel ,'b'); hold on;
title('Diameter/velocity')
xlabel('Object diameter (cm)')
ylabel('Diameter/velocity (s)')
axis tight
