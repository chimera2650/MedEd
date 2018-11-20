clc;
clear;
close all;

%%
prefix = 'MedEdFlynn_';
chan_name1 = 'FCz';
working_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
working_dir1 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback';
cd(working_dir);
load('final_summary.mat');

for i = 1:62
    if strcmp(final_summary.chanlocs(i).labels,chan_name1) == 1
        chan_loc(i) = 1;
    else
        chan_loc(i) = 0;
    end
end

c_index = find(chan_loc == 1);
cd(working_dir1);
filenames = dir(strcat(prefix,'*'));   % Get a count of file number
file_num = length(filenames);

for x = 1:length(filenames)
    subject_data = importdata(filenames(x).name);
    summary_win(x,:) = subject_data.ERP.data{1}(c_index,:);
    summary_loss(x,:) = subject_data.ERP.data{2}(c_index,:);
end

mean_win = nanmean(summary_win,1);
mean_loss = namean(summary_loss,1);

%%
f = figure(1);
hold on
mean = plot(final_summary.ERP.time,mean_win,'-k');
movegui(f,'south');
ax = gca;
ax.YLim = [-20 20];

for x = 1:length(filenames)
    num = filenames(x).name;
    disp(num);    
    win = plot(final_summary.ERP.time,summary_win(x,:),'-r');
    q = questdlg(num,...
        'Action',...
        'Keep',...
        'Flag','Flag');
    switch q
        case 'Keep'
            tracker(x,1) = 0;
        case 'Flag'
            tracker(x,1) = 1;
    end
    win.Color(4) = 0.25;
end
hold off

names = {filenames.name}.';
tracker = num2cell(tracker);
result = [names tracker];
result(cellfun(@(x) any(x<1),result(:,2)),:) = [];
result(:,2) = [];
celldisp(result);

%%
clear ax;
clear f;
clear i;
clear mean;
clear num;
clear q;
clear subject_data;
clear tracker;
clear x;
close all;

%%
win = result;
loss = result;
flag = [win;loss];

%% 
clearvars -except flag win loss;