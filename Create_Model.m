%% load data
data = load("C:\Users\natha\OneDrive\Documenten\Project Module 3\Data\final_data.mat");
%% Optimal parameter determination based on RSE/MSE

% Define parameter values to be tested
A = -1:0.01:1; % Values to test for A
D = -200:0.01:1000; % Values to test for D
vel_train = [0.5 0.91 1.23 1.50]; % Training values for velocity resulting from experiment
hr_train = [100 140 170 180]; % Training values for HR resulting from experiment
hr_init = 80; % Initial HR value; resting HR
t = 2; % Time after initiating effort


% Double for loop that calculates the RSE for different combinations of
% parameters

hr = [];
residuals = [];
rse = [];

for i=1:length(A) % Run over values of A
    for j=1:length(D) % Run over values of D
        
        hr = hr_init*exp(A(i)*t) + D(j).*vel_train; % Predict heart rate with model
        residuals = hr_train-hr; % Compare predicted HR and actual HR
        rss = sum(residuals.^2); % Calculate residual sum of squares
        
        rse(i,j) = sqrt(rss/(length(vel_train)-2)); % Calculate residual standard error for this set of parameters
        mse(i,j) = rss/length(vel_train); % Calculate mean squared error for this set of parameters

    end
end

[row_rse, col_rse] = find(rse == min(rse(:))); % Find minimum value for RSE and corresponding values for A and D
A_optrse = A(row_rse);
D_optrse = D(col_rse);
[row_mse, col_mse] = find(mse == min(mse(:))); % Find minimum value for MSE and corresponding values for A and D
A_optmse = A(row_mse);
D_optmse = D(col_mse);

disp(['The optimal values for A and D based on the minimal MSE are ',num2str(A_optmse),' and ',num2str(D_optmse),', respectively.'])
disp(['The model then becomes: y(t) = ',num2str(A_optmse),'*e^(',num2str(A_optmse),'t) + ',num2str(D_optmse),'*u(t).']);

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

%% Optimal parameter determination by visual inspection

% Define parameter values to be tested
A = -1:0.25:1; % Values to test for A
D = -20:10:20; % Values to test for D
vel_train = [1 2 3 4]; % Training values for velocity resulting from experiment
hr_train = [100 120 140 160]; % Training values for HR resulting from experiment
hr_init = 80; % Initial HR value; resting HR
t = 2; % Time after initiating effort

figure(3);
hold on;
leg = [];
for i = 1:length(A) % Double for loop that calculates predicted HR value for the training velocities
    for j = 1:length(D)

        hr = hr_init*exp(A(i)*t) + D(j).*vel_train; % Calculate predicted HR

        plot(vel_train, hr);

        leg(i,j) = ['A = ',num2str(A(i)),', B = ' num2str(D(j)), '  '];

    end 
end

plot(vel_train, hr_train);
title('Plots of predicted HR and actual HR at different velocities at different values of A');
xlabel('Velocity (m/s)');
ylabel('HR (bpm)');
legend(leg);
