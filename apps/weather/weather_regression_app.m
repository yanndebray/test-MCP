function weather_regression_app
% Weather Data Analysis App
% Fetches hourly temperature data and fits a polynomial of selectable order.

% Main figure
fig = uifigure('Name','Weather Data Analysis','Color',[0.94 0.94 0.94]);
fig.Position = [100 100 1000 700];

% Main grid
mainGrid = uigridlayout(fig,[4 3]);
mainGrid.ColumnWidth = {'2x','6x','2x'};
mainGrid.RowHeight = {'fit','8x','fit','fit'};
mainGrid.Padding = [10 10 10 10];
mainGrid.RowSpacing = 10;
mainGrid.ColumnSpacing = 10;

% Title
titleLabel = uilabel(mainGrid);
titleLabel.Text = 'Weather Temperature Analysis';
titleLabel.FontSize = 20;
titleLabel.FontWeight = 'bold';
titleLabel.Layout.Row = 1;
titleLabel.Layout.Column = [1 3];
titleLabel.HorizontalAlignment = 'center';

% Control panel (left)
controlPanel = uipanel(mainGrid,'BackgroundColor','white','Title','Controls','FontWeight','bold');
controlPanel.Layout.Row = 2;
controlPanel.Layout.Column = 1;

% Control grid: place dropdown, button, spinner, results
% Rows: 1=label,2=dropdown,3=button,4=order label,5=order spinner,6=results
controlGrid = uigridlayout(controlPanel,[6 1]);
controlGrid.RowHeight = {'fit','fit','fit','fit','fit','1x'};
controlGrid.Padding = [10 10 10 10];
controlGrid.RowSpacing = 8;

% Location label + dropdown
locationLabel = uilabel(controlGrid);
locationLabel.Text = 'Select Location:';
locationLabel.Layout.Row = 1;

locationDropdown = uidropdown(controlGrid);
locationDropdown.Items = {'London','Paris','New York','Tokyo'};
locationDropdown.Value = 'London';
locationDropdown.Layout.Row = 2;

% Fetch button (below dropdown)
fetchButton = uibutton(controlGrid,'Text','Fetch Data',... 
    'ButtonPushedFcn',@fetchData,...
    'BackgroundColor',[0 0.4470 0.7410],...
    'FontColor','white','FontWeight','bold');
fetchButton.Layout.Row = 3;
fetchButton.FontSize = 12;

% Order label + spinner
orderLabel = uilabel(controlGrid);
orderLabel.Text = 'Polynomial Order:';
orderLabel.Layout.Row = 4;

orderSpinner = uispinner(controlGrid);
orderSpinner.Limits = [1 10];
orderSpinner.RoundFractionalValues = true;
orderSpinner.Value = 1;
orderSpinner.Layout.Row = 5;
orderSpinner.ValueChangedFcn = @orderChanged;

% Results area (bottom)
resultsPanel = uipanel(controlGrid,'Title','Analysis Results','BackgroundColor','white');
resultsPanel.Layout.Row = 6;
resultsArea = uitextarea(resultsPanel);
resultsArea.Position = [8 8 resultsPanel.Position(3)-16 resultsPanel.Position(4)-16];
resultsArea.Value = {'Ready to fetch data...'};
resultsArea.Editable = 'off';

% Plot panel (right)
plotPanel = uipanel(mainGrid,'BackgroundColor','white','Title','Temperature Trend Analysis','FontWeight','bold');
plotPanel.Layout.Row = [2 3];
plotPanel.Layout.Column = [2 3];

plotGrid = uigridlayout(plotPanel,[1 1]);
plotGrid.Padding = [10 10 10 10];
ax = uiaxes(plotGrid);
ax.XGrid = 'on'; ax.YGrid = 'on';
ax.GridColor = [0.8 0.8 0.8]; ax.GridAlpha = 0.3; ax.FontSize = 11;

% Variables to hold last fetched data
timeData = [];
tempData = [];
hoursData = [];

