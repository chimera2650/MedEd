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
  loadData <-
    function(dataFile1,
             dataFile2,
             condition1,
             condition2,
             condition3) {
      # Load Data
      dataFile = cbind(dataFile2, dataFile1)
      # Change column names - This is important because it will be what appears in the legend
      colnames(dataFile) = c("Frequency", condition1, condition2, condition3)
      # The melt function transforms the columns in the measured variable from your data frame. Look over the new
      # data frame and compare it to your original table to ensure you understand what the function did.
      output = as.data.frame(dataFile[, c("Frequency", condition1, condition2, condition3)])
      output = melt(output,
                    id = "Frequency",
                    measure = c(condition1, condition2, condition3))
      return(output)
    }
  plotFFT <-
    function(dataFile,
             lineColours,
             lineTypes,
             xLabels,
             yLabels,
             yRange) {
      # Plot Data CW
      # Creates your variable, designating the x and y column from your data frame, and the levels of your factor
      yBreaks = c(-2, 0, 5, 10, 15, 20)
      xBreaks = c(5, 10, 15, 20, 25, 30)
      output = ggplot(dataFile,
                      aes(
                        x = Frequency,
                        y = value,
                        colour = variable,
                        linetype =  variable
                      )) +
        # Determines the type of plot, size refers to the width of the lines
        geom_line(stat = "identity", size = 1) +
        # This adds a horizontal dotted line at y = 0, this can be useful with ERP data, but you may want to remove this
        # with other data
        geom_hline(yintercept = 0, linetype = "dotted") +
        
        # Waveform Colours and Type
        # Colours of your lines. This variable is defined above
        scale_color_manual(values = lineColours) +
        # The line type. Here, they are both solid but other options include dashed, dotted, and so forth
        scale_linetype_manual(values = lineTypes) +
        
        # Axis Scales
        # This is a way to control the x axis labels. It ranges from min to max and puts a label every 5 datapoints
        scale_y_continuous(breaks = yBreaks,
                           # Expand is so that the lines touch the y axis
                           expand = c(0, 0)) +
        # This is a way to control the x axis labels. It ranges from min to max and puts a label every 100 datapoints
        scale_x_continuous(breaks = xBreaks,
                           # Expand is so that the lines touch the y axis
                           expand = c(0, 0)) +
        coord_cartesian(xlim = c(1,30),
                        ylim = yRange) +
        
        # Labels
        # X axis label
        xlab(xLabels) +
        # Y axis label
        ylab(yLabels) +
        
        #Legend
        # ggplot has several themes. You can look up different one's to see what it has to offer
        theme_bw() +
        # Position of a legend
        theme(
          legend.position = c(0.8, 0.8),
          # Text size within the legend
          legend.text = element_text(size = 13),
          # Size of legend box colour
          legend.key.size = unit(.6, "cm"),
          # Remove borders around colours
          legend.key = element_rect(colour = FALSE),
          # Removed title of legend
          legend.title = element_blank()
        ) +
        
        # Background and border
        # Adds white space around your plot
        theme(
          plot.margin = unit(c(.5, .5, .5, .5), "cm"),
          # This adds a x axis line
          axis.line.x = element_line(color = "black", size = 0.5),
          # This adds a y axis line
          axis.line.y = element_line(color = "black", size = 0.5),
          # Removes grid
          panel.grid.major = element_blank(),
          # Removes more grid
          panel.grid.minor = element_blank(),
          # Removes grey background
          panel.background = element_blank(),
          #Removes lines around the plot
          panel.border = element_blank()
        )
      
      return(output)
    }
}

# Set Variables
{
  # First, change your working directory to the folder with your data
  # Data must be laid out as Time, Condition1, Condition2
  # Filenames
  stimulusFzName = "../../Data/MedEd/R/FFT Data/stimulusFz.csv"
  stimulusPzName = "../../Data/MedEd/R/FFT Data/stimulusPz.csv"
  responseFzName = "../../Data/MedEd/R/FFT Data/responseFz.csv"
  responsePzName = "../../Data/MedEd/R/FFT Data/responsePz.csv"
  referenceName = "../../Data/MedEd/R/FFT Data/frequency.csv"
  stimulusSave = "../../Data/MedEd/Plots/stimulusFFT.jpeg"
  responseSave = "../../Data/MedEd/Plots/responseFFT.jpeg"
  # Condition Names
  condition1 = "Control"
  condition2 = "Conflict"
  condition3 = "Difference"
  # Colours of your lines
  lineColours = c("#505050", "#909090", "#000000")
  # Type of line
  lineTypes = c("solid", "solid", "twodash")
  # Y Axis label
  yLabels = expression(paste("Power (", mu, "V" ^2, ")", sep = ""))
  # Y Axis Range
  yRange = c(-2, 20)
  # X Axis label
  xLabels = "Frequency (Hz)"
}

# Load Data
{
  stimulusFzFile = t(read.csv(stimulusFzName, header = FALSE))
  stimulusPzFile = t(read.csv(stimulusPzName, header = FALSE))
  responseFzFile = t(read.csv(responseFzName, header = FALSE))
  responsePzFile = t(read.csv(responsePzName, header = FALSE))
  referenceFile = t(read.csv(referenceName, header = FALSE))
  stimulusFzData = loadData(stimulusFzFile,
                            referenceFile,
                            condition1,
                            condition2,
                            condition3)
  stimulusPzData = loadData(stimulusPzFile,
                            referenceFile,
                            condition1,
                            condition2,
                            condition3)
  responseFzData = loadData(responseFzFile,
                            referenceFile,
                            condition1,
                            condition2,
                            condition3)
  responsePzData = loadData(responsePzFile,
                            referenceFile,
                            condition1,
                            condition2,
                            condition3)
}

# Generate Plots
{
  stimulusFzPlot = plotFFT(stimulusFzData,
                           lineColours,
                           lineTypes,
                           xLabels,
                           yLabels,
                           yRange)
  stimulusPzPlot = plotFFT(stimulusPzData,
                           lineColours,
                           lineTypes,
                           xLabels,
                           yLabels,
                           yRange)
  responseFzPlot = plotFFT(responseFzData,
                           lineColours,
                           lineTypes,
                           xLabels,
                           yLabels,
                           yRange)
  responsePzPlot = plotFFT(responsePzData,
                           lineColours,
                           lineTypes,
                           xLabels,
                           yLabels,
                           yRange)
}

# Combine Plots
{
  stimulusPlot = plot_grid(
    stimulusFzPlot,
    stimulusPzPlot,
    ncol = 2,
    nrow = 1,
    labels = c("Fz", "Pz")
  )
  responsePlot = plot_grid(
    responseFzPlot,
    responsePzPlot,
    ncol = 2,
    nrow = 1,
    labels = c("Fz", "Pz")
  )
  print(stimulusPlot)
  print(responsePlot)
}

# Save Plot - Here, we can save the plot as an image. This will save the current plot in your R plot tab.
# Output name was determined at the top of the script
{
  ggsave(
    filename = stimulusSave,
    plot = stimulusPlot,
    width = 13.08,
    height = 4.36,
    dpi = 600
  )
  ggsave(
    filename = responseSave,
    plot = responsePlot,
    width = 13.08,
    height = 4.36,
    dpi = 600
  )
}