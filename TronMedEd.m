%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
prefix = 'MedEdFlynn_';
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    working_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    working_dir2 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
    save_path = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\cog_assess.mat';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    working_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    working_dir2 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
    save_path = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\cog_assess.mat';
end

clear comp

%% Load Data
cd(working_dir);
load('final_summary.mat');

%% ERP Analysis
cd(working_dir1);
filenames = dir(strcat(prefix,'*'));
file_num = length(filenames);
disp('Summarizing ERP by subject');

for x = 1:file_num
    subject_data = importdata(filenames(x).name);
    for i = 1:2
        for ii = 1:62
            for iii = 1:62
                if strcmpi(subject_data.chanlocs(iii).labels,final_summary.chanlocs(ii).labels) == 1
                    chan_loc(iii) = 1;
                else
                    chan_loc(iii) = 0;
                end
            end
            c_index = find(chan_loc == 1);
            temp_data(ii,:) = subject_data.ERP.data{i}(c_index,:);
        end
        summary_table{i} = temp_data;
    end
    summary_data{x} = summary_table;
end

disp('Combining subject ERP data');

for x = 1:2
    for i = 1:62
        for ii = 1:file_num
            temp_sub_sum(ii,:) = summary_data{ii}{x}(i,:); % Collapse by subject
        end
        temp_sub_sum(13,:) = [];
        temp_chan_sum(i,:) = mean(temp_sub_sum(:,:)); % Create a row for each channel
    end
    grand_summary{x} = temp_chan_sum; % Create a cell for each condition
end

final_summary.ERP.data = grand_summary;

clear c_index;
clear chan_loc;
clear i;
clear ii;
clear iii;
clear subject_data;
clear summary_data;
clear summary_table;
clear temp_chan_sum;
clear temp_data;
clear temp_sub_sum;
clear x;

disp('Summarizing ERP descriptive stats by subject');

for x = 1:file_num
    subject_data = importdata(filenames(x).name);
    for i = 1:2
        for ii = 1:62
            for iii = 1:62
                if strcmpi(subject_data.chanlocs(iii).labels,final_summary.chanlocs(ii).labels) == 1
                    chan_loc(iii) = 1;
                else
                    chan_loc(iii) = 0;
                end
            end
            c_index = find(chan_loc == 1);
            temp_data(ii,:) = subject_data.ERP.data{i}(c_index,:);
        end
        summary_table{i} = temp_data;
    end
    summary_data{x} = summary_table;
end

disp('Combining descriptive stats for ERP');

for x = 1:2
    for i = 1:62
        for ii = 1:file_num
            temp_sub_sum(ii,:) = summary_data{ii}{x}(i,:);
        end
        temp_sub_sum(13,:) = [];
        temp_chan_sum(i,:) = std(temp_sub_sum(:,:));
    end
    grand_summary{x} = temp_chan_sum;
end
final_summary.ERP.std = grand_summary;

summary_table = [];
disp('Running ERP ANOVAs by subject');

for x = 1:file_num
    subject_data = importdata(filenames(x).name);
    temp_data1 = transpose(subject_data.ERP.data{1}(c_index,:));
    temp_data2 = transpose(subject_data.ERP.data{2}(c_index,:));
    summary_data1(:,1) = temp_data1;
    summary_data1(:,2) = temp_data2;
    
    for i = 1:length(summary_data1)
        summary_data2(i,:) = mean(summary_data1(i,:));
    end
    
    summary_table(end+1,:) = transpose(summary_data2);
end

cond1 = isnan(summary_table(:,1));
summary_table(cond1,:) = [];
summary_table = transpose(summary_table);

[p,tbl,stats] = anova1(summary_table,[],'off');
ERPanova.p = p;
ERPanova.tbl = tbl;
ERPanova.stats = stats;
final_summary.ERP.anova = ERPanova;

clear c_index;
clear cond1;
clear ERPanova;
clear i;
clear p;
clear stats;
clear subject_data;
clear summary_data1;
clear summary_data2;
clear tbl;
clear temp_data1;
clear temp_data2;
clear x;

for x = 1:200
    time_point(1,x) = (-200+(4*x));
end
final_summary.ERP.time = time_point;

clear c_index;
clear chan_loc;
clear filenames;
clear grand_summary;
clear i;
clear ii;
clear iii;
clear subject_data;
clear summary_data;
clear summary_table;
clear temp_chan_sum;
clear temp_data;
clear temp_sub_sum;
clear time_point;
clear x;

%% FFT Analysis
cd(working_dir2);
filenames = dir(strcat(prefix,'*'));
file_num = length(filenames);

