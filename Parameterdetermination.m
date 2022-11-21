clear all, close all

%% Load data
data = load('final_data.mat');

%% Optimal parameter determination based on RSE/MSE

% Define parameter values to be tested
A = -1:0.01:1; % Values to test for A
D = -50:0.01:50; % Values to test for D
vel_train = data.final_data.acc; % Training values for velocity resulting from experiment
hr_train = data.final_data.hr'; % Training values for HR resulting from experiment
t = data.final_data.t_gen';

%% Select jogging measurement
start_index = 176765;
end_index = 268850;

hr_train = hr_train(start_index:end_index);
vel_train = vel_train(start_index:end_index);
t = t(1:(end_index-start_index+1));

%% Double for loop that calculates the RSE for different combinations of
% Parameters
hr_init = hr_train(1); % Initial HR value; resting HR
% hr = [];
% residuals = [];
% rse = [];

disp("");
disp("Started estimation of parameters..");

for i=1:length(A) % Run over values of A
    for j=1:length(D) % Run over values of D
        
        hr_predict = hr_init.*exp(A(i).*t) + D(j).*vel_train; % Predict heart rate with model
        
        %residuals = hr_train-hr; % Compare predicted HR and actual HR
        %rss = sum(residuals.^2); % Calculate residual sum of squares
        
        %rse(i,j) = sqrt(rss/(length(vel_train)-2)); % Calculate residual standard error for this set of parameters
        %mse(i,j) = rss/length(vel_train); % Calculate mean squared error for this set of parameters

        mse(i,j) = immse(hr_predict, hr_train);
    end

    if i == length(A)/2
        disp(50)
    end
end

%[row_rse, col_rse] = find(rse == min(rse(:))); % Find minimum value for RSE and corresponding values for A and D
%A_optrse = A(row_rse);
%D_optrse = D(col_rse);
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

%% Optimal parameter determination by visual inspection

% Define parameter values to be tested
A = -1:0.25:1; % Values to test for A
D = -20:10:20; % Values to test for D
vel_train = [1 2 3 4]; % Training values for velocity resulting from experiment
hr_train = [100 120 140 160]; % Training values for HR resulting from experiment
hr_init = 80; % Initial HR value; resting HR
t = 2; % Time after initiating effort

hr=[];
for i = 1:length(A) % Double for loop that calculates predicted HR value for the training velocities
    for j = 1:length(D)

        hr(i,j,:) = hr_init*exp(A(i)*t) + D(j).*vel_train; % Calculate predicted HR

    end 
end

A_plot = 1; % Value of A for which the plot must be made
D_plot = 10; % Value of D for which the plot must be made
A_pos = find(A == A_plot); % Index of desired A-value
D_pos = find(D == D_plot); % Index of desired D-value
hr_pred = [hr(A_pos,D_pos,1),hr(A_pos,D_pos,2),hr(A_pos,D_pos,3),hr(A_pos,D_pos,4)]; % Predicted HR for given values for A and D

figure(4); % Plot predicted and 
clf;
plot(vel_train, hr_train);
hold on;
plot(vel_train, hr_pred)
title(['Plots of predicted HR and actual HR at A = ',num2str(A_plot),', and B = ',num2str(D_plot)]);
xlabel('Velocity (m/s)');
ylabel('HR (bpm)');
legend('Actual HR','Predicted HR');

%% Optimal parameter determination using simulink

% Define parameter values to be tested
A = -100:10:100; % Values to test for A
B = -100:10:100; % Values to test for B
C = -100:10:100; % Values to test for C
D = -100:10:100; % Values to test for D
vel_train = [1 2 3 4]; % Training values for velocity resulting from experiment
hr_train = [100 120 140 160]; % Training values for HR resulting from experiment
hr_init = 80; % Initial HR value; resting HR
t = 2; % Time after initiating effort


% Double for loop that calculates the RSE for different combinations of
% parameters

hr = [];
residuals = [];
rse = [];

for i=1:length(A) % Run over values of A
    for j=1:length(B) % Run over values of B
        for k=1:length(C) % Run over values of C
            for l=1:length(D) % Run over values of D
        
                hr = hr_init*exp(A(i)*t) + D(j).*vel_train; % Predict heart rate with simulink model
                residuals = hr_train-hr; % Compare predicted HR and actual HR
                rss = sum(residuals.^2); % Calculate residual sum of squares
                
                rse(i,j) = sqrt(rss/(length(vel_train)-2)); % Calculate residual standard error for this set of parameters
                mse(i,j) = rss/length(vel_train); % Calculate mean squared error for this set of parameters
                    
            end
        end
    end
end

[row_rse, col_rse] = find(rse == min(rse(:))); % Find minimum value for RSE and corresponding values for A and D
A_optrse = A(row_rse);
B_optrse = B(row_rse);
C_optrse = C(row_rse);
D_optrse = D(col_rse);
[row_mse, col_mse] = find(mse == min(mse(:))); % Find minimum value for MSE and corresponding values for A and D
A_optmse = A(row_mse);
B_optmse = B(row_mse);
C_optmse = C(row_mse);
D_optmse = D(col_mse);

disp(['The optimal values for A, B, C and D based on the minimal MSE are ',num2str(A_optmse),', ',num2str(B_optmse),', ',num2str(C_optmse),', and ',num2str(D_optmse),', respectively.']);
