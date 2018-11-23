%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
chan_count = 62; % Number of channels in analysis
chan_name = 'FCz'; % Name of channel where effect occurs
cond_count = 2; % Number of conditions in analysis
d_name = 'med_ed.mat'; % Name of master data file
prefix = 'MedEdNLFlynn_';
s_rate = 4; % Sampling rate in milliseconds
time_points = [-200 600]; % Desired time range for data
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    erp_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Feedback NL';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\med_ed.mat';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    erp_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback NL';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\med_ed.mat';
end

clear comp

%% Load Data
cd(master_dir);
load(d_name);
time_range = abs(max(time_points) - min(time_points));

for a = 1:chan_count
    if strcmp(summary.chanlocs(a).labels,chan_name) == 1
        c_index(a) = 1;
    else
        c_index(a) = 0;
    end
end

chan_num = find(c_index == 1);

clear a;
clear c_index;

%% NL ERP Analysis
cd(erp_dir);
filenames = dir(strcat(prefix,'*')); % Get a count of file number
file_num = length(filenames);
disp('Summarizing ERP by subject'); % Display current subject

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

disp('Generating raw ERP data table');

for a = 1:cond_count
    for b = 1:file_num
       raw_data(:,:,a,b) = temp_data{b}{a}(:,:); 
    end
end

summary.ERP_NL.raw = raw_data;

clear a;
clear b;
clear raw_data;

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

summary.ERP_NL.data = sum_data;

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

summary.ERP_NL.std = sum_data;

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
    temp_data(:,1) = transpose(sub_data.ERP.data{1}(chan_num,:));
    temp_data(:,2) = transpose(sub_data.ERP.data{2}(chan_num,:));
    
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
summary.ERP_NL.anova = sum_anova;

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

for a = 1:(time_range/s_rate)
    t_point(1,a) = (min(time_points)+(s_rate*a));
end

summary.ERP_NL.time = t_point;

clear a;
clear t_point;
clear time_points;
clear time_range;

%% Save Data
disp('Saving data');
save(save_dir,'summary');

%% Final Cleanup
disp('Analysis complete');

clearvars -except summary;