% Fetch data callback
function fetchData(~,~)
    try
        resultsArea.Value = {'Fetching data...'};
        resultsArea.FontColor = [0.2 0.2 0.2];
        drawnow;

        coords = getLocationCoords(locationDropdown.Value);
        baseURL = 'https://api.open-meteo.com/v1/forecast';
        url = [baseURL, '?latitude=', coords.lat, '&longitude=', coords.lon, ...
            '&hourly=temperature_2m&past_days=7&timezone=auto'];
        data = webread(url);

        % Extract
        time = datetime(data.hourly.time,'InputFormat','yyyy-MM-dd''T''HH:mm');
        temp = data.hourly.temperature_2m;

        % Store
        timeData = time;
        tempData = temp;
        hoursData = hours(time - time(1));
        nPoints = numel(hoursData);

        % Ensure spinner limits valid
        orderSpinner.Limits = [1 max(1,nPoints-1)];
        if orderSpinner.Value >= nPoints
            orderSpinner.Value = max(1,nPoints-1);
        end

        % Do initial fit using current spinner value
        doFitAndPlot(orderSpinner.Value);

    catch ME
        resultsArea.Value = {'Error: Could not fetch or process data.'};
        resultsArea.FontColor = [0.6350 0.0780 0.1840];
        fprintf('Error: %s\n',ME.message);
    end
end

% Refit and redraw using requested order (used by both fetch and spinner)
function doFitAndPlot(order)
    if isempty(hoursData) || isempty(tempData)
        resultsArea.Value = {'No data available. Click Fetch Data.'};
        return
    end
    order = round(order);
    nPoints = numel(hoursData);
    if order >= nPoints
        resultsArea.Value = {sprintf('Error: Order must be < %d (data points).',nPoints)};
        resultsArea.FontColor = [0.6350 0.0780 0.1840];
        return
    end

    p = polyfit(hoursData,tempData,order);
    yFit = polyval(p,hoursData);

    cla(ax);
    hold(ax,'on');
    scatter(ax,timeData,tempData,30,[0 0.4470 0.7410],'filled','MarkerFaceAlpha',0.6,'DisplayName','Actual Temperature');
    plot(ax,timeData,yFit,'r-','LineWidth',2,'DisplayName',sprintf('Poly Trend (order %d)',order));
    hold(ax,'off');
    title(ax,['Temperature Trend: ' locationDropdown.Value],'FontSize',14);
    xlabel(ax,'Time','FontSize',12); ylabel(ax,'Temperature (°C)','FontSize',12);
    legend(ax,'Location','best','FontSize',11);

    leadingCoeff = p(1);
    r = corrcoef(tempData,yFit);
    r2 = r(1,2)^2;

    resultsArea.Value = {sprintf('Location: %s',locationDropdown.Value), ...
        sprintf('Poly Order: %d',order), ...
        sprintf('Leading Coeff: %.4g',leadingCoeff), ...
        sprintf('R² = %.3f',r2), ...
        sprintf('Mean Temp: %.1f°C',mean(tempData))};
    if leadingCoeff > 0
        resultsArea.FontColor = [0.4660 0.6740 0.1880];
    elseif leadingCoeff < 0
        resultsArea.FontColor = [0.6350 0.0780 0.1840];
    else
        resultsArea.FontColor = [0.3 0.3 0.3];
    end
end

% Spinner callback: re-fit using stored data
function orderChanged(~,~)
    if isempty(hoursData)
        resultsArea.Value = {'No data available. Click Fetch Data first.'};
        return
    end
    doFitAndPlot(orderSpinner.Value);
end

end

function coords = getLocationCoords(location)
% Returns latitude/longitude strings for supported locations
switch location
    case 'London'
        coords.lat = '51.5085'; coords.lon = '-0.1257';
    case 'Paris'
        coords.lat = '48.8566'; coords.lon = '2.3522';
    case 'New York'
        coords.lat = '40.7128'; coords.lon = '-74.0060';
    case 'Tokyo'
        coords.lat = '35.6762'; coords.lon = '139.6503';
    otherwise
        coords.lat = '0'; coords.lon = '0';
end
end