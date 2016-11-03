function auswertung_gui(data)
% auswertung_gui will help you getting an impression
% of the measured data. You will be able to select
% fields of interest and sum them up.

% ----------------------------------------------------------------------
% Creating the UI
% ----------------------------------------------------------------------

% Create and then hide the UI as it is being constructed.
f = figure('Visible', 'off', 'Position', [1060,200,800,600]);

% Construct the components.
% Create save button
hsave   = uicontrol('Style', 'pushbutton',...
                    'String', 'Save parameters',...
                    'Position', [550,30,100,25]);
% Create export button
hexport = uicontrol('Style', 'pushbutton',...
                    'String', 'Export pdf',...
                    'Position', [680,30,100,25]);

% Create pop-up menu to change temperature
temperatures = [;data.Temp];
temperatures = unique(temperatures);
current_temp = temperatures(1);

htemp   = uicontrol('Style', 'popupmenu',...
                    'String', num2cell(temperatures),...
                    'Position', [400,30,100,25],...
                    'Callback', @popup_temp_Callback);
% Create label for pop-up menu
htxt_t  = uicontrol('Style', 'text',...
                    'Position', [400,60,100,25],...
                    'String', 'Temperature (K)');

% search starting data
minimum = min(min(data(50).XData));
maximum = max(max(data(50).XData));

% Create slider for left end
hleft   = uicontrol('Style', 'slider',...
                    'Min', minimum, 'Max', maximum, 'Value', minimum,...
                    'Position', [550,130,230,25],...
                    'Callback', @left_slider_Callback);
% Create label for the left slider
htxt_l  = uicontrol('Style', 'text',...
                    'Position', [550,160,70,20],...
                    'String', 'Left');
htxt_l_label  = uicontrol('Style', 'text',...
                    'Position', [600,160,70,20],...
                    'String', num2str(hleft.Value));
% Create slider for right end
hright  = uicontrol('Style', 'slider',...
                    'Min', minimum, 'Max', maximum, 'Value', maximum,...
                    'Position', [550,70,230,25],...
                    'Callback', @right_slider_Callback);
% Create label for the right slider
htxt_r  = uicontrol('Style', 'text',...
                    'Position', [550,100,70,15],...
                    'String', 'Right');
htxt_r_label  = uicontrol('Style', 'text',...
                    'Position', [600,100,70,15],...
                    'String', num2str(hright.Value));

% Create B vs lambda
hBvsL   = axes('Units', 'pixels',...
               'Position', [60,270,300,300]);
% Create B vs I
hBvsI   = axes('Units', 'pixels',...
               'Position', [440,270,150,300]);
% Create I vs lambda
hIvsL   = axes('Units', 'pixels',...
               'Position', [60,140,300,70]);
% Create PL vs lambda
hPLvsL   = axes('Units', 'pixels',...
               'Position', [60,60,300,70]);

% ----------------------------------------------------------------------
% creating content
% ----------------------------------------------------------------------

plotODMR(current_temp);

% plot lines in overview
hBvsL_line_l = line(hBvsL, [hleft.Value,hleft.Value], hBvsL.YLim,...
               'Color', 'r',...
               'Linewidth', 2);
hBvsL_line_r = line(hBvsL, [hright.Value,hright.Value], hBvsL.YLim,...
               'Color', 'r',...
               'Linewidth', 2);

% ----------------------------------------------------------------------
% Initializing the UI
% ----------------------------------------------------------------------

% Change units to normalized so components resize automatically
f.Units = 'normalized';
hsave.Units = 'normalized';
hexport.Units = 'normalized';
htemp.Units = 'normalized';
htxt_t.Units = 'normalized';
hleft.Units = 'normalized';
htxt_l.Units = 'normalized';
hright.Units = 'normalized';
htxt_r.Units = 'normalized';
hBvsL.Units = 'normalized';
hIvsL.Units = 'normalized';
hBvsI.Units = 'normalized';

% Assign a name to the window title
f.Name = 'Analyzing Data';

% Make UI visible
f.Visible = 'on';

% Pop-up menu temp callback.
function popup_temp_Callback(source,eventdata)
    % Determine the selected data set
    str = get(source, 'String');
    val = get(source, 'Value');
    
    % set the current temperature
    current_temp = str2num(str{val});
    plotODMR(current_temp);
    
    % plot lines in overview
    x_l = [hleft.Value,hleft.Value];
    x_r = [hright.Value,hright.Value];
    hBvsL_line_l = line(hBvsL, x_l, hBvsL.YLim,...
               'Color', 'r',...
               'Linewidth', 2);
    hBvsL_line_r = line(hBvsL, x_r, hBvsL.YLim,...
               'Color', 'r',...
               'Linewidth', 2);
    hIvsL.XLim = [x_l(1), x_r(1)];
    hPLvsL.XLim = [x_l(1), x_r(1)];
    
    % update ODMR signal plot
    update_BvsI();
end

