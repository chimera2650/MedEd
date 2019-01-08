%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
chan_count = 62; % Number of channels in analysis
chan_name1 = 'FCz';
chan_name2 = 'Pz';
d_name = 'cog_assess.mat'; % Name of master data file
prefix = 'CogAssess_flynn_'; % Prefix of raw data files
s_rate = 4; % Sampling rate in milliseconds
significance = 0.05;
x_lim = [-200 600];
y_lim = [-5 15];
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\Cog Assess';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\Cog Assess';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Export';
end

clear comp

%% Load Variables
cd(master_dir);
load(d_name);
set(0,'DefaultFigurePosition',[1921,45,1280,907]);

for a = 1:62
    if strcmp(summary.chanlocs(a).labels,chan_name1) == 1
        chan_loc(a) = 1;
    elseif strcmp(summary.chanlocs(a).labels,chan_name2) == 1
        chan_loc(a) = 2;
    else
        chan_loc(a) = 0;
    end
end

sig_label = strcat('p > ',num2str(significance));
colors = cbrewer('qual','Dark2',8);
colors = flipud(colors);
time = summary.time;

clear a;

%% Plot Reward Positivity
disp('Plotting RewP');
c_index = find(chan_loc == 1);

for a = 1:length(time)
    if summary.rewp.ttest(c_index,a) < significance
        sig(1,a) = 1;
    else
        sig(1,a) = NaN;
    end
end

sum_win = summary.rewp.data{1}(c_index,:);
sum_loss = summary.rewp.data{2}(c_index,:);
sum_diff = sum_win - sum_loss;
ci_data = summary.rewp.ci_data(c_index,:);

f1 = figure('Name','Reward Positivity',...
    'NumberTitle','off');
hold on;
bl = boundedline(time,sum_win,ci_data,...
    time,sum_loss,ci_data,...
    time,sum_diff,ci_data,...
    'cmap',colors,'alpha');
ax = gca;
s = plot(time,sig*(max(y_lim)*0.9),'sk');
l1 = line([0 0],[min(y_lim) max(y_lim)],...
    'Color','k',...
    'LineStyle',':',...
    'LineWidth',1);
l2 = line([min(x_lim) max(x_lim)],[0 0],...
    'Color','k',...
    'LineStyle',':',...
    'LineWidth',1);
legend({'Win','Loss','Difference'});
text(50,(max(y_lim)*0.9),sig_label,...
    'FontWeight','bold',...
    'FontAngle','italic',...
    'FontSize',10);
ax.FontSize = 12;
ax.XLim = x_lim;
ax.XLabel.String = 'Time (ms)';
ax.YLim = y_lim;
ax.YLabel.String = 'Voltage (\muV^2)';
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
cd(save_dir);
export_fig(f1,'RewP','-png');

%% Clean Workspace
clear a;
clear ax;
clear bl;
clear ci_data;
clear f1;
clear l1;
clear l2;
clear s;
clear sig;
clear sum_win;
clear sum_loss;
clear sum_diff;

%% Plot P300
disp('Plotting P300');
c_index = find(chan_loc == 2);

for a = 1:length(time)
    if summary.p300.ttest(c_index,a) < significance
        sig(1,a) = 1;
    else
        sig(1,a) = NaN;
    end
end

sum_odd = summary.p300.data{1}(c_index,:);
sum_con = summary.p300.data{2}(c_index,:);
sum_diff = sum_odd - sum_con;
ci_data = summary.p300.ci_data(c_index,:);
summary.p300.ci_data(c_index,:);

f2 = figure('Name','P300',...
    'NumberTitle','off');
hold on;
bl = boundedline(time,sum_odd,ci_data,...
    time,sum_con,ci_data,...
    time,sum_diff,ci_data,...
    'cmap',colors,'alpha');
ax = gca;
s = plot(time,sig*(max(y_lim)*0.9),'sk');
l1 = line([0 0],[min(y_lim) max(y_lim)],...
    'Color','k',...
    'LineStyle',':',...
    'LineWidth',1);
l2 = line([min(x_lim) max(x_lim)],[0 0],...
    'Color','k',...
    'LineStyle',':',...
    'LineWidth',1);
legend({'Oddball','Control','Difference'});
text(50,(max(y_lim)*0.9),sig_label,...
    'FontWeight','bold',...
    'FontAngle','italic',...
    'FontSize',10);
ax.FontSize = 12;
ax.XLim = x_lim;
ax.XLabel.String = 'Time (ms)';
ax.YLim = y_lim;
ax.YLabel.String = 'Voltage (\muV^2)';
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
cd(save_dir);
export_fig(f2,'P300','-png');

%% Clean Workspace
clear a;
clear ax;
clear bl;
clear ci_data;
clear f2;
clear l1;
clear l2;
clear s;
clear sig;
clear sum_con;
clear sum_diff;
clear sum_odd;

%% Final Clear
clearvars -except summary