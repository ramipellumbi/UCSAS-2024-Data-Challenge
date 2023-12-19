# looks for any number of digits followed by a period followed by rds
pattern <- ".*_(\\d+)\\.rds$"

# read all files in directory `simulation_results`
files <- list.files("./simulation_results", full.names = TRUE)
# filter for .rds only
files <- files[grepl(pattern, files)]

unique_names <- c("team_medalists",
                  "individual_aa_medalists",
                  "apparatus_medalists")

usa_samples <- data.frame()
other_samples <- data.frame()
team_usa <- data.frame()
apparatus_medalists <- data.frame()
team_medalists <- data.frame()
individual_aa_medalists <- data.frame()

for (file in files) {
  results <- readRDS(file)
  sublist <- results[[1]]
  team_usa_5 <- results[[2]]

  team_usa <- rbind(team_usa, team_usa_5)
  
  for (name in unique_names) {
    # Extract all data frames with this name
    dfs_to_combine <- lapply(seq_along(sublist), function(i) {
      df <- sublist[[i]][[name]]
      df
    })
    dfs_to_combine <- dfs_to_combine[!sapply(dfs_to_combine, is.null)]  # Remove null entries
    
    if (name == "apparatus_medalists") {
      # Combine the data frames by row
      apparatus_medalists_t <- do.call(rbind, dfs_to_combine)
      apparatus_medalists <- rbind(apparatus_medalists, apparatus_medalists_t)
    }
    
    if (name == "team_medalists") {
      # Combine the data frames by row
      team_medalists_t <- do.call(rbind, dfs_to_combine)
      team_medalists <- rbind(team_medalists, team_medalists_t)
    }
    
    if (name == "individual_aa_medalists") {
      # Combine the data frames by row
      individual_aa_medalists_t <- do.call(rbind, dfs_to_combine)
      individual_aa_medalists <- rbind(individual_aa_medalists, individual_aa_medalists_t)
    }
  }
  
  modified_usa_samples <- list()
  # Iterate over each element in the sublist
  for (i in seq_along(sublist)) {
    # Check if the element is a 'usa_sample' data frame
    if (length(names(sublist[[i]])) == 5 && "name" %in% names(sublist[[i]]) && "apparatus" %in% names(sublist[[i]])) {
      modified_usa_samples[[i]] <- sublist[[i]]
    }
  }
  combined_usa_sample <- do.call(rbind, modified_usa_samples)
  usa_samples <- rbind(usa_samples, combined_usa_sample)
  
  modified_other_samples <- list()
  # Iterate over each element in the sublist
  for (i in seq_along(sublist)) {
    # Check if the element is a 'usa_sample' data frame
    if (length(names(sublist[[i]])) == 6 && "name" %in% names(sublist[[i]]) && "apparatus" %in% names(sublist[[i]]) && "country" %in% names(sublist[[i]])) {
            modified_other_samples[[i]] <- sublist[[i]]
    }
  }
  combined_other_sample <- do.call(rbind, modified_other_samples)
  other_samples <- rbind(other_samples, combined_other_sample)
}

# save as rds in server/sim_database
saveRDS(team_usa, "./server/sim_database/team_usa.rds")
saveRDS(apparatus_medalists, "./server/sim_database/apparatus_medalists.rds")
saveRDS(team_medalists, "./server/sim_database/team_medalists.rds")
saveRDS(individual_aa_medalists, "./server/sim_database/individual_aa_medalists.rds")
saveRDS(usa_samples, "./server/sim_database/usa_samples.rds")
saveRDS(other_samples, "./server/sim_database/other_samples.rds")
