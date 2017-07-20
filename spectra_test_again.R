library(ChemoSpec)
library(R.utils)
setwd("~mario/Research/Collaborations/NickyHendricks/2017/ChemoSpec_runs/20-7-16TxT_H2-TE1-WT-BCG_CORRECTED/20_7_16/")
files2SpectraObject(gr.crit = c("Dry", "After_Scan", "No_Cncnt_Yet", "During_Scan", "OCP"), gr.cols = c("red3", "dodgerblue4", "black", "purple", "green"),
                    freq.unit = "ppm", int.unit = "peak intensity", descrip = "Raman Spectra",
                    out.file = "ramanspec")
#files2SpectraObject(gr.crit = c("MedLow", "Medium"), gr.cols = c("red3", "dodgerblue4"),
#                    freq.unit = "ppm", int.unit = "peak intensity", descrip = "Raman Spectra",
#                    out.file = "ramanspec")

#files2SpectraObject(gr.crit = c("150mV","200mV","230mV","260mV","300mV","500mV","520mV","550mV","570mV","600mV","620mV","650mV","670mV","700mV","720mV"),
#                    freq.unit = "ppm", int.unit = "peak intensity", descrip = "Raman Spectra",
#                    out.file = "ramanspec")



testsamples <- loadObject("ramanspec.RData")
sumSpectra(testsamples)
plotSpectra(testsamples, which = c(1:42), xlim =c(200,350))
baseline_corrected <- baselineSpectra(testsamples, int = FALSE, method = "rfbaseline", retC = TRUE)
plotSpectra(baseline_corrected, which = c(1:52), xlim =c(200,350))
hca <- hcaSpectra(baseline_corrected)
pcaclass_m <- r_pcaSpectra(baseline_corrected, choice = "noscale")
