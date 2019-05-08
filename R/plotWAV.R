# Copyright (C) 2019 Jordan Middleton

# Load Libraries
{
  library(RColorBrewer)
  library(ggplot2)
  library(dplyr)
  library(reshape2)
  library(cowplot)
}

# Functions
{
  loadWAV <- function(dataName, sigName, frequencyData, timeData) {
    dataFile = read.csv(dataName,
                        header = FALSE)
    dataFile = as.matrix(dataFile)
    rownames(dataFile) = frequencyData
    colnames(dataFile) = timeData
    names(attributes(dataFile)$dimnames) <- c("frequency",
                                              "time")
    dataFile = melt(dataFile,
                    id = c("frequency",
                           "time"))
    dataFile = dataFile[c("time", "frequency", "value")]
    colnames(dataFile) = c("x", "y", "z")
    sigFile = read.csv(sigName,
                       header = FALSE)
    sigFile = as.matrix(sigFile)
    rownames(sigFile) = frequencyData
    colnames(sigFile) = timeData
    names(attributes(sigFile)$dimnames) <- c("frequency",
                                             "time")
    sigFile = melt(sigFile,
                   id = c("frequency",
                          "time"))
    sigFile = sigFile[c("time", "frequency", "value")]
    colnames(sigFile) = c("x", "y", "sig")
    sigFile = sigFile[c("sig")]
    output = cbind(dataFile,
                   sigFile)
    return(output)
  }
  plotWAV <- function(dataFile, channel, index) {
    if (index == "stimulus") {
      xLimits = c(0, 2000)
    } else if (index == "response") {
      xLimits = c(-2000, 0)
    }
    
    output <- ggplot(dataFile,
                     aes(x, y)) +
      geom_raster(aes(fill = z),
                  interpolate = TRUE) +
      coord_cartesian(xlim = xLimits,
                      ylim = c(1, 30)) +
      scale_fill_gradientn(colors = c("#FF0000FF",
                                      "#FFFFFFFF",
                                      "#0000FFFF"),
                           limits = c(-0.55, 0.55),
                           breaks = c(-0.5,-0.25, 0, 0.25, 0.5),
                           guide = guide_colourbar(title = "Power (dB)",
                                                   position = "right",
                                                   direction = "vertical",
                                                   label.position = "right",
                                                   barheight = unit(0.5,
                                                                    "npc"))) +
      scale_x_continuous(expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      labs(x = "Time (ms)",
           y = "Frequency (Hz)",
           z = "Power (dB)") +
      theme_bw() +
      theme(plot.margin = unit(c(0.25, 0.25, 0.25, 0.5),
                               "cm"),
            axis.line.x = element_line(color = "black",
                                       size = 0.5),
            axis.line.y = element_line(color = "black",
                                       size = 0.5),
            axis.text = element_text(color = "black",
                                     size = 10),
            axis.text.x = element_text(angle = 30,
                                       vjust = 1,
                                       hjust = 1),
            axis.title = element_text(color = "black",
                                      size = 12,
                                      face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank(),
        legend.position = "none")
    
    if (index == "stimulus") {
      output = last_plot() +
        theme(axis.title.x = element_blank(),
              axis.line.x = element_line(color = "black",
                                         size = 0.5),
              axis.line.y = element_line(color = "black",
                                         size = 0.5))
    }
    
    if (channel == "Pz") {
      output = last_plot() +
        theme(plot.margin = unit(c(0.25, 0.25, 0.25, 1),
                                 "cm"),
              axis.title.y = element_blank(),
              axis.line.x = element_line(color = "black",
                                         size = 0.5),
              axis.line.y = element_line(color = "black",
                                         size = 0.5))
    }
    
    output = last_plot() +
      stat_contour(data = dataFile,
                   aes(x = x,
                       y = y,
                       z = sig),
                   colour = "black",
                   size = 1,
                   bins = 1,
                   show.legend = FALSE)
    
    return(output)
  }
}

# Load Data
{
  frequency = seq(1, 30, 0.5)
  stimulusTime = seq(0, 1996, 4)
  responseTime = seq(-1996, 0, 4)
  color = rev(brewer.pal(8, "RdBu"))
  stimulusFzFile = loadWAV("../../Data/MedEd/R/WAV Data/stimulusFz.csv",
                           "../../Data/MedEd/R/WAV Data/stimulusSigFz.csv",
                           frequency,
                           stimulusTime)
  stimulusPzFile = loadWAV("../../Data/MedEd/R/WAV Data/stimulusPz.csv",
                           "../../Data/MedEd/R/WAV Data/stimulusSigPz.csv",
                           frequency,
                           stimulusTime)
  responseFzFile = loadWAV("../../Data/MedEd/R/WAV Data/responseFz.csv",
                           "../../Data/MedEd/R/WAV Data/responseSigFz.csv",
                           frequency,
                           responseTime)
  responsePzFile = loadWAV("../../Data/MedEd/R/WAV Data/responsePz.csv",
                           "../../Data/MedEd/R/WAV Data/responseSigPz.csv",
                           frequency,
                           responseTime)
}

# Generate plots
{
  stimulusFzPlot = plotWAV(stimulusFzFile,
                           "Fz",
                           "stimulus")
  stimulusPzPlot = plotWAV(stimulusPzFile,
                           "Pz",
                           "stimulus")
  responseFzPlot = plotWAV(responseFzFile,
                           "Fz",
                           "response")
  responsePzPlot = plotWAV(responsePzFile,
                           "Pz",
                           "response")
}

# Combine plots
{
  stimulusPlot = plot_grid(stimulusFzPlot,
                           stimulusPzPlot,
                           nrow = 1,
                           ncol = 2,
                           labels = c("Fz", "Pz"),
                           label_size = 14)
  responsePlot = plot_grid(responseFzPlot,
                           responsePzPlot,
                           nrow = 1,
                           ncol = 2,
                           labels = c("Fz", "Pz"),
                           label_size = 14)
  wavPlot = plot_grid(stimulusPlot,
                      responsePlot,
                      nrow = 2,
                      ncol = 1,
                      rel_heights = c(1, 1.15)) +
    draw_line(x = c(0, 1),
              y = c(0.55, 0.55),
              size = 1,
              colour = "black",
              linetype = 2) +
    draw_line(x = c(0.505, 0.505),
              y = c(0, 1),
              size = 1,
              colour = "black",
              linetype = 2)
  plotLegend = get_legend(stimulusFzPlot +
                            theme(legend.position = "right",
                                  legend.text = element_text(size = 8),
                                  legend.title = element_text(face = "bold",
                                                              size = 10,
                                                              hjust = 0.5)))
  plotSum = plot_grid(wavPlot,
                      plotLegend,
                      ncol = 2,
                      rel_widths = c(1, 0.175),
                      rel_heights = c(1, 1))
}

# Save Plot - Here, we can save the plot as an image. This will save the current plot in your R plot tab.
# Output name was determined at the top of the script
{
  ggsave(filename = "../../Data/MedEd/Plots/plotWAV.jpeg",
         plot = plotSum,
         width = 6.54,
         height = 4.36,
         dpi = 600)
}