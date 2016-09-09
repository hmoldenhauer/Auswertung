% function that will allow fitting to specified fittype
%
% output arguments
% f = fit data
% gof = goodness of fit data
% x = x data of the chosen interval
% y = y data of the chosen inverval
% amplitudes = heights of the peaks used for fitting
% positions = positions of the peaks used for fitting
%
% input arguments
%
% data = all measured data read in before
% campx = number of pixels the camera has
% x_min = min x value
% x_max = max x value
% numberofgaussians = number of gaussian functions which will be used to
%                     fit
% n = iterator to fit over a complete set of data

function [f, gof, x, y,...
          amplitudes, positions] = fittingData(data, campx,...
                                      x_min, x_max,...
                                      numberofgaussians, n)

% define some helping variables
lower = 1 + (n-1)*campx;
upper = n*campx;

% find starting parameters in given intervall
x = data.XData(lower:upper);
y = data.YData(lower:upper);
x_values = x>x_min & x<x_max;      % define intervall
x = x(x_values);                    % set x and
y = y(x_values);                    % y values

% find peaks in the given data
yy = smooth(y);                                         % smooth the data
[pks, locs] = findpeaks(yy,'MinPeakProminence',0.4);    % find peaks
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
positions = x(locs(index(1:numberofgaussians))');
variances = ones(1,numberofgaussians);

% fitfunction -> if anything is changed, take care of the StartPoint!!!
[f, gof] = fit(x',y',...
                   multigaussfit,...
                   'StartPoint',...
                   [1,...
                   amplitudes,...
                   positions,...
                   variances,...
                   0]);