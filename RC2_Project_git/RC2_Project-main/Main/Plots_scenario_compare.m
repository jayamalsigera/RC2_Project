%% Plot to compare performance on tuning simulation

close all; % Decommenta se vuoi chiudere le figure precedenti prima di plottare

% Definiamo i colori per il plot
c_L  = '#0072BD';  % Blu per controllore Lineare
c_NL = '#D95319';  % Arancione per controllore Non Lineare

figure('Name', 'Linear vs Non-Linear Trajectory Tracking', 'Position', [100, 100, 1200, 600]);

% --- Plot X-Y (Trajectory) ---
subplot(1, 2, 1); hold on; grid on;
% Reference
plot(ref.Data(:, 1), ref.Data(:, 2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Reference');
% Linear Actual
plot(L.q(:, 1), L.q(:, 2), 'Color', c_L, 'LineWidth', 1.5, 'DisplayName', 'Linear Traj');
% Non-Linear Actual
plot(NL.q(:, 1), NL.q(:, 2), 'Color', c_NL, 'LineWidth', 1.5, 'DisplayName', 'Non-Linear Traj');

title('XY Path - Trajectory Tracking Comparison');
xlabel('X [cm]'); ylabel('Y [cm]'); axis equal;
lgd1 = legend('Location', 'best');
lgd1.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Linear Velocity Plot ---
subplot(2, 2, 2); hold on; grid on;
% Reference v_d (usiamo quella salvata in L, assumendo sia identica per la stessa ref trajectory)
plot(L.t, L.vd_wd(:, 1), '--', 'Color', "k", 'LineWidth', 1, 'DisplayName', 'v_d');
% Linear v
plot(L.t, L.vw(:, 1), '-', 'Color', c_L, 'LineWidth', 1.5, 'DisplayName', 'v (Linear)');
% Non-Linear v
plot(NL.t, NL.vw(:, 1), '-', 'Color', c_NL, 'LineWidth', 1.5, 'DisplayName', 'v (Non-Linear)');

title('Linear Velocity'); xlabel('Time [s]'); ylabel('v [cm/s]'); 
xlim([0, shift_time]); 
lgd2 = legend('Location', 'best');
lgd2.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));

% --- Angular Velocity Plot ---
subplot(2, 2, 4); hold on; grid on;
% Reference omega_d
plot(L.t, L.vd_wd(:, 2), '--', 'Color', "k", 'LineWidth', 1, 'DisplayName', '\omega_d');
% Linear omega
plot(L.t, L.vw(:, 2), '-', 'Color', c_L, 'LineWidth', 1.5, 'DisplayName', '\omega (Linear)');
% Non-Linear omega
plot(NL.t, NL.vw(:, 2), '-', 'Color', c_NL, 'LineWidth', 1.5, 'DisplayName', '\omega (Non-Linear)');

title('Angular Velocity'); xlabel('Time [s]'); ylabel('\omega [rad/s]'); 
xlim([0, shift_time]); 
lgd3 = legend('Location', 'best');
lgd3.ItemHitFcn = @(~, evt) set(evt.Peer, 'Visible', ~strcmp(evt.Peer.Visible, 'on'));