datafolder = '..\..\Messdaten\2016-11-15-Dummy\';

M = dlmread(strcat(datafolder, '01'));

Y = fft(M(2,:))