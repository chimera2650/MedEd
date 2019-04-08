% Copyright (C) 2019 Jordan Middleton

% This function will create a linear dataset for use when plotting data. It
% requires a minimum and maximum frequency, as well as a sampling rate to
% produce the dataset

function frequency = frequencyPoints(frequencyMin,frequencyMax,sampleRate)
disp('Creating timepoints for FFT');
% First, determine the number of datapoints necessary to represent the
% desired range
frequencyCount = (abs(frequencyMax - frequencyMin))/sampleRate;
% Then generate the dataset using a linear progression
frequencyData = linspace(frequencyMin,frequencyMax,frequencyCount);
frequency = frequencyData;
end