#ERP Waveform plots created by Chad C. Williams from the University of Victoria's Neuroeconomics Laboratory, 2016.

###################################################################################################################

###MODIFY THIS SECTION TO YOUR LIKING###                                  

###################################################################################################################

#First, change your working directory to the folder with your data
#Data must be laid out as Time, Condition1, Condition2

#Filenames
filename = "./Data/fft_fz_decision.txt"
OutputName = "Decision_Fz.jpeg"
#Condition Names
Condition1 = "No Conflict"
Condition2 = "High Conflict"
Condition3 = "Difference"

#Colours of your lines
colourscw = c("#505050","#909090","#000000")
#Type of line
linetypecw = c("solid", "solid","dotted")
#Y Axis Values range
lineylim = range(0,10)
#Y Axis label
lineylab = "Power (dB)"  #Amplitude (Î¼V)
#X Axis label
linexlab = "Time (ms)" 

###################################################################################################################

###DO NOT CHANGE ANYTHING BEYOND THIS POINT UNLESS YOU KNOW WHAT YOU ARE DOING###

###################################################################################################################

#Load Packages
library(reshape2)
library(ggplot2)

#Load Data
data = read.csv(filename, header = FALSE)
#Change column names - This is important because it will be what appears in the legend
colnames(data) = c("Frequency",Condition1,Condition2,Condition3,"CI","TTest")
#The melt function transforms the columns in the measured variable from your data frame. Look over the new 
#data frame and compare it to your original table to ensure you understand what the function did. 
longdata = data[,c("Frequency",Condition1,Condition2,Condition3)]
longdata = melt(longdata, id = "Frequency", measured = c(Condition1,Condition2,Condition3))

###################################################################################################################

#Plot Data CW
Plot = ggplot(longdata, aes(x = Frequency, y = value, colour = variable, linetype =  variable)) #Creates your variable, designating the x and y column from your data frame, and the levels of your factor
print(#Because ggplot is meant to be done in the console tab, we must print any ggplot in a script. 
  #Print essentially puts it into the console tab
  Plot #Here, we recall plot so we can add properties to the variable, anything below with a + in front of it is us adding a property
  +geom_freqpoly(stat = "identity", size= 1) #Determines the type of plot, size refers to the width of the lines
  
  #Waveform Colours and Type
  +scale_color_manual(values = colourscw) #Colours of your lines. This variable is defined above
  +scale_linetype_manual(values = linetypecw) #The line type. Here, they are both solid but other options include dashed, dotted, and so forth
  
  #Axis Scales
  +coord_cartesian(ylim = lineylim) #This determines the y axis limits. This was determined at the top of the script
  #This is a way to control the x axis labels. It ranges from min to max and puts a label every 100 datapoints
  +scale_x_continuous(breaks = round(seq(min(0), max(30), by = 5),1),expand = c(0,0)) #Expand is so that the lines touch the y axis
  
  #Labels
  +xlab(linexlab) #X axis label
  +ylab(lineylab) #Y axis label
  
  #Legend
  +theme_bw() #ggplot has several themes. You can look up different one's to see what it has to offer
  + theme(legend.position = c(0.85, 0.85)) #Position of a legend
  + theme(legend.text=element_text(size=13)) #Text size within the legend
  + theme(legend.key.size = unit(.6, "cm")) #Size of legend box colour
  + theme(legend.key = element_rect(colour = FALSE)) #Remove borders around colours
  + theme(legend.title=element_blank()) #Removed title of legend
  
  #Background and border
  +theme(plot.margin=unit(c(.5,.5,.5,.5),"cm")) #Adds white space around your plot
  +theme(axis.line.x = element_line(color="black", size = 0.5), #This adds a x axis line
         axis.line.y = element_line(color="black", size = 0.5), #This adds a y axis line
         panel.grid.major = element_blank(), #Removes grid
         panel.grid.minor = element_blank(), #Removes more grid
         panel.background = element_blank(), #Removes grey background
         panel.border = element_blank())) #Removes lines around the plot

###################################################################################################################

#Save Plot - Here, we can save the plot as an image. This will save the current plot in your R plot tab. 
#Output name was determined at the top of the script
ggsave(filename = OutputName, width = 6.54, height = 4.36, dpi = 600)
