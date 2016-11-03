% function to read data into structure to work with
%
% datafolder = folder where subfolders with the requested data lie
% details = name of the Temperature and Frequency file (lies in the
%                                           same directory as the
%                                           subfolders)

function data = readData(datafolder, details)

% add datafolder and all subfolders to path in order to access all data
alldatafolder = genpath(datafolder);            % generate folder list
addpath(alldatafolder);                         % add to path

% work on alldatafolder in order to sort the folders in correct order
alldatafolder = strsplit(alldatafolder, ';');   % seperate substrings
    % careful:  ':' for unix
    %           ';' for windows
alldatafolder = sort_nat(alldatafolder);        % sort everything
alldatafolder(1) = [];                          % delete first empty element
alldatafolder(1) = [];                          % same as datafolder
alldatafolder = char(alldatafolder);            % convert to char array

%create structure that contains all the measured data
field1 = 'Measurement'; value1 = [];    % enumerate measurements
field2 = 'XData';       value2 = [];    % all x-data (wavelength)
field3 = 'YData';       value3 = [];    % all y-data (intensity)
field4 = 'ZData';       value4 = [];    % all z-data (magnetic field and integral)
field5 = 'Temp';        value5 = [];    % temperature measured at
field6 = 'Field';       value6 = [];    % starting value for magnetic field
field7 = 'Step';        value7 = [];    % step size of B-field
field8 = 'Freq';        value8 = [];    % frequency of generator
field9 = 'PL';          value9 = [];    % 1 is PL, 0 differencial signal
field10 = 'OCE';         value10 = [];  % 0 is off, 1 is cw, 2 is external

data = struct(field1,value1,...
              field2,value2,...
              field3,value3,...
              field4,value4,...
              field5,value5,...
              field6,value6,...
              field7,value7,...
              field8,value8,...
              field9,value9,...
              field10,value10);
          
% read temperatures and frequencies
fileID = fopen(strcat(datafolder, details));
C = textscan(fileID, '%d %d %f %f %s %f %s');
fclose(fileID);

temps = [C{1,2}];
fields = [C{1,3}];
steps = [C{1,4}];
freqs = [C{1,6}];
pls = [C{1,5}];
oces = [C{1,7}];

measurements = length(C{1,1});

% iterate over all given folders to read data into given structure
for k = 1:measurements;
    % create filenames
    filename_x = strcat(alldatafolder(k,:), '\CCDz_X.dat');
    filename_y = strcat(alldatafolder(k,:), '\CCDz_Y.dat');
    filename_z = strcat(alldatafolder(k,:), '\CCDz_Z.dat');
    % read data into structure
    data(k).Measurement = k;
    data(k).XData = importdata(filename_x);
    data(k).YData = importdata(filename_y);
    data(k).ZData = importdata(filename_z);
    data(k).Temp = temps(k);
    data(k).Field = fields(k);
    data(k).Step = steps(k);
    data(k).Freq = freqs(k);
    if strcmp(pls(k),'PL')
        data(k).PL = 1;
    else
        data(k).PL = 0;
    end
    if strcmp(oces(k),'off')
        data(k).OCE = 0;
    elseif strcmp(oces(k),'cw')
        data(k).OCE = 1;
    else
        data(k).OCE = 2;
    end
end
