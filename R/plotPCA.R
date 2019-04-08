# Load libraries
{
  library(ggplot2)
  library(reshape2)
  library(dplyr)
  library(RColorBrewer)
  library(cowplot)
}

# Define variables
{
  colourCount = 10
  getPalette <- colorRampPalette(brewer.pal(n = 8,
                                            name = "Blues"))
}

# Functions
{
  loadData <- function(dataFile, varFile, dataIndex) {
    tempData = read.csv(dataFile,
                        header = FALSE)
    colnames(tempData) = c(dataIndex,
                           "v1",
                           "v2",
                           "v3",
                           "v4",
                           "v5",
                           "v6",
                           "v7",
                           "v8",
                           "v9",
                           "v10")
    tempData = tempData[, c(dataIndex,
                            "v1",
                            "v2",
                            "v3",
                            "v4",
                            "v5",
                            "v6",
                            "v7",
                            "v8",
                            "v9",
                            "v10")]
    tempData = melt(
      tempData,
      id = dataIndex,
      measured = c("v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10")
    )
    label = read.csv(varFile,
                     header = FALSE)
    label = t(label)
    rownames(label) = c()
    x = tempData %>%
      group_by(variable) %>%
      slice(which.max(value)) %>%
      ungroup() %>%
      select(dataIndex)
    tempVar = cbind(x, label)
    colnames(tempVar) = c("x", "label")
    output = list(data = tempData, var = tempVar)
    return(output)
  }
  plotPCA <- function(plotData, varData, window) {
    if (window == "template") {
      xRange = seq(0, 2000, 500)
      index = "time"
    } else if (window == "decision") {
      xRange = seq(-2000, 0, 500)
      index = "time"
    } else if (window == "frequency") {
      xRange = seq(0, 30, 5)
      index = "freq"
    }
    
    tempLabels = varData
    tempData = plotData
    
    output = ggplot(data = tempData,
                    aes_string(x = index,
                               y = "value")) +
      geom_freqpoly(aes(colour = variable,
                        group = rev(variable)),
                    stat = "identity",
                    size = 1) +
      scale_colour_manual(values = rev(getPalette(colourCount))) +
      geom_text(
        data = tempLabels,
        aes(
          label = label,
          y = 1.25,
          x = x,
          angle = 40
        ),
        colour = "black",
        size = 2.5
      ) +
      coord_cartesian(ylim = c(-0.5, 1.5)) +
      scale_x_continuous(breaks = xRange,
                         expand = c(0, 0)) +
      theme_bw() +
      theme(
        plot.margin = unit(c(.5, .5, .5, .5), "cm"),
        legend.position = "none",
        axis.line.x = element_line(color = "black", size = 0.5),
        axis.line.y = element_line(color = "black", size = 0.5),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank()
      )
    return(output)
  }
}

# Load data
{
  frequency = list(
    FTF = loadData(
      "./Data/PCA Data/FTF.txt",
      "./Data/PCA Data/FTFvar.txt",
      "freq"
    ),
    FDF = loadData(
      "./Data/PCA Data/FDF.txt",
      "./Data/PCA Data/FDFvar.txt",
      "freq"
    ),
    PTF = loadData(
      "./Data/PCA Data/PTF.txt",
      "./Data/PCA Data/PTFvar.txt",
      "freq"
    ),
    PDF = loadData(
      "./Data/PCA Data/PDF.txt",
      "./Data/PCA Data/PDFvar.txt",
      "freq"
    )
  )
  
  temporal = list(
    FTT = loadData(
      "./Data/PCA Data/FTT.txt",
      "./Data/PCA Data/FTTvar.txt",
      "time"
    ),
    FDT = loadData(
      "./Data/PCA Data/FDT.txt",
      "./Data/PCA Data/FDTvar.txt",
      "time"
    ),
    PTT = loadData(
      "./Data/PCA Data/PTT.txt",
      "./Data/PCA Data/PTTvar.txt",
      "time"
    ),
    PDT = loadData(
      "./Data/PCA Data/PDT.txt",
      "./Data/PCA Data/PDTvar.txt",
      "time"
    )
  )
  
  freq = seq(1, 30, 59)
  ttime = seq(0, 1996, 500)
  dtime = seq(-1996, 0, 500)
}

# Generate plots
{
  plotFDT <-
    plotPCA(temporal[["FDT"]][["data"]], temporal[["FDT"]][["var"]], "decision")
  plotFTT <-
    plotPCA(temporal[["FTT"]][["data"]], temporal[["FTT"]][["var"]], "template")
  plotPDT <-
    plotPCA(temporal[["PDT"]][["data"]], temporal[["PDT"]][["var"]], "decision")
  plotPTT <-
    plotPCA(temporal[["PTT"]][["data"]], temporal[["PTT"]][["var"]], "template")
  plotFDF <-
    plotPCA(frequency[["FDF"]][["data"]], frequency[["FDF"]][["var"]], "frequency")
  plotFTF <-
    plotPCA(frequency[["FTF"]][["data"]], frequency[["FTF"]][["var"]], "frequency")
  plotPDF <-
    plotPCA(frequency[["PDF"]][["data"]], frequency[["PDF"]][["var"]], "frequency")
  plotPTF <-
    plotPCA(frequency[["PTF"]][["data"]], frequency[["PTF"]][["var"]], "frequency")
}

# Combine plots
{
  plotTemp = plot_grid(
    plotFTT,
    plotPTT,
    plotFDT,
    plotPDT,
    labels = c("Fz", "Pz", "Fz", "Pz"),
    label_size = 12,
    hjust = -0.15,
    vjust = 2,
    nrow = 4,
    align = "v"
  ) +
    draw_label(
      "Temporal PCA",
      x = 0.5,
      y = 0.9975,
      hjust = 0.5,
      vjust = 1,
      size = 12,
      colour = "black",
      fontface = "bold"
    ) +
    draw_label(
      "Time (ms)",
      x = 0.5,
      y = 0.01,
      hjust = 0.5,
      vjust = 0,
      size = 10,
      colour = "black"
    )
  
  plotFreq = plot_grid(
    plotFTF,
    plotPTF,
    plotFDF,
    plotPDF,
    labels = c("Fz", "Pz", "Fz", "Pz"),
    label_size = 12,
    hjust = -0.15,
    vjust = 2,
    ncol = 1,
    nrow = 4,
    align = "v"
  ) +
    draw_label(
      "Frequency PCA",
      x = 0.5,
      y = 0.9975,
      hjust = 0.5,
      vjust = 1,
      size = 12,
      colour = "black",
      fontface = "bold"
    ) +
    draw_label(
      "Frequency (Hz)",
      x = 0.5,
      y = 0.01,
      hjust = 0.5,
      vjust = 0,
      size = 10,
      colour = "black"
    )
  
  plotSum = plot_grid(plotTemp,
                      plotFreq,
                      ncol = 2,
                      align = "h") +
    draw_line(x = c(0,1),
              y = c(0.515,0.515),
              size = 1,
              colour = "black",
              linetype = 2)
  
  plotSum
}

# Save plot
{
  ggsave(
    "./Plots/PCA_plot.png",
    width = 8,
    height = 8,
    units = "in",
    dpi = 600
  )
}
