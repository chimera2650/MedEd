%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
chan_count = 62; % Number of channels in analysis
chan_name1 = 'FCz'; % Name of channel where effect occurs
chan_name2 = 'Fz';
chan_name3 = 'Pz';
cond_count = 2; % Number of conditions in analysis
d_name = 'med_ed.mat'; % Name of master data file
prefix = 'MedEdFlynn_'; % Prefix of raw data files
f_res = 0.5; % Frequency resolution
freq_points = [0 30]; % Desired time range for data
s_rate = 4; % Sampling rate in milliseconds
time_points1 = [-200 600]; % Desired time range for data
time_points2 = [-2000 0]; % Desired time range for data
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    erp_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    fft_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
    wav_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\med_ed.mat';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    erp_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    fft_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
    wav_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\med_ed.mat';
end

clear comp

%% Load Data
cd(master_dir);
load(d_name);
freq_range = abs(max(freq_points) - min(freq_points));
time_range1 = abs(max(time_points1) - min(time_points1));
time_range2 = abs(max(time_points2) - min(time_points2));

for a = 1:chan_count
    if strcmp(summary.chanlocs(a).labels,chan_name1) == 1
        c_index(a) = 1;
    elseif strcmp(summary.chanlocs(a).labels,chan_name2) == 1
        c_index(a) = 2;
    elseif strcmp(summary.chanlocs(a).labels,chan_name3) == 1
        c_index(a) = 3;
    else
        c_index(a) = 0;
    end
end

chan_num1 = find(c_index == 1);
chan_num2 = find(c_index == 2);
chan_num3 = find(c_index == 3);

clear a;
clear c_index;

%% ERP Analysis
%Summarize ERP data by subject
cd(erp_dir);
filenames = dir(strcat(prefix,'*'));
file_num = length(filenames);
disp('Summarizing ERP by subject');

for a = 1:file_num
    % First, data is collected by subject into a temporary array
    sub_data = importdata(filenames(a).name);
    for b = 1:cond_count
        % Each array is divided into cells, one per condition
        for c = 1:chan_count
            % Each row in the cell corrosponds to a channel
            for d = 1:chan_count
                % This normalizes the row number to ensure that all
                % channels corrospond to the same row
                if strcmpi(sub_data.chanlocs(d).labels,summary.chanlocs(c).labels) == 1
                    chan_loc(d) = 1;
                else
                    chan_loc(d) = 0;
                end
            end
            c_index = find(chan_loc == 1);
            temp_data{a}{b}(c,:) = sub_data.ERP.data{b}(c_index,:);
        end
    end
end

clear a;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear d;
clear sub_data;

disp('Combining ERP data by condition');

for a = 1:cond_count
    % Data is collapsed between subjects to create condition averages
    for b = 1:chan_count
        for c = 1:file_num
            temp_sum(c,:) = temp_data{c}{a}(b,:);
        end
        sum_data{a}(b,:) = nanmean(temp_sum(:,:));
    end
end

summary.ERP.data = sum_data;

clear a;
clear b;
clear c;
clear temp_sum;

% Standard Deviation for ERP
disp('Calculating ERP standard deviations');

for a = 1:cond_count
    % Data is collapsed between subjects to create condition standard
    % deviations
    for b = 1:chan_count
        for c = 1:file_num
            temp_sum(c,:) = temp_data{c}{a}(b,:);
        end
        sum_data{a}(b,:) = nanstd(temp_sum(:,:));
    end
end

summary.ERP.std = sum_data;

clear a;
clear b;
clear c;
clear sum_data;
clear temp_data;
clear temp_sum;

% ANOVA
disp('Calculating between-subject ANOVAs for ERP');

for a = 1:file_num
    sub_data = importdata(filenames(a).name);
    temp_data(:,1) = transpose(sub_data.ERP.data{1}(chan_num1,:));
    temp_data(:,2) = transpose(sub_data.ERP.data{2}(chan_num1,:));
    
    for b = 1:length(temp_data)
        temp_sum = nanmean(temp_data(b,:),1);
    end
    
    sum_data(a,:) = transpose(temp_sum);
end

clear a;
clear b;
clear sub_data;
clear temp_data;
clear temp_sum;

% Remove empty rows
nan_rows = isnan(sum_data(:,1));
sum_data(nan_rows,:) = [];
sum_data = transpose(sum_data);

% Calculate ANOVA
[p,tbl,stats] = anova1(sum_data,[],'off');
sum_anova.p = p;
sum_anova.tbl = tbl;
sum_anova.stats = stats;
summary.ERP.anova = sum_anova;

clear chan_num;
clear nan_rows;
clear p;
clear stats;
clear sub_data;
clear sum_anova;
clear sum_data;
clear tbl;

