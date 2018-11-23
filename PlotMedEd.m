%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
prefix = 'MedEdFlynn_';
chan_name1 = 'FCz';
chan_name2 = 'Fz';
chan_name3 = 'Pz';
d_name = 'med_ed.mat'; % Name of master data file
significance = 0.05;
t_wind1 = [-1000 -500];
f_wind1 = [5 7];
t_wind2 = [-800 -500];
f_wind2 = [10 14];
wav_limits = [-2 2];
topo_limits = [-1.25 1.25];
cond1 = 1;
cond2 = 3;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    erp_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    erpnl_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Feedback NL';
    fft_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
    wav_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
    topo_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
    beh_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Behavioral';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    erp_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    erpnl_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback NL';
    fft_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
    wav_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
    topo_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
    beh_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Behavioral';
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
    elseif strcmp(summary.chanlocs(a).labels,chan_name3) == 1
        chan_loc(a) = 3;
    else
        chan_loc(a) = 0;
    end
end

sig_label = strcat('p > ',num2str(significance));

% Theta highlight
wav_wind1 = [min(t_wind1) min(f_wind1) 2;...
    max(t_wind1) min(f_wind1) 2;...
    max(t_wind1) max(f_wind1) 2;...
    min(t_wind1) max(f_wind1) 2];

% Alpha highlight
wav_wind2 = [min(t_wind2) min(f_wind2) 2;...
    max(t_wind2) min(f_wind2) 2;...
    max(t_wind2) max(f_wind2) 2;...
    min(t_wind2) max(f_wind2) 2];

clear a;

%% Plot Reward Positivity
disp('Plotting Reward Positivity');
time = summary.ERP.time;
colors = cbrewer('qual','Dark2',8);
colors = flipud(colors);
x_lim = [-200 600];
y_lim = [-20 20];
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
clear a;
clear ax;
clear bl;
clear ci_data;
clear f2;
clear l1;
clear l2;
clear s;
clear sig;
clear sum_win;
clear sum_loss;
clear sum_diff;

%% Plot FFT
disp('Plotting FFT');
cd(fft_dir);
colors = cbrewer('qual','Dark2',8);
colors = flipud(colors);
f3 = figure('Name','FFT',...
        'NumberTitle','off');
    
for a = 1:2
    if a == 1
        c_index = find(chan_loc == 2);
        chan_name = chan_name2;
        band = 'Theta';
        region = 'frontal';
        sh = [4 8];
    elseif a == 2
        c_index = find(chan_loc == 3);
        chan_name = chan_name3;
        band = 'Alpha';
        region = 'parietal';
        sh = [8 15];
    end
    
    freq = summary.FFT.freq(1,1:59);
    x_lim = [0 30];
    y_lim = [0 6];
    
    for b = 1:(length(freq))
        if summary.FFT.ttest(c_index,b) < significance
            sig(1,b) = 1;
        else
            sig(1,b) = NaN;
        end
    end
    
    sum_0c = summary.FFT.data{1}(c_index,1:59);
    sum_1c = summary.FFT.data{2}(c_index,1:59);
    sum_2c = summary.FFT.data{3}(c_index,1:59);
    ci_data = summary.FFT.ci_data(c_index,1:59);
    
    subplot(1,2,a);
    hold on;
    bl = boundedline(freq,sum_0c,ci_data,...
        freq,sum_1c,ci_data,...
        freq,sum_2c,ci_data,...
        'cmap',colors,'alpha');
    ax = gca;
    s = plot(freq,sig*(max(y_lim)*0.9),'sk');
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
export_fig(f3,'FFT','-png');

%% Clean Workspace
clear a;
clear ax;
clear b;
clear bl;
clear ci_data;
clear f3;
clear s;
clear sig;
clear sum_0c;
clear sum_1c;
clear sum_2c;

%% Plot Wavelets
disp('Plotting wavelets');
colors3 = cbrewer('div','RdBu',64,'PCHIP');
colors3 = flipud(colors3);

f4 = figure('Name','Wavelets',...
    'NumberTitle','off');