for x = 1:file_num
    num = num2str(x);
    subject_data = importdata(filenames(x).name);
    disp(['Summarizing FFT for subject ' num]);
    for i = 1:3
        for ii = 1:62
            for iii = 1:62
                if strcmpi(subject_data.chanlocs(iii).labels,final_summary.chanlocs(ii).labels)
                    chan_loc(iii) = 1;
                else
                    chan_loc(iii) = 0;
                end
            end
            c_index = find(chan_loc == 1);
            temp_data(ii,:) = subject_data.FFT.data{i}(c_index,:);
        end
        summary_table{i} = temp_data;
    end
    summary_data{x} = summary_table;
end

disp('Combining subject FFT data');

for x = 1:3
    for i = 1:62
        for ii = 1:file_num
            temp_sub_sum(ii,:) = summary_data{ii}{x}(i,:); % Collapse by subject
        end
        temp_chan_sum(i,:) = mean(temp_sub_sum(:,:)); % Create a row for each channel
    end
    grand_summary{x} = temp_chan_sum; % Create a cell for each condition
end
final_summary.FFT.data = grand_summary;

clear c_index;
clear chan_loc;
clear grand_summary;
clear i;
clear ii;
clear iii;
clear subject_data;
clear summary_data;
clear summary_table;
clear temp_chan_sum;
clear temp_data;
clear temp_sub_sum;
clear x;

disp('Summarizing FFT descriptive stats by subject');

for x = 1:file_num
    subject_data = importdata(filenames(x).name);
    for i = 1:3
        for ii = 1:62
            for iii = 1:62
                if strcmpi(subject_data.chanlocs(iii).labels,final_summary.chanlocs(ii).labels)
                    chan_loc(iii) = 1;
                else
                    chan_loc(iii) = 0;
                end
            end
            c_index = find(chan_loc == 1);
            temp_data(ii,:) = subject_data.FFT.data{i}(c_index,:);
        end
        summary_table{i} = temp_data;
    end
    summary_data{x} = summary_table;
end

disp('Combining descriptive stats for FFT');

for x = 1:3
    for i = 1:62
        for ii = 1:file_num
            temp_sub_sum(ii,:) = summary_data{ii}{x}(i,:); % Collapse by subject
        end
        temp_chan_sum(i,:) = std(temp_sub_sum(:,:)); % Create a row for each channel
    end
    grand_summary{x} = temp_chan_sum; % Create a cell for each condition
end
final_summary.FFT.std = grand_summary;

for x = 1:59
    freq_point(1,x) = 0.5+(0.5*x);
end
final_summary.FFT.freq = freq_point;

clear c_index;
clear chan_loc;
clear filenames;
clear freq_point;
clear grand_summary;
clear i;
clear ii;
clear iii;
clear subject_data;
clear summary_data;
clear summary_table;
clear temp_chan_sum;
clear temp_data;
clear temp_sub_sum;
clear x;

%% Wavelet Analysis
cd(working_dir2);
filenames = dir(strcat(prefix,'*'));   % Get a count of file number
file_num = length(filenames);

for x = 1:file_num
    num = num2str(x);
    subject_data = importdata(filenames(x).name); % Import subject data
    disp(['Summarizing wavelets for subject ' num]);    % Display current subject
    for i = 1:3
        for ii = 1:62
            for iii = 1:62
                if strcmpi(subject_data.chanlocs(iii).labels,final_summary.chanlocs(ii).labels)
                    chan_loc(iii) = 1;
                else
                    chan_loc(iii) = 0;
                end
            end
            c_index = find(chan_loc == 1);
            temp_data(ii,:,:) = subject_data.WAV.data{i}(c_index,:,:);
        end
        summary_table{i} = temp_data;
    end
    summary_data{x} = summary_table;
end

for x = 1:3
    num = num2str(x);
    disp(['Combining wavelets for condition ' num]);
    for i = 1:62
        for ii = 1:file_num
            temp_sub_sum(ii,:,:) = summary_data{ii}{x}(i,:,:); % Collapse by subject
        end
        temp_chan_sum(i,:,:) = mean(temp_sub_sum(:,:,:)); % Create a row for each channel
    end
    grand_summary{x} = temp_chan_sum; % Create a cell for each condition
end
    final_summary.wavelet.data = grand_summary;

for x = 1:59
    freq_point(1,x) = 0.5+(0.5*x);
end
final_summary.wavelet.freq = freq_point;

for x = 1:500
    time_point(1,x) = (4*x)-2000;
end
final_summary.wavelet.time = time_point;

clear c_index;
clear chan_loc;
clear file_num;
clear filenames;
clear freq_point;
clear grand_summary;
clear i;
clear ii;
clear iii;

clear subject_data;
clear summary_data;
clear summary_table;
clear temp_chan_sum;
clear temp_data;
clear temp_sub_sum;
clear time_point;
clear x;

%% Save Data
save(save_path,'final_summary');