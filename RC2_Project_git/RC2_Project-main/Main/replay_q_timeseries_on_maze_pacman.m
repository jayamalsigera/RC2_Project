function replay_q_timeseries_on_maze_pacman()
    % Recupero variabili dal workspace
    q       = evalin('base','q');
    qdot    = evalin('base','qdot');
    wallPlot= evalin('base','wallPlot');
    Hh      = evalin('base','Hh');
    Wh      = evalin('base','Wh');
    
    Q = q.Data;
    V = qdot.Data;
    x  = Q(:,1);  y  = Q(:,2);
    vx = V(:,1);  vy = V(:,2);
    
    bad = ~(isfinite(x) & isfinite(y));
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
    
    % --- SETUP COLORI NEON ---
    neonCyan = [0 0.8 1];
    neonRed = [1 0.15 0.15];
    
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
    
    % --- SETUP PUNTI DA "MANGIARE" IN TUTTA LA MAPPA ---
    try
        scale = evalin('base', 'scale');
    catch
        scale = 50; 
    end
    
    offset = scale / 2;
    margin = scale; % <--- ECCO IL PADDING! Tagliamo via una cella dai bordi esterni
    
    % Generiamo la griglia partendo più internamente
    [Xg, Yg] = meshgrid((offset + margin) : scale : (Hh - offset - margin), ...
                        (offset + margin) : scale : (Wh - offset - margin));
    all_px = Xg(:);
    all_py = Yg(:);
    
    % Manteniamo solo i punti sulla strada (dove wallPlot == 1)
    keep_initial = false(size(all_px));
    for i = 1:length(all_px)
        c_idx = max(1, min(Hh, round(all_px(i))));
        r_idx = max(1, min(Wh, round(all_py(i))));
        
        if wallPlot(r_idx, c_idx) == 1 
            keep_initial(i) = true;
        end
    end
    
    active_px = all_px(keep_initial);
    active_py = all_py(keep_initial);
    
    % Disegniamo i punti validi
    hPoints = plot(ax, active_px, active_py, 'o', ...
        'MarkerSize', 4, 'MarkerEdgeColor', neonCyan, ...
        'MarkerFaceColor', [0.7 0.9 1], 'LineWidth', 1);
    
    k0 = find(~bad, 1, 'first');
    
    % --- SCIA DEL ROBOT ---
    hTrail = plot(ax, x(k0), y(k0), '-', 'Color', [1 0.2 0.8 0.6], 'LineWidth', 1.5);
    
    % --- DISEGNO ROBOT E VELOCITÀ ---
    hDot = plot(ax, x(k0), y(k0), 'o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', neonRed, ...
        'MarkerFaceColor', neonRed, 'LineWidth', 2.5);
        
    velScale = 0.3;
    hVel = quiver(ax, x(k0), y(k0), velScale*vx(k0), velScale*vy(k0), 0, ...
        'Color', neonRed, 'LineWidth', 2.5, 'MaxHeadSize', 2);
        
    drawnow;
    
    N = numel(x);
    timesteps = 5;
    
    trail_x = x(k0);
    trail_y = y(k0);
    
    eat_radius = scale * 0.6; 
    eat_radius_sq = eat_radius^2;
    
    for k = k0:timesteps:N
        if ~ishandle(fig), return; end
        if bad(k)
            continue;
        end
        
        trail_x = [trail_x; x(k)];
        trail_y = [trail_y; y(k)];
        set(hTrail, 'XData', trail_x, 'YData', trail_y);
        set(hDot, 'XData', x(k), 'YData', y(k));
        
        if isfinite(vx(k)) && isfinite(vy(k))
            set(hVel, 'XData', x(k), 'YData', y(k), ...
                      'UData', velScale*vx(k), 'VData', velScale*vy(k));
        end
        
        % --- LOGICA RIMOZIONE PUNTI ---
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