close all;

PCA_data = squeeze(summary.raw(53,:,:,[1,3],:));
time = summary.time;
freq = summary.freq;
pcaCounter = 1;

for subjectCounter = 1:30
    for conditionCounter = 1:2
        for timeCounter = 1:59
            temporalPCAData(pcaCounter,1:500) = PCA_data(timeCounter,:,conditionCounter,subjectCounter);
            pcaCounter = pcaCounter + 1;
        end
    end
end

[PCAResults1] = temporalPCA(temporalPCAData,time,'VMAX',5);
pcaCounter = 1;

for subjectCounter = 1:30
    for conditionCounter = 1:2
        for timeCounter = 1:500
            frequencyPCAData(pcaCounter,1:59) = PCA_data(:,timeCounter,conditionCounter,subjectCounter);
            pcaCounter = pcaCounter + 1;
        end
    end
end

[PCAResults2] = temporalPCA(frequencyPCAData,freq,'VMAX',5);

PCA.decision.timePlot(2,:,:) = PCAResults1.FacPat;
PCA.decision.timeVAR(2,:) = PCAResults1.facVar * 100;
PCA.decision.freqPlot(2,:,:) = PCAResults2.FacPat;
PCA.decision.freqVAR(2,:) = PCAResults2.facVar * 100;
PCA.time = time;
PCA.freq = freq;

save('med_ed_pca.mat','PCA');