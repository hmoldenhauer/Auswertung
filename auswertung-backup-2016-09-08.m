% ----------------------------------------------------------------------
% User input before programm runs
% ----------------------------------------------------------------------

% define name of the folder with data of interest
datafolder = '..\..\Messdaten\2016-05-09-CuBO-T-and-PL\';

% define the starting number
start = 1;

% define how many gaussian functions should be used
numberofgaussians = 2;

% define range for fit window
x_min = 896;
x_max = 911;

% ----------------------------------------------------------------------
% Definitions needed by the program
% ----------------------------------------------------------------------

% add folder and all subfolders to path in order to make this analyze work
addpath(genpath('..\Auswertung\'));

% ----------------------------------------------------------------------
% Reading the data
% ----------------------------------------------------------------------

% read the data
%[data, measurements] = readData(datafolder, 'Temp-Freq.txt');

% ----------------------------------------------------------------------
% Fitting the data
% ----------------------------------------------------------------------

% find out number of pixels of the CCD and the number of spectra
[campx, spectra] = size(data(3).XData);

% iterate over one set of data
for n = 1:10
    % find starting parameters in given intervall
    limit = (n-1)*campx;                % define some helping variables
    lower = 1 + limit;
    upper = n*campx;
    x = data(3).XData(lower:upper);
    x1 = data(3).XData(lower:upper);
    y = data(3).YData(lower:upper);
    x_values = x>x_min & x1<x_max;      % define intervall
    x = x(x_values);                    % set x and
    y = y(x_values);                    % y values
    
    yy = smooth(y);                                         %smooth the data
    [pks, locs] = findpeaks(yy,'MinPeakProminence',0.4);      % find peaks
    [amplitude, index] = sortrows([pks, locs], -1);         % sort them to fit to highest peaks
    
    % build fit function dynamically for the defined number of gaussians
    fitstring = 'y0+a*x';                           % use a linear function as base
    for k = 1:numberofgaussians
        ampstr = strcat('amp', num2str(k));
        posstr = strcat('pos', num2str(k));
        varstr = strcat('var', num2str(k));
        gaussstr = strcat(ampstr, '*exp(-(x-', posstr, ')^2/(2*', varstr, '^2))');
        fitstring = strcat(fitstring, '+', gaussstr);
    end
    
    % build fittype which will be used for fitting
    multigaussfit = fittype(fitstring);
    
    % build fitting parameters
    amplitudes = amplitude(1:numberofgaussians);
    positions = locs(index(1:numberofgaussians))';
    variances = ones(1,numberofgaussians);
    
    % fitfunction -> if anything is changed, take care of the StartPoint!!!
    [f, gof] = fit(x',y',...
                   multigaussfit,...
                   'StartPoint',...
                   [1,...
                   amplitudes,...
                   x(positions),...
                   variances,...
                   0]);
    
    % plot fit
    hold on;
    plot(f,x,y);
    plot(x(locs),y(locs), 'ro');
    
    % plot seperate fit functions used
    if false
    for k = 1:numberofgaussians
        if k == 1
            fplot(@(x) f.('y0')+f.('a')*x,...
                [x(1),x(end)]);
        end
        ampstr = strcat('amp', num2str(k));
        posstr = strcat('pos', num2str(k));
        varstr = strcat('var', num2str(k));
        fplot(@(x) f.(ampstr)*exp(-(x-f.(posstr))^2/(2*f.(varstr)^2)),...
            [x(1),x(end)]);
    end
    end
    hold off;
    fprintf('Plot %d of %d finished\n', n, spectra);
end

% ----------------------------------------------------------------------
% Ploting the whole stuff
% ----------------------------------------------------------------------
if false
    hold on;
    legend_vec = [];

    % iterate over all data
    for k = start:measurements
        for n = 1:size(data(k).XData,2)
            % plot all data
            plot(data(k).XData((1+(n-1)*campx):(n*campx)),...
                 data(k).YData((1+(n-1)*campx):(n*campx)));
            % generate legend vector
            legend_vec = [legend_vec;[k],[n]];
        end
    end
    % create legend
    legend(strtrim(cellstr(num2str(legend_vec))))
end