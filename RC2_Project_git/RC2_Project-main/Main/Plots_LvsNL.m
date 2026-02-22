%% 1. Initialization
clc; close all;
% load data
S = load('trajectory.mat');
xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1] 
shift_time = t(end);
stop_time = t(end) + 10;
ref = timeseries(xy, t);  
load('results.mat', 'res'); 
load('parking_box.mat');
% colours for the plot
cL  = '#0072BD'; % Blue for linear controller
cNL = '#D95319'; % Red for non-linear controller + posture 1
cNL2= '#EDB120'; % Yellow for non-linear controller + posture 2

%% 2. Trajectory Tracking Plots (L-NL are the same of L2-NL2) ( t <= shift_time )
idx_L_traj  = res.L.t <= shift_time;
idx_NL_traj = res.NL.t <= shift_time;
figure('Name', 'Trajectory Tracking Phase: L vs NL', 'Position', [100, 100, 1200, 600]);

% --- Plot X-Y (Trajectory) ---
subplot(1, 2, 1); hold on; grid on;
plot(ref.Data(:, 1), ref.Data(:, 2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Reference');
plot(res.L.q(idx_L_traj, 1), res.L.q(idx_L_traj, 2), 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear');
plot(res.NL.q(idx_NL_traj, 1), res.NL.q(idx_NL_traj, 2), 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'Non-Linear');
title('XY Path - Trajectory Tracking (Linear vs Non-Linear)');
xlabel('X [cm]'); ylabel('Y [cm]'); axis equal;
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Linear Velocity Plot ---
subplot(2, 2, 2); hold on; grid on;
plot(res.L.t(idx_L_traj), res.L.vd(idx_L_traj), '--', 'Color', "k", 'LineWidth', 1, 'DisplayName', 'Flatness v_d');
plot(res.L.t(idx_L_traj), res.L.v(idx_L_traj), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L v');
plot(res.NL.t(idx_NL_traj), res.NL.v(idx_NL_traj), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL v');
title('Linear Velocity (v_d, v)');
xlabel('Time [s]'); ylabel('v [cm/s]'); 
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Angular Velocity Plot ---
subplot(2, 2, 4); hold on; grid on;
plot(res.L.t(idx_L_traj), res.L.wd(idx_L_traj), '--', 'Color', "k", 'LineWidth', 1, 'DisplayName', 'Flatness \omega_d');
plot(res.L.t(idx_L_traj), res.L.w(idx_L_traj), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L w');
plot(res.NL.t(idx_NL_traj), res.NL.w(idx_NL_traj), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL w');
title('Angular Velocity (\omega, \omega_d)');
xlabel('Time [s]'); ylabel('\omega [rad/s]'); 
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

%% Posture Regulation 1 PLOTS (L e NL) ( t > shift_time )
idx_L_reg  = res.L.t > shift_time;
idx_NL_reg = res.NL.t > shift_time;
figure('Name', 'Posture Regulation Phase: L vs NL', 'Position', [150, 150, 1200, 800]);

% --- Plot X-Y (Trajectory to the box) ---
subplot(1, 2, 1); hold on; grid on;
plot(x_box, y_box, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'DisplayName', 'Target Box');
plot(res.L.q(idx_L_reg, 1), res.L.q(idx_L_reg, 2), 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear (L)');
plot(res.NL.q(idx_NL_reg, 1), res.NL.q(idx_NL_reg, 2), 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'Non-Linear (NL1)');
title('XY Path - Regulation to Box (L vs NL)');
xlabel('X [cm]'); ylabel('Y [cm]'); axis equal;
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Distance Error Plot ---
subplot(3, 2, 2); hold on; grid on;
dist_L = sqrt((res.L.q(idx_L_reg, 1) - x_box).^2 + (res.L.q(idx_L_reg, 2) - y_box).^2);
dist_NL = sqrt((res.NL.q(idx_NL_reg, 1) - x_box).^2 + (res.NL.q(idx_NL_reg, 2) - y_box).^2);
plot(res.L.t(idx_L_reg), dist_L, '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L error');
plot(res.NL.t(idx_NL_reg), dist_NL, '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL1 error');
title('Distance Error to Target'); ylabel('Distance [cm]'); 
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Linear velocity plot v ---
subplot(3, 2, 4); hold on; grid on;
plot(res.L.t(idx_L_reg), res.L.v(idx_L_reg), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L v');
plot(res.NL.t(idx_NL_reg), res.NL.v(idx_NL_reg), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL1 v');
title('Linear Velocity v - regulation'); ylabel('v [cm/s]'); 
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Angular velocity plot w ---
subplot(3, 2, 6); hold on; grid on;
plot(res.L.t(idx_L_reg), res.L.w(idx_L_reg), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L w');
plot(res.NL.t(idx_NL_reg), res.NL.w(idx_NL_reg), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'NL1 w');
title('Angular Velocity \omega - regulation');
xlabel('Time [s]'); ylabel('\omega [rad/s]'); 
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

%% Posture Regulation 2 PLOTS (L2 e NL2) ( t > shift_time )
idx_L2_reg  = res.L2.t > shift_time;
idx_NL2_reg = res.NL2.t > shift_time;
figure('Name', 'Posture Regulation Phase: L2 vs NL2', 'Position', [250, 250, 1200, 800]);

% --- Plot X-Y (Trajectory to the box) ---
subplot(1, 2, 1); hold on; grid on;
plot(x_box, y_box, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'DisplayName', 'Target Box');
plot(res.L2.q(idx_L2_reg, 1), res.L2.q(idx_L2_reg, 2), 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear (L2)');
plot(res.NL2.q(idx_NL2_reg, 1), res.NL2.q(idx_NL2_reg, 2), 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'Non-Linear (NL2)');
title('XY Path - Regulation to Box (L2 vs NL2)');
xlabel('X [cm]'); ylabel('Y [cm]'); axis equal;
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Distance Error Plot ---
subplot(3, 2, 2); hold on; grid on;
dist_L2 = sqrt((res.L2.q(idx_L2_reg, 1) - x_box).^2 + (res.L2.q(idx_L2_reg, 2) - y_box).^2);
dist_NL2 = sqrt((res.NL2.q(idx_NL2_reg, 1) - x_box).^2 + (res.NL2.q(idx_NL2_reg, 2) - y_box).^2);
plot(res.L2.t(idx_L2_reg), dist_L2, '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L2 error');
plot(res.NL2.t(idx_NL2_reg), dist_NL2, '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL2 error');
title('Distance Error to Target'); ylabel('Distance [cm]'); 
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Linear velocity plot v ---
subplot(3, 2, 4); hold on; grid on;
plot(res.L2.t(idx_L2_reg), res.L2.v(idx_L2_reg), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L2 v');
plot(res.NL2.t(idx_NL2_reg), res.NL2.v(idx_NL2_reg), '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL2 v');
title('Linear Velocity v - regulation'); ylabel('v [cm/s]'); 
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Angular velocity plot w ---
subplot(3, 2, 6); hold on; grid on;
plot(res.L2.t(idx_L2_reg), res.L2.w(idx_L2_reg), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'L2 w');
plot(res.NL2.t(idx_NL2_reg), res.NL2.w(idx_NL2_reg), '-', 'Color', cNL2, 'LineWidth', 1.5, 'DisplayName', 'NL2 w');
title('Angular Velocity \omega - regulation');
xlabel('Time [s]'); ylabel('\omega [rad/s]'); 
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));