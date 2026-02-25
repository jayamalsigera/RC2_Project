function replay_q_timeseries_on_maze_pacman_real(save_gif, gif_filename)
    % Impostazioni di default per la GIF
    if nargin < 1
        save_gif = false; 
    end
    if nargin < 2
        gif_filename = 'pacman_maze_animation.gif'; 
    end

    % Recupero variabili dal workspace
    q       = evalin('base','q');
    qdot    = evalin('base','qdot');
    wallPlot= evalin('base','wallPlot');
    Hh      = evalin('base','Hh');
    Wh      = evalin('base','Wh');
    
    % --- Setup Parking box ---
    x_box = 850;
    y_box = 880;
    box_side = 60; 
    box_x = [x_box-box_side/2, x_box+box_side/2, x_box+box_side/2, x_box-box_side/2];
    box_y = [y_box-box_side/2, y_box-box_side/2, y_box+box_side/2, y_box+box_side/2];
    
    Q = q.Data;
    V = qdot.Data;
    x  = Q(:,1);  
    y  = Q(:,2);
    
    if size(Q, 2) >= 3
        theta = Q(:,3);
    else
        theta = zeros(size(x)); 
    end
    
    vx = V(:,1);  
    vy = V(:,2);
    
    bad = ~(isfinite(x) & isfinite(y) & isfinite(theta));
    xf = x(~bad);  yf = y(~bad);
    
    pad = 5;
    xmin = min([0; xf]) - pad;  xmax = max([Hh; xf]) + pad;
    ymin = min([0; yf]) - pad;  ymax = max([Wh; yf]) + pad;
    
    % --- COLOURS SETUP ---
    neonCyan   = [0 0.8 1];
    neonYellow = [1 1 0]; % Giallo Pac-Man classico
    
    fig = figure('Name','Replay q(t) on Maze','Color','k');
    ax  = axes(fig); hold(ax,'on');
    
    imagesc(ax, [0 Hh], [0 Wh], double(wallPlot));
    set(ax,'YDir','normal');
    customColormap = [neonCyan; 0 0 0]; 
    colormap(ax, customColormap);
    clim(ax,[0 1]);
    axis(ax,'equal'); axis(ax,'off');
    xlim(ax,[xmin xmax]);
    ylim(ax,[ymin ymax]);
    
    % --- PARKING BOX DRAW ---
    patch(ax, box_x, box_y, neonCyan, ...
          'FaceAlpha', 0.3, ...          
          'EdgeColor', neonCyan, ...    
          'LineWidth', 2, ...
          'LineStyle', '-');
    
   % --- POINTS IN MAZE ---
    try scale = evalin('base', 'scale'); catch, scale = 50; end
    offset = scale / 2; margin = scale; 
    [Xg, Yg] = meshgrid((offset + margin) : scale : (Hh - offset - margin), ...
                        (offset + margin) : scale : (Wh - offset - margin));
    all_px = Xg(:); all_py = Yg(:);
    
    keep_initial = false(size(all_px));
    for i = 1:length(all_px)
        px = all_px(i);
        py = all_py(i);
        
        c_idx = max(1, min(Hh, round(px)));
        r_idx = max(1, min(Wh, round(py)));
        
        if wallPlot(r_idx, c_idx) == 1
            % --- ZONE DA ESCLUDERE ---
            exclude_right = (px >= 1270 && px <= 1480) && ...
                            ((py >= 1020 && py <= 1080) || (py >= 720 && py <= 780));
                            
            exclude_left = (px >= 70 && px <= 280) && ...
                           ((py >= 1020 && py <= 1080) || (py >= 720 && py <= 780));
            
            if ~exclude_right && ~exclude_left
                keep_initial(i) = true; 
            end
        end
    end
    active_px = all_px(keep_initial); active_py = all_py(keep_initial);
    
    hPoints = plot(ax, active_px, active_py, 'o', ...
        'MarkerSize', 2, 'MarkerEdgeColor', neonCyan, ...
        'MarkerFaceColor', [0.7 0.9 1], 'LineWidth', 1);
    
    k0 = find(~bad, 1, 'first');
    hTrail = plot(ax, x(k0), y(k0), '-', 'Color', [1 1 0 0.3], 'LineWidth', 1.5);
    
    % --- PAC-MAN SHAPE SETUP ---
    radius = scale * 0.6;
    num_pts = 10; % Risoluzione del cerchio
    
    % Inizializziamo la patch del robot (Pac-Man)
    hRobot = patch(ax, 0, 0, neonYellow, 'EdgeColor', 'none');
        
    velScale = 0.3;
    hVel = quiver(ax, x(k0), y(k0), 0, 0, 0, 'Color', neonYellow, 'LineWidth', 2.5, 'Visible', 'off');
    
    N = numel(x);
    timesteps = 50;
    trail_x = x(k0); trail_y = y(k0);
    eat_radius_sq = (scale * 0.6)^2;
    
    % --- CICLO DI ANIMAZIONE ---
    first_frame = true; % Flag per l'inizializzazione del file GIF
    
    for k = k0:timesteps:N
        % Controllo iniziale di sicurezza
        if ~ishandle(fig), return; end
        
        if bad(k), continue; end
        
        trail_x = [trail_x; x(k)]; trail_y = [trail_y; y(k)];
        set(hTrail, 'XData', trail_x, 'YData', trail_y);
        
        % --- LOGICA BOCCA DINAMICA ---
        m_open = 0.5 * abs(sin(k/10)); 
        angles = linspace(m_open, 2*pi - m_open, num_pts);
        
        px_local = [0, radius * cos(angles)];
        py_local = [0, radius * sin(angles)];
        
        th = theta(k);
        R = [cos(th), -sin(th); sin(th), cos(th)];
        pts = (R * [px_local; py_local])';
        
        pts(:,1) = pts(:,1) + x(k);
        pts(:,2) = pts(:,2) + y(k);
        
        set(hRobot, 'XData', pts(:,1), 'YData', pts(:,2));
        
        if isfinite(vx(k)) && isfinite(vy(k))
            set(hVel, 'XData', x(k), 'YData', y(k), ...
                      'UData', velScale*vx(k), 'VData', velScale*vy(k));
        end
        
        % --- EAT LOGIC ---
        if ~isempty(active_px)
            dist_sq = (active_px - x(k)).^2 + (active_py - y(k)).^2;
            keep_idx = dist_sq > eat_radius_sq;
            if any(~keep_idx)
                active_px = active_px(keep_idx);
                active_py = active_py(keep_idx);
                set(hPoints, 'XData', active_px, 'YData', active_py);
            end
        end
        
        % Forza l'aggiornamento grafico
        drawnow; 
        
        % --- CONTROLLO CHIUSURA FINESTRA ---
        % Se chiudi la finestra a metà esecuzione, intercettiamo l'evento in modo pulito
        if ~ishandle(fig)
            if save_gif
                fprintf('Finestra chiusa in anticipo. La GIF è stata salvata correttamente fino a questo momento in: %s\n', gif_filename);
            end
            return;
        end
        
        % --- LOGICA SALVATAGGIO GIF ---
        if save_gif
            % Cattura il frame corrente (qui siamo sicuri che 'fig' esista ancora)
            frame = getframe(fig);
            im = frame2im(frame);
            [imind, cm] = rgb2ind(im, 256);
            
            % Scrive il frame nel file
            if first_frame
                % Crea il file e imposta il loop infinito
                imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.05);
                first_frame = false;
            else
                % Aggiunge i frame successivi al file esistente
                imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
            end
        end
    end
    
    if save_gif
        fprintf('Animazione completata! GIF salvata in: %s\n', gif_filename);
    end
end