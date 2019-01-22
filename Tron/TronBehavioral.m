%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
d_name = 'med_ed_behav.mat';
prefix = 'Medical_DM_';
sub_keep = '001,002,003,005,008,009,011,012,013,014,022,024,025,027,029,030,031,035,037,041,043,044,047,048,049,050,051,054,056,057';
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    behav_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Behavioral';
    raw_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Behavioral\Raw\';
    save_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_behav.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    behav_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Behavioral';
    raw_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Behavioral\Raw\';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_behav.mat';
end

clearvars comp

%% Load Data
cd(master_dir);
%load(d_name);
cd(behav_dir);

subject_data = load('Medical_DM_Conflict.txt');
subject_data = array2table(subject_data);
subject_data.Properties.VariableNames = {'subject','phase','block_count','block_total','trial_count','trial_total','RT','accuracy','disease','conflict','winloss','confidence','ALT','AST'};
nrow = height(subject_data);

%% Correct conflict scores
for a = 1:nrow
    if subject_data.conflict(a) == 1
        subject_data.conflict(a) = 2;
    elseif subject_data.conflict(a) == 4
        subject_data.conflict(a) = 1;
    end
end

clearvars a;

% summary.conflict.ttest = string(summary.conflict.ttest);
summary.conflict.ttest(2,1) = '0-1';
summary.conflict.ttest(3,1) = '0-2';
summary.conflict.ttest(4,1) = '1-2';
summary.conflict.ttest(1,2) = 'accuracy';
summary.conflict.ttest(1,3) = 'reactiontime';
summary.conflict.ttest(1,4) = 'confidence';

%% Correlate conflict score
disp('Correlating conflict scores');

subject_data.cfscore = zeros(nrow,1);
subject_data.cfscore = (1-(((abs(subject_data.ALT-70)/60)+(abs(subject_data.AST-275)/225))*0.5));
summary.conflict.correlation = string(summary.(analysis).correlation);
summary.conflict.correlation(1,1) = 'winloss';
summary.conflict.correlation(2,1) = round(corr(subject_data.cfscore,subject_data.winloss),3);
summary.conflict.correlation(1,2) = 'RT';
summary.conflict.correlation(2,2) = round(corr(subject_data.cfscore,subject_data.RT),3);
summary.conflict.correlation(1,3) = 'confidence';
summary.conflict.correlation(2,3) = round(corr(subject_data.cfscore,subject_data.confidence),3);

clearvars nrow;

%% Accuracy
disp('Summarizing accuracy data');

% Create summary data
for a = 1:max(subject_data.subject)
    cond1 = subject_data.subject == a;
    temp_data1 = subject_data(cond1,:);
    
    for b = 1:3
        cond2 = temp_data1.conflict == b;
        temp_data2 = temp_data1(cond2,:);
        temp_data3(b,1) = a;
        temp_data3(b,2) = b;
        temp_data3(b,3) = mean(temp_data2.winloss);
        temp_data3(b,4) = std(temp_data2.winloss);
        temp_data3(b,5) = length(temp_data2.winloss);
    end
    
    winloss = [winloss; temp_data3];
end

clearvars a b cond1 cond2 temp_data1 temp_data2;

cond1 = isnan(winloss(:,3));
winloss(cond1,:) = [];
winloss = array2table(winloss,'VariableNames',{'subject','conflict','mean','stdev','num'});
winloss.error = (winloss.stdev./sqrt(winloss.num));
ts = tinv(0.95,(winloss.num)-1);
winloss.ci = winloss.mean+(ts.*winloss.error);
accuracy.summary = winloss;

clearvars temp_data3 ts;

% Generate plot data
for a = 1:3
    cond1 = accuracy.summary.conflict == a;
    temp_data1 = accuracy.summary(cond1,:);
    temp_data2(a,1) = a;
    temp_data2(a,2) = mean(temp_data1.mean);
    temp_data2(a,3) = std(temp_data1.mean);
    temp_data2(a,4) = length(temp_data1.mean);
    plotwinloss = temp_data2;
end

clearvars a cond1 temp_data1 temp_data2;

cond1 = isnan(plotwinloss(:,2));
plotwinloss(cond2,:) = [];
plotwinloss = array2table(plotwinloss,'VariableNames',{'conflict','mean','stdev','num'});
plotwinloss.error = (plotwinloss.stdev./sqrt(plotwinloss.num));
ts = tinv(0.95,(plotwinloss.num)-1);
plotwinloss.ci = plotwinloss.mean+(ts.*plotwinloss.error);
accuracy.plot = plotwinloss;

clearvars cond1 plotwinloss temp_data2 ts winloss;

