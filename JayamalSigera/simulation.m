%% Linear Trajectory Tracking Controller constants:

a = 3;
xi = 0.6;

%% Non linear Trajectory Tracking Controller constants:

b = 5;
xi = 0.6;

%% Parking box pose
x_box     = 850;
y_box     = 880;
theta_box = 0;


%% Gains for posture regulation
k1 = 0.22;    
k2 = 1.0;     
k3 = 0.4;

%% Simulation Variables

shift_time = 20;
stop_time = shift_time + 10;

%% desired trajectory generation

S = load('trajectory.mat');   % contains S.traj.xy and S.traj.t
xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1]

Tfinal = shift_time;           % seconds
t = t * Tfinal;

ref = timeseries(xy, t);      % ref.Data is Nx2: [x_d y_d]

assignin('base','ref', ref);