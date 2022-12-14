clear all, close all

%% Load data
data = load('preprocessed_data.mat');

%% Optimal parameter determination based on RSE/MSE

vel_train = data.final_data.acc; % Training values for velocity resulting from experiment
hr_train = data.final_data.hr'; % Training values for HR resulting from experiment
t = data.final_data.t_gen';

%% Select jogging measurement
start_index = 17918;
end_index = 26764;

hr_train = hr_train(start_index:end_index);
vel_train = vel_train(start_index:end_index);
t = t(1:(end_index-start_index+1));

%% Select sample point
hr_train = [100.50 143 169 174];
vel_train = [0.487 0.99 1.248 1.60];
t_anders = [105 185.4 297.7 379.8];
t = [105 80.5 112.3 82.5];

%% Double for loop that calculates the RSE for different combinations of
% Parameters
hr_init = 80; % Initial HR value; resting HR
A = 0.000001:0.0000001:0.00001; % Values to test for A
D = 30:0.001:80; % Values to test for D

f = waitbar(0, "Started estimation of parameters..");

for i=1:length(A) % Run over values of A
    for j=1:length(D) % Run over values of D
        hr_predict = hr_init.*exp(A(i).*t) + D(j).*vel_train; % Predict heart rate with model
        mse(i,j) = immse(hr_predict, hr_train);
    end
    
    waitbar(i/length(A), f, sprintf('Progress: %d %%', floor(i/length(A)*100)));
    
end

[row_mse, col_mse] = find(mse == min(mse(:))); % Find minimum value for MSE and corresponding values for A and D
A_optmse = A(row_mse);
D_optmse = D(col_mse);

disp(['The optimal values for A and D based on the minimal MSE are ',num2str(A_optmse),' and ',num2str(D_optmse),', respectively.'])
disp(['The model then becomes: y(t) = ',num2str(hr_init),'*e^(',num2str(A_optmse),'t) + ',num2str(D_optmse),'*u(t).']);

%% Plots MSE
figure(1);
plot(A, mse(:,col_mse));
title('MSE for different parameter values of A, at the optimal value for D');
xlabel('A')
ylabel('MSE')

figure(2);
plot(D, mse(row_mse,:));
title('MSE for different parameter values of D, at the optimal value for A');
xlabel('D')
ylabel('MSE')

%% Plot results

figure(3)
plot(t,hr_predict, "blue")
hold on
plot(t,hr_train, "red")
xlabel('Time(s)', 'FontSize', 10);
ylabel('Heart Rate (BPM)', 'FontSize', 10);
legend("HR prediction","HR truth")
title("Results model on Jogging measurement", 'FontSize', 15)