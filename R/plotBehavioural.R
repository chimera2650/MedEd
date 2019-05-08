# Copyright (C) 2019 Jordan Middleton

# Load Libraries
{
  library(reshape2)
  library(ggplot2)
  library(RColorBrewer)
  library(cowplot)
}

# Functions
{
  loadData <- function(dataPath) {
    # Load data from .csv file
    tempData = read.csv(dataPath,
                        header = FALSE)
    # convert to a data frame for manipulation
    tempData = as.data.frame(tempData)
    # name columns as desired
    colnames(tempData) = c("avg", "stdev", "count", "error", "ci")
    # create condition names for plotting
    tempData["con"] = c("Training", "No Conflict", "High Conflict")
    # select columns to save for plotting
    tempData = tempData[c("con", "avg", "ci")]
    tempData$con <- factor(tempData$con, levels = tempData$con)
    # define variable to be returned
    return(tempData)
  }
  plotData <- function(dataFile, axisTitle, yLimits) {
    # create colour palette with ColorBrewer; see package documentation for details
    getPalette = brewer.pal(3, "Dark2")
    
    # define initial ggplot object
    tempPlot = ggplot(dataFile,
                      aes(x = con,
                          y = avg)) +
      # add a column plot layer, with colors defined by ColorBrewer
      geom_col(aes(fill = getPalette)) +
      # add error bars
      geom_errorbar(aes(
        ymin = avg - (ci - avg),
        ymax = ci,
        width = 0.25
      ),
      size = 1.5) +
      # adjust y-axis limits to desired window
      coord_cartesian(ylim = yLimits) +
      # expand y-axis so plot extends to boundaries
      scale_y_continuous(expand = c(0, 0)) +
      # give the y-axis a title
      ylab(axisTitle) +
      # pick a theme to start with; there are others, but this one is really clean
      theme_bw() +
      theme(
        # give plot a margin; useful for saving plots later
        plot.margin = unit(c(.25, .25, .25, .25), "cm"),
        # remove legend
        legend.position = "none",
        # define parameters for x- and y-axis lines
        axis.line.x = element_line(color = "black", size = 1),
        axis.line.y = element_line(color = "black", size = 1),
        # remove x-axis title
        axis.title.x = element_blank(),
        # define parameters for y-axis title
        axis.title.y = element_text(size = 10,
                                    face = "bold"),
        # define parameters for x-axis text
        axis.text.x = element_text(
          size = 8,
          face = "bold",
          angle = 30,
          hjust = 1,
          vjust = 1
        ),
        axis.text.y = element_text(size = 8,
                                   face = "bold"),
        # remove gridlines and plot border
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank()
      )
    # return plot as function output
    return(tempPlot)
  }
}

# Load Data
{
  accuracyData = loadData("../../Data/MedEd/R/Behavioural Data/accuracy.csv")
  reactionData = loadData("../../Data/MedEd/R/Behavioural Data/reactionTime.csv")
  confidenceData = loadData("../../Data/MedEd/R/Behavioural Data/confidence.csv")
}

# Plot Data
{
  accuracyPlot = plotData(accuracyData, "Accuracy (%)", c(0.5, 1))
  reactionPlot = plotData(reactionData, "Reaction Time (s)", c(3, 10))
  confidencePlot = plotData(confidenceData, "Confidence", c(5, 10))
}

# Combine Plots
{
  summaryPlot = plot_grid(accuracyPlot,
                          reactionPlot,
                          confidencePlot,
                          ncol = 3,
                          nrow = 1)
}

# Save Plot
{
  ggsave(
    filename = "../../Data/MedEd/Plots/behavioural.png",
    plot = summaryPlot,
    width = 6.54,
    height = 2.65,
    dpi = 600
  )
}