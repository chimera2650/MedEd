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
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\Cog Assess';
    rewp_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\Cog Assess\RewP';
    p3_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\Cog Assess\P300';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\Cog Assess\cog_assess.mat';
end

clear comp

%% Load Data
cd(master_dir);
load(d_name);
time_range = abs(max(time_points) - min(time_points));

%% ERP Analysis
for a = 1:2
    if a == 1
        analysis = 'rewp';
        cd(rewp_dir);
    elseif a == 2
        analysis = 'p300';
        cd(p3_dir);
    end
    
    filenames = dir(strcat(prefix,'*'));
    file_num = length(filenames);
    
    disp(['Summarizing ' analysis ' by subject']);
    
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
        artifacts(a,1) = mean(cell2mat(sub_data.ERP.nAccepted));
        artifacts(a,2) = mean(cell2mat(sub_data.ERP.nRejected));
    end
    
    summary.(analysis).artifacts = artifacts;
    
    clear artifacts;
    clear b;
    clear c;
    clear d;
    clear c_index;
    clear chan_loc;
    clear e;
    clear sub_data;
    
    disp(['Generating raw ' analysis ' data table']);
    
    for b = 1:cond_count
        for c = 1:file_num
            raw_data(:,:,b,c) = temp_data{c}{b}(:,:);
        end
    end
    
    summary.(analysis).raw = raw_data;
    
    clear b;
    clear c;
    clear raw_data;
    
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
    
    clear b;
    clear c;
    clear d;
    clear temp_sum;
    
    % Standard Deviation for ERP
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
    
    clear b;
    clear c;
    clear d;
    clear sum_data;
    clear temp_sum;
    
    if a == 1
        dispstat('','init');
        dispstat(sprintf('Calculating RewP confidence intervals and t-tests. Please wait...'),'keepthis');
    elseif a == 2
        dispstat('','init');
        dispstat(sprintf('Calculating P300 confidence intervals and t-tests. Please wait...'),'keepthis');
    end
    
    for b = 1:chan_count
        if b == 1
            perc_last = 0;
            dispstat(sprintf('Progress %d%%',0))
        end
        
        perc_stat = round((b/chan_count)*100);
        
        if perc_stat ~= perc_last
            dispstat(sprintf('Progress %d%%',perc_stat));
        end
        
        perc_last = perc_stat;
        
        for c = 1:(time_range/s_rate)
            for d = 1:file_num
                for e = 1:cond_count
                    sum_data(d,e) = temp_data{d}{e}(b,c);
                end
            end
            
            cond1 = isnan(sum_data(:,2));
            sum_data(cond1,:) = [];
            t_data1 = sum_data(:,1);
            t_data2 = sum_data(:,2);
            [p,tbl] = anova1(sum_data,{'win','loss'},'off');
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
            erp_ttest(b,c) = p;
        end
        
        erp_ci(b,:) = transpose(ci_data(:,6));
    end
    
    dispstat('Finished.','keepprev');
    summary.(analysis).ci_data = erp_ci;
    summary.(analysis).ttest = erp_ttest;
    
    clear b;
    clear c;
    clear c_index;
    clear chan_loc;
    clear ci_data;
    clear cond1;
    clear d;
    clear e;
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
    
    clear b;
    clear filenames;
    clear file_num;
    clear t_point;
end

clear a;

%% Create a table for time points; used in plotting data
disp('Creating timepoints for ERP');

for a = 1:(time_range/s_rate)
    t_point(1,a) = (min(time_points)+(s_rate*a));
end

summary.time = t_point;

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