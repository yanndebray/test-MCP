function pid_tuning_app
    % Create a figure window
    fig = uifigure('Name', 'PID Controller Tuning App', 'Position', [100 100 800 600]);
    
    % Create GridLayout
    gl = uigridlayout(fig, [2 2]);
    gl.RowHeight = {'1x', '1x'};
    gl.ColumnWidth = {'3x', '1x'};
    
    % Create axes for plotting
    ax = uiaxes(gl);
    ax.Layout.Row = [1 2];
    ax.Layout.Column = 1;
    title(ax, 'System Response');
    xlabel(ax, 'Time');
    ylabel(ax, 'Amplitude');
    grid(ax, 'on');
    
    % Create parameter panel
    panel = uipanel(gl, 'Title', 'PID Parameters');
    panel.Layout.Row = 1;
    panel.Layout.Column = 2;
    
    % Create parameter controls
    paramLayout = uigridlayout(panel, [4 2]);
    paramLayout.RowHeight = {'fit', 'fit', 'fit', 'fit'};
    paramLayout.ColumnWidth = {'1x', '1x'};
    
    % Create a struct to store the spinners
    h = struct();
    h.time_spin = [];  % Pre-declare for use in callbacks
    
    % Labels and spinners for PID parameters
    uilabel(paramLayout, 'Text', 'Kp:');
    h.kp_spin = uispinner(paramLayout, 'Value', 0, 'Limits', [0 100], ...
        'ValueDisplayFormat', '%.3f');
    
    uilabel(paramLayout, 'Text', 'Ki:');
    h.ki_spin = uispinner(paramLayout, 'Value', 3, 'Limits', [0 100], ...
        'ValueDisplayFormat', '%.3f');
    
    uilabel(paramLayout, 'Text', 'Kd:');
    h.kd_spin = uispinner(paramLayout, 'Value', 0, 'Limits', [0 100], ...
        'ValueDisplayFormat', '%.3f');
    
    % Create simulation panel
    simPanel = uipanel(gl, 'Title', 'Simulation Controls');
    simPanel.Layout.Row = 2;
    simPanel.Layout.Column = 2;
    
    % Create simulation controls
    simLayout = uigridlayout(simPanel, [2 1]);
    simLayout.RowHeight = {'fit', 'fit'};
    
    % Simulation time control
    uilabel(simLayout, 'Text', 'Simulation Time (s):');
    h.time_spin = uispinner(simLayout, 'Value', 10, 'Limits', [1 100], ...
        'ValueDisplayFormat', '%.1f');
    
    % Setup callbacks for all spinners
    h.kp_spin.ValueChangedFcn = @(src,event) updateSystem(ax, h);
    h.ki_spin.ValueChangedFcn = @(src,event) updateSystem(ax, h);
    h.kd_spin.ValueChangedFcn = @(src,event) updateSystem(ax, h);
    h.time_spin.ValueChangedFcn = @(src,event) updateSystem(ax, h);
    
    % Initial simulation
    updateSystem(ax, h);
end

function updateSystem(ax, h)
    % Time vector
    t = 0:0.01:h.time_spin.Value;
    
    % Transfer function of PID controller
    s = tf('s');
    C = h.kp_spin.Value + h.ki_spin.Value/s + h.kd_spin.Value*s;
    
    % Simple first-order plant
    G = 1/(s + 1);
    
    % Closed-loop system
    sys_cl = feedback(C*G, 1);
    
    % Step response
    [y, t] = step(sys_cl, t);
    
    % Plot results
    cla(ax);
    plot(ax, t, y, 'b', t, ones(size(t)), 'r--');
    grid(ax, 'on');
    legend(ax, 'System Response', 'Reference', 'Location', 'southeast');
    ylim(ax, [0 max(1.5, max(y)*1.1)]);
end