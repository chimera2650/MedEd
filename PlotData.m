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
significance = 0.05;
comp = getenv('computername');

% Theta highlight
wavelet_t = [-825 5 2;...
    -525 5 2;...
    -525 7 2;...
    -825 7 2];

% Alpha highlight
wavelet_a = [-775 10.5 2;...
    -525 10.5 2;...
    -525 12.5 2;...
    -775 12.5 2];

if strcmp(comp,'JORDAN-SURFACE') == 1
    working_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    working_dir2 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
elseif strcmp(comp,'Scratchy') == 1
    working_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    working_dir2 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
end

clear comp

%% Load Variables
cd(working_dir);
load('final_summary.mat');

for i = 1:62
    if strcmp(final_summary.chanlocs(i).labels,chan_name1) == 1
        chan_loc(i) = 1;
    elseif strcmp(final_summary.chanlocs(i).labels,chan_name2) == 1
        chan_loc(i) = 2;
    elseif strcmp(final_summary.chanlocs(i).labels,chan_name3) == 1
        chan_loc(i) = 3;
    else
        chan_loc(i) = 0;
    end
end

c_index1 = find(chan_loc == 1);
c_index2 = find(chan_loc == 2);
c_index3 = find(chan_loc == 3);
sig_label = strcat('p > ',num2str(significance));

clear i;
clear chan_loc

%% Plot Reward Positivity
disp('Plotting Reward Positivity');

for i = 1:200
   if final_summary.ERP.ttest(i,1) < significance
       sig(i) = 1;
   else
       sig(i) = NaN;
   end
end

cd(working_dir1);
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
time = final_summary.ERP.time;
ci_data = final_summary.ERP.ci_data(:,6);

figure(1);
hold on;
bl = boundedline(time,summary_mean1,ci_data,...
    time,summary_mean2,ci_data,...
    time,summary_diff,ci_data,...
    'cmap',colors1,'alpha');

ax = gca;

s = plot(final_summary.ERP.time,sig*(max(ax.YLim)*0.9),'sk');
l1 = line([0 0],[min(ax.YLim) max(ax.YLim)],...
    'Color','k',...
    'LineStyle',':',...
    'LineWidth',1);
l2 = line([min(ax.XLim) max(ax.XLim)],[0 0],...
    'Color','k',...
    'LineStyle',':',...
    'LineWidth',1);

legend({'Win','Loss','Difference'});
text(150,(max(ax.YLim)*0.9),sig_label,'FontWeight','bold','FontAngle','italic');

ax = gca;
ax.FontSize = 12;
ax.XLim = ([-200 600]);
ax.XLabel.String = 'Time (ms)';
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

%% Clean Workspace
clear ax;
clear bl;
clear ci_data;
clear colors1;
clear cond1;
clear i;
clear l1;
clear l2;
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

%% Plot FFT
disp('Plotting FFT');
colors2 = cbrewer('qual','Dark2',8);
colors2 = flipud(colors2);

figure(2);
for x = 1:2
    if x == 1
        c_index = c_index2;
        chan_name = chan_name2;
        band = 'Theta';
        region = 'frontal';
        a = [4 8];
    elseif x == 2
        c_index = c_index3;
        chan_name = chan_name3;
        band = 'Alpha';
        region = 'parietal';
        a = [8 15];
    end
    
    for i = 1:59
        if final_summary.FFT.ttest.(region)(i,1) < significance
            sig(i) = 1;
        else
            sig(i) = NaN;
        end
    end
    
    cd(working_dir2);
    filenames = dir(strcat(prefix,'*'));   % Get a count of file number
    file_num = length(filenames);
    ci_data = final_summary.FFT.ci_data.(region)(:,6);
    freq = final_summary.FFT.freq(:,1:59);
    x_lim = ([0 30]);
    y_lim = ([0 3]);
    b = [min(y_lim) max(y_lim)];
    
    for i = 1:file_num
        subject_data = importdata(filenames(i).name); % Import subject data
        summary_data1(i,:) = subject_data.FFT.data{1}(c_index,:);
        summary_data2(i,:) = subject_data.FFT.data{2}(c_index,:);
        summary_data3(i,:) = subject_data.FFT.data{3}(c_index,:);
    end
    
    cond1 = isnan(summary_data1(:,1));
    summary_data1(cond1,:) = [];
    summary_mean1 = mean(summary_data1(:,1:59));
    cond1 = isnan(summary_data2(:,1));
    summary_data2(cond1,:) = [];
    summary_mean2 = mean(summary_data2(:,1:59));
    cond1 = isnan(summary_data3(:,1));
    summary_data3(cond1,:) = [];
    summary_mean3 = mean(summary_data3(:,1:59));

    subplot(1,2,x);
    hold on;
    s = plot(freq,sig*(max(y_lim)*0.1),'sk');
    bl = boundedline(freq,summary_mean3,ci_data,...
        freq,summary_mean2,ci_data,...
        freq,summary_mean1,ci_data,...
        'cmap',colors2,'alpha');
    ar = patch([a(1) a(2) a(2) a(1)],...
        [b(1) b(1) b(2) b(2)],...
        [0.75 0.75 0.75],...
        'LineStyle','none');
    
    order = get(gca,'Children');
    set(gca,'Children',flipud(order));
    
    legend(bl(1:3),{'No Conflict','One Conflict','Two Conflict'});
    title(sprintf('%s band plot of 2000ms preceeding decision at %s',band,chan_name));
    
    ax = gca;
    ax.FontSize = 12;
    ax.XLim = x_lim;
    ax.XLabel.String = 'Power (\muV^2)';
    ax.YLim = y_lim;
    ax.YLabel.String = 'Frequency (Hz)';
    ax.Legend.Location = 'northeast';
    ax.Legend.Box = 'off';
    ax.Legend.FontSize = 12;
    ax.Legend.FontWeight = 'bold';
    
    bl(1).LineWidth = 2;
    bl(1).LineStyle = '-';
    bl(2).LineWidth = 2;
    bl(2).LineStyle = '-';
    bl(3).LineWidth = 2;
    bl(3).LineStyle = '-';
    
    s.MarkerEdgeColor = 'k';
    s.MarkerFaceColor = 'k';
    s.MarkerSize = 8;
    
    s_lab = text(2,(max(ax.YLim)*0.1),sig_label,'FontWeight','bold','FontAngle','italic');
    hold off
