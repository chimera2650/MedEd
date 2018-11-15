%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
prefix = 'MedEdFlynn_';
chan_name1 = 'FCz';
chan_name2 = 'Fz';
chan_name3 = 'Pz';
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    working_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    working_dir2 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
    save_path = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\final_summary.mat';
elseif strcmp(comp,'Scratchy') == 1
    working_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    working_dir2 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
    save_path = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\final_summary.mat';
end

clear comp

%% Load Data
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

clear chan_loc;
clear i;

%% ERP CI
cd(working_dir1);
filenames = dir(strcat(prefix,'*'));   % Get a count of file number
file_num = length(filenames);

for i = 1:200
    subject = num2str((i*4)-200);
    for x = 1:file_num
        subject_data = importdata(filenames(x).name); % Import subject data
        summary_data(x,1) = subject_data.ERP.data{1}(c_index1,i);
        summary_data(x,2) = subject_data.ERP.data{2}(c_index1,i);
    end
    
    disp(['Calculating ERP confidence intervals at ' subject ' ms']);
    
    cond1 = isnan(summary_data(:,2));
    summary_data(cond1,:) = [];
    summary_data(25,:) = [];
    [p,tbl] = anova1(summary_data,{'win','loss'},'off');
    
    summary_data = mean(summary_data,2);
    
    ci_data(i,1) = mean(summary_data);
    ci_data(i,2) = std(summary_data);
    ci_data(i,3) = length(summary_data);
    ci_data(i,4) = ci_data(i,2)/sqrt(ci_data(i,3)-1);
    ts = tinv(0.95,ci_data(i,3)-1);
    ci_data(i,5) = tbl{3,4};
    ci_data(i,6) = sqrt(ci_data(i,5)/ci_data(i,3))*(ts);
end

final_summary.ERP.ci_data = ci_data;

clear ci_data;
clear cond1;
clear i;
clear p;
clear subject_data;
clear summary_data;
clear tbl;
clear ts;
clear x;

%% ERP T-Tests
cond_ttest = [];

for i = 1:200
    subject = num2str((i*4)-200);
    for x = 1:file_num
        subject_data = importdata(filenames(x).name); % Import subject data
        summary_data(x,1) = subject_data.ERP.data{1}(c_index1,i);
        summary_data(x,2) = subject_data.ERP.data{2}(c_index1,i);
    end
    
    disp(['Calculating ERP t-tests at ' subject ' ms']);
    
    cond1 = isnan(summary_data(:,2));
    summary_data(cond1,:) = [];
    summary_data(25,:) = [];
    a = summary_data(:,1);
    b = summary_data(:,2);
    
    [h,p] = ttest(a,b,'tail','both');
    cond_ttest(i,1) = p;
end

final_summary.ERP.ttest = cond_ttest;

clear a;
clear b;
clear cond_ttest;
clear cond1;
clear h;
clear i;
clear p;
clear summary_data;
clear x;

%% FFT CI
cd(working_dir2);
filenames = dir(strcat(prefix,'*'));   % Get a count of file number
file_num = length(filenames);

for i = 1:59
    subject = num2str(i/2);
    for x = 1:file_num
        subject_data = importdata(filenames(x).name); % Import subject data
        summary_data(x,1) = subject_data.FFT.data{1}(c_index2,i);
        summary_data(x,2) = subject_data.FFT.data{3}(c_index2,i);
    end
    
    disp(['Calculating frontal FFT confidence intervals at ' subject ' Hz']);
    
    cond1 = isnan(summary_data(:,1));
    summary_data(cond1,:) = [];
    
    [p,tbl] = anova1(summary_data,{'0C','2C'},'off');
    summary_data = mean(summary_data,2);
    
    ci_data(i,1) = mean(summary_data);
    ci_data(i,2) = std(summary_data);
    ci_data(i,3) = length(summary_data);
    ci_data(i,4) = ci_data(i,2)/sqrt(ci_data(i,3)-1);
    ts = tinv(0.95,ci_data(i,3)-1);
    ci_data(i,5) = tbl{3,4};
    ci_data(i,6) = sqrt(ci_data(i,5)/ci_data(i,3))*(ts*(ci_data(i,4)-1));
end

final_summary.FFT.ci_data.frontal = ci_data;

for i = 1:59
    subject = num2str(i/2);
    for x = 1:file_num
        subject_data = importdata(filenames(x).name); % Import subject data
        summary_data(x,1) = subject_data.FFT.data{1}(c_index3,i);
        summary_data(x,2) = subject_data.FFT.data{3}(c_index3,i);
    end
    
    disp(['Calculating parietal FFT confidence intervals at ' subject ' Hz']);
    
    cond1 = isnan(summary_data(:,1));
    summary_data(cond1,:) = [];
    
    [p,tbl] = anova1(summary_data,{'0C','2C'},'off');
    summary_data = mean(summary_data,2);
    
    ci_data(i,1) = mean(summary_data);
    ci_data(i,2) = std(summary_data);
    ci_data(i,3) = length(summary_data);
    ci_data(i,4) = ci_data(i,2)/sqrt(ci_data(i,3)-1);
    ts = tinv(0.95,ci_data(i,3)-1);
    ci_data(i,5) = tbl{3,4};
    ci_data(i,6) = sqrt(ci_data(i,5)/ci_data(i,3))*(ts*(ci_data(i,4)-1));
end

final_summary.FFT.ci_data.parietal = ci_data;

clear ci_data;
clear cond1;
clear i;
clear p;
clear subject_data;
clear summary_data;
clear tbl;
clear ts;
clear x;

%% FFT T-Tests
cond_ttest = [];

for i = 1:59
    subject = num2str(i/2);
    for x = 1:file_num
        subject_data = importdata(filenames(x).name); % Import subject data
        summary_data(x,1) = subject_data.FFT.data{1}(c_index2,i);
        summary_data(x,2) = subject_data.FFT.data{3}(c_index2,i);
    end
    
    disp(['Calculating frontal FFT t-tests at ' subject ' Hz']);
    
    cond1 = isnan(summary_data(:,2));
    summary_data(cond1,:) = [];
    a = summary_data(:,1);
    b = summary_data(:,2);
    
    [h,p] = ttest(a,b,'tail','both');
    cond_ttest(i,1) = p;
end

final_summary.FFT.ttest.frontal = cond_ttest;
cond_ttest = [];

for i = 1:59
    subject = num2str(i/2);
    for x = 1:file_num
        subject_data = importdata(filenames(x).name); % Import subject data
        summary_data(x,1) = subject_data.FFT.data{1}(c_index3,i);
        summary_data(x,2) = subject_data.FFT.data{3}(c_index3,i);
    end
    
    disp(['Calculating frontal FFT t-tests at ' subject ' Hz']);
    
    cond1 = isnan(summary_data(:,2));
    summary_data(cond1,:) = [];
    a = summary_data(:,1);
    b = summary_data(:,2);
    
    [h,p] = ttest(a,b,'tail','both');
    cond_ttest(i,1) = p;
end

final_summary.FFT.ttest.parietal = cond_ttest;

clear a;
clear b;
clear cond_ttest;
clear cond1;
clear cond2;
clear h;
clear i;
clear p;
clear summary_data1;
clear summary_data2;
clear x;

%% Save Data
save(save_path,'final_summary');

%% Clean Workspace
clear c_index1;
clear c_index2;
clear c_index3;
clear file_num;
clear filenames;
clear subject_data;
