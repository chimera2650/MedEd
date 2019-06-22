# Copyright (C) 2019 Jordan Middleton

##########################################################
# With nlme

# Load Libraries
{
  library(multcomp)
  library(nlme)
}

# Load Data
{
  dataFile = read.csv("../../Data/MedEd/R/FFT Data/anova.csv", header = FALSE)
  
  colnames(dataFile) = c("time",
                         "channel",
                         "condition",
                         "band",
                         "subject",
                         "value")
  
  dataFile$time[dataFile$time == 1]           = "stimulus"
  dataFile$time[dataFile$time == 2]           = "response"
  dataFile$channel[dataFile$channel == 1]     = "Fz"
  dataFile$channel[dataFile$channel == 2]     = "Pz"
  dataFile$condition[dataFile$condition == 1] = "control"
  dataFile$condition[dataFile$condition == 2] = "conflict"
  dataFile$band[dataFile$band == 1]           = "delta"
  dataFile$band[dataFile$band == 2]           = "theta"
  dataFile$band[dataFile$band == 3]           = "alpha"
  dataFile$band[dataFile$band == 4]           = "beta"
  
  dataFile$time      = factor(dataFile$time,      levels = unique(dataFile$time))
  dataFile$channel   = factor(dataFile$channel,   levels = unique(dataFile$channel))
  dataFile$condition = factor(dataFile$condition, levels = unique(dataFile$condition))
  dataFile$band      = factor(dataFile$band,      levels = unique(dataFile$band))
  dataFile$subject   = factor(dataFile$subject,   levels = unique(dataFile$subject))
  
  dataStimulus      = dataFile[dataFile$time == "stimulus",]
  dataStimulus$time = NULL
  dataResponse      = dataFile[dataFile$time == "response",]
  dataResponse$time = NULL
}

# Stimulus
{
  # ANOVA
  {
    lmStimulus = lme(value ~ 0 + channel*condition*band,
                     random = ~1|subject,
                     method = "ML",
                     data   = dataFile)
    anovaStimulus = anova(lmStimulus)
    
    colnames(anovaStimulus) = c("numDF",
                                "denDF",
                                "F_value",
                                "p_value")
  }
  # Post Hoc
  {
    rowIndex = row.names(anovaStimulus)
    rowIndex = rowIndex[anovaStimulus$p_value < 0.05]
    
    lsmeanChannel     = lsmeans(lmStimulus,
                                pairwise ~ channel,
                                adjust = "tukey")
    lsmeanChannel     = lsmeanChannel[[1]]
    lsmeanBand        = lsmeans(lmStimulus,
                                pairwise ~ band,
                                adjust = "tukey")
    lsmeanBand        = lsmeanBand[[1]]
    lsmeanChannelBand = lsmeans(lmStimulus,
                                pairwise ~ channel:band,
                                adjust = "tukey")
    lsmeanChannelBand = lsmeanChannelBand[[1]]
    tukeyChannel      = cld(lsmeanChannel,
                            alpha   = 0.05,
                            Letters = letters)
    tukeyBand         = cld(lsmeanBand,
                            alpha   = 0.05,
                            Letters = letters)
    tukeyChannelBand  = cld(lsmeanChannelBand,
                            alpha   = 0.05,
                            Letters = letters)
    
    posthocStimulus   = list(channel      = tukeyChannel,
                             band         = tukeyBand,
                             channel.band = tukeyChannelBand)
  }
  # Clear Variables
  {
    rm(rowIndex,
       lmStimulus,
       lsmeanChannel,
       lsmeanBand,
       lsmeanChannelBand,
       tukeyChannel,
       tukeyBand,
       tukeyChannelBand)
  }
}
  
# Response
{
  # ANOVA
  {
    lmResponse = lme(value ~ 0 + channel*condition*band,
                     random = ~1|subject,
                     method = "ML",
                     data   = dataFile)
    anovaResponse = anova(lmResponse)
    
    colnames(anovaResponse) = c("numDF",
                                "denDF",
                                "F_value",
                                "p_value")
  }
  # Post Hoc
  {
    rowIndex = row.names(anovaResponse)
    rowIndex = rowIndex[anovaResponse$p_value < 0.05]
    
    lsmeanChannel     = lsmeans(lmResponse,
                                pairwise ~ channel,
                                adjust = "tukey")
    lsmeanChannel     = lsmeanChannel[[1]]
    lsmeanBand        = lsmeans(lmResponse,
                                pairwise ~ band,
                                adjust = "tukey")
    lsmeanBand        = lsmeanBand[[1]]
    lsmeanChannelBand = lsmeans(lmResponse,
                                pairwise ~ channel:band,
                                adjust = "tukey")
    lsmeanChannelBand = lsmeanChannelBand[[1]]
    tukeyChannel      = cld(lsmeanChannel,
                            alpha   = 0.05,
                            Letters = letters)
    tukeyBand         = cld(lsmeanBand,
                            alpha   = 0.05,
                            Letters = letters)
    tukeyChannelBand  = cld(lsmeanChannelBand,
                            alpha   = 0.05,
                            Letters = letters)
    
    posthocResponse   = list(channel      = tukeyChannel,
                             band         = tukeyBand,
                             channel.band = tukeyChannelBand)
  }
  # Clear Variables
  {
    rm(rowIndex,
       lmResponse,
       lsmeanChannel,
       lsmeanBand,
       lsmeanChannelBand,
       tukeyChannel,
       tukeyBand,
       tukeyChannelBand)
  }
}

##########################################################
# With ezANOVA

