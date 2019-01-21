%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
prefix = 'MedEdFlynn_';
chan_name1 = 'Fz';
chan_name2 = 'Pz';
d_name = 'med_ed_fft.mat'; % Name of master data file
significance = 0.05;
x_lim = [0 30];
y_lim = [0 6];
cond1 = 1;
cond2 = 3;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    fft_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
    set(0,'DefaultFigurePosition','remove');
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    fft_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Export';
    set(0,'DefaultFigurePosition',[1921,45,1280,907]);
end

clear comp

%% Load Variables
cd(master_dir);
load(d_name);
sig_label = strcat('p > ',num2str(significance));

for b = 1:62
    if strcmp(summary.chanlocs(b).labels,chan_name1) == 1
        chan_loc(b) = 1;
    elseif strcmp(summary.chanlocs(b).labels,chan_name2) == 1
        chan_loc(b) = 2;
    end
end

clear a;

%% Plot FFT
disp('Plotting FFT');
cd(fft_dir);
colors = cbrewer('qual','Dark2',8);
colors = flipud(colors);
f1 = figure('Name','FFT',...
    'NumberTitle','off');

for a = 1:2
    for b = 1:2
        if a == 1
            save_name = 'FFT_Template';
            analysis = 'template';
        elseif a == 2
            save_name = 'FFT_Decision';
            analysis = 'decision';
        end
        
        if b == 1
            c_index = find(chan_loc == 1);
            chan_name = chan_name1;
            band = 'Theta';
            region = 'frontal';
            sh = [4 8];
        elseif b == 2
            c_index = find(chan_loc == 2);
            chan_name = chan_name2;
            band = 'Alpha';
            region = 'parietal';
            sh = [8 15];
        end
        
        freq = summary.freq(1,1:59);
        
        for c = 1:(length(freq))
            if summary.(analysis).ttest(c_index,c) < significance
                sig(1,c) = 1;
            else
                sig(1,c) = NaN;
            end
        end
        
        sum_0c = summary.(analysis).data{1}(c_index,1:59);
        sum_1c = summary.(analysis).data{2}(c_index,1:59);
        sum_2c = summary.(analysis).data{3}(c_index,1:59);
        ci_data = summary.(analysis).ci_data(c_index,1:59);
        
        subplot(1,2,b);
        hold on;
        bl = boundedline(freq,sum_0c,ci_data,...
            freq,sum_1c,ci_data,...
            freq,sum_2c,ci_data,...
            'cmap',colors,'alpha');
        ax = gca;
        s = plot(freq,sig*(max(y_lim)*0.9),'sk');
        title(['FFT for ' chan_name ' during ' analysis]);
        legend({'No Conflict','One Conflict','Two Conflict'});
        text(25,(max(y_lim)*0.9),sig_label,...
            'FontWeight','bold',...
            'FontAngle','italic',...
            'FontSize',10);
        ax.FontSize = 12;
        ax.XLim = x_lim;
        ax.XLabel.String = 'Frequency (Hz)';
        ax.YLim = y_lim;
        ax.YLabel.String = 'Power (dB)';
        ax.Legend.Location = 'southwest';
        ax.Legend.Box = 'off';
        ax.Legend.FontSize = 12;
        ax.Legend.FontWeight = 'bold';
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
    end
    cd(save_dir);
    export_fig(f1,save_name,'-png');
end

%% Clean Workspace
clearvars -except summary