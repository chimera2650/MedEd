%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
t_name = 'med_ed_twav.mat'; % Name of master data file
d_name = 'med_ed_dwav.mat'; % Name of master data file
c_name = 'chanlocs.mat';
theta = [4 8];
alpha = [8 12];
chan_theta = 'Fz';
chan_alpha = 'Pz';

comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    temp_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Template';
    dec_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_stats.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    temp_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Template';
    dec_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_stats.mat';
end

clearvars comp

%% Load Data
cd(master_dir)
load(c_name);

for a = 1:62
    if strcmp(chanlocs(a).labels,chan_theta) == 1
        chan_loc(a) = 1;
    elseif strcmp(chanlocs(a).labels,chan_alpha) == 1
        chan_loc(a) = 2;
    end
end

clear a;

%% Statistics Analysis
for a = 1:2
    disp('Loading data');
    
    if a == 1
        cd(master_dir);
        load(t_name);
        analysis = 'template';
        freq = summary.freq;
    elseif a == 2
        cd(master_dir);
        load(d_name);
        analysis = 'decision';
        freq = summary.freq;
    end
    
    disp(['Analyzing ' analysis ' data']);

    for b = 1:2
        if b == 1
            freq_range = [find(freq == theta(1)) find(freq == theta(2))];
            c_index = find(chan_loc == 1);
            band = 'theta';
        elseif b == 2
            freq_range = [find(freq == alpha(1)) find(freq == alpha(2))];
            c_index = find(chan_loc == 2);
            band = 'alpha';
        end
        
        data = squeeze(summary.raw(c_index,:,:,:,:));
        
        for c = 1:size(data,4)
            for d = 1:size(data,3)
                temp_data = squeeze(data(freq_range(1):freq_range(2),:,d,c));
                temp_mean = squeeze(mean(temp_data,1));
                temp_mean = squeeze(mean(temp_mean));
                sub_mean(c,d) = squeeze(mean(temp_mean));
            end
        end
        
        clearvars c d temp_data temp_mean;
        
        cond_mean(b,:) = squeeze(mean(sub_mean,1));
        cond_stdev(b,:) = squeeze(std(sub_mean,1));   
        [h,p] = ttest(sub_mean(:,1),sub_mean(:,3));
        pval(b,:) = p;
    end
    
    stats.(analysis) = table(cond_mean,cond_stdev,pval,'VariableNames',{'mean','stdev','pval'},'RowNames',{'theta','alpha'});
    
    clearvars b band c_index cond_mean cond_stdev freq_range p pval sub_mean;
end

%% Save Data
disp('Saving data');
save(save_dir,'stats');
%% Final Cleanup
disp('Analysis complete');

clearvars -except stats;