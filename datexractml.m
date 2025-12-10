zc=1
load(['S' num2str(zc) '_E3_A1.mat']) 
sortdata=unique(restimulus);
len=length(sortdata)
for i=1: len
emgdata{i,:}=emg((restimulus==sortdata(i)),:);
fdata{i,:}=force((restimulus==sortdata(i)),:);
end
 clearvars -except zc emgdata fdata
emgdata(1, :) = [];fdata(1,:)=[];minNumRows = inf; 
for i = 1:9
    numRows = size(emgdata{i}, 1); % Get the number of rows in the current data
    % Update minNumRows if the current data has fewer rows
    if numRows < minNumRows
        minNumRows = numRows;
    end
end
% Truncate all data arrays to have the minimum number of rows
for i = 1:9
    eall{i} = emgdata{i}(1:minNumRows, :)
    fall{i} = fdata{i}(1:minNumRows, :)
end

emg={}
force12={}
z=9
for j = 1:z
CH1=eall{j};
%%notch filter to elimnate power line noise
notch_f = fdesign.notch(4,0.05,10); %notch filter (50Hz)
D = design(notch_f );
notch_EMG_CH = filter(D,CH1);
% BAND PASS BUTTERWORTH FILTER 4TH ORDER
fn=2000;%sampling freq
flow=500;%cutoff freq
fhigh=20;%cutoff freq
[b,a]=butter(4,[fhigh,flow]/fn,"bandpass");%butterworth 4thorder bandpass
filt_CH=filtfilt(b,a,notch_EMG_CH);
FEATURE1=[];
for i=1:10
ch1 = buffer(filt_CH(:,i),600,300);%0.3s
f1=featf(ch1)
FEATURE1=[FEATURE1 f1];
end
[mm n]=size(f1);
%label=j*ones(n,1)label
features=FEATURE1;
emg{j}=features
end
for j=1:z
f1=fall{j};
notch_f1 = fdesign.notch(4,0.05,10); %notch filter (50Hz)
D1 = design(notch_f1 );
notch_f1 = filter(D1,f1);
% BAND PASS BUTTERWORTH FILTER 4TH ORDER
fn=2000;%sampling freq
flow1=20;%cutoff freq%cutoff freq
[b1,a1]=butter(4,flow1/fn,"low");%butterworth 4thorder bandpass
filt_f1=filtfilt(b1,a1,notch_f1);

force1=[]
for i=1:6
fo1 = buffer(filt_f1(:,i),600,300);
fo1=mean(fo1)
fo=fo1'
force1=[force1 fo];
end
force12{j}=force1
end
save s1ml force12 emg