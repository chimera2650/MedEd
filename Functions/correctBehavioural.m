% Copyright (C) 2019 Jordan Middleton

% This function just corrects for a data labelling oversight when
% programming the experiment. The conflict scores were not labelled
% intuitively, so this function reorders them.

function subjectData = correctBehavioural(dataFile)
tempData = dataFile;
trialCount = size(tempData,1);

for trialCounter = 1:trialCount
    if tempData.conflict(trialCounter) == 1
        tempData.conflict(trialCounter) = 7;
    elseif tempData.conflict(trialCounter) == 2
        tempData.conflict(trialCounter) = 8;
    elseif tempData.conflict(trialCounter) == 0
        tempData.conflict(trialCounter) = 1;
    elseif tempData.conflict(trialCounter) == 4
        tempData.conflict(trialCounter) = 2;
    end
end

conditionRemove = tempData.conflict == 7;
tempData(conditionRemove,:) = [];
conditionRemove = tempData.conflict == 8;
tempData(conditionRemove,:) = [];

subjectData = tempData;
end
