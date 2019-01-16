%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
chan_count = 62; % Number of channels in analysis
cond_count1 = 2; % Number of conditions in analysis
cond_count2 = 3;
d_name = 'med_ed.mat'; % Name of master data file
prefix = 'MedEdFlynn_';
f_res = 0.5; % Frequency resolution
freq_points = [0 30]; % Desired time range for data
s_rate = 4; % Sampling rate in milliseconds
time_points1 = [-200 600]; % Desired time range for data
time_points2 = [-2000 0]; % Desired time range for data
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    erp_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback';
    erpnl_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback NL';
    fft_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    wav_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed.mat';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    erp_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback';
    erpnl_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback NL';
    fft_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    wav_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed.mat';
end

clear comp

%% Load Data
cd(master_dir);
load(d_name);
freq_range = abs(max(freq_points) - min(freq_points));
time_range1 = abs(max(time_points1) - min(time_points1));
time_range2 = abs(max(time_points2) - min(time_points2));

%% ERP Analysis
%Summarize ERP data by subject
cd(erp_dir);
filenames = dir(strcat(prefix,'*'));
file_num = length(filenames);
disp('Summarizing ERP by subject');

for a = 1:file_num
    % First, data is collected by subject into a temporary array
    sub_data = importdata(filenames(a).name);
    for b = 1:cond_count1
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

clear a;
clear artifacts;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear d;
clear sub_data;

disp('Generating raw ERP data table');

for a = 1:cond_count1
    for b = 1:file_num
       raw_data(:,:,a,b) = temp_data{b}{a}(:,:); 
    end
end

summary.ERP.raw = raw_data;

clear a;
clear b;
clear raw_data;

disp('Combining ERP data by condition');

for a = 1:cond_count1
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

for a = 1:cond_count1
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
clear temp_sum;

dispstat('','init');
dispstat(sprintf('Calculating ERP confidence intervals. Please wait...'),'keepthis');

for a = 1:chan_count
    for b = 1:(time_range1/s_rate)        
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
            for d = 1:cond_count1
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
summary.ERP.ci_data = erp_ci;
summary.ERP.ttest = erp_ttest;

clear a;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear ci_data;
clear cond1;
clear d;
clear erp_ci;
clear erp_ttest;
clear h;
clear num;
clear p;
clear sub_data;
clear sum_data;
clear t_data1;
clear t_data2;
clear tbl;
clear temp_data;
clear ts;

% Create a table for time points; used in plotting data
disp('Creating timepoints for ERP');

for a = 1:(time_range1/s_rate)
    t_point(1,a) = (min(time_points1)+(s_rate*a));
end

summary.ERP.time = t_point;

clear a;
clear erp_dir;
clear filenames;
clear file_num;
clear t_point;

%% ERP NL Analysis
%Summarize ERP data by subject
cd(erpnl_dir);
filenames = dir(strcat(prefix,'*'));
file_num = length(filenames);
disp('Summarizing ERP NL by subject');

for a = 1:file_num
    % First, data is collected by subject into a temporary array
    sub_data = importdata(filenames(a).name);
    for b = 1:cond_count1
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

clear a;
clear atrifacts;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear d;
clear sub_data;

disp('Generating raw ERP NL data table');

for a = 1:cond_count1
    for b = 1:file_num
       raw_data(:,:,a,b) = temp_data{b}{a}(:,:); 
    end
end

summary.ERP_NL.raw = raw_data;

clear a;
clear b;
clear raw_data;

disp('Combining ERP NL data by condition');

for a = 1:cond_count1
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
disp('Calculating ERP NL standard deviations');

for a = 1:cond_count1
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
clear temp_sum;

dispstat('','init');
dispstat(sprintf('Calculating NL confidence intervals. Please wait...'),'keepthis');

for a = 1:chan_count
    for b = 1:(time_range1/s_rate)
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
            for d = 1:cond_count1
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

clear a;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear ci_data;
clear cond1;
clear d;
clear erp_ci;
clear erp_ttest;
clear h;
clear num;
clear p;
clear sub_data;
clear sum_data;
clear t_data1;
clear t_data2;
clear tbl;
clear temp_data;
clear ts;

% Create a table for time points; used in plotting data
disp('Creating timepoints for ERP NL');

for a = 1:(time_range1/s_rate)
    t_point(1,a) = (min(time_points1)+(s_rate*a));
end

summary.ERP_NL.time = t_point;

clear a;
clear filenames;
clear file_num;
clear t_point;
clear time_points1;
clear time_range1;

%% FFT Analysis
cd(fft_dir);
filenames = dir(strcat(prefix,'*'));
file_num = length(filenames);

% Summarise FFT data by subject
dispstat('','init');
dispstat(sprintf('Summarizing FFT by subject. Please wait...'),'keepthis');

for a = 1:file_num
    if a == 1
        perc_last = 0;
        dispstat(sprintf('Progress %d%%',0))
    end
    
    perc_stat = round((a/file_num)*100);
    
    if perc_stat ~= perc_last
        dispstat(sprintf('Progress %d%%',perc_stat));
    end
    
    perc_last = perc_stat;
    % First, data is collected by subject into a temporary array
    sub_data = importdata(filenames(a).name);
    for b = 1:cond_count2
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
    artifacts(a,1) = mean(cell2mat(sub_data.FFT.nAccepted));
    artifacts(a,2) = mean(cell2mat(sub_data.FFT.nRejected));
end

dispstat('Finished.','keepprev');
summary.FFT.artifacts = artifacts;

