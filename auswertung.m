% ----------------------------------------------------------------------
% User input before programm runs
% ----------------------------------------------------------------------

% define name of the folder with data of interest
datafolder = '..\..\Messdaten\2016-05-09-CuBO-T-and-PL\';

% define how many gaussian functions should be used
numberofgaussians = 2;

% define range for fit window
x_min = 896; % 896
x_max = 911; % 911

% ----------------------------------------------------------------------
% Definitions needed by the program
% ----------------------------------------------------------------------

% add folder and all subfolders to path in order to make this analyze work
addpath(genpath('..\Auswertung\'));

% ----------------------------------------------------------------------
% Reading the data
% ----------------------------------------------------------------------

% read the data
%data = readData(datafolder, 'details_matlab.txt');

% ----------------------------------------------------------------------
% Fitting the data
% ----------------------------------------------------------------------
for m = 1:data(end).Measurement
    if data(m).PL == 1
    % find out number of pixels of the CCD and the number of spectra
    [campx, spectra] = size(data(m).XData);
    
    % fit all the spectra
    for n = 1:9:spectra
        [ftemp, goftemp, xtemp, ytemp, ampstemp, postemp] = fittingData(data(m),...
                                                            campx,...
                                                            x_min, x_max,...
                                                            numberofgaussians, n);
         % save fit data of all spectra
         f{m,n} = ftemp;
         gof{m,n} = goftemp;
         x{m,n} = xtemp;
         y{m,n} = ytemp;
         amps{m,n} = ampstemp;
         pos{m,n} = postemp;
         fprintf('Fit %d of %d finished\n', n, spectra);
         
         if xtemp == 0
         % plot each 10th fit in a new figure
         elseif mod(n,10) == 0 | n == 1
             figure;
             hold on;
             plot(f{m,n},x{m,n},y{m,n});
             plot(pos{m,n},amps{m,n}, 'ro');
             
             % plot seperate fit functions used
             if true
                 for k = 1:numberofgaussians
                     if k == 1
                         fplot(@(x) f{m,n}.('y0')+f{m,n}.('a')*x,...
                             [x{m,n}(1),x{m,n}(end)]);
                     end
                     ampstr = strcat('amp', num2str(k));
                     posstr = strcat('pos', num2str(k));
                     varstr = strcat('var', num2str(k));
                     fplot(@(x) f{m,n}.(ampstr)*exp(-(x-f{m,n}.(posstr))^2/(2*f{m,n}.(varstr)^2)),...
                         [x{m,n}(1),x{m,n}(end)]);
                 end
             end
             xlabel('Wavelength (nm)');
             ylabel('Intensity (cps)');
             title(['m = ' num2str(m) ' n = ' num2str(n)]);
             hold off;
             fprintf('Plot %d of %d finished\n', n, spectra);
         end
    end
    end
end

clear -regexpr *temp *str spectra campx k m n

% ----------------------------------------------------------------------
% Ploting the whole stuff
% ----------------------------------------------------------------------
if false
    hold on;
    legend_vec = [];

    % iterate over all data
    for k = 1:data(end).Measurement
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