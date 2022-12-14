clear all, clc

%% Load data
data = importdata('converted_data_test1.txt'); % loading the converted data from txt file from OpenSignals

%% Putting data in variables
fs = 1000;                                  % Sample frequency of the recorded signals
t = 0:1/fs:(length(data.data(:,1))-1)/fs;   % creating time axis in seconds
ecg_data = data.data(:,2)/65535;            % loading ECG data in variable
acc_x = data.data(:,3);                     % loading X-axis data in variable
acc_y = data.data(:,4)+1;                   % loading Y-axis data in variable and 1 to adjust for gravity
acc_z = data.data(:,5);                     % loading Z-axis data in variable

%% Plotting signals
figure(1);
subplot(4,1,1); 
plot(t,ecg_data);   % plotting ECG signal                             
title('ECG');     
xlabel('Time(s)');
ylabel('Signal(V)');

subplot(4,1,2);
plot(t,acc_x);      % plotting X-axis accelerometer data
title('acc_x');
xlabel('Time(s)');
ylabel('Accelaration (G)');

subplot(4,1,3);
plot(t,acc_y);      % plotting Y-axis accelerometer data
title('acc_y');
xlabel('Time(s)');
ylabel('Accelaration (G)');

subplot(4,1,4);
plot(t,acc_z);
title('acc_z');     % plotting Z-axis accelorometer data
xlabel('Time(s)');
ylabel('Accelaration (G)');

%% Filtering ECG signal using bandpassfilter
d = designfilt('bandpassfir', 'FilterOrder', 20, 'CutoffFrequency1', 0.5, 'CutoffFrequency2', 150, 'SampleRate', fs); % Designing FIR bandpass filter from 0.5 till 150 Hz.
Filtered_ECG_data = filtfilt(d, ecg_data);   % Filtering the data with the bandpass filter

%% Determining the Heart rate
figure(2)
findpeaks(Filtered_ECG_data, 'MinPeakHeight', 1*10^-5, 'MinPeakDistance', 500); % plotting findpeaks, Minimal Peak Height of 10*-5 Volt, and Minimal Peak distance of 333
title('Heart Rate with selected peaks using findpeaks()')
xlabel('Time(s)');
xlabel('mV')

[pks,logs] = findpeaks(Filtered_ECG_data, 'MinPeakHeight', 1*10^-5, 'MinPeakDistance', 333); % finding height and locations of the peaks
hr = 60./(diff(logs)./fs);                  % calculating heart rate from locations of the peaks
filtered_hr = movmean(hr, [5 5]);           % Moving average over last 5 and next 5 heart rate peaks

%% Interpolating heart rate vector
t_hr = logs(1:end-1)./1000;                         % time axis for heart rate to interpolate
interp_hr = interp1(t_hr,filtered_hr,t);            % interpolating heart rate to sample freq of 1000 Hz

%% Plotting filtered HR data
figure(3);
t_hr = logs(1:end-1)./1000;         % creating time axis for heart rate
plot(t,interp_hr);             % plotting heart rate 
title('Heart Rate');
xlabel('Time(s)');
ylabel('Heart Rate (BPM)');

%% Calculating eucladian distance
acc_vector = sqrt(acc_x.^2 + acc_y.^2 + acc_z.^2);          % calculating Eucladian distance of the acceleration vector
filtered_acc_vector = movmean(acc_vector, [2000 2000]);     % Moving average over last 2 seconds and next 2 seconds of accelaration signal.

%% Downsample data from 1000 Hz to 100 Hz
interp_hr = downsample(interp_hr, 10);
filtered_acc_vector = downsample(filtered_acc_vector, 10);
t = downsample(t, 10);

%% Plot acceleration vector and HR
figure(4);
subplot(2,1,1);
plot(t, filtered_acc_vector);           % plotting filtered acceleration vector 
title('Acceleration Vector');   
xlabel('Time(s)');
ylabel('Accelaration (g)');

subplot(2,1,2);
plot(t, interp_hr);                % plotting Heart rate over time
title('Heart ');
xlabel('Time(s)');
ylabel('BPM');



%% Save data
final_data.t_gen = t;                       % General time axis for the ECG and accelerometer data
final_data.fs = fs;                         % Sample frequency of the ECG and accelerometer data
final_data.acc = filtered_acc_vector;       % Filtered accelerometer vector data (Moving average of eucladian distance of acc_x, acc_y and acc_z)
final_data.hr = interp_hr;                  % Filtered Heart rate data 
save('preprocessed_data.mat', 'final_data');       % saving data in new structure
