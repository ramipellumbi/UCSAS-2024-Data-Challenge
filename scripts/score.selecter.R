individual_aa_medalists <- c("individual_aa_medalists_simulations_results")
team_aa_medalist <- c("team_aa_medalists_simulations_results")
apparatus_medalist <- c("apparatus_medalists_simulations_results")

## sample 1 for each score_simulation
# individual aa
individual_aa <- read.csv(paste0('output_csvs/', individual_aa_medalists, ".csv")) 
file.remove(paste0("output_csvs/", individual_aa_medalists, '.csv'))

df_update <- individual_aa %>%
  arrange(run_simulation, sample_simulation, score_simulation, gender, medal) %>%
  group_by(run_simulation, sample_simulation, score_simulation) %>%
  mutate(identifier = paste(gender, name, medal, country, collapse = "|")) %>%
  summarise(identifier = first(identifier), .groups = "keep") %>%
  ungroup()

mode_group <- df_update %>%
  group_by(run_simulation, sample_simulation) %>%
  count(identifier, sort = TRUE) %>%
  top_n(1, wt = n) %>%
  sample_n(1, replace = FALSE)

updated_csv <- mode_group %>%
  separate_rows(identifier, sep = "\\|") %>%
  mutate(gender = substr(identifier, 1, 1),
         country = substr(identifier, nchar(identifier) - 2 ,nchar(identifier)),
         name_medal = substr(identifier, 3, nchar(identifier) - 4),
         name = gsub(" [A-Za-z]+$", "", name_medal), 
         medal = gsub(".* ", "", name_medal)) %>%
  dplyr::select(gender, name, country, medal)

write.csv(file = paste0("output_csvs/", individual_aa_medalists, '.csv'),  
          x = updated_csv)


# team aa
team_aa <- read.csv(paste0('output_csvs/', team_aa_medalist, ".csv")) 
file.remove(paste0("output_csvs/", team_aa_medalist, '.csv'))
df_update <- team_aa %>%
  arrange(run_simulation, sample_simulation, score_simulation, gender, medal) %>%
  group_by(run_simulation, sample_simulation, score_simulation) %>%
  mutate(identifier = paste(gender, medal, country, collapse = "|")) %>%
  summarise(identifier = first(identifier), .groups = "keep") %>%
  ungroup()

mode_group <- df_update %>%
  group_by(run_simulation, sample_simulation) %>%
  count(identifier, sort = TRUE) %>%
  top_n(1, wt = n) %>%
  sample_n(1, replace = FALSE)

updated_csv <- mode_group %>%
  separate_rows(identifier, sep = "\\|") %>%
  mutate(gender = substr(identifier, 1, 1),
         country = substr(identifier, nchar(identifier) - 2 ,nchar(identifier)),
         medal = substr(identifier, 3, nchar(identifier) - 4)) %>%
  dplyr::select(gender, country, medal)

write.csv(file = paste0("output_csvs/", team_aa_medalist, '.csv'),  
            x = updated_csv)


# apparatus
apparatus <- read.csv(paste0('output_csvs/', apparatus_medalist, ".csv")) 
file.remove(paste0("output_csvs/", apparatus_medalist, '.csv'))
df_update <- apparatus %>%
  filter(score_simulation == 3) %>%
  dplyr::select(-score_simulation)

write.csv(file = paste0("output_csvs/", apparatus_medalist, '.csv'),  
          x = df_update)
  