# Load Libraries
{
  library(RcolourBrewer)
  library(ggplot2)
  library(dplyr)
  library(reshape2)
  library(cowplot)
}

# Functions
{
  loadWAV <- function(dataFile) {
    output = read.csv(dataFile, header = FALSE)
    colnames(output) = c("x", "y", "z", "sig")
    return(output)
  }
  plotWAV <- function(dataFile, index) {
    if (index == "template") {
      linxlim = range(0, 2000)
    } else if (index == "decision") {
      linxlim = range(-2000, 0)
    }
    
    output <- ggplot(dataFile, aes(x, y)) +
      geom_raster(aes(fill = z),
                  interpolate = TRUE) +
      coord_cartesian(xlim = linxlim,
                      ylim = c(1, 30)) +
      scale_fill_gradientn(
        colours = c("#FF0000FF", "#FFFFFFFF", "#0000FFFF"),
        limits = c(-0.535, 0.535),
        breaks = c(-0.5, -0.25, 0, 0.25, 0.5),
        guide = guide_colourbar(
          title = NULL,
          position = "right",
          direction = "vertical",
          label.position = "right",
          barheight = unit(1, "npc"),
          ticks.colour = "black",
          ticks.linewidth = 2
        )
      ) +
      scale_x_continuous(expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      labs(x = "Time (ms)",
           y = "Frequency (Hz)",
           z = "Power (dB)") +
      theme_bw() +
      theme(
        plot.margin = unit(c(0.75, 1, 0.75, 0.75), "cm"),
        legend.position = "none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank(),
        axis.text = element_text(size = 24),
        axis.title = element_text(size = 28,
                                  face = "bold")
        
      )
    
    output = last_plot() +
      stat_contour(
        data = dataFile,
        aes(x = x,
            y = y,
            z = sig),
        colour = "black",
        size = 1,
        bins = 1,
        show.legend = FALSE
      )
    
    return(output)
  }
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
    tempVar = tempVar[1:9, ]
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
                    size = 1.5) +
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
        size = 6
      ) +
      coord_cartesian(ylim = c(-0.5, 1.5)) +
      scale_x_continuous(breaks = xRange,
                         expand = c(0, 0)) +
      theme_bw() +
      theme(
        plot.margin = unit(c(0.75, 1, 0.75, 0.75), "cm"),
        legend.position = "none",
        axis.line.x = element_line(colour = "black", size = 1),
        axis.line.y = element_line(colour = "black", size = 1),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = 24),
        axis.title = element_text(size = 28,
                                  face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank()
      )
    return(output)
  }
}

# Load Variables
{
  colourCount = 10
  getPalette <- colorRampPalette(brewer.pal(n = 8,
                                            name = "BuPu"))
}

# Load Data tables
{
  dataFT = loadWAV("./Data/WAV Data/FT.txt")
  dataPT = loadWAV("./Data/WAV Data/PT.txt")
  dataFD = loadWAV("./Data/WAV Data/FD.txt")
  dataPD = loadWAV("./Data/WAV Data/PD.txt")
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
  plotFTwav = plotWAV(dataFT, "template")
  plotPTwav = plotWAV(dataPT, "template")
  plotFDwav = plotWAV(dataFD, "decision")
  plotPDwav = plotWAV(dataPD, "decision")
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
  plotFTpca = plot_grid(plotFTT,
                        plotFTF,
                        ncol = 1,
                        nrow = 2)
  
  plotFT = plot_grid(
    plotFTwav,
    plotFTpca,
    ncol = 2,
    nrow = 1,
    labels = c("Fz", ""),
    label_x = 0,
    label_y = 0.975,
    label_size = 28
  )
  
  plotFDpca = plot_grid(plotFDT,
                        plotFDF,
                        ncol = 1,
                        nrow = 2)
  
  
  plotFD = plot_grid(
    plotFDwav,
    plotFDpca,
    ncol = 2,
    nrow = 1,
    labels = c("Fz", ""),
    label_x = 0,
    label_y = 0.975,
    label_size = 28
  )
  
  plotPTpca = plot_grid(plotPTT,
                        plotPTF,
                        ncol = 1,
                        nrow = 2)
  
  plotPT = plot_grid(
    plotPTpca,
    plotPTwav,
    ncol = 2,
    nrow = 1,
    labels = c("", "Pz"),
    label_x = 0,
    label_y = 0.975,
    label_size = 28
  )
  
  plotPDpca = plot_grid(plotPDT,
                        plotPDF,
                        ncol = 1,
                        nrow = 2)
  
  plotPD = plot_grid(
    plotPDpca,
    plotPDwav,
    ncol = 2,
    nrow = 1,
    labels = c("", "Pz"),
    label_x = 0,
    label_y = 0.975,
    label_size = 28
  )
  
  plotCom = plot_grid(plotFT,
                      plotPT,
                      plotFD,
                      plotPD,
                      nrow = 2,
                      ncol = 2) +
    draw_line(
      x = c(0, 1),
      y = c(0.5, 0.5),
      size = 2,
      colour = "black",
      linetype = 2
    ) +
    draw_line(
      x = c(0.505, 0.505),
      y = c(0, 1),
      size = 2,
      colour = "black",
      linetype = 2
    )
  
  plotLegend = get_legend(plotFTwav +
                            theme(
                              legend.position = "right",
                              legend.text = element_text(size = 24)
                            ))
  
  plotSum = plot_grid(
    plotCom,
    plotLegend,
    ncol = 2,
    rel_widths = c(1, 0.04),
    rel_heights = c(1, 1)
  )
}

# Save plot
{
  ggsave(
    "./Plots/Summary_plot.png",
    width = 34,
    height = 10.5,
    units = "in",
    dpi = 300
  )
}