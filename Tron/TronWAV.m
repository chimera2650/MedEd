%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
chan_count = 62; % Number of channels in analysis
cond_count = 3;
t_name = 'med_ed_twav.mat'; % Name of master data file
d_name = 'med_ed_dwav.mat'; % Name of master data file
prefix = 'MedEdFlynn_';
f_res = 0.5; % Frequency resolution
freq_points = [1 30]; % Desired time range for data
s_rate = 4; % Sampling rate in milliseconds
time_points1 = [0 1996];
time_points2 = [-1996 0]; % Desired time range for data
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    temp_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Template';
    dec_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    tsave_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_twav.mat';
    dsave_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_dwav.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    temp_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Template';
    dec_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    tsave_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_twav.mat';
    dsave_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_dwav.mat';
end

clearvars comp

%% Load Data
freq_count = (abs(max(freq_points) - min(freq_points))/f_res)+1;
time_count1 = (abs(max(time_points1) - min(time_points1))/s_rate)+1;
time_count2 = (abs(max(time_points2) - min(time_points2))/s_rate)+1;

%% Wavelet Analysis
%Summarise data
for a = 1:2
    if a == 1
        cd(master_dir);
        load(t_name);
        cd(temp_dir);
        analysis = 'template';
        time_points = time_points1;
        time_count = time_count1;
        save_dir = tsave_dir;
    elseif a == 2
        cd(master_dir);
        load(d_name);
        cd(dec_dir);
        analysis = 'decision';
        time_points = time_points2;
        time_count = time_count2;
        save_dir = dsave_dir;
    end
    
    filenames = dir(strcat(prefix,'*'));
    file_num = length(filenames);
    dispstat('','init');
    dispstat(sprintf(['Summarizing ' analysis ' wavelets by subject. Please wait...']),'keepthis');
    
    for b = 1:file_num
        if b == 1
            perc_last = 0;
            dispstat(sprintf('Progress %d%%',0))
        end
        
        perc_stat = round((b/file_num)*100);
        
        if perc_stat ~= perc_last
            dispstat(sprintf('Progress %d%%',perc_stat));
        end
        
        perc_last = perc_stat;
        % First, data is collected by subject into a temporary array
        sub_data = importdata(filenames(b).name);
        
        for c = 1:cond_count
            % Each array is divided into cells, one per condition
            for d = 1:chan_count
                % Each row in the cell corrosponds to a channel
                for e = 1:chan_count
                    % This normalizes the row number to ensure that all
                    % channels corrospond to the same row
                    if strcmpi(sub_data.chanlocs(e).labels,summary.chanlocs(d).labels)
                        chan_loc(e) = 1;
                    else
                        chan_loc(e) = 0;
                    end
                end
                c_index = find(chan_loc == 1);
                temp_data{b}{c}(d,:,:) = sub_data.WAV.data{c}(c_index,:,51:550);
            end
        end
        artifacts(b,1) = mean(cell2mat(sub_data.WAV.nAccepted));
        artifacts(b,2) = mean(cell2mat(sub_data.WAV.nRejected));
    end
    
    dispstat('Finished','keepprev');
    summary.artifacts = artifacts;
    
    clearvars artifacts b c c_index chan_loc d e sub_data;
    
    disp(['Generating raw ' analysis ' wavelet data table']);
    
    for b = 1:cond_count
        for c = 1:file_num
            raw_data(:,:,:,b,c) = temp_data{c}{b}(:,:,:);
        end
    end
    
    clearvars b c temp_data;
    
    for b = 1:size(raw_data,1)        
        for c = 1:size(raw_data,2)
            for d = 1:size(raw_data,4)                
                for e = 1:size(raw_data,5)
                    temp_data = squeeze(raw_data(b,c,:,d,e));
                    temp_stdev = std(squeeze(temp_data));
                    temp_mean = mean(squeeze(temp_data));
                    temp_z = (temp_data - temp_mean) ./ temp_stdev;
                    norm_data(b,c,:,d,e) = temp_z;
                end
            end
        end
    end
    
    summary.raw = norm_data;
    
    clearvars b c d e raw_data temp_data temp_mean temp_std temp_z;
    
    disp(['Combining ' analysis ' wavelet data by condition']);
    
    mean_data = squeeze(mean(summary.raw,5));
    
    summary.data = mean_data;
    
    clearvars mean_data;
    
    dispstat('','init');
    dispstat(sprintf(['Calculating Cohens d between no conflict and high conflict ' analysis ' conditions. Please wait...']),'keepthis');
    
    for b = 1:size(summary.raw,1)
        if b == 1
            perc_last = 0;
            dispstat(sprintf('Progress %d%%',0))
        end
        
        perc_stat = round((b/chan_count)*100);
        
        if perc_stat ~= perc_last
            dispstat(sprintf('Progress %d%%',perc_stat));
        end
        
        perc_last = perc_stat;
        
        for c = 1:size(summary.raw,2)
            for d = 1:size(summary.raw,3)
                temp_data(1,:) = squeeze(summary.raw(b,c,d,1,:));
                temp_data(2,:) = squeeze(summary.raw(b,c,d,3,:));
                stdev(1) = std(temp_data(1,:));
                stdev(2) = std(temp_data(2,:));
                m_data(1) = mean(temp_data(1,:));
                m_data(2) = mean(temp_data(2,:));
                pool_stdev = sqrt(((stdev(1)^2) + (stdev(2)^2)) /...
                    (size(summary.raw,5) - 2));
                cohen(b,c,d) = (m_data(2) - m_data(1)) / pool_stdev;
            end
        end
    end
    
    dispstat('Finished','keepprev');
    summary.cohen = cohen;
    
    clearvars b c cohen d e m_data num pool_stdev std t_data temp_data;
    
    %% Create frequency and time points for plots
    disp(['Creating ' analysis ' frequency and time points']);
    
    % Create a table for frequency points; used in plotting data
    f_point = linspace(min(freq_points),max(freq_points),freq_count);
    summary.freq = f_point;
    
    clearvars f_point
    
    % Create a table for time points; used in plotting data
    t_point = linspace(min(time_points),max(time_points),time_count);
    summary.time = t_point;
    
    clearvars s_rate t_point time_count time_points;
    
    %% Save Data
    disp('Saving data');
    save(save_dir,'summary');
end

%% Final Cleanup
disp('Analysis complete');

clearvars -except summary;