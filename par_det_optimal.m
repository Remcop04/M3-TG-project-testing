clear all, close all

%% Load data
data = load('final_data.mat');

%% Optimal parameter determination based on RSE/MSE

vel_train = data.final_data.acc; % Training values for velocity resulting from experiment
hr_train = data.final_data.hr'; % Training values for HR resulting from experiment
t = data.final_data.t_gen';

%% Select jogging measurement
start_index = 176765;
end_index = 268850;

hr_train = hr_train(start_index:end_index);
vel_train = vel_train(start_index:end_index);
t = t(1:(end_index-start_index+1));

%% Downsample data from 1000 Hz to 100 Hz
hr_train = downsample(hr_train, 10);
vel_train = downsample(vel_train, 10);
t = downsample(t, 10);

%% Double for loop that calculates the RSE for different combinations of
% Parameters
hr_init = hr_train(1); % Initial HR value; resting HR
A = 0.002:0.00001:0.01; % Values to test for A
D = 20:0.01:40; % Values to test for D

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
legend("HR prediction","HR truth")

disp("Current best results:")
disp("The optimal values for A and D based on the minimal MSE are 0.00521 and 31.37, respectively.")
disp("The model then becomes: y(t) = 76.5259*e^(0.00521t) + 31.37*u(t).")

%% Save results
bestresults.A = A
bestresults.D = D
bestresults.optimalA = A_optmse
bestresults.optimalD = D_optmse
bestresults.mse = mse
save bestresults.mat bestresults

%% Test on new segment
vel_train = data.final_data.acc; % Training values for velocity resulting from experiment
hr_train = data.final_data.hr'; % Training values for HR resulting from experiment
t = data.final_data.t_gen';

% Select jogging measurement
start_index = 370595;
end_index = 527862;

hr_train = hr_train(start_index:end_index);
vel_train = vel_train(start_index:end_index);
t = t(1:(end_index-start_index+1));
hr_init = hr_train(1);

%% Downsample data from 1000 Hz to 100 Hz
hr_train = downsample(hr_train, 10);
vel_train = downsample(vel_train, 10);
t = downsample(t, 10);

%% Plot predicted HR
figure(4);
plot(t, hr_init.*exp(optmse_A.*t) + optmse_D.*vel_train)
hold on
plot(t,hr_train)
legend("HR prediction","HR truth")