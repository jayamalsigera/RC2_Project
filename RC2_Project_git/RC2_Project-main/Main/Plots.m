%% 1. Inizialization
clc; close all;

% load data
S = load('trajectory.mat');
xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1] 
%Tfinal = shift_time;           % seconds
%t = t * Tfinal;          %------------- TO BE MODIFIED --------------------
%ref = timeseries(xy, t);
shift_time = t(end);
stop_time = t(end) + 10;

ref = timeseries(xy, t);  

load('results.mat', 'res'); 
load('parking_box.mat');

% colours for the plot
cL  = '#0072BD'; % Blu for linear controller
cNL = '#D95319'; % red for non-linear controller + posture 1
cNL2= '#EDB120'; % yellow for non-linear controller + posture 2

%% 2. Trajectory Tracking Plots ( t <= shift_time )

% Traj Track Indexes
idx_L_traj  = res.L.t <= shift_time;
idx_NL_traj = res.NL.t <= shift_time;
idx_NL2_traj= res.NL2.t <= shift_time;

figure('Name', 'Trajectory Tracking Phase', 'Position', [100, 100, 1200, 600]);

% --- Plot X-Y (Trajectory) ---
subplot(1, 2, 1);
hold on; grid on;
plot(ref.Data(:, 1), ref.Data(:, 2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Reference');
plot(res.L.q(idx_L_traj, 1), res.L.q(idx_L_traj, 2), 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear');
plot(res.NL.q(idx_NL_traj, 1), res.NL.q(idx_NL_traj, 2), 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL 1');
plot(res.NL2.q(idx_NL2_traj, 1), res.NL2.q(idx_NL2_traj, 2), 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL 2');
title('XY Path - Trajectory Tracking');
xlabel('X [m]'); ylabel('Y [m]');
legend('Location', 'best');
axis equal;

% --- Linear Velocity Plot ---
subplot(2, 2, 2);
hold on; grid on;
% Desired velocity (vd) - dashed
plot(res.L.t(idx_L_traj), res.L.vd(idx_L_traj), '--', 'Color', cL, 'LineWidth', 1, 'DisplayName', 'L v_d');
plot(res.NL.t(idx_NL_traj), res.NL.vd(idx_NL_traj), '--', 'Color', cNL, 'LineWidth', 1, 'DisplayName', 'NL1 v_d');
plot(res.NL2.t(idx_NL2_traj), res.NL2.vd(idx_NL2_traj), '--', 'Color', cNL2, 'LineWidth', 1, 'DisplayName', 'NL2 v_d');
% Linear velocity input (v) - continue
plot(res.L.t(idx_L_traj), res.L.v(idx_L_traj), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L v');
plot(res.NL.t(idx_NL_traj), res.NL.v(idx_NL_traj), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL1 v');
plot(res.NL2.t(idx_NL2_traj), res.NL2.v(idx_NL2_traj), '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL2 v');
title('Linear Velocity (v_d, v)');
xlabel('Time [s]'); ylabel('v [m/s]');
legend('Location', 'best'); 

% --- Angular Velocity Plot ---
subplot(2, 2, 4);
hold on; grid on;
% Desired input (wd) - dashed
plot(res.L.t(idx_L_traj), res.L.wd(idx_L_traj), '--', 'Color', cL, 'LineWidth', 1, 'DisplayName', 'L wd');
plot(res.NL.t(idx_NL_traj), res.NL.wd(idx_NL_traj), '--', 'Color', cNL, 'LineWidth', 1, 'DisplayName', 'NL1 wd');
plot(res.NL2.t(idx_NL2_traj), res.NL2.wd(idx_NL2_traj), '--', 'Color', cNL2, 'LineWidth', 1, 'DisplayName', 'NL2 wd');
% Angular velocity input (w) - continue
plot(res.L.t(idx_L_traj), res.L.w(idx_L_traj), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L w');
plot(res.NL.t(idx_NL_traj), res.NL.w(idx_NL_traj), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL1 w');
plot(res.NL2.t(idx_NL2_traj), res.NL2.w(idx_NL2_traj), '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL2 w');
title('Angular Velocity (\omega, \omega_d)');
xlabel('Time [s]'); ylabel('\omega [rad/s]');
legend("location", "best")

%% 3. Posture Regulation ( t > shift_time )

% Regulation Indexes
idx_L_reg  = res.L.t > shift_time;
idx_NL_reg = res.NL.t > shift_time;
idx_NL2_reg= res.NL2.t > shift_time;

figure('Name', 'Posture Regulation Phase', 'Position', [150, 150, 1200, 800]);

% --- Plot X-Y (Trajectory to the box) ---
subplot(1, 2, 1);
hold on; grid on;
plot(x_box, y_box, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'DisplayName', 'Target Box');
plot(res.L.q(idx_L_reg, 1), res.L.q(idx_L_reg, 2), 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear');
plot(res.NL.q(idx_NL_reg, 1), res.NL.q(idx_NL_reg, 2), 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL1');
plot(res.NL2.q(idx_NL2_reg, 1), res.NL2.q(idx_NL2_reg, 2), 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL2');
title('XY Path - Regulation to Box');
xlabel('X [m]'); ylabel('Y [m]');
legend('Location', 'best');
axis equal;

% --- Distance Error Plot ---
subplot(3, 2, 2);
hold on; grid on;
dist_L = sqrt((res.L.q(idx_L_reg, 1) - x_box).^2 + (res.L.q(idx_L_reg, 2) - y_box).^2);
dist_NL = sqrt((res.NL.q(idx_NL_reg, 1) - x_box).^2 + (res.NL.q(idx_NL_reg, 2) - y_box).^2);
dist_NL2 = sqrt((res.NL2.q(idx_NL2_reg, 1) - x_box).^2 + (res.NL2.q(idx_NL2_reg, 2) - y_box).^2);

plot(res.L.t(idx_L_reg), dist_L, '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L error');
plot(res.NL.t(idx_NL_reg), dist_NL, '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL1 error');
plot(res.NL2.t(idx_NL2_reg), dist_NL2, '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL2 error');
title('Distance Error to Target');
ylabel('Distance [m]');
legend('Location', 'best');

% --- Linear velocity plot v ---
subplot(3, 2, 4);
hold on; grid on;
% Attuali (v) - continue
plot(res.L.t(idx_L_reg), res.L.v(idx_L_reg), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L v');
plot(res.NL.t(idx_NL_reg), res.NL.v(idx_NL_reg), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL1 v');
plot(res.NL2.t(idx_NL2_reg), res.NL2.v(idx_NL2_reg), '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL2 v');
title('Linear Velocity v - regulation');
ylabel('v [m/s]');
legend("location", "best")


% --- Angular velocity plot w ---
subplot(3, 2, 6);
hold on; grid on;
% Attuali (w) - continue
plot(res.L.t(idx_L_reg), res.L.w(idx_L_reg), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L w');
plot(res.NL.t(idx_NL_reg), res.NL.w(idx_NL_reg), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL1 w');
plot(res.NL2.t(idx_NL2_reg), res.NL2.w(idx_NL2_reg), '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL2 w');
title('Angular Velocity \omega - regulation');
xlabel('Time [s]'); ylabel('\omega [rad/s]');
legend("location", "best")