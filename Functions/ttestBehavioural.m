% Copyright (C) 2019 Jordan Middleton

function tScore = ttestBehavioural(dataFile)
subjectData = dataFile;
subjectCount = size(unique(subjectData.subject),1);
conflictCount = max(subjectData.conflict);

% Significance testing
for conflictCounter = 1:conflictCount
    conditionConflict = subjectData.conflict == conflictCounter;
    tempData = subjectData.mean(conditionConflict,:);
    significanceData(:,conflictCounter) = tempData;
end

significanceData = array2table(significanceData,'VariableNames',{'feedback','noConflict','highConflict'});
[h,p] = ttest(significanceData.noConflict,significanceData.highConflict);
tScore = p;
end