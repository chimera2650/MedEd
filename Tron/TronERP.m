%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
chan_count = 62; % Number of channels in analysis
cond_count = 2; % Number of conditions in analysis
d_name = 'med_ed_erp.mat'; % Name of master data file
prefix = 'MedEdFlynn_';
s_rate = 4; % Sampling rate in milliseconds
time_points = [-200 600]; % Desired time range for data
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    erp_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback';
    erpnl_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback NL';
    save_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_erp.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    erp_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback';
    erpnl_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback NL';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_erp.mat';
end

clearvars comp;

%% Load Data
cd(master_dir);
load(d_name);
time_range = abs(max(time_points) - min(time_points));

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
    artifacts(a,1) = mean(cell2mat(sub_data.ERP.nAccepted));
    artifacts(a,2) = mean(cell2mat(sub_data.ERP.nRejected));
end

summary.ERP.artifacts = artifacts;

clearvars  a artifacts b c c_index chan_loc d sub_data;

disp('Generating raw ERP data table');

for a = 1:cond_count
    for b = 1:file_num
       raw_data(:,:,a,b) = temp_data{b}{a}(:,:); 
    end
end

summary.ERP.raw = raw_data;

clearvars a b raw_data;

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

clearvars a b c temp_sum;

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

clearvars a b c sum_data temp_sum;

dispstat('','init');
dispstat(sprintf('Calculating ERP confidence intervals. Please wait...'),'keepthis');

for a = 1:chan_count
    for b = 1:(time_range/s_rate)        
        if a == 1
            perc_last = 0;
            dispstat(sprintf('Progress %d%%',0))
        end
        
        perc_stat = round((a/chan_count)*100);
        
        if perc_stat ~= perc_last
            dispstat(sprintf('Progress %d%%',perc_stat));
        end
        
        perc_last = perc_stat;
        
        for c = 1:file_num
            for d = 1:cond_count
                sum_data(c,d) = temp_data{c}{d}(a,b);
            end
        end
        
        cond1 = isnan(sum_data(:,2));
        sum_data(cond1,:) = [];
        t_data1 = sum_data(:,1);
        t_data2 = sum_data(:,2);
        [p,tbl] = anova1(sum_data,{'win','loss'},'off');
        sum_data = mean(sum_data,2);
        ci_data(b,1) = mean(sum_data);
        ci_data(b,2) = std(sum_data);
        ci_data(b,3) = length(sum_data);
        ci_data(b,4) = ci_data(b,2)/sqrt(ci_data(b,3)-1);
        ts = tinv(0.95,ci_data(b,3)-1);
        ci_data(b,5) = tbl{3,4};
        ci_data(b,6) = sqrt(ci_data(b,5)/ci_data(b,3))*(ts);
        
        clearvars p;
        
        [h,p] = ttest(t_data1,t_data2,'tail','both');
        erp_ttest(a,b) = p;
    end
    erp_ci(a,:) = transpose(ci_data(:,6));
end

dispstat('Finished.','keepprev');
summary.ERP.ci_data = erp_ci;
summary.ERP.ttest = erp_ttest;

clearvars a b c c_index chan_loc ci_data cond1 d erp_ci erp_ttest h num p ...
    sub_data sum_data t_data1 t_data2 tbl temp_data ts;

test_data = squeeze(nanmean(summary.ERP.raw(35,:,1,:),4)) -...
    squeeze(nanmean(summary.ERP.raw(35,:,2,:),4));
[val,peak_idx] = max(test_data);

for a = 1:size(summary.ERP.raw,3)
    for b = 1:size(summary.ERP.raw,4)
        temp_data = squeeze(summary.ERP.raw(35,:,a,b));
        temp_data(isnan(temp_data)) = 0;
        peak(b,a) = mean(temp_data(peak_idx-25:peak_idx+25));
    end
end

std_peak = [std(peak(:,1)) std(peak(:,2))];
[h,sig_peak] = ttest(peak(:,1),peak(:,2));
ci_peak = [(1.96*(std_peak(1)/sqrt(size(summary.ERP.raw,4)))) ...
    (1.96*(std_peak(2)/sqrt(size(summary.ERP.raw,4))))];
summary.ERP.peak.mean = val;
summary.ERP.peak.stdev = std_peak;
summary.ERP.peak.ci = ci_peak;
summary.ERP.peak.sig = sig_peak;
summary.ERP.peak.latency = peak_idx;

% Create a table for time points; used in plotting data
disp('Creating timepoints for ERP');

for a = 1:(time_range/s_rate)
    t_point(1,a) = (min(time_points)+(s_rate*a));
end

summary.ERP.time = t_point;

clearvars a erp_dir filenames file_num t_point;