% Create a table for time points; used in plotting data
disp('Creating timepoints for ERP');

for a = 1:(time_range1/s_rate)
    t_point(1,a) = (min(time_points1)+(s_rate*a));
end

summary.ERP.time = t_point;

clear a;
clear t_point;
clear time_points1;
clear time_range1;

%% FFT Analysis
cd(fft_dir);

% Summarise FFT data by subject
disp('Summarizing FFT by subject. Please wait...');

for a = 1:file_num
    % First, data is collected by subject into a temporary array
    sub_data = importdata(filenames(a).name);
    for b = 1:cond_count
        % Each array is divided into cells, one per condition
        for c = 1:chan_count
            % Each row in the cell corrosponds to a channel
            for d = 1:chan_count
                % This normalizes the row number to ensure that all
                % channels corrospond to the same row
                if strcmpi(sub_data.chanlocs(d).labels,summary.chanlocs(c).labels)
                    chan_loc(d) = 1;
                else
                    chan_loc(d) = 0;
                end
            end
            c_index = find(chan_loc == 1);
            temp_data{a}{b}(c,:) = sub_data.FFT.data{b}(c_index,:);
        end
    end
end

clear a;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear d;
clear sub_data;

disp('Combining FFT data by condition');

for a = 1:cond_count
    % Data is collapsed between subjects to create condition averages
    for b = 1:chan_count
        for c = 1:file_num
            temp_sum(c,:) = temp_data{c}{a}(b,:);
        end
        sum_data{a}(b,:) = nanmean(temp_sum(:,:));
    end
end

summary.FFT.data = sum_data;

clear a;
clear b;
clear c;
clear temp_sum;

% Standard deviation for FFT
disp('Calculating FFT standard deviations');

for a = 1:cond_count
    % Data is collapsed between subjects to create condition standard
    % deviations
    for b = 1:chan_count
        for c = 1:file_num
            temp_sum(c,:) = temp_data{c}{a}(b,:);
        end
        sum_data{a}(b,:) = nanstd(temp_sum(:,:));
    end
end

summary.FFT.std = sum_data;

clear a;
clear b;
clear c;
clear sum_data;
clear temp_data;
clear temp_sum;

% Create frequency points for plots
disp('Creating frequency points');

% Create a table for frequency points; used in plotting data
for a = 1:(freq_range/f_res)
    f_point(1,a) = (1+min(freq_points)+(f_res*a));
end

summary.FFT.freq = f_point;

clear a;
clear f_point;

%% Wavelet Analysis
%Summarise data
disp('Summarizing wavelets by subject. Please wait...');

for a = 1:file_num
    % First, data is collected by subject into a temporary array
    sub_data = importdata(filenames(a).name);
    for b = 1:cond_count
        % Each array is divided into cells, one per condition
        for c = 1:chan_count
            % Each row in the cell corrosponds to a channel
            for d = 1:chan_count
                % This normalizes the row number to ensure that all
                % channels corrospond to the same row
                if strcmpi(sub_data.chanlocs(d).labels,summary.chanlocs(c).labels)
                    chan_loc(d) = 1;
                else
                    chan_loc(d) = 0;
                end
            end
            c_index = find(chan_loc == 1);
            temp_data{a}{b}(c,:,:) = sub_data.FFT.data{b}(c_index,:);
        end
    end
end

clear a;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear d;
clear sub_data;

disp('Combining wavelet data by condition. Please wait...');

for a = 1:cond_count
    % Data is collapsed between subjects to create condition averages
    for b = 1:chan_count
        for c = 1:file_num
            temp_sum(c,:,:) = temp_data{c}{a}(b,:,:);
        end
        sum_data{a}(b,:,:) = nanmean(temp_sum(:,:,:));
    end
end

summary.WAV.data = sum_data;

clear a;
clear b;
clear c;
clear temp_sum;

%% Create frequency and time points for plots
disp('Creating frequency and time points');

% Create a table for frequency points; used in plotting data
for a = 1:(freq_range/f_res)
    f_point(1,a) = (1+min(freq_points)+(f_res*a));
end

summary.WAV.freq = f_point;

clear a;
clear f_point;
clear f_res;
clear freq_points;
clear freq_range;

% Create a table for time points; used in plotting data
for a = 1:(time_range2/s_rate)
    t_point(1,a) = (min(time_points2)+(s_rate*a));
end

summary.WAV.time = t_point;

clear a;
clear s_rate;
clear t_point;
clear time_points2;
clear time_range2;

%% Save Data
disp('Saving data');
save(save_dir,'summary');

%% Final Cleanup
disp('Analysis complete');

clearvars -except summary;