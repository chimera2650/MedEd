% This function will create a linear dataset for use when plotting data. It
% requires a minimum and maximum time, as well as a sampling rate to
% produce the dataset

function time = timePoints(timeMin,timeMax,sampleRate)
disp('Creating timepoints for ERP');
% First, determine the number of datapoints necessary to represent the
% desired range
timeCount = (abs(timeMax - timeMin))/sampleRate;
% Then generate the dataset using a linear progression
timeData = linspace(timeMin,timeMax,timeCount);
time = timeData;
end