%% Phase 1: Complex Pac-Man Scenario Generation
clear; clc; close all;

%% 1. Map Configuration
% The map in your image is wide. Let's define a 20m x 10m world.
map_width = 20;
map_height = 10;
resolution = 20; % Cells per meter (High resolution for smooth walls)

% Create the Binary Occupancy Grid
map = binaryOccupancyMap(map_width, map_height, resolution);

%% 2. Construct the Walls (Geometric Approach)
% We define obstacles as [x, y, width, height] rectangles.
obstacles = [
    % --- Outer Borders ---
    [0, 0, 20, 0.5];        % Bottom border
    [0, 9.5, 20, 0.5];      % Top border
    [0, 0, 0.5, 10];        % Left border
    [19.5, 0, 0.5, 10];     % Right border
    
    % --- The Central "Ghost House" (Parking Box) ---
    [8, 3.5, 4, 0.2];       % Bottom of box
    [8, 6.3, 4, 0.2];       % Top of box
    [12, 3.5, 0.2, 3];      % Right of box
    [8, 3.5, 0.2, 1];       % Left of box (Lower part)
    [8, 5.5, 0.2, 1];       % Left of box (Upper part) -> Gap in middle
    
    % --- Left Side Obstacles ---
    [2.5, 2.5, 0.5, 5];     % Vertical bar left
    [2.5, 7.5, 3, 0.5];     % Horizontal top-left
    [2.5, 2.0, 3, 0.5];     % Horizontal bottom-left
    [5.0, 4.0, 0.5, 2.0];   % Small vertical T-piece
    
    % --- Top/Bottom Vertical Separators ---
    [6.5, 7.0, 0.5, 2.5];   % Top vertical divider
    [6.5, 0.5, 0.5, 2.5];   % Bottom vertical divider
    
    % --- Right Side Obstacles ---
    [13.5, 7.0, 0.5, 2.5];  % Top vertical
    [13.5, 0.5, 0.5, 2.5];  % Bottom vertical
    [15.5, 2.5, 0.5, 5];    % Vertical bar right
    [15.5, 7.5, 3, 0.5];    % Horizontal top-right
    [15.5, 2.0, 3, 0.5];    % Horizontal bottom-right
];

% --- FIX STARTS HERE ---
% Apply obstacles to the map by filling the rectangles with points
for i = 1:size(obstacles, 1)
    % Extract rectangle parameters
    x0 = obstacles(i, 1);
    y0 = obstacles(i, 2);
    w  = obstacles(i, 3);
    h  = obstacles(i, 4);
    
    % Generate a grid of points inside this rectangle
    % We use a step size smaller than the map resolution to ensure no gaps
    step_size = 1 / (resolution * 2); 
    [X_pts, Y_pts] = meshgrid(x0:step_size:x0+w, y0:step_size:y0+h);
    
    % Convert 2D grid matrices into a single list of [x, y] points
    points_to_occupy = [X_pts(:), Y_pts(:)];
    
    % Set these specific points as occupied
    setOccupancy(map, points_to_occupy, 1);
end


% Inflate walls slightly for safety (optional)
inflate(map, 0.2);

%% 3. Generate the "Red Line" Trajectory
% We define waypoints that mimic the red curve in your image:
% Starts Left -> Curves Up -> Goes Right -> Snakes Down -> Enters Box
%% Phase 3: Unicycle Tracking Control with Animation
clear; clc; close all;

%% 1. Setup Environment & Path
% (Re-defining map briefly to ensure script is standalone)
map_width = 20; map_height = 10;
map = binaryOccupancyMap(map_width, map_height, 20);
obstacles = [
    0,0,20,0.5; 0,9.5,20,0.5; 0,0,0.5,10; 19.5,0,0.5,10; % Borders
    8,3.5,4,0.2; 8,6.3,4,0.2; 12,3.5,0.2,3; 8,3.5,0.2,1; 8,5.5,0.2,1; % Box
    2.5,2.5,0.5,5; 2.5,7.5,3,0.5; 2.5,2.0,3,0.5; 5.0,4.0,0.5,2.0; % Left
    6.5,7.0,0.5,2.5; 6.5,0.5,0.5,2.5; % Dividers
    13.5,7.0,0.5,2.5; 13.5,0.5,0.5,2.5; 15.5,2.5,0.5,5; 15.5,7.5,3,0.5; 15.5,2.0,3,0.5 % Right
];
% Fill obstacles
for i=1:size(obstacles,1)
    [X,Y] = meshgrid(obstacles(i,1):0.05:obstacles(i,1)+obstacles(i,3), ...
                     obstacles(i,2):0.05:obstacles(i,2)+obstacles(i,4));
    setOccupancy(map, [X(:) Y(:)], 1);
end
inflate(map, 0.2); % Safety padding

% Define Waypoints (The Red Line)
waypoints = [1,5; 1.6,7.5; 1.8,9; 5,8.7; 6,7; 6,6; 7.5,5; 8,5; 9,5; 10,4.8]';
t_wp = 0:size(waypoints,2)-1; 
t_final = t_wp(end);

%% 2. Generate Reference Signals (The "Ghost")
dt = 0.05; % Time step
t_sim = 0:dt:t_final;

% Spline Interpolation for x_r, y_r
x_r = spline(t_wp, waypoints(1,:), t_sim);
y_r = spline(t_wp, waypoints(2,:), t_sim);

% Calculate Derivatives for Feedforward Control
dx_r = gradient(x_r, dt);   dy_r = gradient(y_r, dt);
ddx_r = gradient(dx_r, dt); ddy_r = gradient(dy_r, dt);

