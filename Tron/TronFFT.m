%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
chan_count = 62; % Number of channels in analysis
cond_count = 3;
d_name = 'med_ed_fft.mat'; % Name of master data file
prefix = 'MedEdFlynn_';
f_res = 0.5; % Frequency resolution
freq_points = [1 30]; % Desired frequency range for data
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    temp_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Template';
    dec_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_fft.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    temp_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Template';
    dec_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_fft.mat';
end

clearvars comp

%% Load Data
cd(master_dir);
load(d_name);
freq_count = (abs(max(freq_points) - min(freq_points))/f_res)+1;

%% FFT Analysis
for a = 2:2
    if a == 1
        cd(temp_dir);
        analysis = 'template';
    elseif a == 2
        cd(dec_dir);
        analysis = 'decision';
    end
    
    filenames = dir(strcat(prefix,'*'));
    file_num = length(filenames);
    
    % Summarise FFT data by subject
    dispstat('','init');
    dispstat(sprintf(['Summarizing ' analysis ' by subject. Please wait...']),'keepthis');
    
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
                temp_data{b}{c}(d,:) = sub_data.FFT.data{c}(c_index,:);
            end
        end
        artifacts(b,1) = mean(cell2mat(sub_data.FFT.nAccepted));
        artifacts(b,2) = mean(cell2mat(sub_data.FFT.nRejected));
    end
    
    dispstat('Finished.','keepprev');
    summary.(analysis).artifacts = artifacts;
    
    clearvars artifacts b c c_index chan_loc d e sub_data;
    
    disp(['Generating raw ' analysis ' data table']);
    
    for b = 1:cond_count
        for c = 1:file_num
            raw_data(:,:,b,c) = temp_data{c}{b}(:,:);
        end
    end
    
    summary.(analysis).raw = raw_data;
    
    clearvars b c raw_data;
    
    disp(['Combining ' analysis ' data by condition']);
    
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
    
    clearvars b c d temp_sum;
    
    % Standard deviation for FFT
    disp(['Calculating ' analysis ' standard deviations']);
    
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
    
    clearvars b c d sum_data temp_sum;
    
    dispstat('','init');
    dispstat(sprintf(['Calculating ' analysis ' confidence intervals. Please wait...']),'keepthis');
    
    for b = 1:chan_count
        for c = 1:freq_count
            if b == 1
                perc_last = 0;
                dispstat(sprintf('Progress %d%%',0))
            end
            
            perc_stat = round((b/chan_count)*100);
            
            if perc_stat ~= perc_last
                dispstat(sprintf('Progress %d%%',perc_stat));
            end
            
            perc_last = perc_stat;
            
            for d = 1:file_num
                for e = 1:cond_count
                    sum_data(d,e) = temp_data{d}{e}(b,c);
                    for f = 1:5
                        g = c-3+e;
                        if g < 1
                            win_data(e) = NaN;
                        else
                            win_data(e) = temp_data{d}{e}(b,g);
                        end
                    end
                    t_data(d,e) = nanmean(win_data);
                end
            end
            
            cond1 = isnan(sum_data(:,2));
            sum_data(cond1,:) = [];
            t_data1 = t_data(:,1);
            t_data2 = t_data(:,3);
            [p,tbl] = anova1(sum_data,{'No Conflict','One Conflict','Two Conflict'},'off');
            sum_data = mean(sum_data,2);
            ci_data(c,1) = mean(sum_data);
            ci_data(c,2) = std(sum_data);
            ci_data(c,3) = length(sum_data);
            ci_data(c,4) = ci_data(c,2)/sqrt(ci_data(c,3)-1);
            ts = tinv(0.95,ci_data(c,3)-1);
            ci_data(c,5) = tbl{3,4};
            ci_data(c,6) = sqrt(ci_data(c,5)/ci_data(c,3))*(ts);
            
            clear p;
            
            [h,p] = ttest(t_data1,t_data2,'tail','both');
            fft_ttest(b,c) = p;
        end
        fft_ci(b,:) = transpose(ci_data(:,6));
    end
    
    dispstat('Finished.','keepprev');
    summary.(analysis).ci_data = fft_ci(:,1:freq_count);
    summary.(analysis).ttest = fft_ttest(:,1:freq_count);
    
    clearvars b c c_index chan_loc ci_data cond1 d e f fft_ci fft_ttest ...
        g h num p sub_data sum_data t_data1 t_data2 tbl temp_data ts;
end

% Create frequency points for plots
disp('Creating frequency points');

% Create a table for frequency points; used in plotting data
f_point = linspace(min(freq_points),max(freq_points),freq_count);
summary.freq = f_point;

clearvars f_point filenames file_num;

%% Save Data
disp('Saving data');
save(save_dir,'summary');

%% Final Cleanup
disp('Analysis complete');

clearvars -except summary;