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
cL     = '#0072BD'; % Blue for linear
cNL    = '#D95319'; % Orange for non-linear
c_C    = '#EDB120'; % Yellow for Cartesian Reg.
c_P    = '#7E2F8E'; % Purple for Posture Reg.

%% 2. Trajectory Tracking Phase (L vs NL) ( t <= shift_time )
idx_L_traj  = res.L.t <= shift_time;
idx_NL_traj = res.NL.t <= shift_time;

figure('Name', 'Trajectory Tracking: Linear vs Non-Linear', 'Position', [100, 100, 1200, 600]);

% --- Plot X-Y (Trajectory) ---
subplot(1, 2, 1); hold on; grid on;
plot(ref.Data(:, 1), ref.Data(:, 2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Reference');
plot(res.L.q(idx_L_traj, 1), res.L.q(idx_L_traj, 2), 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear');
plot(res.NL.q(idx_NL_traj, 1), res.NL.q(idx_NL_traj, 2), 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'Non-Linear');
title('XY Path - Trajectory Tracking');
xlabel('X [cm]'); ylabel('Y [cm]'); axis equal;
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Linear Velocity Plot ---
subplot(2, 2, 2); hold on; grid on;
plot(res.L.t(idx_L_traj), res.L.vd(idx_L_traj), '--', 'Color', "k", 'LineWidth', 1, 'DisplayName', 'v_d');
plot(res.L.t(idx_L_traj), res.L.v(idx_L_traj), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear v');
plot(res.NL.t(idx_NL_traj), res.NL.v(idx_NL_traj), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'Non-Linear v');
title('Linear Velocity'); ylabel('v [cm/s]'); 
xlim([0, shift_time]); % Limite bloccato alla fine del tracking

% --- Angular Velocity Plot ---
subplot(2, 2, 4); hold on; grid on;
plot(res.L.t(idx_L_traj), res.L.wd(idx_L_traj), '--', 'Color', "k", 'LineWidth', 1, 'DisplayName', '\omega_d');
plot(res.L.t(idx_L_traj), res.L.w(idx_L_traj), '-', 'Color', cL, 'LineWidth', 1.5, 'DisplayName', 'Linear \omega');
plot(res.NL.t(idx_NL_traj), res.NL.w(idx_NL_traj), '-', 'Color', cNL, 'LineWidth', 1.5, 'DisplayName', 'Non-Linear \omega');
title('Angular Velocity'); xlabel('Time [s]'); ylabel('\omega [rad/s]'); 
xlim([0, shift_time]); % Limite bloccato alla fine del tracking

%% 3. Regulation Phase (Cartesian vs Posture) ( t > shift_time )
idx_Cart_reg = res.NL.t > shift_time;
idx_Post_reg = res.NL2.t > shift_time;
t_end_reg = max(res.NL.t(end), res.NL2.t(end)); % Trova il tempo finale effettivo

figure('Name', 'Regulation Phase: Cartesian vs Posture', 'Units', 'normalized', 'Position', [0.05, 0.1, 0.9, 0.8]);

% --- COLONNA CENTRALE: XY Path ---
subplot(2, 3, [2, 5]); hold on; grid on;
plot(x_box, y_box, 'ks', 'MarkerSize', 15, 'MarkerFaceColor', 'k', 'DisplayName', 'Target Box');
plot(res.NL.q(idx_Cart_reg, 1), res.NL.q(idx_Cart_reg, 2), '-', 'Color', c_C, 'LineWidth', 1.5, 'DisplayName', 'Cartesian');
plot(res.NL2.q(idx_Post_reg, 1), res.NL2.q(idx_Post_reg, 2), '-', 'Color', c_P, 'LineWidth', 1.5, 'DisplayName', 'Posture');
title('XY Path - Regulation');
xlabel('X [cm]'); ylabel('Y [cm]'); axis equal;
lgd = legend('Location', 'best');
lgd.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- COLONNA SINISTRA ALTA: Distance Error ---
subplot(2, 3, 1); hold on; grid on;
dist_Cart = sqrt((res.NL.q(idx_Cart_reg, 1) - x_box).^2 + (res.NL.q(idx_Cart_reg, 2) - y_box).^2);
dist_Post = sqrt((res.NL2.q(idx_Post_reg, 1) - x_box).^2 + (res.NL2.q(idx_Post_reg, 2) - y_box).^2);
plot(res.NL.t(idx_Cart_reg), dist_Cart, '-', 'Color', c_C, 'LineWidth', 1.5);
plot(res.NL2.t(idx_Post_reg), dist_Post, '-', 'Color', c_P, 'LineWidth', 1.5);
title('Distance Error'); ylabel('[cm]'); xlim([shift_time, t_end_reg]);

% --- COLONNA SINISTRA BASSA: Linear velocity v ---
subplot(2, 3, 4); hold on; grid on;
plot(res.NL.t(idx_Cart_reg), res.NL.v(idx_Cart_reg), '-', 'Color', c_C, 'LineWidth', 1.5);
plot(res.NL2.t(idx_Post_reg), res.NL2.v(idx_Post_reg), '-', 'Color', c_P, 'LineWidth', 1.5);
title('Linear Velocity v'); xlabel('Time [s]'); ylabel('[cm/s]'); xlim([shift_time, t_end_reg]);

% --- COLONNA DESTRA ALTA: Theta ---
subplot(2, 3, 3); hold on; grid on;
yline(0, 'k--', 'LineWidth', 1.5);
plot(res.NL.t(idx_Cart_reg), res.NL.q(idx_Cart_reg, 3), '-', 'Color', c_C, 'LineWidth', 1.5);
plot(res.NL2.t(idx_Post_reg), res.NL2.q(idx_Post_reg, 3), '-', 'Color', c_P, 'LineWidth', 1.5);
title('Orientation Angle \theta'); ylabel('[rad]'); xlim([shift_time, t_end_reg]);

% --- COLONNA DESTRA BASSA: Angular velocity w ---
subplot(2, 3, 6); hold on; grid on;
plot(res.NL.t(idx_Cart_reg), res.NL.w(idx_Cart_reg), '-', 'Color', c_C, 'LineWidth', 1.5);
plot(res.NL2.t(idx_Post_reg), res.NL2.w(idx_Post_reg), '-', 'Color', c_P, 'LineWidth', 1.5);
title('Angular Velocity \omega'); xlabel('Time [s]'); ylabel('[rad/s]'); xlim([shift_time, t_end_reg]);