% Reference Velocities (v_ref, w_ref)
v_ref = sqrt(dx_r.^2 + dy_r.^2);
theta_ref = atan2(dy_r, dx_r); 
w_ref = (dx_r.*ddy_r - dy_r.*ddx_r) ./ (dx_r.^2 + dy_r.^2 + 1e-6);

%% 3. Simulation Initialization
% Initial Robot State [x, y, theta]
% We start slightly OFF the path to prove the controller works!
q = [1.5; 4.5; pi/2]; 

% Controller Gains (Tunable)
zeta = 0.6;  % Damping
g = 8;       % Natural frequency
% These gains define how aggressively the robot corrects errors

% Data logging
history_q = [];
history_e = [];

%% 4. Animation Setup
figure('Color','k','Position',[100 100 1000 500]);
ax = axes('Color','k','XColor','w','YColor','w');
show(map, 'Parent', ax); hold on; axis equal;
plot(x_r, y_r, 'r--', 'LineWidth', 1); % Draw path
pacman_body = []; % Handle for the robot graphics

disp('Starting Simulation... Press Ctrl+C to stop early.');

%% 5. Main Control Loop
for k = 1:length(t_sim)
    % A. Current State
    x = q(1); y = q(2); theta = q(3);
    
    % B. Current Reference
    xr = x_r(k); yr = y_r(k); tr = theta_ref(k);
    vr = v_ref(k); wr = w_ref(k);
    
    % C. Error Calculation (in Robot Frame)
    ex = cos(theta)*(xr - x) + sin(theta)*(yr - y);
    ey = -sin(theta)*(xr - x) + cos(theta)*(yr - y);
    eth = tr - theta;
    % Normalize angle error to [-pi, pi]
    eth = atan2(sin(eth), cos(eth)); 
    
    % D. NONLINEAR CONTROL LAW (Kanayama / Samson)
    % This is the standard "Tracking" controller
    k1 = 2 * zeta * g; 
    k2 = g^2;         % Stiffness
    k3 = k1;
    
    % Control Inputs
    v_cmd = vr * cos(eth) + k1 * ex;
    w_cmd = wr + vr * (k2 * ey + k3 * sin(eth));
    
    % E. Update Robot Dynamics (Euler Integration)
    q(1) = q(1) + v_cmd * cos(q(3)) * dt;
    q(2) = q(2) + v_cmd * sin(q(3)) * dt;
    q(3) = q(3) + w_cmd * dt;
    
    % F. Collision Check
    if checkOccupancy(map, [q(1) q(2)])
        title('CRASH! GAME OVER', 'Color', 'r', 'FontSize', 20);
        break;
    end
    
    % --- ANIMATION ---
    if mod(k, 2) == 0 % Update every 2nd frame for speed
        if ~isempty(pacman_body), delete(pacman_body); end
        
        % Draw Pac-Man (Yellow Circle with Mouth)
        pacman_body = draw_pacman(q(1), q(2), q(3), 0.4, ax);
        
        title(sprintf('Time: %.2fs | Error: %.2fm', t_sim(k), sqrt(ex^2+ey^2)), 'Color','w');
        drawnow;
    end
    
    % Store History
    history_q = [history_q, q];
end

%% Helper Function: Draw Pac-Man
function h = draw_pacman(x, y, theta, size, ax)
    % Create a "pie chart" wedge shape
    t = linspace(0.5, 2*pi-0.5, 20); % The mouth opening
    % Rotate points by theta
    x_c = size/2 * cos(t + theta) + x;
    y_c = size/2 * sin(t + theta) + y;
    
    % Add center point to close the wedge
    x_c = [x, x_c, x];
    y_c = [y, y_c, y];
    
    h = fill(ax, x_c, y_c, 'y', 'EdgeColor', 'k');
end

%% 4. Define Goal & Parking Zone
box_area = [8.5, 4.0, 3, 2]; % [x, y, w, h] Visual rectangle for the "Red Square"
goal_pos = [10.0, 4.8, 0];   % Exact parking spot [x, y, theta]

%% 5. Visualization (Matching your Image Style)
figure('Color', 'k', 'Position', [100, 100, 1000, 500]);
ax = axes;
set(ax, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');
hold on; axis equal;

% A. Draw Map Walls (Neon Blue Outline)
show(map, 'Parent', ax);
% The default map is black/white. Let's customize it.
% We overlay the walls with neon blue lines for the "Tron/Pacman" look.
for i = 1:size(obstacles, 1)
    obs = obstacles(i,:);
    rectangle('Position', obs, 'FaceColor', [0 0.1 0.3], 'EdgeColor', [0 0.8 1], 'LineWidth', 2);
end

% B. Draw the Parking Box (Red Square)
rectangle('Position', [9.5, 4.3, 1, 1], 'FaceColor', 'r', 'EdgeColor', 'w', 'LineWidth', 2);

% C. Draw the Trajectory (Red Line)
plot(path_x, path_y, 'r-', 'LineWidth', 3);
plot(waypoints(1,:), waypoints(2,:), 'r.', 'MarkerSize', 15); % Debug dots

% D. Draw Start and End
plot(waypoints(1,1), waypoints(2,1), 'go', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'g');
text(waypoints(1,1), waypoints(2,1)-0.5, 'START', 'Color', 'g', 'FontWeight', 'bold');

title('Phase 1: Pac-Man Scenario Layout', 'Color', 'w', 'FontSize', 14);
xlabel('X [m]'); ylabel('Y [m]');
xlim([0 map_width]); ylim([0 map_height]);

%% 6. Save Data
% Save the map and trajectory for Phase 2/3
ref_trajectory = [path_x; path_y];
save('pacman_scenario_data.mat', 'map', 'ref_trajectory', 'goal_pos');