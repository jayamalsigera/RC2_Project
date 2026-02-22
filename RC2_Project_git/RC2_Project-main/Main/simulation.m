%% Linear Trajectory Tracking Controller constants
a = 3;  % >0
xi = 0.7;  % (0,1)

%% Non linear Trajectory Tracking Controller constants
b = 5;  % >0
xi = 0.4;  % (0,1)

%% Parking box pose
x_box     = 850;
y_box     = 880;
theta_box = 0;

save('parking_box.mat', 'x_box', 'y_box', 'theta_box');

%% Gains for posture regulation
%k1 = 3;
%k2 = 1.5;  GAINS DI DAVIDE
%k3 = 2;

% Cartesian Regulation Gains
Kv = 1;
Kw = 4;
save("Cartesian_gains.mat", "Kv", "Kw");

% Posture Regulation Gains
K1 = 0.5;
K2 = 5;
K3 = 2;
save("Posture_gains.mat", "K1", "K2", "K3")

%% Simulation Variables

Ts = 0.001;


%% desired trajectory generation
S = load('trajectory.mat');   % contains S.traj.xy and S.traj.t

% unicycle initial conditions
x0 = S.traj.xy(1,1);
y0 = S.traj.xy(1,2);
theta0 = pi/4;

xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1] [belongs to (0,1)]

% simulation times
shift_time = t(end);  % time traj2reg
stop_time = t(end) + 10;  % stop simulation

ref = timeseries(xy, t);      % ref.Data is Nx2: [x_d y_d]

assignin('base','ref', ref);