%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
chan_count = 62; % Number of channels in analysis
chan_name1 = 'FCz'; % Name of channel where effect occurs
chan_name2 = 'Fz';
chan_name3 = 'Pz';
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
    master_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    erp_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    fft_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\med_ed.mat';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    erp_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    fft_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
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

%% ERP CI and t-tests
cd(erp_dir);
filenames = dir(strcat(prefix,'*'));   % Get a count of file number
file_num = length(filenames);

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
end

for a = 1:chan_count
    for b = 1:(time_range1/s_rate)
        num = summary.chanlocs(a).labels;
        
        if b == 1
            disp(['Calculating ERP confidence intervals and t-tests for ' num]);
        end
        
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

%% FFT CI and t-tests
cd(fft_dir);
filenames = dir(strcat(prefix,'*'));   % Get a count of file number
file_num = length(filenames);

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
            temp_data{a}{b}(c,:) = sub_data.FFT.data{b}(c_index,:);
        end
    end
end

for a = 1:chan_count
    for b = 1:(freq_range/f_res)
        num = summary.chanlocs(a).labels;
        
        if b == 1
            disp(['Calculating FFT confidence intervals and t-tests for ' num]);
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
        fft_ttest(a,b) = p;
    end
    fft_ci(a,:) = transpose(ci_data(:,6));
end

summary.FFT.ci_data = fft_ci;
summary.FFT.ttest = fft_ttest;

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

%% Save Data
save(save_path,'final_summary');

%% Clean Workspace
clear c_index1;
clear c_index2;
clear c_index3;
clear file_num;
clear filenames;
clear num;
clear subject_data;
