library(ggplot2)
library(grid)
library(ggthemes)
theme_set(theme_light())

# Read results
results <- read.csv(file = "./scripts/analysis/results.csv", header = FALSE)
names(results) <- c("name", "method", "method_time", "total_time", "SPFN", "SPFP")

# Barplot for running time
ggplot(data=results, aes(x=method, y=method_time, group=name, fill=name)) +
    geom_bar(stat='identity', position="dodge") +
    labs(x="Graph trace method", y="Running time (s)", fill="Instance") +
    scale_fill_brewer(palette="Set3")
ggsave("./scripts/analysis/times.pdf")

# Barplot for score
ggplot(data=results, aes(x=method, y=(SPFN + SPFP) /2, group=name, fill=name)) +
    geom_bar(stat='identity', position="dodge") +
    labs(x="Graph trace method", y="(SPFN + SPFP) / 2", fill="Instance") +
    scale_fill_brewer(palette="Set3")
ggsave("./scripts/analysis/scores.pdf")