function left_slider_Callback(source,eventdata)
    % get value from left slider
    x_l = source.Value;
    % get value from right line
    x_r = hBvsL_line_r.XData(1);
    
    % set left value to source.value,
    % maximal to right line
    if x_l < x_r
        hBvsL_line_l.XData = [x_l, x_l];
    else
        hBvsL_line_l.XData = [x_r, x_r];
        source.Value = x_r;
    end
    % rescale I vs L
    hIvsL.XLim = [source.Value, hIvsL.XLim(2)];
    % rescale PL vs L
    hPLvsL.XLim = [source.Value, hPLvsL.XLim(2)];
    
    % update text
    htxt_l_label.String = num2str(source.Value);
    
    % update ODMR signal plot
    update_BvsI();
end

function right_slider_Callback(source,eventdata)
    % get value from right slider
    x_r = source.Value;
    % get value from left line
    x_l = hBvsL_line_l.XData(1);
    
    % set right value to source.value,
    % minimal to left line
    if x_r > x_l
        hBvsL_line_r.XData = [x_r, x_r];
    else
        hBvsL_line_r.XData = [x_l, x_l];
        source.Value = x_l;
    end
    % rescale I vs L
    hIvsL.XLim = [hIvsL.XLim(1), source.Value];
    % rescale PL vs L
    hPLvsL.XLim = [hPLvsL.XLim(1), source.Value];
    
    % update text
    htxt_r_label.String = num2str(source.Value);
    
    % update ODMR signal plot
    update_BvsI();
end

function [X, Y, Z, PL_on, PL_off] = update_Data(current_temp)
    % find PL data with mw on/off
    k_off = [data(:).Temp] == current_temp & [data(:).PL] == 1 & [data(:).OCE] == 0;
    k_on  = [data(:).Temp] == current_temp & [data(:).PL] == 1 & [data(:).OCE] == 1;
    
    k_off = find(k_off);
    k_on = find(k_on);
    
    % plot magnetic field vs lambda
    % wavelength
    X = data(k_on).XData(1:1040);

    % magnetic field
    step = data(k_on).Step;
    field = data(k_on).Field;
    Y = (field:step:field+step*(size(data(k_on).XData,2)-1));
    
    % intensity (PL on - PL off)
    PL_on = data(k_on).YData;
    PL_off = data(k_off).YData;
    Z = PL_on - PL_off;
end

function update_BvsI()
    % update Data
    [X, Y, Z] = update_Data(current_temp);
    % find all data in range
    indices = find(X > hIvsL.XLim(1) & X < hIvsL.XLim(2));
    plotBvsI(Y, Z(indices,:));
end

function I = integrate(Y, Z)
    I = [];
    
    % integrate
    for i = 1:length(Y)
        I = [I;sum(Z(:,i))];
    end
end

function plotBvsI(Y, Z)
    I = integrate(Y, Z);
    plot(hBvsI,I,Y);
    
    % fit gaussian to plot
    %hold(hBvsI, 'on');
    pks = abs(max(I));                          % find peaks
    %result = fit(Y',I,...
    %    'y0+a1*x+amp*exp(-(x-pos)^2/(2*var^2))');
    %B_fit = [Y(1):((Y(end)-Y(1))/100):Y(end)];
    %I_fit = feval(result, B_fit);
    %plot(hBvsI, I_fit, B_fit, 'r');
    %hold(hBvsI, 'off');
    
    % plot configuration
    hBvsI.YLim = hBvsL.YLim;
    hBvsI.Title.String = 'ODMR signal';         % title
    hBvsI.XLabel.String = 'Intensity (cps)';    % x label
    hBvsI.YLabel.String = 'B (T)';              % y label
    hBvsI.XGrid = 'on';                         % x grid on
    hBvsI.YGrid = 'on';                         % y grid on
end

function plotODMR(current_temp)
    [X, Y, Z, PL_on, PL_off] = update_Data(current_temp);
    
    % plot B vs lambda
    imagesc(hBvsL,X,Y,Z');
    
    % plot configuration
    hBvsL.YDir = 'normal';                  % change direction of y axis
    colormap(parula(128));                  % think of your colormap! (pmkmp(128))
    hBvsL.Title.String = 'Overview';        % title
    hBvsL.XLabel.String = '\lambda (nm)';   % x label
    hBvsL.YLabel.String = 'B (T)';          % y label
    hBvsLc = colorbar(hBvsL);               % add a colorbar
    hBvsLc.Label.String = 'Intensity (cps)';% title of colorbar
    
    % plot B vs I
    plotBvsI(Y, Z);
    
    % plot I vs wavelength
    plot(hIvsL,X,Z);
    
    % plot configuration
    hIvsL.XLim = hBvsL.XLim;
    hIvsL.Title.String = '';                % title
    hIvsL.XLabel.String = ' ';              % x label
    hIvsL.YLabel.String = 'diff-Int.';      % y label
    
    % plot I vs wavelength
    plot(hPLvsL,X,PL_off);
    
    % plot configuration
    hPLvsL.XLim = hBvsL.XLim;
    hPLvsL.Title.String = '';                % title
    hPLvsL.XLabel.String = '\lambda (nm)';   % x label
    hPLvsL.YLabel.String = 'PL-Intensity';   % y label
end

end