%% ERP NL Analysis
%Summarize ERP data by subject
cd(erpnl_dir);
filenames = dir(strcat(prefix,'*'));
file_num = length(filenames);
disp('Summarizing ERP NL by subject');

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
    artifacts(a,1) = mean(cell2mat(sub_data.ERP.nAccepted));
    artifacts(a,2) = mean(cell2mat(sub_data.ERP.nRejected));
end

summary.ERP_NL.artifacts = artifacts;

clearvars a artifacts b c c_index chan_loc d sub_data;

disp('Generating raw ERP NL data table');

for a = 1:cond_count
    for b = 1:file_num
       raw_data(:,:,a,b) = temp_data{b}{a}(:,:); 
    end
end

summary.ERP_NL.raw = raw_data;

clearvars a b raw_data;

disp('Combining ERP NL data by condition');

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

clearvars a b c temp_sum;

% Standard Deviation for ERP
disp('Calculating ERP NL standard deviations');

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

clearvars a b c sum_data temp_sum;

dispstat('','init');
dispstat(sprintf('Calculating NL confidence intervals. Please wait...'),'keepthis');

for a = 1:chan_count
    for b = 1:(time_range/s_rate)
        if a == 1
            perc_last = 0;
            dispstat(sprintf('Progress %d%%',0))
        end
        
        perc_stat = round((a/chan_count)*100);
        
        if perc_stat ~= perc_last
            dispstat(sprintf('Progress %d%%',perc_stat));
        end
        
        perc_last = perc_stat;
        
        for c = 1:file_num
            for d = 1:cond_count
                sum_data(c,d) = temp_data{c}{d}(a,b);
            end
        end
        
        cond1 = isnan(sum_data(:,2));
        sum_data(cond1,:) = [];
        t_data1 = sum_data(:,1);
        t_data2 = sum_data(:,2);
        [p,tbl] = anova1(sum_data,{'win','loss'},'off');
        sum_data = mean(sum_data,2);
        ci_data(b,1) = mean(sum_data);
        ci_data(b,2) = std(sum_data);
        ci_data(b,3) = length(sum_data);
        ci_data(b,4) = ci_data(b,2)/sqrt(ci_data(b,3)-1);
        ts = tinv(0.95,ci_data(b,3)-1);
        ci_data(b,5) = tbl{3,4};
        ci_data(b,6) = sqrt(ci_data(b,5)/ci_data(b,3))*(ts);
        
        clear p;
        
        [h,p] = ttest(t_data1,t_data2,'tail','both');
        erp_ttest(a,b) = p;
    end
    erp_ci(a,:) = transpose(ci_data(:,6));
end

dispstat('Finished.','keepprev');
summary.ERP_NL.ci_data = erp_ci;
summary.ERP_NL.ttest = erp_ttest;

clearvars a b c c_index chan_loc ci_data cond1 d erp_ci erp_ttest h num p ...
    sub_data sum_data t_data1 t_data2 tbl temp_data ts;

test_data = squeeze(nanmean(summary.ERP_NL.raw(35,:,1,:),4)) -...
    squeeze(nanmean(summary.ERP_NL.raw(35,:,2,:),4));
[val,peak_idx] = max(test_data);

for a = 1:size(summary.ERP_NL.raw,3)
    for b = 1:size(summary.ERP_NL.raw,4)
        temp_data = squeeze(summary.ERP_NL.raw(35,:,a,b));
        temp_data(isnan(temp_data)) = 0;
        peak(b,a) = mean(temp_data(peak_idx-25:peak_idx+25));
    end
end

std_peak = [std(peak(:,1)) std(peak(:,2))];
[h,sig_peak] = ttest(peak(:,1),peak(:,2));
ci_peak = [(1.96*(std_peak(1)/sqrt(size(summary.ERP_NL.raw,4)))) ...
    (1.96*(std_peak(2)/sqrt(size(summary.ERP_NL.raw,4))))];
summary.ERP_NL.peak.mean = val;
summary.ERP_NL.peak.stdev = std_peak;
summary.ERP_NL.peak.ci = ci_peak;
summary.ERP_NL.peak.sig = sig_peak;
summary.ERP_NL.peak.latency = peak_idx;

% Create a table for time points; used in plotting data
disp('Creating timepoints for ERP NL');

for a = 1:(time_range/s_rate)
    t_point(1,a) = (min(time_points)+(s_rate*a));
end

summary.ERP_NL.time = t_point;

clearvars a filenames file_num t_point time_points1 time_range1;

%% Save Data
disp('Saving data');
save(save_dir,'summary');

%% Final Cleanup
disp('Analysis complete');

clearvars -except summary;