clear a;
clear artifacts;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear d;
clear sub_data;

disp('Generating raw FFT data table');

for a = 1:cond_count2
    for b = 1:file_num
       raw_data(:,:,a,b) = temp_data{b}{a}(:,:); 
    end
end

summary.FFT.raw = raw_data;

clear a;
clear b;
clear raw_data;

disp('Combining FFT data by condition');

for a = 1:cond_count2
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

for a = 1:cond_count2
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
clear temp_sum;

dispstat('','init');
dispstat(sprintf('Calculating FFT confidence intervals. Please wait...'),'keepthis');

for a = 1:chan_count
    for b = 1:((freq_range/f_res)-1)
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
            for d = 1:cond_count2
                sum_data(c,d) = temp_data{c}{d}(a,b);
                for e = 1:5
                    f = b-3+e;
                    if f < 1
                        win_data(e) = NaN;
                    else
                        win_data(e) = temp_data{c}{d}(a,f);
                    end
                end
                t_data(c,d) = nanmean(win_data);
            end
        end
        
        cond1 = isnan(sum_data(:,2));
        sum_data(cond1,:) = [];
        t_data1 = t_data(:,1);
        t_data2 = t_data(:,3);
        [p,tbl] = anova1(sum_data,{'No Conflict','One Conflict','Two Conflict'},'off');
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
        fft_ttest(a,b) = p;
    end
    fft_ci(a,:) = transpose(ci_data(:,6));
end

dispstat('Finished.','keepprev');
summary.FFT.ci_data = fft_ci(:,1:59);
summary.FFT.ttest = fft_ttest(:,1:59);

clear a;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear ci_data;
clear cond1;
clear d;
clear fft_ci;
clear fft_ttest;
clear h;
clear num;
clear p;
clear sub_data;
clear sum_data;
clear t_data1;
clear t_data2;
clear tbl;
clear temp_data;
clear ts;

% Create frequency points for plots
disp('Creating frequency points');

% Create a table for frequency points; used in plotting data
for a = 1:(freq_range/f_res)
    f_point(1,a) = (1+min(freq_points)+(f_res*a));
end

summary.FFT.freq = f_point;

clear a;
clear f_point;
clear filenames;
clear file_num;

%% Wavelet Analysis
%Summarise data
cd(wav_dir);
filenames = dir(strcat(prefix,'*'));
file_num = length(filenames);
dispstat('','init');
dispstat(sprintf('Summarizing wavelets by subject. Please wait...'),'keepthis');

for a = 1:file_num
    if a == 1
        perc_last = 0;
        dispstat(sprintf('Progress %d%%',0))
    end
    
    perc_stat = round((a/file_num)*100);
    
    if perc_stat ~= perc_last
        dispstat(sprintf('Progress %d%%',perc_stat));
    end
    
    perc_last = perc_stat;
    % First, data is collected by subject into a temporary array
    sub_data = importdata(filenames(a).name);
    
    for b = 1:cond_count2
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
            temp_data{a}{b}(c,:,:) = sub_data.WAV.data{b}(c_index,:,:);
        end
    end
    artifacts(a,1) = mean(cell2mat(sub_data.WAV.nAccepted));
    artifacts(a,2) = mean(cell2mat(sub_data.WAV.nRejected));
end

dispstat('Finished.','keepprev');
summary.WAV.artifacts = artifacts;

clear a;
clear artifacts;
clear b;
clear c;
clear c_index;
clear chan_loc;
clear d;
clear sub_data;

disp('Generating raw wavelet data table');

for a = 1:cond_count2
    for b = 1:file_num
       raw_data(:,:,:,a,b) = temp_data{b}{a}(:,:,:); 
    end
end

summary.WAV.raw = raw_data;

clear a;
clear b;
clear raw_data;

disp('Combining wavelet data by condition');

for a = 1:cond_count2
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

dispstat('','init');
dispstat(sprintf('Calculating Cohens d between no conflict and high conflict conditions. Please wait...'),'keepthis');

for a = 1:chan_count
    if a == 1
        perc_last = 0;
        dispstat(sprintf('Progress %d%%',0))
    end
    
    perc_stat = round((a/chan_count)*100);
    
    if perc_stat ~= perc_last
        dispstat(sprintf('Progress %d%%',perc_stat));
    end
    
    perc_last = perc_stat;
    
    for b = 1:((freq_range/f_res)-1)
        for c = 1:(time_range2/s_rate)
            for d = 1:file_num
                t_data(1,d) = temp_data{d}{1}(a,b,c);
                t_data(2,d) = temp_data{d}{3}(a,b,c);
            end
            
            stdev(1) = std(t_data(1,:));
            stdev(2) = std(t_data(2,:));
            m_data(1) = mean(t_data(1,:));
            m_data(2) = mean(t_data(2,:));
            pool_stdev = sqrt(((stdev(1)^2)+(stdev(2)^2))/(file_num-2));
            cohen(a,b,c) = (m_data(2)-m_data(1))/pool_stdev;
        end
    end
end

dispstat('Finished.','keepprev');
summary.WAV.cohen = cohen;

clear a;
clear b;
clear c;
clear cohen;
clear d;
clear m_data;
clear num;
clear pool_stdev;
clear std;
clear t_data;
clear temp_data;

%% Create frequency and time points for plots
disp('Creating frequency and time points');

% Create a table for frequency points; used in plotting data
for a = 1:(freq_range/f_res)
    f_point(1,a) = (min(freq_points)+((f_res*a)+0.5));
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