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