end

%% Clean Workspace
clear a;
clear ar;
clear ax;
clear b;
clear band;
clear bl;
clear c_index;
clear chan_name;
clear ci_data;
clear colors2;
clear cond1;
clear freq;
clear i;
clear order;
clear region;
clear sig;
clear subject_data;
clear summary_data1;
clear summary_data2;
clear summary_data3;
clear summary_mean1;
clear summary_mean2;
clear summary_mean3;
clear s;
clear x;
clear x_lim;
clear y_lim;

%% Plot Wavelets
disp('Plotting wavelets');
colors3 = cbrewer('div','RdBu',64,'PCHIP');
colors3 = flipud(colors3);

figure(3);
for i = 1:2
    if i == 1
        c_index = c_index2;
        shade_x = [wavelet_t(1,1) wavelet_t(2,1) wavelet_t(3,1) wavelet_t(4,1)];
        shade_y = [wavelet_t(1,2) wavelet_t(2,2) wavelet_t(3,2) wavelet_t(4,2)];
        shade_z = [wavelet_t(1,3) wavelet_t(2,3) wavelet_t(3,3) wavelet_t(4,3)];
        chan_name = chan_name2;
    elseif i == 2
        c_index = c_index3;
        shade_x = [wavelet_a(1,1) wavelet_a(2,1) wavelet_a(3,1) wavelet_a(4,1)];
        shade_y = [wavelet_a(1,2) wavelet_a(2,2) wavelet_a(3,2) wavelet_a(4,2)];
        shade_z = [wavelet_a(1,3) wavelet_a(2,3) wavelet_a(3,3) wavelet_a(4,3)];
        chan_name = chan_name3;
    end

    subplot(2,1,i);
    plotdata = squeeze(final_summary.wavelet.data{1}(c_index,:,:)) - squeeze(final_summary.wavelet.data{3}(c_index,:,:));
    
    s = surf(final_summary.wavelet.time,final_summary.wavelet.freq,plotdata);
    hold on
    shade = fill3(shade_x,shade_y,shade_z,0);
    hold off
    
    if i == 1
        title(sprintf('Wavelet plot at %s for the 2000ms preceeding decision',chan_name));
    elseif i == 2
        title(sprintf('Wavelet plot at %s for the 2000ms preceeding decision',chan_name));
    end
    
    set(gca,'ydir','normal');
    
    c = colorbar;
    c.TickDirection = 'out';
    c.Box = 'off';
    c.Label.String = 'Power (dB)';
    c.Limits = [-2 2];
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
    ax.XLabel.String = 'Time (ms)';
    ax.XTick = [-2000 -1500 -1000 -500 0];
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

%% Clean Workspace
clear ax;
clear axpos;
clear c;
clear c_index;
clear colors3;
clear cpos;
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
clear wavelet_t1;
clear wavelet_t2;
clear wavelet_t3;
clear wavelet_t4;
clear wavelet_a1;
clear wavelet_a2;
clear wavelet_a3;
clear wavelet_a4;

