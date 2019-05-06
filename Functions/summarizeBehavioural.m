% Copyright (C) 2019 Jordan Middleton

function outputData = summarizeBehavioural(dataFile,condition,window)
behaviouralData = dataFile;
subjectCount = max(behaviouralData.subject);
conflictCount = max(behaviouralData.conflict);
tempData = [];

for subjectCounter = 1:subjectCount
    conditionSubject = behaviouralData.subject == subjectCounter;
    subjectData = behaviouralData(conditionSubject,:);
    
    for conflictCounter = 1:conflictCount
        conditionConflict = subjectData.conflict == conflictCounter;
        conflictData = subjectData(conditionConflict,:);
        subject(conflictCounter,1) = subjectCounter;
        conflict(conflictCounter,1) = conflictCounter;
        mean(conflictCounter,1) = nanmean(conflictData.(condition));
        stdev(conflictCounter,1) = nanstd(conflictData.(condition));
        count(conflictCounter,1) = length(conflictData.(condition));
    end
    
    tempData = table(subject,conflict,mean,stdev,count);
    
%     if strcmp(window,'feedback') == 1
%         subject = subjectCounter;
%         mean = nanmean(subjectData.(condition));
%         stdev = nanstd(subjectData.(condition));
%         count = length(subjectData.(condition));
%         
%         tempData = table(subject,mean,stdev,count);
%     elseif strcmp(window,'conflict') == 1
%         for conflictCounter = 1:conflictCount
%             conditionConflict = subjectData.conflict == conflictCounter;
%             conflictData = subjectData(conditionConflict,:);
%             subject(conflictCounter,1) = subjectCounter;
%             conflict(conflictCounter,1) = conflictCounter;
%             mean(conflictCounter,1) = nanmean(conflictData.(condition));
%             stdev(conflictCounter,1) = nanstd(conflictData.(condition));
%             count(conflictCounter,1) = length(conflictData.(condition));
%         end
%         
%         tempData = table(subject,conflict,mean,stdev,count);
%     end
    
    if subjectCounter == 1
        summaryData = tempData;
    else
        summaryData = vertcat(summaryData,tempData);
    end
end

conditionNan = isnan(summaryData.mean);
summaryData(conditionNan,:) = [];
summaryData.error = (summaryData.stdev./sqrt(summaryData.count));
tStat = tinv(0.95,(summaryData.count)-1);
summaryData.ci = summaryData.mean+(tStat.*summaryData.error);

% if strcmp(window,'conflict') == 1
%     conditionRemove = summaryData.conflict == 2;
%     summaryData(conditionRemove,:) = [];
%     conditionCorrection = summaryData.conflict == 3;
%     summaryData.conflict(conditionCorrection) = 2;
% end

outputData = summaryData;
end
