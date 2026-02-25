%% Simulation Variables


scale = 15;
v_des = 50;
type = 'square';

run('draw_simply_scenarios(scale, type, v_des)');
uiwait(gcf);  % wait until figure is closed

%% desired trajectory generation
S = load('trajectory.mat');   % contains S.traj.xy and S.traj.t

% unicycle initial conditions
x0 = S.traj.xy(1,1);
y0 = S.traj.xy(1,2);
theta0 = pi/4;

xy = S.traj.xy;               % [N x 2]
t  = S.traj.t;                % [N x 1]


shift_time = t(end);

ref = timeseries(xy, t);      % ref.Data is Nx2: [x_d y_d]

assignin('base','ref', ref);

%% 4. Run First Simulink Program and save results

Ts = 0.001;
model1 = 'L_tuning';

% Linear Trajectory Tracking Controller constants
a = 15;  % >0
xi = 0.6;  % (0,1)

load_system(model1);

set_param(model1, 'StopTime', num2str(shift_time));
sim(model1);

L.t = tout;
L.q = q.Data;
L.vw = vw.Data;
L.vd_wd = vd_wd.Data;


%% Replay the saved data

replay_q_timeseries_on_scenario_pacman(type, true, "Tuning_scenario/Square/Square_Lin_a15_xi06.gif");

%% Run Second Simulink Program

Ts = 0.001;
model2 = 'NL_tuning';

% Non linear Trajectory Tracking Controller constants

b = 15;  % >0
xi = 0.6;  % (0,1)


load_system(model2);

set_param(model2, 'StopTime', num2str(shift_time));
sim(model2);

NL.t = tout;
NL.q = q.Data;
NL.vw = vw.Data;
NL.vd_wd = vd_wd.Data;

%% Replay the saved data

% Nota l'uso del backslash (o slash) per entrare nelle cartelle
replay_q_timeseries_on_scenario_pacman(type, true, "Tuning_scenario/Square/Square_NonLin_b15_xi06.gif");

%% Show plot

Plots_scenario_compare