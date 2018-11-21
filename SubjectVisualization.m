%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Define Variables
chan_count = 62; % Number of channels in analysis
chan_name = 'FCz'; % Name of channel where effect occurs
cond_count = 2; % Number of conditions in analysis
d_name = 'med_ed.mat'; % Name of master data file
prefix = 'MedEdFlynn_'; % Prefix of raw data files
y_lim = [-20 20]; % Set range for y-axis
master_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data'; % Location of master data file
erp_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback'; % Location of raw data for condition 1
save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\flag.mat';  % Location where analyzed data is to be saved

%% Load Data
cd(master_dir);
load(d_name);
cd(erp_dir);
filenames = dir(strcat(prefix,'*')); % Get a count of file number
file_num = length(filenames); % Get a length of file count

for a = 1:chan_count
    if strcmp(summary.chanlocs(a).labels,chan_name) == 1
        c_index(a) = 1;
    else
        c_index(a) = 0;
    end
end

chan_num = find(c_index == 1);

for a = 1:length(filenames)
    sub_data = importdata(filenames(a).name);
    sum_win(a,:) = sub_data.ERP.data{1}(chan_num,:);
    sum_loss(a,:) = sub_data.ERP.data{2}(chan_num,:);
end

mean_win = nanmean(sum_win,1);
mean_loss = nanmean(sum_loss,1);

clear a;
clear c_index;
clear sub_data;

%% Plot figure
f = figure('Name','Subject Screening',...
    'NumberTitle','off');
hold on
mean = plot(summary.ERP.time,mean_win,'-k'); % Plot mean data as reference
set(f,...
    'Units','inches',...
    'Position',[0 0 10 6]);
movegui(f,'south'); % Set location of figure on screen
ax = gca;
ax.YLim = y_lim; % Set y-axis limits

for a = 1:length(filenames)
    num = filenames(a).name;
    disp(num); % Display subject number in command window
    sub = plot(summary.ERP.time,sum_win(a,:),'-r'); % Plot highlighted subject data
    q = questdlg(num,... % Generate input window to keep or flag participant
        'Action',...
        'Keep',...
        'Flag','Flag');
    switch q % Define what action should be taken for each possible input
        case 'Keep'
            tracker(a,1) = 0;
        case 'Flag'
            tracker(a,1) = 1;
    end
    sub.Color(4) = 0.25; % Increase subject transparency to allow for next subject to be visible
end
hold off

names = {filenames.name}.'; % Extract all subject names from directory
tracker = num2cell(tracker); 
result = [names tracker]; % Concatinate names and flag data
result(cellfun(@(x) any(x<1),result(:,2)),:) = []; % Remove all unflagged subjects
result(:,2) = []; % Remove tracker column
celldisp(result); % Display flagged subjects in command window

%% Clean up workspace
clear a;
clear ax;
clear f;
clear mean;
clear num;
clear q;
clear sub;
clear tracker;
close all;

%% Save Data
disp('Saving data');
save(save_dir,'result');

%% Final Cleanup
disp('Analysis complete');

clearvars -except result;