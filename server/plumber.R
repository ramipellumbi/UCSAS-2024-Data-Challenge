library(doParallel)
library(foreach)
library(plumber)
library(tidyverse)

source("R/model.R")

source("./R/simulate.get_team_final_qualifiers.R")
source("./R/simulate.get_team_aa_medalists.R")

source('./R/simulate.get_eligible_individuals_for_aa_final.R')
source("./R/simulate.get_individual_aa_final_qualifiers.R")
source("./R/simulate.get_individual_aa_medalists.R")

source("./R/simulate.get_apparatus_final_qualifiers.R")
source("./R/simulate.get_apparatus_final_medalists.R")

options("plumber.port" = 7138) # client is expecting API to be hosted on this port

#* @apiTitle Gymnastics API
#* @apiDescription API for running simulations

# Enable CORS Filtering to allow requests from the client
#' @filter cors
cors <- function(req, res) {
  safe_domains <- c("http://localhost:3000") # the domain of the client is the only one allowed to make requests
  
  if (any(grepl(pattern = paste0(safe_domains,collapse="|"), req$HTTP_REFERER,ignore.case=T))) {
    res$setHeader("Access-Control-Allow-Origin", sub("/$","",req$HTTP_REFERER)) # Have to remove last slash, for some reason
    
    if (req$REQUEST_METHOD == "OPTIONS") {
      res$setHeader("Access-Control-Allow-Methods","GET,HEAD,PUT,PATCH,POST,DELETE") # This is how node.js does it
      res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
      res$status <- 200
      return(list())
    } else {
      plumber::forward()
    }
  } else {
    plumber::forward()
  }
} 

apparatuses_g <- list(m = c("FX", "PH", "SR", "VT", "PB", "HB"),
                      w = c("VT", "UB", "BB", "FX"))

#* Run a simulation for the specified gender and list of US team members for that gender
#* @post /simulate
function(req) {
  bodyList <- jsonlite::fromJSON(req$postBody)
  body <- bodyList$body

  gender_t <- body$gender[1]
  count_t <- body$count[1]
  apparatuses <- apparatuses_g[[gender_t]]
  
  # load the data
  df <- readRDS("df.rds")
  df_g <- df %>%
    filter(gender == gender_t) %>%
    dplyr::select(name, gender, country, apparatus, all_avg_d_score)
  
  
  alternates <- read.csv(paste0("alt_", gender_t, ".csv"))
  # the 36 alternates
  alternates_df <- df %>%
    filter(name %in% alternates$name) %>%
    group_by(name, gender, country, apparatus) %>%
    summarise(all_avg_d_score = first(all_avg_d_score),
              .groups = "keep") %>%
    ungroup()
  
  filename <- paste0("team_", gender_t, '.csv')
  # the 55 non usa members as part of a team
  non_usa_team_competitors <- read.csv(filename)
  
  # get the 5 USA people & their data
  filename <- paste0(gender_t, '.csv')
  non_usa_competitors <- read.csv(filename)
  usa_competitors <- body$team

  usa_options <- data.frame()
  for (apparatus_t in apparatuses) {
    apparatus_names <- body[[apparatus_t]]
    df_temp <- data.frame(name = apparatus_names,
                          country = "USA",
                          apparatus = apparatus_t,
                          gender = gender_t)

    # for each athlete, get their all_avg_d_score for this apparatus from df
    df_temp <- df_temp %>%
      left_join(df, by = c("name", "gender", "apparatus", "country")) %>%
      group_by(name, country, apparatus, gender) %>%
      summarise(all_avg_d_score = first(all_avg_d_score)) %>%
      ungroup()
    
    usa_options <- bind_rows(usa_options, df_temp)
  }

  other_options <- df_g %>%
    filter(name %in% non_usa_team_competitors$name) %>%
    group_by(name, gender, country, apparatus) %>%
    summarise(all_avg_d_score = first(all_avg_d_score),
              .groups = "keep") %>%
    ungroup()
  
  # get the models from memory
  models <- readRDS("models.rds")
  
  numCores <- detectCores() - 1
  registerDoParallel(cores = numCores)
  
  combine <- function(x, ...) {  
    mapply(rbind, x, ..., SIMPLIFY = FALSE)
  }
  
  sample_records <- data.frame()
  foreach(i = 1:1) %do% {
    other_sample <- other_options %>%
      group_by(country, name, apparatus, gender) %>%
      summarise(all_avg_d_score = mean(all_avg_d_score),
                .groups = "keep") %>%
      group_by(country, apparatus, gender) %>%
      sample_n(4, replace = FALSE) %>%
      ungroup()
    
    sample_records <- rbind(sample_records, other_sample %>% mutate(run = i) %>% dplyr::select(name, country, apparatus))
    
    country_competitors <- bind_rows(usa_sample, other_sample)
    
    results <- foreach(i = 1:count_t, .combine = combine) %dopar% {
      sim_team <- predict_scores_from_models(country_competitors,
                                             models)
      sim_alternates <- predict_scores_from_models(alternates_df,
                                                   models)
      
      # teams that qualified for the final round
      team_final_qualifiers <- get_team_final_qualifiers(sim_team)
      
      # team medalists
      team_medalists <- get_team_aa_medalists(sim_team,
                                              team_final_qualifiers,
                                              models)
      
      
      # athletes eligible for the individual aa qualifiers are ones that competed on all apparatuses
      eligible_individuals_from_team <- get_eligible_individuals_for_aa_final(sim_team)
      eligible_individuals_from_alternates <- get_eligible_individuals_for_aa_final(sim_alternates)
      # combine these with the alternates
      individual_competitors_sim <- bind_rows(eligible_individuals_from_alternates,
                                              eligible_individuals_from_team)
      # get the individual aa qualifiers
      individual_aa_final_qualifiers <- get_individual_aa_final_qualifiers(individual_competitors_sim)
      
      # athletes that received a medal in the individual aa final
      individual_aa_medalists <- get_individual_aa_medalists(individual_aa_final_qualifiers,
                                                             individual_aa_final_qualifiers,
                                                             models)
      
      # athletes that qualified for the apparatus for each apparatus final
      apparatus_final_qualifiers <- get_apparatus_final_qualifiers(bind_rows(sim_team, sim_alternates))
      apparatus_medalists <- get_apparatus_final_medalists(apparatus_final_qualifiers,
                                                           models)
      
      return(list(
        team_medalists,
        individual_aa_medalists,
        apparatus_medalists
      ))
    }
  }
  
  return(list(
    team_medalists = results[[1]],
    individual_aa_medalists = results[[2]],
    apparatus_medalists = results[[3]],
    sample_records = sample_records
  ))
}

#* @plumber
function(pr) {
    pr %>%
        # Overwrite the default serializer to return unboxed JSON
        pr_set_serializer(serializer_unboxed_json())
}
