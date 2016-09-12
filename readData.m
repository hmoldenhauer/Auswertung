% function to read data into structure to work with
%
% datafolder = folder where subfolders with the requested data lie
% tempfreqfile = name of the Temperature and Frequency file (lies in the
%                                           same directory as the
%                                           subfolders)

function data = readData(datafolder, tempfreqfile)

% add datafolder and all subfolders to path in order to access all data
alldatafolder = genpath(datafolder);            % generate folder list
addpath(alldatafolder);                         % add to path

% work on alldatafolder in order to sort the folders in correct order
alldatafolder = strsplit(alldatafolder, ';');   % seperate substrings
alldatafolder = sort_nat(alldatafolder);        % sort everything
alldatafolder(1) = [];                          % delete first empty element
alldatafolder(1) = [];                          % same as datafolder
alldatafolder = char(alldatafolder);            % convert to char array

[measurements, foldernamelength] = size(alldatafolder);

%create structure that contains all the measured data
field1 = 'Measurement'; value1 = [];    % enumerate measurements
field2 = 'XData';       value2 = [];    % all x-data (wavelength)
field3 = 'YData';       value3 = [];    % all y-data (intensity)
field4 = 'ZData';       value4 = [];    % all z-data (magnetic field and integral)
field5 = 'Temp';        value5 = [];    % temperature measured at
field6 = 'Freq';        value6 = [];    % frequency of generator

data = struct(field1,value1,...
              field2,value2,...
              field3,value3,...
              field4,value4,...
              field5,value5,...
              field6,value6);
          
% read temperatures and frequencies
fileID = fopen(strcat(datafolder, tempfreqfile));
C = textscan(fileID, '%d %f');
fclose(fileID);

temps = [C{1}];
freqs = [C{2}];

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
    data(k).Freq = freqs(k);
end
