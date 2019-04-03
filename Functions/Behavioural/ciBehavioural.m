function ciData = ciBehavioural(dataFile);
subjectData = dataFile;
subjectCount = unique(subjectData.subject);
conflictCount = max(subjectData.conflict);

% Repeated Measures ANOVA
for conflictCounter = 1:conflictCount
    for subjectCounter = 1:subjectCount
        temp_data1(subjectCounter,1) = subjectCounter;
    end
    
    cond1 = accuracy.summary.conflict == conflictCounter;
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
ci = [];

for conflictCounter = 1:max(accuracy.summary.subject)
    cond1 = accuracy.summary.subject(:) == conflictCounter;
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