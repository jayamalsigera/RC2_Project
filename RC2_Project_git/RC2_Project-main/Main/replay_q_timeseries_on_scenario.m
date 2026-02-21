function replay_q_timeseries_on_scenario(type)
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
    
    % Setup Grafico Base
    fig = figure('Name',['Replay q(t) on Maze - ', upper(type)],'Color','k');
    ax  = axes(fig); hold(ax,'on');
    imagesc(ax, [0 Hh], [0 Wh], double(wallPlot));
    set(ax,'YDir','normal');
    colormap(ax, gray(2));
    clim(ax,[0 1]);
    axis(ax,'equal'); axis(ax,'off');
    xlim(ax,[xmin xmax]);
    ylim(ax,[ymin ymax]);
    
    neonCyan = [0 0.8 1];
    offset = min(Hh, Wh) * 0.05;
    cx = Hh / 2; 
    cy = Wh / 2;
    
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
    
    % Punti luminosi centrali
    step = max(1, floor(size(xy,1) / 40));
    idx = 1:step:size(xy,1);
    plot(ax, xy(idx,1), xy(idx,2), 'o', ...
        'MarkerSize', 5, 'MarkerEdgeColor', neonCyan, ...
        'MarkerFaceColor', [0.7 0.9 1], 'LineWidth', 1.5);
        
    neonPink = [1 0.2 0.8];
    k0 = find(~bad, 1, 'first');
    
    % Inizializza la scia (trail) per vedere il tracking passato
    hTrail = plot(ax, x(k0), y(k0), '-', 'Color', [1 0.2 0.8 0.6], 'LineWidth', 1.5);
    
    % Disegna l'Uniciclo (Marker Rosa Neon)
    hDot = plot(ax, x(k0), y(k0), 'o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', neonPink, ...
        'MarkerFaceColor', [1 0.6 0.9], 'LineWidth', 2.5);
        
    % Disegna il vettore velocità
    velScale = 0.3;
    hVel = quiver(ax, x(k0), y(k0), velScale*vx(k0), velScale*vy(k0), 0, ...
        'Color', neonPink, 'LineWidth', 2.5, 'MaxHeadSize', 2);

    drawnow;
    
    N = numel(x);
    timesteps = 5; % Accelerazione del replay
    
    % Variabili per accumulare la scia
    trail_x = x(k0);
    trail_y = y(k0);
    
    % Ciclo di animazione
    for k = k0:timesteps:N
        if ~ishandle(fig), return; end
        if bad(k)
            continue;
        end
        
        % Aggiorna i dati della scia
        trail_x = [trail_x; x(k)];
        trail_y = [trail_y; y(k)];
        
        % Aggiorna posizioni su schermo
        set(hTrail, 'XData', trail_x, 'YData', trail_y);
        set(hDot, 'XData', x(k), 'YData', y(k));
        
        % Aggiorna vettore velocità
        if isfinite(vx(k)) && isfinite(vy(k))
            set(hVel, 'XData', x(k), 'YData', y(k), ...
                      'UData', velScale*vx(k), 'VData', velScale*vy(k));
        end
        drawnow limitrate;
    end
end