for a = 1:2
    if a == 1
        c_index = find(chan_loc == 2);
        shade_x = [wav_wind1(1,1) wav_wind1(2,1) wav_wind1(3,1) wav_wind1(4,1)];
        shade_y = [wav_wind1(1,2) wav_wind1(2,2) wav_wind1(3,2) wav_wind1(4,2)];
        shade_z = [wav_wind1(1,3) wav_wind1(2,3) wav_wind1(3,3) wav_wind1(4,3)];
        chan_name = chan_name2;
    elseif a == 2
        c_index = find(chan_loc == 3);
        shade_x = [wav_wind2(1,1) wav_wind2(2,1) wav_wind2(3,1) wav_wind2(4,1)];
        shade_y = [wav_wind2(1,2) wav_wind2(2,2) wav_wind2(3,2) wav_wind2(4,2)];
        shade_z = [wav_wind2(1,3) wav_wind2(2,3) wav_wind2(3,3) wav_wind2(4,3)];
        chan_name = chan_name3;
    end
    
    plotdata = squeeze(summary.WAV.data{cond1}(c_index,:,:)) - squeeze(summary.WAV.data{cond2}(c_index,:,:));
    freq = summary.WAV.freq(1,1:59);
    time = summary.WAV.time;
    subplot(2,1,a);
    s = surf(time,freq,plotdata);
    hold on
    shade = fill3(shade_x,shade_y,shade_z,0);
    hold off
    
    if a == 1
        title(sprintf('Difference wavelet plot at %s for the 2000ms preceeding decision',chan_name));
    elseif a == 2
        title(sprintf('Difference wavelet plot at %s for the 2000ms preceeding decision',chan_name));
    end
    
    set(gca,'ydir','normal');
    
    c = colorbar;
    c.TickDirection = 'out';
    c.Box = 'off';
    c.Label.String = 'Power (dB)';
    c.Limits = wav_limits;
    drawnow;
    
    axpos = get(gca,'Position');
    cpos = c.Position;
    cpos(3) = 0.5*cpos(3);
    c.Position = cpos;
    drawnow;
    
    set(gca,'position',axpos);
    drawnow;
    
    ax = gca;
    ax.FontSize = 12;
    ax.FontName = 'Arial';
    ax.LineWidth = 1.5;
    ax.YLabel.String = 'Frequency (Hz)';
    ax.YTick = [0 5 10 15 20 25 30];
    ax.YLim = [0 30];
    ax.XLabel.String = 'Time (ms)';
    ax.XTick = [-2000 -1500 -1000 -500 0];
    ax.XLim = [-2000 0];
    ax.TickDir = 'out';
    ax.FontWeight = 'bold';
    ax.Box = 'off';
    
    s.EdgeColor = 'none';
    s.FaceColor = 'interp';
    shade.FaceColor = 'none';
    shade.EdgeColor = [0 0 0];
    shade.LineWidth = 2;
    
    view([0,0,90]);
    colormap(colors3);
end

cd(save_dir);
export_fig(f4,'Wavelet','-png');

%% Clean Workspace
clear a;
clear ax;
clear axpos;
clear c;
clear c_index;
clear chan_name;
clear colors;
clear cpos;
clear f4;
clear freq;
clear i;
clear plot_0C;
clear plot_1C;
clear plot_2C;
clear plotdata;
clear s;
clear shade;
clear shade_x;
clear shade_y;
clear shade_z;
clear time;
clear wav_limits;
clear wav_wind1;
clear wav_wind2;

%% Plot Topography
disp('Plotting topographies');
colors = cbrewer('div','RdBu',64,'PCHIP');
colors = flipud(colors);

f5 = figure('Name','Topography',...
    'NumberTitle','off');
for a = 1:2
    if a == 1
        t_wind = t_wind1;
        f_wind = f_wind1;
        t_lab = 'Theta burst preceding decision';
    elseif a == 2
        t_wind = t_wind2;
        f_wind = f_wind2;
        t_lab = 'Alpha burst preceding decision';
    end
    
    t_index = dsearchn(summary.WAV.time',t_wind');
    f_index = dsearchn(summary.WAV.freq',f_wind');
    
    for ii = 1:3
        t_data{ii} = squeeze(mean(summary.WAV.data{ii}(:,f_index(1):f_index(2),t_index(1):t_index(2)),3));
    end
    
    topodata = t_data{cond1}-t_data{cond2};
    t_vector = squeeze(mean(topodata,2));
    t_min = min(t_vector);
    t_max = max(t_vector);
    
    subplot(1,2,a);
    topo = topoplot(t_vector,summary.chanlocs,...
        'maplimits',topo_limits,...
        'style','map',...
        'electrodes','on',...
        'nosedir','+X',...
        'headrad','rim',...
        'shading','interp',...
        'conv','on',...
        'emarker',{'o','k',[],1},...
        'numcontour',32,...
        'whitebk','on',...
        'colormap',colors);
    
    title(t_lab)
    colormap(colors);
    
    ax = gca;
    ax.FontSize = 12;
    
    c = colorbar();
    c.TickDirection = 'out';
    c.Box = 'off';
    c.Label.String = 'Power (dB)';
    c.FontSize = 12;
    c.Limits = topo_limits;
    drawnow;
