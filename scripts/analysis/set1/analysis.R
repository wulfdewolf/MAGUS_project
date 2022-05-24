library(ggplot2)
library(grid)
library(ggthemes)
library(plyr)
theme_set(theme_light())

# Read results
results <- read.csv(file = "./scripts/analysis/set1/results.csv")
results$group <- 0
results$error <- 0

# Split and calculate avg score
for (row in 1:nrow(results)) {
    if(grepl("ROSE", results[row,"name"], fixed = TRUE)){
        parts = unlist(strsplit(results[row,"name"], "-"))
        results[row,"name"] = paste(parts[1],parts[2])
        results[row,"error"] = (results[row,"SPFP"] + results[row,"SPFN"]) / 2
    }
}

## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
    library(plyr)

    # New version of length which can handle NA's: if na.rm==T, don't count them
    length2 <- function (x, na.rm=FALSE) {
        if (na.rm) sum(!is.na(x))
        else       length(x)
    }

    # This does the summary. For each group's data frame, return a vector with
    # N, mean, and sd
    datac <- ddply(data, groupvars, .drop=.drop,
      .fun = function(xx, col) {
        c(N    = length2(xx[[col]], na.rm=na.rm),
          mean = mean   (xx[[col]], na.rm=na.rm),
          sd   = sd     (xx[[col]], na.rm=na.rm)
        )
      },
      measurevar
    )

    # Rename the "mean" column    
    datac <- rename(datac, c("mean" = measurevar))

    datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean

    # Confidence interval multiplier for standard error
    # Calculate t-statistic for confidence interval: 
    # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
    ciMult <- qt(conf.interval/2 + .5, datac$N-1)
    datac$ci <- datac$se * ciMult

    return(datac)
}

# Barplot for running time
ggplot(data=summarySE(results, measurevar="run_time", groupvars=c("name", "method")), aes(x=name, y=run_time, group=method, fill=method)) +
    geom_bar(position = "dodge", stat = "summary", fun=mean) +
    geom_errorbar(aes(ymin=run_time-se, ymax=run_time+se), width=.2,position=position_dodge(.9)) +
    labs(x="Instance", y="Running time (s)", fill="Trace finding method: ") +
    theme(legend.position="top") +
    scale_fill_brewer(palette="Set3")
ggsave("./scripts/analysis/set1/plots/set1_small_time.pdf", device = "pdf", width = 30, height = 18, units = "cm")

# Barplot for memory
ggplot(data=summarySE(results, measurevar="memory", groupvars=c("name", "method")), aes(x=name, y=memory, group=method, fill=method)) +
    geom_bar(position = "dodge", stat = "summary", fun=mean) +
    geom_errorbar(aes(ymin=memory-se, ymax=memory+se), width=.2,position=position_dodge(.9)) +
    labs(x="Instance", y="Max used memory (MB)", fill="Trace finding method: ") +
    theme(legend.position="top") +
    scale_fill_brewer(palette="Set3")
ggsave("./scripts/analysis/set1/plots/set1_small_memory.pdf", device = "pdf", width = 30, height = 18, units = "cm")

# Barplot for error
ggplot(data=summarySE(results, measurevar="error", groupvars=c("name", "method")), aes(x=name, y=error, group=method, fill=method)) +
    geom_bar(position = "dodge", stat = "summary", fun=mean) +
    geom_errorbar(aes(ymin=error-se, ymax=error+se), width=.2,position=position_dodge(.9)) +
    labs(x="Instance", y=expression(frac("SPFP + SPFN", "2")), fill="Trace finding method: ") +
    theme(legend.position="top") +
    scale_fill_brewer(palette="Set3")
ggsave("./scripts/analysis/set1/plots/set1_small_error.pdf", device = "pdf", width = 30, height = 18, units = "cm")