% Repeated Measures ANOVA
for a = 1:3
    for b = 1:(length(accuracy.summary.subject)/3)
        temp_data1(b,1) = b;
    end
    
    cond1 = accuracy.summary.conflict == a;
    temp_data2 = accuracy.summary.mean(cond1);
    temp_data1 = [temp_data1 temp_data2];
end

clearvars a b cond1 temp_data2;

accuracy.anova.data = array2table(temp_data1,'VariableNames',{'subject','zero','one','two'});
meas = table([1 2 3]','VariableNames',{'Measurements'});
rm = fitrm(accuracy.anova.data,'zero-two~subject','WithinDesign',meas);
accuracy.anova.output = ranova(rm);

clearvars meas rm temp_data1;

% Within Confidence Intervals
for a = 1:max(accuracy.summary.subject)
    cond1 = accuracy.summary.subject(:) == a;
    temp_data1 = accuracy.summary.mean(cond1);
    temp_data2 = mean(temp_data1);
    ci(end+1,:) = temp_data2;
end

clearvars a cond1 temp_data1;

cond1 = isnan(ci(:,1));
ci(cond1,:) = [];
accuracy.ci.data = ci;
within(1,1) = mean(accuracy.ci.data);
within(1,2) = std(accuracy.ci.data);
within(1,3) = length(accuracy.ci.data);
within(1,4) = within(1,2)/sqrt(within(1,3)-1);
within(1,5) = accuracy.anova.output.MeanSq(2);
ts = tinv(0.95,within(1,3)-1);
within(1,6) = sqrt(within(1,5)/within(1,3))*(ts);
accuracy.ci.within = within;

clearvars ci cond1 temp_data2 ts;

% Significance testing
for a = 1:3
    cond1 = accuracy.summary.conflict == a;
    temp_data = accuracy.summary.mean(cond1,:);
    sigaccuracy(:,a) = temp_data;
end

clearvars a cond1 temp_data

sigaccuracy = array2table(sigaccuracy,'VariableNames',{'c0','c1','c2'});
accuracy.significance = sigaccuracy;
summary.conflict.ttest(2,2) = ttest(accuracy.significance.c0,accuracy.significance.c1);
summary.conflict.ttest(3,2) = ttest(accuracy.significance.c0,accuracy.significance.c2);
summary.conflict.ttest(4,2) = ttest(accuracy.significance.c1,accuracy.significance.c2);
summary.conflict.accuracy = accuracy;

clearvars accuracy sigaccuracy;

%% Reaction Time
disp('Summarizing reaction time data');

for a = 1:max(subject_data.subject)
    cond1 = subject_data.subject == a;
    temp_data1 = subject_data(cond1,:);
    
    for b = 1:3
        cond2 = temp_data1.conflict == b;
        temp_data2 = temp_data1(cond2,:);
        temp_data3(b,1) = a;
        temp_data3(b,2) = b;
        temp_data3(b,3) = mean(temp_data2.RT);
        temp_data3(b,4) = std(temp_data2.RT);
        temp_data3(b,5) = length(temp_data2.RT);
    end
    
    RT = [RT; temp_data3];
end

clearvars a b cond1 cond2 temp_data1 temp_data2;

cond1 = isnan(RT(:,3));
RT(cond1,:) = [];
RT = array2table(RT,'VariableNames',{'subject','conflict','mean','stdev','num'});
RT.error = (RT.stdev./sqrt(RT.num));
ts = tinv(0.95,(RT.num)-1);
RT.ci = RT.mean+(ts.*RT.error);
reactiontime.summary = RT;

clearvars cond1 temp_data3 RT ts;

for a = 1:3
    cond1 = reactiontime.summary.conflict == a;
    temp_data1 = reactiontime.summary(cond1,:);
    temp_data2(a,1) = a;
    temp_data2(a,2) = mean(temp_data1.mean);
    temp_data2(a,3) = std(temp_data1.mean);
    temp_data2(a,4) = length(temp_data1.mean);
    plotRT = temp_data2;
end

clearvars a cond1 temp_data1 temp_data2;

cond1 = isnan(plotRT(:,2));
plotRT(cond1,:) = [];
plotRT = array2table(plotRT,'VariableNames',{'conflict','mean','stdev','num'});
plotRT.error = (plotRT.stdev./sqrt(plotRT.num));
ts = tinv(0.95,(plotRT.num)-1);
plotRT.ci = plotRT.mean+(ts.*plotRT.error);
reactiontime.plot = plotRT;

clearvars cond1 plotRT ts;

% Repeated Measures ANOVA
for a = 1:3
    for b = 1:(length(reactiontime.summary.subject)/3)
        temp_data1(b,1) = b;
    end
    
    cond1 = reactiontime.summary.conflict == a;
    temp_data2 = reactiontime.summary.mean(cond1);
    temp_data1 = [temp_data1 temp_data2];
end

clearvars a b cond1 temp_data2;

reactiontime.anova.data = array2table(temp_data1,'VariableNames',{'subject','zero','one','two'});
meas = table([1 2 3]','VariableNames',{'Measurements'});
rm = fitrm(reactiontime.anova.data,'zero-two~subject','WithinDesign',meas);
reactiontime.anova.output = ranova(rm);

clearvars meas rm temp_data1;

% Within Confidence Intervals
for a = 1:max(reactiontime.summary.subject)
    cond1 = reactiontime.summary.subject(:) == a;
    temp_data1 = reactiontime.summary.mean(cond1);
    temp_data2 = mean(temp_data1);
    ci(end+1,:) = temp_data2;
end

clearvars a cond1 temp_data1;

cond1 = isnan(ci(:,1));
ci(cond1,:) = [];
reactiontime.ci.data = ci;
within(1,1) = mean(reactiontime.ci.data);
within(1,2) = std(reactiontime.ci.data);
within(1,3) = length(reactiontime.ci.data);
within(1,4) = within(1,2)/sqrt(within(1,3)-1);
within(1,5) = reactiontime.anova.output.MeanSq(2);
ts = tinv(0.95,within(1,3)-1);
within(1,6) = sqrt(within(1,5)/within(1,3))*(ts);
reactiontime.ci.within = within;

clearvars cond1 ci temp_data2 ts;

% Significance testing
for a = 1:3
    cond1 = reactiontime.summary.conflict == a;
    temp_data1 = reactiontime.summary.mean(cond1,:);
    temp_data2(:,a) = temp_data1;
    sigRT = temp_data2;
end

clearvars a cond1 temp_data1 temp_data2;

sigRT = array2table(sigRT,'VariableNames',{'c0','c1','c2'});
reactiontime.significance = sigRT;
summary.(analysis).ttest(2,3) = ttest(reactiontime.significance.c0,reactiontime.significance.c1);
summary.(analysis).ttest(3,3) = ttest(reactiontime.significance.c0,reactiontime.significance.c2);
summary.(analysis).ttest(4,3) = ttest(reactiontime.significance.c1,reactiontime.significance.c2);
summary.conflict.reactiontime = reactiontime;

clearvars reactiontime sigRT;

%% Confidence
disp('Summarizing confidence data');

for a = 1:max(subject_data.subject)
    cond1 = subject_data.subject == a;
    temp_data1 = subject_data(cond1,:);
    
    for b = 1:3
        cond2 = temp_data1.conflict == b;
        temp_data2 = temp_data1(cond2,:);
        temp_data3(b,1) = a;
        temp_data3(b,2) = b;
        temp_data3(b,3) = mean(temp_data2.confidence);
        temp_data3(b,4) = std(temp_data2.confidence);
        temp_data3(b,5) = length(temp_data2.confidence);
    end
    
    conf = [conf; temp_data3];
end

clearvars a b cond1 cond2 temp_data1 temp_data2;

cond1 = isnan(conf(:,3));
conf(cond1,:) = [];
conf = array2table(conf,'VariableNames',{'subject','conflict','mean','stdev','num'});
conf.error = (conf.stdev./sqrt(conf.num));
ts = tinv(0.95,(conf.num)-1);
conf.ci = conf.mean+(ts.*conf.error);
confidence.summary = conf;

clearvars cond1 temp_data3 ts;

for a = 1:3
    cond1 = confidence.summary.conflict == a;
    temp_data1 = confidence.summary(cond1,:);
    temp_data2(a,1) = a;
    temp_data2(a,2) = mean(temp_data1.mean);
    temp_data2(a,3) = std(temp_data1.mean);
    temp_data2(a,4) = length(temp_data1.mean);
    plotconfidence = temp_data2;
end

clearvars a cond1 temp_data1 temp_data2;

cond1 = isnan(plotconfidence(:,2));
plotconfidence(cond1,:) = [];
plotconfidence = array2table(plotconfidence,'VariableNames',{'conflict','mean','stdev','num'});
plotconfidence.error = (plotconfidence.stdev./sqrt(plotconfidence.num));
ts = tinv(0.95,(plotconfidence.num)-1);
plotconfidence.ci = plotconfidence.mean+(ts.*plotconfidence.error);
confidence.plot = plotconfidence;

clearvars cond1 conf plotconfidence ts;

% Repeated Measures ANOVA
for a = 1:3
    for b = 1:(length(confidence.summary.subject)/3)
        temp_data1(b,1) = b;
    end
    
    cond1 = confidence.summary.conflict == a;
    temp_data2 = confidence.summary.mean(cond1);
    temp_data1 = [temp_data1 temp_data2];
end

clearvars a b cond1 temp_data2;

confidence.anova.data = array2table(temp_data1,'VariableNames',{'subject','zero','one','two'});
meas = table([1 2 3]','VariableNames',{'Measurements'});
rm = fitrm(confidence.anova.data,'zero-two~subject','WithinDesign',meas);
confidence.anova.output = ranova(rm);

clearvars meas rm temp_data1;

% Within Confidence Intervals
for a = 1:max(confidence.summary.subject)
    cond1 = confidence.summary.subject(:) == a;
    temp_data1 = confidence.summary.mean(cond1);
    temp_data2 = mean(temp_data1);
    ci(end+1,:) = temp_data2;
end

clearvars a cond1 temp_data1 temp_data2;

cond1 = isnan(ci(:,1));
ci(cond1,:) = [];
confidence.ci.data = ci;
within(1,1) = mean(confidence.ci.data);
within(1,2) = std(confidence.ci.data);
within(1,3) = length(confidence.ci.data);
within(1,4) = within(1,2)/sqrt(within(1,3)-1);
within(1,5) = confidence.anova.output.MeanSq(2);
ts = tinv(0.95,within(1,3)-1);
within(1,6) = sqrt(within(1,5)/within(1,3))*(ts);
confidence.ci.within = within;

clearvars ci cond1 temp_data2 ts;

% Significance testing
for a = 1:3
    cond1 = confidence.summary.conflict == a;
    temp_data1 = confidence.summary.mean(cond1,:);
    temp_data2(:,a) = temp_data1;
    sigconf = temp_data2;
end

clearvars a cond1 temp_data1 temp_data2;

sigconf = array2table(sigconf,'VariableNames',{'c0','c1','c2'});
confidence.significance = sigconf;
summary.(analysis).ttest(2,4) = ttest(confidence.significance.c0,confidence.significance.c1);
summary.(analysis).ttest(3,4) = ttest(confidence.significance.c0,confidence.significance.c2);
summary.(analysis).ttest(4,4) = ttest(confidence.significance.c1,confidence.significance.c2);
summary.conflict.confidence = confidence;

clearvars confidence sigconf;

%% Summarize Important Variables
disp('Summarizing important variables');

cd(raw_dir);
sub_num = strsplit(sub_keep,',');
file_num = length(sub_num);

for a = 1:file_num
    file_name = [raw_dir prefix sub_num{a} '.mat'];
    load(file_name);
    hr(a,1) = ImportantValue(1);
    nbp(a,1) = ImportantValue(2);
    alt(a,1) = ImportantValue(3);
    ggt(a,1) = ImportantValue(4);
    spo2(a,1) = ImportantValue(5);
    ast(a,1) = ImportantValue(6);
    alp(a,1) = ImportantValue(7);
    temp(a,1) = ImportantValue(8);
    rr(a,1) = ImportantValue(9);
    ultra(a,1) = ImportantValue(10);
end

summary_table = table(hr,nbp,alt,ggt,spo2,ast,alp,temp,rr,ultra);

summary_data = {'hr',sum(summary_table.hr(:) == 1);...
    'nbp',sum(summary_table.nbp(:) == 1);...
    'alt',sum(summary_table.alt(:) == 1);...
    'ggt',sum(summary_table.ggt(:) == 1);...
    'spo2',sum(summary_table.spo2(:) == 1);...
    'ast',sum(summary_table.ast(:) == 1);...
    'alp',sum(summary_table.alp(:) == 1);...
    'temp',sum(summary_table.temp(:) == 1);...
    'rr',sum(summary_table.rr(:) == 1);...
    'ultra',sum(summary_table.ultra(:) == 1)};

cond1 = summary_table.alt(:) == 1 & summary_table.ast(:) == 1;
summary_data{11,1} = 'both';
summary_data{11,2} = sum(cond1);
num = cell2mat(summary_data(:,2));
percent = round((num./file_num).*100,2);
percent = num2cell(percent);
summary_data = horzcat(summary_data,percent);
variables.data = summary_table;
variables.summary = summary_data;
summary.conflict.variables = variables;

clearvars a alp alt ast cond1 file_name file_num ggt hr ImportantValue nbp ...
    num percent rr spo2 sub_num summary_data summary_table temp ultra variables;

%% Save Data
save(save_dir,'summary');

%% Clean Up Workspace
clearvars -except summary;