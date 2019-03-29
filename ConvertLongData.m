plotData = squeeze(mean(summary.raw(53,:,:,3,:),5)) - squeeze(mean(summary.raw(53,:,:,1,:),5));
sigData = squeeze(summary.ttest(53,:,:));
tempData = sigData;
sigData(tempData <= 0.05) = 0.5;
sigData(tempData > 0.05) = 0;
x = [];
y = [];
z = [];
sig = [];
tempTime = linspace(-1996,0,500)';

for freqCounter = 1:59
    x = vertcat(x,tempTime);
    tempFreq = ones(500,1) * freqCounter;
    y = vertcat(y,tempFreq);
    tempData = plotData(freqCounter,:)';
    z = vertcat(z,tempData);
    tempSig = sigData(freqCounter,:)';
    sig = vertcat(sig,tempSig);
end

exData = horzcat(x,y,z,sig);

csvwrite('C:\Users\Jordan\Documents\R\MedEd-R\Data\WAV Data\PD.txt',exData);