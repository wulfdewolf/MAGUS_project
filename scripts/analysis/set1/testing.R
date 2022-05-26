library(nortest)

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
    } else if(grepl("RNA", results[row,"name"], fixed = TRUE)) {
        parts = unlist(strsplit(results[row,"name"], "-"))
        results[row,"name"] = paste(parts[1],parts[2])
        results[row,"error"] = (results[row,"SPFP"] + results[row,"SPFN"]) / 2
    }
}

# Groups
group1 = results[results$name=="ROSE 1000M3" & results$method=="minclusters","error"] 
group2 = results[results$name=="ROSE 1000M3" & results$method=="minclusters_reimplemented","error"] 

# Lilliefors
lillie.test(group1-group2)

# Paired student t-test
t.test(group1, group2, paired=TRUE)

# Paired Wilcoxon signed rank test
wilcox.test(group1, group2, paired=TRUE)
