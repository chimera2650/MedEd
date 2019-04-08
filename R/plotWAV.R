# Load Libraries
{
  library(RColorBrewer)
  library(ggplot2)
  library(dplyr)
  library(akima)
  library(reshape2)
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
        colors = c("#FF0000FF", "#FFFFFFFF", "#0000FFFF"),
        limits = c(-0.55, 0.55),
        breaks = c(-0.5,-0.25, 0, 0.25, 0.5),
        guide = guide_colourbar(
          title = NULL,
          position = "right",
          direction = "vertical",
          label.position = "left",
          barheight = unit(0.8, "npc")
        )
      ) +
      scale_x_continuous(expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      labs(x = "Time (ms)",
           y = "Frequency (Hz)",
           z = "Power (dB)") +
      theme_bw() +
      theme(
        plot.margin = unit(c(.5, .5, .5, .5), "cm"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank()
      )

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

# Load Variables
{
  color = rev(brewer.pal(8, "RdBu"))
}

# Load Data tables
{
  dataFT = loadWAV("./Data/WAV Data/FT.txt")
  dataPT = loadWAV("./Data/WAV Data/PT.txt")
  dataFD = loadWAV("./Data/WAV Data/FD.txt")
  dataPD = loadWAV("./Data/WAV Data/PD.txt")
}

# Generate plots
{
  plotFT = plotWAV(dataFT, "template")
  plotPT = plotWAV(dataPT, "template")
  plotFD = plotWAV(dataFD, "decision")
  plotPD = plotWAV(dataPD, "decision")
}