
medalists <- c("individual_aa_medalists_simulations_results",
               "team_aa_medalists_simulations_results",
               "apparatus_medalists_simulations_results")
usa_team <- c("usa_qualified_competitors")
apparatus_competitors <- c("apparatus_country_competitors")

team <- read.csv(paste0('output_csvs/', usa_team, ".csv")) 
apparatus_name <- read.csv(paste0('output_csvs/', apparatus_competitors, ".csv")) 

for (file in medalists) {
  medalist_file <- read.csv(paste0('output_csvs/', file, ".csv")) 
  team_m <- team %>%
    filter(gender == "m") %>%
    group_by(run_simulation) %>%
    summarise(team_m = paste(name, collapse = ","))
  
  team_w <- team %>%
    filter(gender == "w") %>%
    group_by(run_simulation) %>%
    summarise(team_w = paste(name, collapse = ","))
  
  fx_m <- apparatus_name %>%
    filter(country == "USA",
           gender == "m",
           apparatus == "fx") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(fx_m = paste(name, collapse = ","))
  
  hb_m <- apparatus_name %>%
    filter(country == "USA",
           gender == "m",
           apparatus == "hb") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(hb_m = paste(name, collapse = ","))
  
  # men apparatus
  pb_m <- apparatus_name %>%
    filter(country == "USA",
           gender == "m",
           apparatus == "pb") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(pb_m = paste(name, collapse = ","))
  
  ph_m <- apparatus_name %>%
    filter(country == "USA",
           gender == "m",
           apparatus == "ph") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(ph_m = paste(name, collapse = ","))
  
  sr_m <- apparatus_name %>%
    filter(country == "USA",
           gender == "m",
           apparatus == "sr") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(sr_m = paste(name, collapse = ","))
  
  vt_m <- apparatus_name %>%
    filter(country == "USA",
           gender == "m",
           apparatus == "vt") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(vt_m = paste(name, collapse = ","))
  
  # women apparatus
  bb_w <- apparatus_name %>%
    filter(country == "USA",
           gender == "w",
           apparatus == "bb") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(bb_w = paste(name, collapse = ","))
  
  fx_w <- apparatus_name %>%
    filter(country == "USA",
           gender == "w",
           apparatus == "fx") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(fx_w = paste(name, collapse = ","))
  
  ub_w <- apparatus_name %>%
    filter(country == "USA",
           gender == "w",
           apparatus == "ub") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(ub_w = paste(name, collapse = ","))
  
  vt_w <- apparatus_name %>%
    filter(country == "USA",
           gender == "w",
           apparatus == "vt") %>%
    group_by(run_simulation, sample_simulation) %>%
    summarise(vt_w = paste(name, collapse = ","))
  
  # Left join medalist dataset
  updated_medalist <- medalist_file %>%
    left_join(team_m, by = "run_simulation") %>%
    left_join(team_w, by = "run_simulation") %>% 
    left_join(fx_m, by = c("run_simulation", "sample_simulation")) %>%
    left_join(hb_m, by = c("run_simulation", "sample_simulation")) %>%
    left_join(pb_m, by = c("run_simulation", "sample_simulation")) %>%
    left_join(ph_m, by = c("run_simulation", "sample_simulation")) %>%
    left_join(sr_m, by = c("run_simulation", "sample_simulation")) %>%
    left_join(vt_m, by = c("run_simulation", "sample_simulation")) %>%
    left_join(bb_w, by = c("run_simulation", "sample_simulation")) %>%
    left_join(fx_w, by = c("run_simulation", "sample_simulation")) %>%
    left_join(ub_w, by = c("run_simulation", "sample_simulation")) %>%
    left_join(vt_w, by = c("run_simulation", "sample_simulation")) 
  
  write.csv(file = paste0("submission_csvs/", file, '.csv'),  
            x = updated_medalist)
}
