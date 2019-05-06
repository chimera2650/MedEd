% Copyright (C) 2019 Jordan Middleton

function ciData = ciBehavioural(dataFile)
subjectData = dataFile;
subjectCount = size(unique(subjectData.subject),1);
conflictCount = max(subjectData.conflict);
anovaData = linspace(1,subjectCount,subjectCount)';

% Repeated Measures ANOVA
for conflictCounter = 1:conflictCount
    conditionAnova = subjectData.conflict == conflictCounter;
    tempData = subjectData.mean(conditionAnova);
    anovaData = [anovaData tempData];
end

anovaData = array2table(anovaData,'VariableNames',{'subject','meas1','meas2','meas3'});
measures = table([1 2 3]','VariableNames',{'Measurements'});
repeatedMeasures = fitrm(anovaData,'meas1-meas3~subject','WithinDesign',measures);
anovaOutput = ranova(repeatedMeasures);

% Within Confidence Intervals
ciTemp = [];

for subjectCounter = 1:subjectCount
    conditionSubject = subjectData.subject(:) == subjectCounter;
    anovaData = subjectData.mean(conditionSubject);
    tempData = mean(anovaData);
    ciTemp(end+1,:) = tempData;
end

conditionNan = isnan(ciTemp(:,1));
ciTemp(conditionNan,:) = [];
ciWithin(1,1) = mean(ciTemp);
ciWithin(1,2) = std(ciTemp);
ciWithin(1,3) = length(ciTemp);
ciWithin(1,4) = ciWithin(1,2)/sqrt(ciWithin(1,3)-1);
ciWithin(1,5) = anovaOutput.MeanSq(2);
tStat = tinv(0.95,ciWithin(1,3)-1);
ciWithin(1,6) = sqrt(ciWithin(1,5)/ciWithin(1,3))*(tStat);

ciData = ciWithin;
end