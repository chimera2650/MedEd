freq = linspace(1,30,59)';
ttime = linspace(0,1996,500)';
dtime = linspace(-1996,0,500)';

ftTempPCA = squeeze(PCA.template.timePlot(1,:,:));
FTTvar = round(squeeze(PCA.template.timeVAR(1,:)),2);
FTT = horzcat(ttime,ftTempPCA);
clearvars ftTempPCA;

ptTempPCA = squeeze(PCA.template.timePlot(2,:,:));
PTTvar = round(squeeze(PCA.template.timeVAR(2,:)),2);
PTT = horzcat(ttime,ptTempPCA);
clearvars ptTempPCA;

fdTempPCA = squeeze(PCA.decision.timePlot(1,:,:));
FDTvar = round(squeeze(PCA.decision.timeVAR(1,:)),2);
FDT = horzcat(dtime,fdTempPCA);
clearvars fdTempPCA;

pdTempPCA = squeeze(PCA.decision.timePlot(2,:,:));
PDTvar = round(squeeze(PCA.decision.timeVAR(2,:)),2);
PDT = horzcat(dtime,pdTempPCA);
clearvars pdTempPCA;

ftFreqPCA = squeeze(PCA.template.freqPlot(1,:,:));
FTFvar = round(squeeze(PCA.template.freqVAR(1,:)),2);
FTF = horzcat(freq,ftFreqPCA);
clearvars ftFreqPCA;

ptFreqPCA = squeeze(PCA.template.freqPlot(2,:,:));
PTFvar = round(squeeze(PCA.template.freqVAR(2,:)),2);
PTF = horzcat(freq,ptFreqPCA);
clearvars ptFreqPCA;

fdFreqPCA = squeeze(PCA.decision.freqPlot(1,:,:));
FDFvar = round(squeeze(PCA.decision.freqVAR(1,:)),2);
FDF = horzcat(freq,fdFreqPCA);
clearvars fdFreqPCA;

pdFreqPCA = squeeze(PCA.decision.freqPlot(2,:,:));
PDFvar = round(squeeze(PCA.decision.freqVAR(2,:)),2);
PDF = horzcat(freq,pdFreqPCA);
clearvars pdFreqPCA;

cd('C:\Users\Jordan\Documents\R\MedEd-R\Data\PCA Data');

csvwrite('FDF.txt',FDF);
csvwrite('FDT.txt',FDT);
csvwrite('FTF.txt',FTF);
csvwrite('FTT.txt',FTT);
csvwrite('PDF.txt',PDF);
csvwrite('PDT.txt',PDT);
csvwrite('PTF.txt',PTF);
csvwrite('PTT.txt',PTT);

csvwrite('FDFvar.txt',FDFvar);
csvwrite('FDTvar.txt',FDTvar);
csvwrite('FTFvar.txt',FTFvar);
csvwrite('FTTvar.txt',FTTvar);
csvwrite('PDFvar.txt',PDFvar);
csvwrite('PDTvar.txt',PDTvar);
csvwrite('PTFvar.txt',PTFvar);
csvwrite('PTTvar.txt',PTTvar);