%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
prefix = 'MedEdFlynn_';
chan_name = 'FCz';
d_name = 'med_ed_erp.mat'; % Name of master data file
significance = 0.05;
x_lim = [-200 600];
y_lim = [-20 20];
cond1 = 1;
cond2 = 3;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    erp_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback';
    erpnl_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback NL';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
    set(0,'DefaultFigurePosition','remove');
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    erp_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback';
    erpnl_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback NL';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Export';
    set(0,'DefaultFigurePosition',[1921,45,1280,907]);
end

clear comp

%% Load Variables
cd(master_dir);
load(d_name);
sig_label = strcat('p > ',num2str(significance));

for a = 1:62
    if strcmp(summary.chanlocs(a).labels,chan_name) == 1
        chan_loc(a) = 1;
    end
end

clear a;

%% Plot Reward Positivity
disp('Plotting Reward Positivity');
time = summary.ERP.time;
colors = cbrewer('qual','Dark2',8);
colors = flipud(colors);
c_index = find(chan_loc == 1);

for a = 1:length(time)
    if summary.ERP.ttest(c_index,a) < significance
        sig(1,a) = 1;
    else
        sig(1,a) = NaN;
    end
end

sum_win = summary.ERP.data{1}(c_index,:);
sum_loss = summary.ERP.data{2}(c_index,:);
sum_diff = sum_win - sum_loss;
ci_data = summary.ERP.ci_data(c_index,:);

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
export_fig(f1,'Feedback','-png');

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
clear x_lim;
clear y_lim;

%% Plot Non-Learners
disp('Plotting Non-Learners');
time = summary.ERP_NL.time;
colors = cbrewer('qual','Dark2',8);
colors = flipud(colors);
x_lim = [-200 600];
y_lim = [-20 20];
c_index = find(chan_loc == 1);

for a = 1:length(time)
    if summary.ERP_NL.ttest(c_index,a) < significance
        sig(1,a) = 1;
    else
        sig(1,a) = NaN;
    end
end

sum_win = summary.ERP_NL.data{1}(c_index,:);
sum_loss = summary.ERP_NL.data{2}(c_index,:);
sum_diff = sum_win - sum_loss;
ci_data = summary.ERP_NL.ci_data(c_index,:);

f2 = figure('Name','Non-Learners',...
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
export_fig(f2,'Feedback NL','-png');

%% Clean Workspace
clearvars -except summary;