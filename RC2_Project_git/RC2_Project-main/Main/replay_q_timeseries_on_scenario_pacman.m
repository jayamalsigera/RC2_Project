function replay_q_timeseries_on_scenario_pacman(type)
    % Se non viene specificato il tipo, di default usa 'circle'
    if nargin < 1
        type = 'circle'; 
    end
    
    % Recupero variabili dal workspace principale
    q       = evalin('base','q');
    qdot    = evalin('base','qdot');
    wallPlot= evalin('base','wallPlot');
    xy      = evalin('base', 'scenario');
    Hh      = evalin('base','Hh');
    Wh      = evalin('base','Wh');
    
    Q = q.Data;
    V = qdot.Data;
    x  = Q(:,1);  
    y  = Q(:,2);
    
    % Estraggo theta per orientare la bocca di Pac-Man
    if size(Q, 2) >= 3
        theta = Q(:,3);
    else
        theta = zeros(size(x)); 
    end
    
    vx = V(:,1);  
    vy = V(:,2);
    
    bad = ~(isfinite(x) & isfinite(y) & isfinite(theta));
    if any(bad)
        fprintf('Non-finite q samples: %d / %d\n', nnz(bad), numel(bad));
    end
    xf = x(~bad);  yf = y(~bad);
    if isempty(xf) || isempty(yf)
        error('All q samples are non-finite (NaN/Inf). Fix your simulation first.');
    end
    
    pad = 5;
    xmin = min([0; xf]) - pad;  xmax = max([Hh; xf]) + pad;
    ymin = min([0; yf]) - pad;  ymax = max([Wh; yf]) + pad;
    
    % --- SETUP GRAFICO BASE ---
    fig = figure('Name',['Replay q(t) on Scenario - ', upper(type)],'Color','k');
    ax  = axes(fig); hold(ax,'on');
    imagesc(ax, [0 Hh], [0 Wh], double(wallPlot));
    set(ax,'YDir','normal');
    colormap(ax, gray(2));
    clim(ax,[0 1]);
    axis(ax,'equal'); axis(ax,'off');
    xlim(ax,[xmin xmax]);
    ylim(ax,[ymin ymax]);
    
    neonCyan   = [0 0.8 1];
    neonYellow = [1 1 0]; % Giallo Pac-Man classico
    
    offset = min(Hh, Wh) * 0.05;
    cx = Hh / 2; 
    cy = Wh / 2;
    
    % Disegna il contorno dello scenario scelto
    switch lower(type)
        case 'line'
            x_min = min(xy(:,1)) - offset;
            x_max = max(xy(:,1)) + offset;
            y_cen = xy(1,2);
            pos = [x_min, y_cen - offset, x_max - x_min, 2*offset];
            rectangle(ax, 'Position', pos, 'Curvature', 1, 'EdgeColor', neonCyan, 'LineWidth', 2.5);
            
        case 'circle'
            R = min(Hh, Wh) * 0.35; 
            rectangle(ax, 'Position', [cx-(R+offset), cy-(R+offset), 2*(R+offset), 2*(R+offset)], ...
                      'Curvature', 1, 'EdgeColor', neonCyan, 'LineWidth', 2.5);
            rectangle(ax, 'Position', [cx-(R-offset), cy-(R-offset), 2*(R-offset), 2*(R-offset)], ...
                      'Curvature', 1, 'EdgeColor', neonCyan, 'LineWidth', 2.5);
                      
        case 'square'
            side = min(Hh, Wh) * 0.6;
            s2 = side / 2;
            pos_out = [cx-s2-offset, cy-s2-offset, side+2*offset, side+2*offset];
            rectangle(ax, 'Position', pos_out, 'Curvature', 0.15, 'EdgeColor', neonCyan, 'LineWidth', 2.5);
            pos_in = [cx-s2+offset, cy-s2+offset, side-2*offset, side-2*offset];
            rectangle(ax, 'Position', pos_in, 'Curvature', 0.15, 'EdgeColor', neonCyan, 'LineWidth', 2.5);
    end
    
    % --- SETUP PUNTI DA "MANGIARE" ---
    step = max(1, floor(size(xy,1) / 40));
    idx = 1:step:size(xy,1);
    
    active_px = xy(idx,1);
    active_py = xy(idx,2);
    
    hPoints = plot(ax, active_px, active_py, 'o', ...
        'MarkerSize', 5, 'MarkerEdgeColor', neonCyan, ...
        'MarkerFaceColor', [0.7 0.9 1], 'LineWidth', 1.5);
        
    k0 = find(~bad, 1, 'first');
    
    % Inizializza la scia (trail) gialla e trasparente
    hTrail = plot(ax, x(k0), y(k0), '-', 'Color', [1 1 0 0.3], 'LineWidth', 1.5);
    
    % --- PAC-MAN SHAPE SETUP ---
    % Cerco la scala per dimensionare correttamente Pac-Man, con fallback automatico
    try
        scale = evalin('base', 'scale');
    catch
        scale = min(Hh, Wh) * 0.05; 
    end
    radius = scale * 0.6;
    num_pts = 20; % Risoluzione del cerchio leggermente aumentata per un bordo più morbido
    
    hRobot = patch(ax, 0, 0, neonYellow, 'EdgeColor', 'none');
        
    % Disegna il vettore velocità (nascosto di default, impostabile su 'on' se serve)
    velScale = 0.3;
    hVel = quiver(ax, x(k0), y(k0), 0, 0, 0, 'Color', neonYellow, 'LineWidth', 2.5, 'Visible', 'off');
    
    N = numel(x);
    timesteps = 5; % Accelerazione del replay
    
    trail_x = x(k0);
    trail_y = y(k0);
    
    % Raggio d'azione per mangiare i punti
    eat_radius_sq = radius^2; 
    
    % --- CICLO DI ANIMAZIONE ---
    for k = k0:timesteps:N
        if ~ishandle(fig), return; end
        if bad(k), continue; end
        
        % Aggiorna scia
        trail_x = [trail_x; x(k)];
        trail_y = [trail_y; y(k)];
        set(hTrail, 'XData', trail_x, 'YData', trail_y);
        
        % --- LOGICA BOCCA DINAMICA ---
        % L'apertura oscilla in base al frame attuale 'k'
        m_open = 0.5 * abs(sin(k/10)); 
        angles = linspace(m_open, 2*pi - m_open, num_pts);
        
        % Coordinate locali
        px_local = [0, radius * cos(angles)];
        py_local = [0, radius * sin(angles)];
        
        % Rotazione in base a theta
        th = theta(k);
        R = [cos(th), -sin(th); sin(th), cos(th)];
        pts = (R * [px_local; py_local])';
        
        % Traslazione sul punto attuale
        pts(:,1) = pts(:,1) + x(k);
        pts(:,2) = pts(:,2) + y(k);
        
        set(hRobot, 'XData', pts(:,1), 'YData', pts(:,2));
        
        % Aggiorna vettore velocità
        if isfinite(vx(k)) && isfinite(vy(k))
            set(hVel, 'XData', x(k), 'YData', y(k), ...
                      'UData', velScale*vx(k), 'VData', velScale*vy(k));
        end
        
        % --- LOGICA EAT ---
        if ~isempty(active_px)
            dist_sq = (active_px - x(k)).^2 + (active_py - y(k)).^2;
            keep_idx = dist_sq > eat_radius_sq;
            
            if any(~keep_idx)
                active_px = active_px(keep_idx);
                active_py = active_py(keep_idx);
                set(hPoints, 'XData', active_px, 'YData', active_py);
            end
        end
        
        drawnow limitrate;
    end
end