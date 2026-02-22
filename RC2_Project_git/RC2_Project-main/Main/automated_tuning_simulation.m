%% 4. Automated Tuning (Grid Search)
model = 'L_tuning';
load_system(model);

% 1. Definisci la griglia dei parametri da esplorare
A_test = 5 : 1 : 15;          % Testa 'a' da 1 a 10
XI_test = 0.2 : 0.1 : 0.8;    % Testa lo smorzamento 'xi' da 0.4 a 1

best_cost = inf;
best_params = [0, 0];

% Matrice per salvare i risultati (utile per fare grafici 3D per la presentazione)
cost_matrix = zeros(length(A_test), length(XI_test));

scale = 15;
type = 'square';
run('draw_scenarios(scale, type)');
uiwait(gcf);  % wait until figure is closed

S = load('trajectory.mat');   % contains S.traj.xy and S.traj.t
        
% unicycle initial conditions
x0 = S.traj.xy(1,1);
y0 = S.traj.xy(1,2);
theta0 = -pi/2;
        
xy = S.traj.xy; % [N x 2]
t  = S.traj.t;  

shift_time = 30;
Tfinal = shift_time;           % seconds
t = t * Tfinal;

ref = timeseries(xy, t);      % ref.Data is Nx2: [x_d y_d]
        
assignin('base','ref', ref);

disp('Inizio Auto-Tuning...');

for i = 1:length(A_test)
    for j = 1:length(XI_test)
        
        % Assegna i parametri correnti al Workspace per Simulink
        a = A_test(i);
        xi = XI_test(j);
        assignin('base', 'a', a);
        assignin('base', 'xi', xi);
        
        % Esegui la simulazione 
        simOut = sim(model, 'StopTime', '400');
               
        e1 = simOut.e_x.Data;
        e2 = simOut.e_y.Data;
        t_sim = simOut.tout;
        
        % 2. Calcola la Funzione di Costo (ISE sull'errore di posizione)
        cost = trapz(t_sim, e1.^2 + e2.^2);
        
        cost_matrix(i,j) = cost;
        
        % 3. Salva i migliori
        if cost < best_cost
            best_cost = cost;
            best_params = [a, xi];
        end
    end
end

fprintf('Tuning completato! Migliori parametri: a = %.2f, xi = %.2f (Costo: %.4f)\n', ...
        best_params(1), best_params(2), best_cost);

%% 5. Salva e Rivedi il Migliore
% Rimanda i migliori al workspace
assignin('base', 'a', best_params(1));
assignin('base', 'xi', best_params(2));

% Fai un'ultima simulazione con i migliori per registrarla
simOut = sim(model);
disp('Eseguo il replay della traiettoria ottimizzata...');
run('replay_q_timeseries_on_maze.m');