%% Plot Behavioural Data
disp('Plotting behavioral data');
colors4 = cbrewer('qual', 'Dark2', 8);
colors4 = flipud(colors4);

figure(4);
for i = 1:3
    if i == 1
        analysis = 'accuracy';
        ylab = 'Accuracy (%)';
        plot_title = 'Accuracy';
        y_lim = [0.5 1];
        y_tick = [0.5 0.6 0.7 0.8 0.9 1.0];
    elseif i == 2
        analysis = 'reactiontime';
        ylab = 'Reaction Time (s)';
        plot_title = 'Reaction Time';
        y_lim = [4 6];
        y_tick = [4.0 4.5 5.0 5.5 6.0];
    elseif i == 3
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
    [h,p] = ttest(final_summary.behavioral.(analysis).significance.c0,...
        final_summary.behavioral.(analysis).significance.c1);
    p01 = p;
    [h,p] = ttest(final_summary.behavioral.(analysis).significance.c1,...
        final_summary.behavioral.(analysis).significance.c2);
    p12 = p;
    [h,p] = ttest(final_summary.behavioral.(analysis).significance.c0,...
        final_summary.behavioral.(analysis).significance.c2);
    p02 = p;
    plot_data = transpose(final_summary.behavioral.(analysis).plot.mean);
    ci_data = final_summary.behavioral.(analysis).ci.within(1,5);
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
    
    subplot(1,3,i);
    hold on;
    
    for c = 1:3
        c = bar(c,plot_data(:,c),'FaceColor', colors4(c,:));
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
    
    colormap(colors4)
    hold off
end

clear analysis;
clear ax;
clear c;
clear cat;
clear ci;
clear ci_data;
clear colors4;
clear e;
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

%% Old Plot Code
% plot_win = plot(final_summary.ERP.time,final_summary.ERP.data{1}(c_index1,:),...
%     'k-',...
%     'LineWidth',2);
% hold on
% plot_loss = plot(final_summary.ERP.time,final_summary.ERP.data{2}(c_index1,:),...
%     'r--',...
%     'LineWidth',2);
% line([0 0],[-7.5 17.5],...
%     'Color','k',...
%     'LineStyle',':',...
%     'LineWidth',1);
% line([-200 600],[0 0],...
%     'Color','k',...
%     'LineStyle',':',...
%     'LineWidth',1);
% shade = fill([250 250 325 325],[-5 15 15 -5],[.7 .7 .7]);
% hold off
% title('ERP of Win/Loss in learning phase');
% set(gca,'children',flipud(get(gca,'children')));
% set(shade,'LineStyle','none',...
%     'FaceAlpha',.5);
% xlim([-200 600]);
% ylim([-7.5 17.5]);
% legend([plot_win plot_loss],{'Win','Loss'});
% ax = gca;
% ax.FontSize = 12;
% ax.FontName = 'Arial';
% ax.LineWidth = 1.5;
% ax.YLabel.String = 'Power (\muV)';
% ax.XLabel.String = 'Time (ms)';
% ax.FontWeight = 'bold';
% ax.Box = 'off';
% ax.YDir = 'reverse';
% ax.Legend.Location = 'northeast';
% ax.Legend.Box = 'off';
% 
% clear ax;
% clear plot_win;
% clear plot_loss;
% clear shade;
% 
% plot_0C = plot(final_summary.FFT.freq,final_summary.FFT.data{1}(c_index,:),...
%     'k-',...
%     'LineWidth',2);
% hold on
% plot_1C = plot(final_summary.FFT.freq,final_summary.FFT.data{2}(c_index,:),...
%     'b--',...
%     'LineWidth',2);
% plot_2C = plot(final_summary.FFT.freq,final_summary.FFT.data{3}(c_index,:),...
%     'r:',...
%     'LineWidth',2);
% shade = fill(shade1,shade2,[.7 .7 .7]);
% hold off
% title(sprintf('%s band plot of 2000ms preceeding decision',band));
% set(gca,'children',flipud(get(gca,'children')));
% set(shade,'LineStyle','none');
% xlim([0 20]);
% ylim([0 4]);
% 
% if i == 1
%     legend([plot_0C plot_1C plot_2C shade],{'No Conflict','One Conflict','Two Conflict','Theta'});
% elseif i == 2
%     legend([plot_0C plot_1C plot_2C shade],{'No Conflict','One Conflict','Two Conflict','Alpha'});
% end
% 
% ax = gca;
% ax.FontSize = 12;
% ax.FontName = 'Arial';
% ax.LineWidth = 1.5;
% ax.YLabel.String = 'Power (\muV^2)';
% ax.XLabel.String = 'Frequency (Hz)';
% ax.FontWeight = 'bold';
% ax.Box = 'off';
% ax.Legend.Location = 'northeast';
% ax.Legend.Box = 'off';