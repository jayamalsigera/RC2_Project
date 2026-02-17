function replay_q_timeseries_on_maze()
    q       = evalin('base','q');
    qdot    = evalin('base','qdot');
    wallPlot= evalin('base','wallPlot');
    xy = evalin('base', 'scenario');
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

    fig = figure('Name','Replay q(t) on Maze','Color','k');
    ax  = axes(fig); hold(ax,'on');

    imagesc(ax, [0 Hh], [0 Wh], double(wallPlot));
    %plot(ax, xy(:,1), xy(:,2), 'r-', 'LineWidth', 2);
    set(ax,'YDir','normal');
    colormap(ax, gray(2));
    clim(ax,[0 1]);
    axis(ax,'equal'); axis(ax,'off');

    xlim(ax,[xmin xmax]);
    ylim(ax,[ymin ymax]);

    k0 = find(~bad, 1, 'first');
    hDot = plot(ax, x(k0), y(k0), 'ro', ...
        'MarkerSize', 10, 'MarkerFaceColor','r', 'LineWidth', 2);

    velScale = 0.3;
    hVel = quiver(ax, x(k0), y(k0), velScale*vx(k0), velScale*vy(k0), 0, ...
        'LineWidth', 1.5, 'MaxHeadSize', 2);
    set(hVel,'Color','r');

    drawnow;

    N = numel(x);
    timesteps = 5;
    for k = k0:timesteps:N
        if ~ishandle(fig), return; end

        if bad(k)
            continue;
        end

        set(hDot, 'XData', x(k), 'YData', y(k));
        if isfinite(vx(k)) && isfinite(vy(k))
            set(hVel, 'XData', x(k), 'YData', y(k), ...
                      'UData', velScale*vx(k), 'VData', velScale*vy(k));
        end

        drawnow limitrate;
    end
end
