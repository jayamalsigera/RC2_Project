function traj = draw_smooth(scale, v_des)

    G = pacBoard();                      % 1=free, 0=wall
    wallHi = kron(G==0, ones(scale));    % 1=wall, 0=free
    [Hh, Wh] = size(wallHi);

    wallPlot = double(wallHi.');         % row->x, col->y

    fig = figure('Name','Draw trajectory (LMB=add, RMB=finish)', ...
                 'Color','k');
    ax = axes(fig); hold(ax,'on');

    imagesc(ax, [0 Hh], [0 Wh], wallPlot);
    set(ax,'YDir','normal');

    %customColormap = [neonCyan; 0 0 0];
    colormap(ax, gray(2));
    %colormap(ax, customColormap);
    clim(ax,[0 1]);

    axis(ax,'equal');
    xlim(ax,[0 Hh]); ylim(ax,[0 Wh]);
    axis(ax,'off');

    title(ax,'Draw trajectory (raw Cartesian coords)','Color','w');
    disp('Left-click to add points, right-click to finish.');

    xy = [];
    hLine = plot(ax, NaN, NaN, 'y-', 'LineWidth', 2);

    while true
        [x,y,btn] = ginput(1);

        if isempty(btn) || btn ~= 1
            break;
        end

        x = min(max(x, 0), Hh);
        y = min(max(y, 0), Wh);

        xy(end+1,:) = [x y];
        set(hLine,'XData',xy(:,1),'YData',xy(:,2));
        drawnow;
    end


    if size(xy,1) < 2
        error('Trajectory too short.');
    end
    
    xy = unique(xy,'rows','stable');
    
    % 1. Ricampionamento spaziale base
    d_raw = sqrt(sum(diff(xy).^2, 2));
    s_raw = [0; cumsum(d_raw)]; 
    
    ds = 0.1; % Risoluzione spaziale
    s_fine = (0:ds:s_raw(end))';
    xy_linear = interp1(s_raw, xy, s_fine, 'linear');
    
    % 2. Raccordo geometrico degli angoli (Curve reali)
    curve_radius = 50; % Cambia questo per stringere/allargare le curve
    window_size = round((curve_radius * 2) / ds); 
    xy_smooth = smoothdata(xy_linear, 1, 'gaussian', window_size);
    xy_smooth(1,:) = xy(1,:);     
    xy_smooth(end,:) = xy(end,:); 
    
    % 3. Riparametrizzazione temporale a velocità costante
    d_smooth = sqrt(sum(diff(xy_smooth).^2, 2));
    s_smooth = [0; cumsum(d_smooth)];
    
    % IL TUO FIX: dt molto più piccolo del Ts di Simulink
    dt = 0.0001; % (Esempio: se in Simulink Ts=0.01, usa 0.001 o meno)
    
    t_final = (0:dt:(s_smooth(end)/v_des))'; 
    s_target = v_des * t_final; 
    
    [s_unique, idx] = unique(s_smooth);
    xy_unique = xy_smooth(idx, :);
    
    % Interpolazione finale pulita
    xy_final = interp1(s_unique, xy_unique, s_target, 'spline');
    
    % Salvataggio
    traj.xy = xy_final;
    traj.t  = t_final;
    
    save('trajectory.mat','traj');
    disp('Saved trajectory.mat (Clean curves, constant velocity)');
    
    % Plot
    plot(ax, xy(:,1), xy(:,2), 'yo', 'MarkerSize', 5, 'LineWidth', 1.5);
    plot(ax, traj.xy(:,1), traj.xy(:,2), 'r-', 'LineWidth', 2);
end