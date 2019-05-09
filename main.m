file =  'E:/Datasets/DAVIS-240C/DAVIS240C-2019-04-20T18-02-15+0900-08360040-0.aedat';
maxEvents = 1e7;
startEvent = 1;

global updatedFilename;
if (~strcmp(file,updatedFilename))
    [addr,Ts]=loadaerdat(file, maxEvents, startEvent);
    [DVS,DVSTs,APS,APSTs,IMU,IMUTs]=extractEventsFromAddr(addr,Ts);
    DVSTs = double(DVSTs)*1e-6; % unit: second 
    APSTs = double(APSTs)*1e-6;
    IMUTs = double(IMUTs)*1e-6;
    IMU(:,7)   = IMU(:,7)*1e-3;
    TimeInterval = max([DVSTs; APSTs; IMUTs]) - min([DVSTs; APSTs; IMUTs]);
    InitialTime = min([DVSTs; APSTs; IMUTs]);
    updatedFilename = file;
end

baseDir = 'E:/Datasets/DAVIS-240C/2019-04-20T18-02/';

mkdir([baseDir 'images']);
fid = fopen([baseDir 'images.txt'],'w+');
for f = 1:min(size(APS,3), size(APSTs,1))
	imwrite(double((APS(:,:,f)+128)/512),sprintf([baseDir 'images/frame_%08d.png'],f-1), 'png');
	fprintf(fid,sprintf('%.6f images/frame_%08d.png\r\n',APSTs(f),f-1));
end
fclose(fid);

fid = fopen([baseDir 'events.txt'],'w+');
h = waitbar(0);
for e = 1:size(DVS,1)
	fprintf(fid,sprintf('%.6f %d %d %d\r\n',DVSTs(e),DVS(e,1),DVS(e,2),(DVS(e,3)+1)/2));
	h = waitbar(e/size(DVS,1),h);
end
close(h);
fclose(fid);

fclose('all');