# Load Libraries
{
  library(ez)
  library(multcomp)
}

# Load Data
{
  dataFile = read.csv("../../Data/MedEd/R/FFT Data/anova.csv",
                      header = FALSE)
  
  colnames(dataFile) = c("time",
                         "channel",
                         "condition",
                         "band",
                         "subject",
                         "value")
  
  dataFile$time[dataFile$time == 1]           = "stimulus"
  dataFile$time[dataFile$time == 2]           = "response"
  dataFile$channel[dataFile$channel == 1]     = "Fz"
  dataFile$channel[dataFile$channel == 2]     = "Pz"
  dataFile$condition[dataFile$condition == 1] = "control"
  dataFile$condition[dataFile$condition == 2] = "conflict"
  dataFile$band[dataFile$band == 1]           = "delta"
  dataFile$band[dataFile$band == 2]           = "theta"
  dataFile$band[dataFile$band == 3]           = "alpha"
  dataFile$band[dataFile$band == 4]           = "beta"
  
  dataFile$time      = factor(dataFile$time,      labels = c("stimulus",
                                                             "response"))
  dataFile$channel   = factor(dataFile$channel,   labels = c("Fz",
                                                             "Pz"))
  dataFile$condition = factor(dataFile$condition, labels = c("control",
                                                             "conflict"))
  dataFile$band      = factor(dataFile$band,      labels = c("delta",
                                                             "theta",
                                                             "alpha",
                                                             "beta"))
  dataFile$subject   = factor(dataFile$subject,   labels = c(1:30))
  
  dataFile = dataFile[order(dataFile$subject),]
  
  dataStimulus      = dataFile[dataFile$time == "stimulus",]
  dataStimulus$time = NULL
  dataResponse      = dataFile[dataFile$time == "response",]
  dataResponse$time = NULL
}

# Stimulus
{
  # ANOVA
  {
    anovaStimulus = ezANOVA(data     = dataStimulus,
                            dv       = .(value),
                            wid      = .(subject),
                            within   = .(channel,condition,band),
                            detailed = TRUE,
                            type     = 3)
    
    anovaStimulus
  }
  
  # Post Hoc
  {
    posthocCondition            = pairwise.t.test(dataStimulus$value,
                                                  dataStimulus$condition,
                                                  paired = TRUE,
                                                  p.adjust.method = "bonferroni")
    posthocBand                 = pairwise.t.test(dataStimulus$value,
                                                  dataStimulus$band,
                                                  paired = TRUE,
                                                  p.adjust.method = "bonferroni")
    posthocChannelBand          = pairwise.t.test(dataStimulus$value,
                                                  interaction(dataStimulus$channel,
                                                              dataStimulus$band),
                                                  paired = TRUE,
                                                  p.adjust.method = "bonferroni")
    posthocConditionBand        = pairwise.t.test(dataStimulus$value,
                                                  interaction(dataStimulus$condition,
                                                              dataStimulus$band),
                                                  paired = TRUE,
                                                  p.adjust.method = "bonferroni")
    posthocChannelConditionBand = pairwise.t.test(dataStimulus$value,
                                                  interaction(dataStimulus$channel,
                                                              dataStimulus$condition,
                                                              dataStimulus$band),
                                                  paired = TRUE,
                                                  p.adjust.method = "bonferroni")
    
    posthocStimulus = list(conditon             = posthocCondition,
                           band                 = posthocBand,
                           channelband          = posthocChannelBand,
                           conditionband        = posthocConditionBand,
                           channelconditionband = posthocChannelConditionBand)
    
    rm(posthocCondition,
       posthocBand,
       posthocChannelBand,
       posthocConditionBand,
       posthocChannelConditionBand)
  }
  
  # Export
  {
    write.csv(anovaStimulus[["ANOVA"]],
              "../../Data/MedEd/R/FFT Data/Export/anovaStimulus.csv")
  }
}

# Response
{
  # ANOVA
  {
    anovaResponse = ezANOVA(data     = dataResponse,
                            dv       = .(value),
                            wid      = .(subject),
                            within   = .(channel,condition,band),
                            detailed = TRUE,
                            type     = 3)
    
    anovaResponse
  }
  
  # Post Hoc
  {
    posthocChannel              = pairwise.t.test(dataStimulus$value,
                                                  dataStimulus$channel,
                                                  paired = TRUE,
                                                  p.adjust.method = "bonferroni")
    posthocBand                 = pairwise.t.test(dataStimulus$value,
                                                  dataStimulus$band,
                                                  paired = TRUE,
                                                  p.adjust.method = "bonferroni")
    posthocChannelBand          = pairwise.t.test(dataStimulus$value,
                                                  interaction(dataStimulus$channel,
                                                              dataStimulus$band),
                                                  paired = TRUE,
                                                  p.adjust.method = "bonferroni")
    posthocConditionBand        = pairwise.t.test(dataStimulus$value,
                                                  interaction(dataStimulus$condition,
                                                              dataStimulus$band),
                                                  paired = TRUE,
                                                  p.adjust.method = "bonferroni")
    
    posthocResponse = list(channel       = posthocChannel,
                           band          = posthocBand,
                           channelband   = posthocChannelBand,
                           conditionband = posthocConditionBand)
    
    rm(posthocChannel,
       posthocBand,
       posthocChannelBand,
       posthocConditionBand)
  }
  
  # Export
  {
    write.csv(anovaResponse[["ANOVA"]],
              "../../Data/MedEd/R/FFT Data/Export/anovaResponse.csv")
  }
}