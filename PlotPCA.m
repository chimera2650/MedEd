%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
d_name = 'med_ed_pca.mat'; % Name of master data file
x_lim = [-2000 0];
y_lim = [-0.5 1];
chan = 2;
cond = 'decision';
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    erp_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback';
    erpnl_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback NL';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Export';
end

clear comp

%% Load Variables
cd(master_dir);
load(d_name);
time1 = linspace(0,1996,500);
time2 = PCA.time;
freq = PCA.freq;
timelabs = string(round(PCA.(cond).timeVAR(chan,1:6),1));
freqlabs = string(round(PCA.(cond).freqVAR(chan,1:6),1));
timedata = squeeze(PCA.(cond).timePlot(chan,:,1:6));
freqdata = squeeze(PCA.(cond).freqPlot(chan,:,1:6));
colors = cbrewer('qual','Dark2',8);
colors = flipud(colors);

%% Plot Reward Positivity
f1 = figure('Name','PCA',...
    'NumberTitle','off','Position',[0,0,1024,768]);
subplot(2,1,1);
p1 = plot(time2,timedata);
ax = gca;
legend(timelabs);
ax.FontSize = 12;
ax.XLim = x_lim;
ax.XLabel.String = 'Time (ms)';
ax.YLim = y_lim;
ax.YLabel.String = 'Component Loading';
ax.Legend.Location = 'northeastoutside';
ax.Legend.Box = 'on';
ax.Legend.FontSize = 12;
ax.Legend.FontWeight = 'bold';

subplot(2,1,2);
p2 = plot(freq,freqdata);
legend(freqlabs);
ax = gca;
ax.FontSize = 12;
ax.XLim = [0 30];
ax.XLabel.String = 'Frequency (Hz)';
ax.YLim = y_lim;
ax.YLabel.String = 'Component Loading';
ax.Legend.Location = 'northeastoutside';
ax.Legend.Box = 'on';
ax.Legend.FontSize = 12;
ax.Legend.FontWeight = 'bold';

cd(save_dir);
export_fig(f1,[cond '_' num2str(chan) '_PCA'],'-png');
