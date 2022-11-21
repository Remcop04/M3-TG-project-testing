%% ECG meting inladen
data = importdata('converted_data_test1.txt');

%% verschillende data
fs = 1000;
t = 0:1/fs:(length(data.data(:,1))-1)/fs;
ecg_data = data.data(:,2)/65535;
acc_x = data.data(:,3);
acc_y = data.data(:,4)+1;
acc_z = data.data(:,5);

%% plot
figure(1);
subplot(4,1,1);
plot(t,ecg_data);
title('ECG');

subplot(4,1,2);
plot(t,acc_x);
title('acc_x');

subplot(4,1,3);
plot(t,acc_y);
title('acc_y');

subplot(4,1,4);
plot(t,acc_z);
title('acc_z');

%% filter ecg
d = designfilt('bandpassfir', 'FilterOrder', 20, 'CutoffFrequency1', 0.5, 'CutoffFrequency2', 150, 'SampleRate', fs);
data_ecg = filtfilt(d, ecg_data);


%% findpeaks
figure(3)
findpeaks(data_ecg, 'MinPeakHeight', 1*10^-5, 'MinPeakDistance', 333);
[pks,logs] = findpeaks(data_ecg, 'MinPeakHeight', 1*10^-5, 'MinPeakDistance', 333);
hr = [];
for i=1:(length(logs)-1)
    hr(i)= 60/((logs(i+1)-logs(i))/fs);
end
filtered_hr = movmean(hr, [5 5]);


%% eucladian distance
acc_vector = sqrt(acc_x.^2 + acc_y.^2 + acc_z.^2);
filtered_acc_vector = movmean(acc_vector, [2000 2000]);



figure(2);
subplot(2,1,1);
plot(t, filtered_acc_vector);
title('Accelaration Vector');
xlabel('Time(s)');
ylabel('Accelaration (g)');

subplot(2,1,2);
plot(filtered_hr);
title('Hr');
xlabel('Time(s)');
ylabel('BPM');


%% save data
final_data.t = t;
final_data.fs = fs;
final_data.acc = filtered_acc_vector;
final_data.hr = filtered_hr;
save('final_data.mat', 'final_data');
