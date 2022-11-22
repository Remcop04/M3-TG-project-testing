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

%% Downsample data from 1000 Hz to 100 Hz
hr_train = downsample(hr_train, 10);
vel_train = downsample(vel_train, 10);
t = downsample(t, 10);


%% Optimal parameter determination using simulink

% Define parameter values to be tested
A = -100:50:100; % Values to test for A
B = -100:50:100; % Values to test for B
C = -100:50:100; % Values to test for C
D = -100:50:100; % Values to test for D


% Double for loop that calculates the RSE for different combinations of
% parameters
f = waitbar(0, "Started estimation of parameters..");

for i=1:length(A) % Run over values of A
    for j=1:length(B) % Run over values of B
        for k=1:length(C) % Run over values of C
            for l=1:length(D) % Run over values of D
        
                u = [t,vel_train];
                A_value = A(i);
                B_value = B(j);
                C_value = C(k);
                D_value = D(l);
                
                simOut = sim('SSmodel.slx', 'StopTime', num2str(t(end)), 'FixedStep', num2str(1/100)); % Predict heart rate with simulink model
                hr_predict = simOut.hr_simulink.signals.values(1:length(vel_train));
                mse(i,j,k,l) = immse(hr_predict, hr_train);

            end
        end
        waitbar(i/length(A), f, sprintf('Progress: %d %%', floor(i/length(A)*100)));
    end

end

[A_index, B_index, C_index, D_index] = find(mse == min(mse(:))); % Find minimum value for MSE and corresponding values for A, B, C and D
A_optmse = A(A_index);
B_optmse = B(B_index);
C_optmse = C(C_index);
D_optmse = D(D_index);

disp(['The optimal values for A, B, C and D based on the minimal MSE are ',num2str(A_optmse),', ',num2str(B_optmse),', ',num2str(C_optmse),', and ',num2str(D_optmse),', respectively.']);

%% Plots MSE
figure(1);
plot(A, mse(:,B_index, C_index, D_index));
title('MSE for different parameter values of A, at the optimal value for B, C and D');
xlabel('A')
ylabel('MSE')

figure(2);
plot(B, mse(A_index,:, C_index, D_index));
title('MSE for different parameter values of B, at the optimal value for A, C and D');
xlabel('B')
ylabel('MSE')

figure(3);
plot(C, mse(A_index, B_index, :, D_index));
title('MSE for different parameter values of A, at the optimal value for A, B and D');
xlabel('C')
ylabel('MSE')

figure(4);
plot(D, mse(A_index, B_index, C_index,:));
title('MSE for different parameter values of D, at the optimal value for A, B and C');
xlabel('D')
ylabel('MSE')

%% Plot results

figure(5)
plot(t,hr_predict, "blue")
hold on
plot(t,hr_train, "red")
legend("HR prediction","HR truth")

%% Save results
bestresults.A = A
bestresults.B = B
bestresults.C = C
bestresults.D = D
bestresults.optimalA = A_optmse
bestresults.optimalB = B_optmse
bestresults.optimalC = C_optmse
bestresults.optimalD = D_optmse
bestresults.mse = mse
save bestresults_simulink.mat bestresults

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
A_value = A_optmse;
B_value = B_optmse;
C_value = C_optmse;
D_value = D_optmse;

figure(4);
simOut = sim('SSmodel.slx', 'StopTime', num2str(t(end)), 'FixedStep', num2str(1/100)); % Predict heart rate with simulink model
hr_predict = simOut.hr_simulink.signals.values(1:length(vel_train));

plot(t, hr_predict)
hold on
plot(t,hr_train)
legend("HR prediction","HR truth")
