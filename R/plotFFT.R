# FFT frequency plots created by Chad C. Williams from the University of Victoria's Neuroeconomics Laboratory, 2016.
# Modified by Jordan Middleton (C) 2019

# Load Libraries
{
  library(reshape2)
  library(ggplot2)
  library(cowplot)
}

# Functions
{
  loadData <- function(dataPath1, dataPath2) {
    dataFile1 = t(read.csv(dataPath1,
                           header = FALSE))
    dataFile2 = t(read.csv(dataPath2,
                           header = FALSE))
    # Load Data
    dataFile = cbind(dataFile2,
                     dataFile1)
    # Change column names - This is important because it will be what appears in the legend
    colnames(dataFile) = c("Frequency", "Control", "Conflict", "Difference")
    # The melt function transforms the columns in the measured variable from your data frame. Look over the new
    # data frame and compare it to your original table to ensure you understand what the function did.
    output = as.data.frame(dataFile[, c("Frequency", "Control", "Conflict", "Difference")])
    output = melt(output,
                  id = "Frequency",
                  measure = c("Control", "Conflict", "Difference"))
    return(output)
  }
  plotFFT <- function(dataFile, channel, index) {
    # Creates your variable, designating the x and y column from your data frame, and the levels of your factor
    output = ggplot(dataFile,
                    aes(x = Frequency,
                        y = value,
                        colour = variable,
                        linetype =  variable)) +
      # Determines the type of plot, size refers to the width of the lines
      geom_line(stat = "identity",
                size = 1) +
      # This adds a horizontal dotted line at y = 0, this can be useful with ERP data, but you may want to remove this
      # with other data
      geom_hline(yintercept = 0,
                 linetype = "dotted") +
      
      # Waveform Colours and Type
      # Colours of your lines. This variable is defined above
      scale_color_manual(values = c("#505050",
                                    "#909090",
                                    "#000000")) +
      # The line type. Here, they are both solid but other options include dashed, dotted, and so forth
      scale_linetype_manual(values = c("solid",
                                       "solid",
                                       "twodash")) +
      
      # Axis Scales
      # This is a way to control the x axis labels. It ranges from min to max and puts a label every 5 datapoints
      scale_y_continuous(breaks = c(-2, 0, 5, 10, 15, 20),
                         # Expand is so that the lines touch the y axis
                         expand = c(0, 0)) +
      # This is a way to control the x axis labels. It ranges from min to max and puts a label every 100 datapoints
      scale_x_continuous(breaks = c(5, 10, 15, 20, 25, 30),
                         # Expand is so that the lines touch the x axis
                         expand = c(0, 0)) +
      coord_cartesian(xlim = c(1, 30),
                      ylim = c(-2, 20)) +
      
      # Labels
      # X axis label
      xlab("Frequency (Hz)") +
      # Y axis label
      ylab("Power (dB)") +
      
      #Legend
      # ggplot has several themes. You can look up different one's to see what it has to offer
      theme_bw() +
      # Position of a legend
      theme(legend.position = c(0.8, 0.8),
            # Text size within the legend
            legend.text = element_text(size = 10),
            # Remove borders around legend
            legend.key = element_blank(),
            # Removed title of legend
            legend.title = element_blank()) +
      
      # Background and border
      # Adds white space around your plot
      theme(plot.margin = unit(c(0.25, 0.25, 0.25, 0.5),
                               "cm"),
            # This adds a x axis line
            axis.line.x = element_line(color = "black",
                                       size = 0.5),
            # This adds a y axis line
            axis.line.y = element_line(color = "black",
                                       size = 0.5),
            axis.text = element_text(color = "black",
                                     size = 10),
            axis.text.x = element_text(vjust = 1,
                                       hjust = 0.5),
            axis.title = element_text(color = "black",
                                      size = 12,
                                      face = "bold"),
            # Removes grid
            panel.grid.major = element_blank(),
            # Removes more grid
            panel.grid.minor = element_blank(),
            # Removes grey background
            panel.background = element_blank(),
            #Removes lines around the plot
            panel.border = element_blank())
    
    if (index == "stimulus") {
      output = last_plot() +
        theme(axis.title.x = element_blank(),
              axis.line.y = element_line(color = "black",
                                         size = 0.5))
    }
    
    if (channel == "Pz") {
      output = last_plot() +
        theme(axis.title.y = element_blank(),
              axis.line.y = element_line(color = "black",
                                         size = 0.5),
              plot.margin = unit(c(0.25, 0.25, 0.25, 1),
                                 "cm"))
    }
    
    if (channel == "Fz" || index == "response") {
      output = last_plot() +
        theme(legend.position = "none",
              axis.line.y = element_line(color = "black",
                                         size = 0.5))
    }
    
    return(output)
  }
}

# Load Data
{
  stimulusFzData = loadData("../../Data/MedEd/R/FFT Data/stimulusFz.csv",
                            "../../Data/MedEd/R/FFT Data/frequency.csv")
  stimulusPzData = loadData("../../Data/MedEd/R/FFT Data/stimulusPz.csv",
                            "../../Data/MedEd/R/FFT Data/frequency.csv")
  responseFzData = loadData("../../Data/MedEd/R/FFT Data/responseFz.csv",
                            "../../Data/MedEd/R/FFT Data/frequency.csv")
  responsePzData = loadData("../../Data/MedEd/R/FFT Data/responsePz.csv",
                            "../../Data/MedEd/R/FFT Data/frequency.csv")
}

# Generate Plots
{
  stimulusFzPlot = plotFFT(stimulusFzData, "Fz", "stimulus")
  stimulusPzPlot = plotFFT(stimulusPzData, "Pz", "stimulus")
  responseFzPlot = plotFFT(responseFzData, "Fz", "response")
  responsePzPlot = plotFFT(responsePzData, "Pz", "response")
}

# Combine Plots
{
  stimulusPlot = plot_grid(stimulusFzPlot,
                           stimulusPzPlot,
                           ncol = 2,
                           nrow = 1,
                           labels = c("Fz", "Pz"),
                           label_size = 14)
  responsePlot = plot_grid(responseFzPlot,
                           responsePzPlot,
                           ncol = 2,
                           nrow = 1,
                           labels = c("Fz", "Pz"),
                           label_size = 14)
  summaryPlot = plot_grid(stimulusPlot,
                          responsePlot,
                          ncol = 1,
                          nrow = 2,
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
}

# Save Plot - Here, we can save the plot as an image. This will save the current plot in your R plot tab.
# Output name was determined at the top of the script
{
  ggsave(filename = "../../Data/MedEd/Plots/plotFFT.jpeg",
         plot = summaryPlot,
         width = 6.54,
         height = 3.27,
         dpi = 600)
}