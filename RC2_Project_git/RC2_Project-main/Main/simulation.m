%% Linear Trajectory Tracking Controller constants
a = 3;  % >0
l_xi = 0.7;  % (0,1)

%% Non linear Trajectory Tracking Controller constants
b = 5;  % >0
nl_xi = 0.4;  % (0,1)

%% Parking box pose
x_box     = 850;
y_box     = 880;
theta_box = 0;

%% Gains for posture regulation
%k1 = 0.22;    
%k2 = 1.0;
%k3 = 0.4;

k1 = 3;
k2 = 1.5;
k3 = 2;

%% Simulation Variables
shift_time = 20;  % trajectory tracking time (before regulation)
stop_time = shift_time + 10;

%% desired trajectory generation
S = load('trajectory.mat');   % contains S.traj.xy and S.traj.t

% unicycle initial conditions
x0 = S.traj.xy(1,1);
y0 = S.traj.xy(1,2);
theta0 = pi/4;

xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1] [belongs to (0,1)]

% last (x,y) to be tracked
%last_t = size(xy, 1)-1;
%assignin('base','last_t', last_t);

Tfinal = shift_time;           % seconds
t = t * Tfinal;

ref = timeseries(xy, t);      % ref.Data is Nx2: [x_d y_d]

assignin('base','ref', ref);