library(ggplot2)
library(grid)
library(ggthemes)
theme_set(theme_light())

rm(list = ls())

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

############ First Fail ############ 

# Read results
results_ff <- read.csv(file = "../results_cp_ff.csv", header = TRUE)

# instances that did not finish yet
nonfinishers_ff <- results_ff[which(is.na(results_ff$NR_CLUSTERS_CP)),]

# instances that did finish
finishers_ff <- results_ff[which(!is.na(results_ff$NR_CLUSTERS_CP)),]

clusters_ff <- finishers_ff[,c("INSTANCE", "NR_CLUSTERS_BEFORE_MINCLUSTERS", "NR_CLUSTERS_MINCLUSTERS", "NR_CLUSTERS_CP")]

#Nr of instances for which cluster breaking was needed
length(which(clusters_ff$NR_CLUSTERS_BEFORE_MINCLUSTERS != clusters_ff$NR_CLUSTERS_MINCLUSTERS))

# Nr of instances for which CP is better than minclusters
length(which(clusters_ff$NR_CLUSTERS_CP != clusters_ff$NR_CLUSTERS_MINCLUSTERS))


############ PLOTS RUNTIME ############ 


df_runtime <- data.frame(results_ff$TIME_TRACING_MINCLUSTERS, results_ff$TIME_TRACING_CP, results_ff$NR_CLUSTERS_BEFORE_MINCLUSTERS != results_ff$NR_CLUSTERS_MINCLUSTERS, substr(results_ff$INSTANCE, 1, 8) == "balibase" )
colnames(df_runtime) <- c("TIME_TRACING_MINCLUSTERS", "TIME_TRACING_CP", "TRACE_FOUND_BY_MCL", "BALIBASE")

df_runtime$TIME_TRACING_CP <- df_runtime$TIME_TRACING_CP - df_runtime$TIME_TRACING_MINCLUSTERS

for(row in 1:nrow(df_runtime)) {
    if(is.na(df_runtime$TIME_TRACING_CP[row])){
        df_runtime[row, 2] = 29000;
    }
}
    
ggplot(df_runtime, aes(x = TIME_TRACING_CP, y = TIME_TRACING_MINCLUSTERS), group=TRACE_FOUND_BY_MCL) +
    geom_point(aes(shape=TRACE_FOUND_BY_MCL, color=TRACE_FOUND_BY_MCL)) +
    
    scale_x_log10(limits=c(0.0001,30000), breaks = c( 1, 30, 60, 300, 3600, 21600 )) +
    scale_y_log10(limits = c(0.0001,21600), breaks = c( 0.001, 0.005, 0.01, 0.05, 1.6)) +
    scale_shape_manual(values=c(1,4)) +
    labs(shape="Cluster breaking required", color="Cluster breaking required") +
    #scale_color_manual(values=c('#E69F00', '#66B4E9')) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
    geom_vline(xintercept = 29000, linetype = "dashed") +
    annotate(
        geom = "text",
        label = "OoT",
        x = 20000,
        y = 10.0,
        angle = 90,
        vjust = 1,
        size = 4
    ) +
    xlab("CP running time (s)") +
    ylab("A* running time (s)") 
ggsave("../time_cp.pdf")


############ PLOTS HOMOLOGIES ############ 

df_homologies <- data.frame(results_ff$NR_HOMOLOGIES_MINCLUSTERS, results_ff$NR_HOMOLOGIES_CP, results_ff$NR_CLUSTERS_BEFORE_MINCLUSTERS == results_ff$NR_CLUSTERS_MINCLUSTERS, substr(results_ff$INSTANCE, 1, 8) == "balibase" )
colnames(df_homologies) <- c("NR_HOMOLOGIES_MINCLUSTERS", "NR_HOMOLOGIES_CP", "TRACE_FOUND_BY_MCL", "BALIBASE")

df_homologies <- df_homologies[which(df_homologies$NR_HOMOLOGIES_CP != 0),]

ggplot(df_homologies, aes(x = NR_HOMOLOGIES_CP, y = NR_HOMOLOGIES_MINCLUSTERS), group=TRACE_FOUND_BY_MCL) +
    geom_point(aes(shape=TRACE_FOUND_BY_MCL, color=TRACE_FOUND_BY_MCL), size=4) +
    scale_x_log10(limits=c(5200000,107000000)) +
    scale_y_log10(limits = c(5200000,107000000)) +
    scale_shape_manual(values=c(1,3)) +
    labs(shape="Cluster breaking required", color="Cluster breaking required") +
    #scale_color_manual(values=c('#E69F00', '#66B4E9')) +
    #scale_color_viridis_d() +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
    xlab("CP number of homologies") +
    ylab("A* number of homologies") 
ggsave("../nr_homologies_cp.pdf")

different_homologies <- df_homologies[which(df_homologies$NR_HOMOLOGIES_MINCLUSTERS != df_homologies$NR_HOMOLOGIES_CP),]
different_homologies$difference = different_homologies$NR_HOMOLOGIES_MINCLUSTERS - different_homologies$NR_HOMOLOGIES_CP

boxplot(different_homologies$difference)

