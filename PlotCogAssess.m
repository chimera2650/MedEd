%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
prefix = 'CogAssessFlynn_';
chan_name1 = 'FCz';
chan_name2 = 'Fz';
significance = 0.05;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    working_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Cog Assess\RewP';
    working_dir2 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Cog Assess\P300';
    working_dir3 = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    working_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Cog Assess\RewP';
    working_dir2 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Cog Assess\P300';
    working_dir3 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Export';
end

clear comp

%% Load Variables
cd(working_dir);
load('cog_assess.mat');

for i = 1:62
    if strcmp(final_summary.chanlocs(i).labels,chan_name1) == 1
        chan_loc(i) = 1;
    elseif strcmp(final_summary.chanlocs(i).labels,chan_name2) == 1
        chan_loc(i) = 2;
    else
        chan_loc(i) = 0;
    end
end

c_index1 = find(chan_loc == 1);
c_index2 = find(chan_loc == 2);
sig_label = strcat('p > ',num2str(significance));

clear i;
clear chan_loc

%% Plot Reward Positivity

for y = 1:2
    if y == 1
        cd(working_dir1);
        analysis = 'rewp';
        leg_lab = {'Win','Loss','Difference'};
    elseif y == 2
        cd(working_dir2);
        analysis = 'rewp';
        leg_lab = {'Oddball','Control','Difference'};
    end
    
    for i = 1:200
        if cog_assess.(analysis).ttest(i,1) < significance
            sig(i) = 1;
        else
            sig(i) = NaN;
        end
    end
    
    filenames = dir(strcat(prefix,'*'));   % Get a count of file number
    file_num = length(filenames);
    summary_data1 = [];
    summary_data2 = [];
    
    for x = 1:file_num
        subject_data = importdata(filenames(x).name); % Import subject data
        summary_data1(end+1,:) = subject_data.ERP.data{1}(c_index1,:);
        summary_data2(end+1,:) = subject_data.ERP.data{2}(c_index1,:);
    end
    
    cond1 = isnan(summary_data1(:,1));
    summary_data1(cond1,:) = [];
    summary_mean1 = mean(summary_data1(:,:));
    cond1 = isnan(summary_data2(:,1));
    summary_data2(cond1,:) = [];
    summary_mean2 = mean(summary_data2(:,:));
    summary_diff = summary_mean1 - summary_mean2;
    
    colors1 = cbrewer('qual','Dark2',8);
    colors1 = flipud(colors1);
    time = cog_assess.time;
    ci_data = cog_assess.(analysis).ci_data(:,6);
    x_lim = [-200 600];
    y_lim = [-10 15];
    
    f1 = figure(x);
    hold on;
    bl = boundedline(time,summary_mean1,ci_data,...
        time,summary_mean2,ci_data,...
        time,summary_diff,ci_data,...
        'cmap',colors1,'alpha');
    
    ax = gca;
    
    s = plot(cog_assess.time,sig*(max(y_lim)*0.9),'sk');
    l1 = line([0 0],[min(y_lim) max(y_lim)],...
        'Color','k',...
        'LineStyle',':',...
        'LineWidth',1);
    l2 = line([min(x_lim) max(x_lim)],[0 0],...
        'Color','k',...
        'LineStyle',':',...
        'LineWidth',1);
    
    legend(leg_lab);
    text(150,(max(ax.YLim)*0.9),sig_label,...
        'FontWeight','bold',...
        'FontAngle','italic',...
        'FontSize',10);
    
    ax = gca;
    ax.FontSize = 12;
    ax.XLim = x_lim;
    ax.XLabel.String = 'Time (ms)';
    ax.YLim = y_lim;
    ax.YLabel.String = 'Voltage';
    ax.Legend.Location = 'southwest';
    ax.Legend.Box = 'off';
    ax.Legend.FontSize = 12;
    ax.Legend.FontWeight = 'bold';
    ax.YDir = 'reverse';
    
    bl(1).LineWidth = 2;
    bl(1).LineStyle = '-';
    bl(2).LineWidth = 2;
    bl(2).LineStyle = '--';
    bl(3).LineWidth = 2;
    bl(3).LineStyle = ':';
    
    s.MarkerEdgeColor = 'k';
    s.MarkerFaceColor = 'k';
    s.MarkerSize = 8;
    hold off
    
    set(f1,...
        'Units','inches',...
        'Position',[0 0 12 8]);
    cd(working_dir3);
    
    if y == 1
        export_fig(f1,'RewP','-png');
    elseif y == 2
        export_fig(f1,'P300','-png');
    end
end

%% Clean Workspace
clear analysis;
clear ax;
clear bl;
clear ci_data;
clear colors1;
clear cond1;
clear f1;
clear i;
clear l1;
clear l2;
clear leg_lab;
clear s;
clear sig;
clear subject_data;
clear summary_data1;
clear summary_data2;
clear summary_diff;
clear summary_mean1;
clear summary_mean2;
clear time;
clear x;
clear x_lim;
clear y_lim;