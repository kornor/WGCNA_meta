
# Script for exploring the relationship of the modules to each other ******************


### Pearson correlations of modules to modules, in order to determine concurrent
### gene programs that may be operating within/between a BC subtype.

### Multidimensional scaling of the modules created, in order to explore
### the interactions between them


setwd("~/Bioinformatics Work/Meth & RNA/Meta-analysis WGCNA")

library(WGCNA)
library(plyr)
library(flashClust)
library(ggplot2)
library(gplots)
library(lattice)
library(extrafont)
loadfonts()
##############


load(file = "MetaAnalysis_trimmed_input.RData")
load(file = "Modules_DS0.RData")
colorsA1 = names(table(modules1))

### add in the rownames for the ME_ data frames

rownames(ME_1A) <- colnames(datExpr1)
rownames(ME_2A) <- colnames(datExpr2)


#### try matching the modules to themselves - 

nGenes = ncol(ME_1A);
nSamples = nrow(ME_1A);
# Recalculate MEs with color labels
#MEs0 = moduleEigengenes(datExpr, moduleColors)$eigengenes
#MEs = orderMEs(MEs0)

moduleTraitCor = cor(ME_1A, ME_1A, use = "p");
moduleTraitPvalue = corPvalueStudent(moduleTraitCor, nSamples);

write.table(moduleTraitCor, "Module_module_cor_TCGA.txt", sep = "\t")
write.table(moduleTraitPvalue, "Module_module_pValue_TCGA.txt", sep = "\t")


sizeGrWindow(10,6)
# Will display correlations and their p-values
textMatrix = paste(signif(moduleTraitCor, 2), "\n(",
                   signif(moduleTraitPvalue, 1), ")", sep = "");

##########Will only display correlations
textMatrix = paste(signif(moduleTraitCor, 2),sep = "");
dim(textMatrix) = dim(moduleTraitCor)

par(mar = c(6, 8.5, 3, 3));

# Display the values within a heatmap plot
labeledHeatmap(Matrix = moduleTraitCor,
               xLabels = names(ME_1A),
               yLabels = names(ME_1A),
               ySymbols = names(ME_1A),
               colorLabels = FALSE,
               colors = blueWhiteRed(50),
               #textMatrix = textMatrix,
               setStdMargins = FALSE,
               cex.text = 0.85,
               zlim = c(-1,1),
               main = paste("Module V Module (TCGA)"))




nGenes = ncol(ME_2A);
nSamples = nrow(ME_2A);

moduleTraitCor = cor(ME_2A, ME_2A, use = "p");
moduleTraitPvalue = corPvalueStudent(moduleTraitCor, nSamples);      
write.table(moduleTraitCor, "Module_module_cor_METABRIC.txt", sep = "\t")
write.table(moduleTraitPvalue, "Module_module_pValue_METABRIC.txt", sep = "\t")

moduleTraitCor <- read.table( "Module_module_cor_METABRIC.txt", sep = "\t", header = TRUE, row.names = 1)

par(mar = c(6, 8.5, 3, 3));

# Display the values within a heatmap plot
labeledHeatmap(Matrix = moduleTraitCor,
               xLabels = names(ME_2A),
               yLabels = names(ME_2A),
               ySymbols = names(ME_2A),
               colorLabels = FALSE,
               colors = blueWhiteRed(50),
               #textMatrix = textMatrix,
               setStdMargins = FALSE,
               cex.text = 0.85,
               zlim = c(-1,1),
               main = paste("Module V Module (META)"))


############

## order the MEs
MET1 <- orderMEs(ME_1A)
MET2 <- orderMEs(ME_2A) 
# Plot the dendrogram
sizeGrWindow(6,6);
par(cex = 1.0)
plotEigengeneNetworks(MET, "Eigengene dendrogram", marDendro = c(0,4,2,0),
                      plotHeatmaps = FALSE)
# Plot the heatmap matrix (note: this plot will overwrite the dendrogram plot)

## install nice fonts

library(extrafont)
font_import()
loadfonts()
pdf("Module_Module.pdf",height=8,width=8, family = "Gill Sans MT")

par(oma = c(1,1,1,1))
plotEigengeneNetworks(MET1, marHeatmap = c(3,4,2,2), setLabels = NULL,
                      plotDendrograms = FALSE, xLabelsAngle = 90)
mtext("Eigengene adjacency heatmap for TCGA", side = 3, line = 0.5, cex = 2)

plotEigengeneNetworks(MET2, setLabels = NULL, marHeatmap = c(3,4,2,2),
                      plotDendrograms = FALSE, xLabelsAngle = 90)
mtext("Eigengene adjacency heatmap for METABRIC", side = 3, line = 0.5, cex = 2)

dev.off()

##### alternate way to visualise this
# Calculate topological overlap anew: this could be done more efficiently by saving the TOM
# calculated during module detection, but let us do it again here.
dissTOM = 1-TOMsimilarityFromExpr(datExpr1, power = 20);
# Transform dissTOM with a power to make moderately strong connections more visible in the heatmap
plotTOM = dissTOM^7;
# Set diagonal to NA for a nicer plot
diag(plotTOM) = NA;
# Call the plot function
sizeGrWindow(9,9)
TOMplot(plotTOM, geneTree, modules1, main = "Network heatmap plot, all genes")




##### Multidimensional scaling (MDS) and plotting #################################


PCs1A    = moduleEigengenes(t(datExpr1),  colors=modules1) 
ME_1A    = PCs1A$eigengenes
distPC1A = 1-abs(cor(ME_1A,use="p"))
distPC1A = ifelse(is.na(distPC1A), 0, distPC1A)
pcTree1A = hclust(as.dist(distPC1A),method="a") 
MDS_1A   = cmdscale(as.dist(distPC1A),2)
colorsA1 = names(table(modules1))

par()
plot(MDS_1A, col= colorsA1,  main="MDS plot", cex=2, pch=19,
     xlab = "Principal component 1", ylab = "Principal component 2")


#### for METAbric
distPC2A = 1-abs(cor(ME_2A,use="p"))
distPC2A = ifelse(is.na(distPC2A), 0, distPC2A)
pcTree2A = hclust(as.dist(distPC2A),method="a") 
MDS_2A   = cmdscale(as.dist(distPC2A),2)

par(oma = c(1,1,1,3))
plot(MDS_1A, col= colorsA1,  main="MDS plot", cex=2, pch=19, 
     xlab = "Principal component 1", ylab = "Principal component 2")
par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), 
    mar = c(0, 0, 0, 0), new = TRUE)
#plot(MDS_2A, col= colorsA1,  main="MDS plot", cex=2, pch=19, 
 #    xlab = "Principal component 1", ylab = "Principal component 2")
legend('topright', col=colorsA1, legend=colorsA1, 
       pch = 16, cex = 0.7, xpd = TRUE)
