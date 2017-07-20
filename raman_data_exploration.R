# detach("package:MALDIquant", unload=TRUE)
library(ChemoSpec)
bac_strains <- files2SpectraObject(gr.crit = c("After_EC", "After_Scan", "During_Scan", "After_EC"), gr.cols = c("auto"), freq.unit = "ppm", int.unit="Peak Intensity", descrip = "Strains", out.file = "strains")
ChemoSpec::plotSpectra(bac_strains, main = "Strains", which =c(55:77), yrange = range(bac_strains$data), offset = 0 )
hcaSpectra(bac_strains)
raman_pca <- c_pcaSpectra(bac_strains, choice = "noscale")
plotScores(bac_strains, main ="Test", raman_pca, ellipse = "rob")