end

cd(save_dir);
export_fig(f5,'Topo','-png');

%% Clean Up Workspace
clear ax;
clear c;
clear colors;
clear f5;
clear f_index;
clear f_wind;
clear i;
clear ii;
clear t_data;
clear t_index;
clear t_lab;
clear t_max;
clear t_min;
clear t_vector;
clear t_wind;
clear topo;
clear topo_limits;
clear topodata;

%% Plot Behavioural Data
disp('Plotting behavioral data');
cd(beh_dir);
colors = cbrewer('qual', 'Dark2', 8);
colors = flipud(colors);

f6 = figure('Name','Behavioural',...
    'NumberTitle','off');
for a = 1:3
    if a == 1
        analysis = 'accuracy';
        ylab = 'Accuracy (%)';
        plot_title = 'Accuracy';
        y_lim = [0.5 1];
        y_tick = [0.5 0.6 0.7 0.8 0.9 1.0];
    elseif a == 2
        analysis = 'reactiontime';
        ylab = 'Reaction Time (s)';
        plot_title = 'Reaction Time';
        y_lim = [4 6];
        y_tick = [4.0 4.5 5.0 5.5 6.0];
    elseif a == 3
        analysis = 'confidence';
        ylab = 'Confidence';
        plot_title = 'Confidence';
        y_lim = [5 10];
        y_tick = [5 6 7 8 9 10];
    end
    
    xpos1 = [1 2];
    xpos2 = [1 3];
    xpos3 = [2 3];
    ypos1 = (y_lim(1)+((y_lim(2)-y_lim(1))*0.96));
    ypos2 = (y_lim(1)+((y_lim(2)-y_lim(1))*0.98));
    ypos3 = (y_lim(1)+((y_lim(2)-y_lim(1))*0.94));
    [h,p] = ttest(summary.behavioral.(analysis).significance.c0,...
        summary.behavioral.(analysis).significance.c1);
    p01 = p;
    [h,p] = ttest(summary.behavioral.(analysis).significance.c1,...
        summary.behavioral.(analysis).significance.c2);
    p12 = p;
    [h,p] = ttest(summary.behavioral.(analysis).significance.c0,...
        summary.behavioral.(analysis).significance.c2);
    p02 = p;
    plot_data = transpose(summary.behavioral.(analysis).plot.mean);
    ci_data = summary.behavioral.(analysis).ci.within(1,5);
    ci = [ci_data ci_data ci_data];
    
    if p01 < 1e-3
        txt1 = '***';
    elseif p01 < 1e-2
        txt1 = '**';
    elseif p01 < 0.05
        txt1 = '*';
    elseif ~isnan(p01)
        txt1 = 'n.s.';
    end
    
    if p02 < 1e-3
        txt2 = '***';
    elseif p02 < 1e-2
        txt2 = '**';
    elseif p02 < 0.05
        txt2 = '*';
    elseif ~isnan(p02)
        txt2 = 'n.s.';
    end
    
    if p12 < 1e-3
        txt3 = '***';
    elseif p12 < 1e-2
        txt3 = '**';
    elseif p12 < 0.05
        txt3 = '*';
    elseif ~isnan(p12)
        txt3 = 'n.s.';
    end
    
    subplot(1,3,a);
    hold on;
    
    for c = 1:3
        c = bar(c,plot_data(:,c),'FaceColor', colors(c,:));
    end
    
    set(gca,'xtick',[1 2 3],...
        'xticklabel',{'No Conflict','One Conflict','Two Conflict'},...
        'xticklabelrotation',45,...
        'xlim', [0.5 3.5]);
    
    title(plot_title);
    
    ax = gca;
    ax.YLim = y_lim;
    ax.YTick = y_tick;
    ax.FontSize = 12;
    ax.FontName = 'Arial';
    ax.LineWidth = 1.5;
    ax.YLabel.String = ylab;
    ax.FontWeight = 'bold';
    ax.Box = 'off';
    
    e = errorbar(plot_data,ci,'.');
    e.LineWidth = 1.5;
    e.Color = 'k';
    e.MarkerEdgeColor = 'none';
    
    l1 = text(mean(xpos1),...
        ypos1+(ypos1*0.0025),...
        txt1,...
        'horizontalalignment','center',...
        'backgroundcolor','none',...
        'margin',2,...
        'fontsize',8,...
        'fontweight','normal', ...
        'color','k');
    l2 = text(mean(xpos2),...
        ypos2+(ypos1*0.0025),...
        txt2,...
        'horizontalalignment','center',...
        'backgroundcolor','none',...
        'margin',2,...
        'fontsize',8,...
        'fontweight','normal', ...
        'color','k');
    l3 = text(mean(xpos3),...
        ypos3+(ypos1*0.0025),...
        txt3,...
        'horizontalalignment','center',...
        'backgroundcolor','none',...
        'margin',2,...
        'fontsize',8,...
        'fontweight','normal', ...
        'color','k');
    
    s1 = plot(gca,...
        [xpos1(1),xpos1(2)],...
        [ypos1 ypos1],...
        'LineStyle','-',...
        'LineWidth',1.5,...
        'color','k');
    s2 = plot(gca,...
        [xpos2(1),xpos2(2)],...
        [ypos2 ypos2],...
        'LineStyle','-',...
        'LineWidth',1.5,...
        'color','k');
    s3 = plot(gca,...
        [xpos3(1),xpos3(2)],...
        [ypos3 ypos3],...
        'LineStyle','-',...
        'LineWidth',1.5,...
        'color','k');
    
    lab1 = text(2.5,...
        (y_lim(1)+((y_lim(2)-y_lim(1))*0.9)),...
        '*** = p>0.001',...
        'horizontalalignment','left',...
        'backgroundcolor','none',...
        'margin',1,...
        'fontsize',8,...
        'fontweight','normal', ...
        'color','k');
    lab2 = text(2.5,...
        (y_lim(1)+((y_lim(2)-y_lim(1))*0.875)),...
        '** = p>0.01',...
        'horizontalalignment','left',...
        'backgroundcolor','none',...
        'margin',1,...
        'fontsize',8,...
        'fontweight','normal', ...
        'color','k');
    lab3 = text(2.5,...
        (y_lim(1)+((y_lim(2)-y_lim(1))*0.85)),...
        '* = p>0.05',...
        'horizontalalignment','left',...
        'backgroundcolor','none',...
        'margin',1,...
        'fontsize',8,...
        'fontweight','normal', ...
        'color','k');
    lab4 = text(2.5,...
        (y_lim(1)+((y_lim(2)-y_lim(1))*0.825)),...
        'n.s. = not significant',...
        'horizontalalignment','left',...
        'backgroundcolor','none',...
        'margin',1,...
        'fontsize',8,...
        'fontweight','normal', ...
        'color','k');
    
    colormap(colors)
    hold off
end

cd(save_dir);
export_fig(f6,'Behavior','-png');

%% Clean Workspace
clear analysis;
clear ax;
clear c;
clear cat;
clear ci;
clear ci_data;
clear colors5;
clear e;
clear f6;
clear h;
clear i;
clear ii;
clear l1;
clear l2;
clear l3;
clear lab1;
clear lab2;
clear lab3;
clear lab4;
clear p;
clear p01;
clear p02;
clear p12;
clear plot_data;
clear plot_title;
clear s1;
clear s2;
clear s3;
clear txt1;
clear txt2;
clear txt3;
clear xpos1;
clear xpos2;
clear xpos3;
clear y_lim;
clear y_tick;
clear ylab;
clear ypos1;
clear ypos2;
clear ypos3;

%% Clean Up Workspace
clear ans;
clear c_index1;
clear c_index2;
clear c_index3;
clear cond1;
clear cond2;
clear f_wind1;
clear f_wind2;
clear t_wind1;
clear t_wind2;