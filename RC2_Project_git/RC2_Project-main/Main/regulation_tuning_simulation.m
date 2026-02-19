kv_test = 0.5 : 0.5 : 3;
kw_test = 1.0 : 0.5 : 5;
kd_test = 0.2 : 0.2 : 2;

best_cost = inf;
best_gains = [0, 0, 0];

x_box = 0; y_box = 0; theta_box = 0;
x0 = -0.8; y0 = 0.5; theta0 = pi/4;
assignin('base', 'x0', x0);
assignin('base', 'y0', y0);
assignin('base', 'theta0', theta0);

for kv = kv_test
    for kw = kw_test
        for kd = kd_test

            assignin('base', 'x0', x0);
            assignin('base', 'y0', y0);
            assignin('base', 'theta0', theta0);

            simOut = sim('Regulation_tuning', 'StopTime', '10');

            t = simOut.tout;
            x_err = simOut.x.Data - x_box;
            y_err = simOut.y.Data - y_box;
            theta_err = simOut.theta.Data - theta_box;

            cost = trapz(t, t .*(abs(x_err) + abs(y_err) + abs(theta)));

            if cost < best_cost
                best_cost = cost;
                best_gains = [kv, kw, kd];

            end



        end

    end

end

fprintf('Migliori guadagni: kv=%.2f, kw=%.2f, kd=%.2f\n', best_gains);