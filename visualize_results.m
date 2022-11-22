clear all, close all

%% Load data
data = load('final_data.mat');

vel_train = data.final_data.acc; % Training values for velocity resulting from experiment
hr_train = data.final_data.hr'; % Training values for HR resulting from experiment
t = data.final_data.t_gen';

%% Select jogging measurement
start_index = 176765;
end_index = 268850;

hr_train = hr_train(start_index:end_index);
vel_train = vel_train(start_index:end_index);
t = t(1:(end_index-start_index+1));
hr_init = hr_train(1);

%% Load best results
bestresults = load('bestresults.mat');
optmse_A = bestresults.bestresults.optimalA;
optmse_D = bestresults.bestresults.optimalD;
A_vector = bestresults.bestresults.A;
D_vector = bestresults.bestresults.D;
mse = bestresults.bestresults.mse;

[row_mse, col_mse]  = find(mse == min(mse(:)));

%% Plot MSE for all values of A and D in A_vector and D_vector
figure(1);
plot(A_vector, mse(:,col_mse));
title('MSE for different parameter values of A, at the optimal value for D');
xlabel('A')
ylabel('MSE')

figure(2);
plot(D_vector, mse(row_mse,:));
title('MSE for different parameter values of D, at the optimal value for A');
xlabel('D')
ylabel('MSE')

%% Plot predicted HR
figure(3);
plot(t, hr_init.*exp(optmse_A.*t) + optmse_D.*vel_train)
hold on
plot(t,hr_train)
legend("HR prediction","HR truth")

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

%% Plot predicted HR
figure(4);
plot(t, hr_init.*exp(optmse_A.*t) + optmse_D.*vel_train)
hold on
plot(t,hr_train)
legend("HR prediction","HR truth")