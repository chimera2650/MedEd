%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
chan_count = 62; % Number of channels in analysis
chan_name1 = 'FCz'; % Name of channel where effect occurs
chan_name2 = 'Pz';
cond_count = 2; % Number of conditions in analysis
d_name = 'cog_assess.mat'; % Name of master data file
prefix = 'CogAssess_flynn_'; % Prefix of raw data files
s_rate = 4; % Sampling rate in milliseconds
time_points = [-200 600]; % Desired time range for data
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    rewp_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Cog Assess\RewP';
    p3_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Cog Assess\P300';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\cog_assess.mat';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    rewp_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Cog Assess\RewP';
    p3_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Cog Assess\P300';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\cog_assess.mat';
end

clear comp

%% Load Data
cd(master_dir);
load(d_name);
time_range = abs(max(time_points) - min(time_points));

for b = 1:chan_count
    if strcmp(summary.chanlocs(b).labels,chan_name1) == 1
        c_loc(b) = 1;
    elseif strcmp(summary.chanlocs(b).labels,chan_name2) == 1
        c_loc(b) = 2;
    else
        c_loc(b) = 0;
    end
end

clear a;

%% ERP Analysis
for a = 1:2
    if a == 1
        analysis = 'rewp';
        cd(rewp_dir);
        chan_num = find(c_loc == 1);
    elseif a == 2
        analysis = 'p300';
        cd(p3_dir);
        chan_num = find(c_loc == 2);
    end
    
    filenames = dir(strcat(prefix,'*'));
    file_num = length(filenames);
    
    for b = 1:file_num
        % First, data is collected by subject into a temporary array
        sub_data = importdata(filenames(b).name);
        for c = 1:cond_count
            % Each array is divided into cells, one per condition
            for d = 1:chan_count
                % Each row in the cell corrosponds to a channel
                for e = 1:chan_count
                    % This normalizes the row number to ensure that all
                    % channels corrospond to the same row
                    if strcmpi(sub_data.chanlocs(e).labels,summary.chanlocs(d).labels) == 1
                        chan_loc(e) = 1;
                    else
                        chan_loc(e) = 0;
                    end
                end
                c_index = find(chan_loc == 1);
                temp_data{b}{c}(d,:) = sub_data.ERP.data{c}(c_index,:);
            end
        end
    end
    
    clear b;
    clear c;
    clear d;
    clear e;
    clear c_index;
    clear chan_loc;
    clear d;
    clear sub_data;
    
    disp('Combining ERP data by condition');
    
    for b = 1:cond_count
        % Data is collapsed between subjects to create condition averages
        for c = 1:chan_count
            for d = 1:file_num
                temp_sum(d,:) = temp_data{d}{b}(c,:);
            end
            sum_data{b}(c,:) = nanmean(temp_sum(:,:));
        end
    end
    
    summary.(analysis).data = sum_data;
    
    clear b;
    clear c;
    clear d;
    clear temp_sum;
    
    % Standard Deviation for ERP
    disp('Calculating ERP standard deviations');
    
    for b = 1:cond_count
        % Data is collapsed between subjects to create condition standard
        % deviations
        for c = 1:chan_count
            for d = 1:file_num
                temp_sum(d,:) = temp_data{d}{b}(c,:);
            end
            sum_data{b}(c,:) = nanstd(temp_sum(:,:));
        end
    end
    
    summary.(analysis).std = sum_data;
    
    clear b;
    clear c;
    clear d;
    clear sum_data;
    clear temp_data;
    clear temp_sum;
    
    % ANOVA
    disp('Calculating between-subject ANOVAs for ERP');
    
    for b = 1:file_num
        sub_data = importdata(filenames(b).name);
        temp_data(:,1) = transpose(sub_data.ERP.data{1}(chan_num,:));
        temp_data(:,2) = transpose(sub_data.ERP.data{2}(chan_num,:));
        
        for c = 1:length(temp_data)
            temp_sum = nanmean(temp_data(c,:),1);
        end
        
        sum_data(b,:) = transpose(temp_sum);
    end
    
    clear b;
    clear c;
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
    summary.(analysis).anova = sum_anova;
    
    clear chan_num;
    clear nan_rows;
    clear p;
    clear stats;
    clear sub_data;
    clear sum_anova;
    clear sum_data;
    clear tbl;
end

clear a;
clear c_loc;

%% Create a table for time points; used in plotting data
disp('Creating timepoints for ERP');

for a = 1:(time_range/s_rate)
    t_point(1,a) = (min(time_points)+(s_rate*a));
end

summary.ERP.time = t_point;

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