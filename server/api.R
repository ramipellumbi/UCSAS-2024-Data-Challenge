library(doParallel)
library(foreach)
library(plumber)
library(tidyverse)

# plumber creates its own environment not associated with .GlobalEnv
# local=TRUE lets it source the data from this specific .R
source("./api-data-load.R", local = TRUE)
source("R/model.R")

source("./R/simulate.get_team_final_qualifiers.R")
source("./R/simulate.get_team_aa_medalists.R")

source("./R/simulate.get_eligible_individuals_for_aa_final.R")
source("./R/simulate.get_individual_aa_final_qualifiers.R")
source("./R/simulate.get_individual_aa_medalists.R")

source("./R/simulate.get_apparatus_final_qualifiers.R")
source("./R/simulate.get_apparatus_final_medalists.R")

options("plumber.port" = 7138) # client is expecting API to be hosted on PORT 7138
num_cores <- detectCores() - 1
registerDoParallel(cores = num_cores)

# utility function for dopar
combine <- function(x, ...) {
  mapply(rbind, x, ..., SIMPLIFY = FALSE)
}


#* @apiTitle Gymnastics API
#* @apiDescription API for running simulations

# Enable CORS Filtering to allow requests from the client
#' @filter cors
cors <- function(req, res) {
  safe_domains <- c("http://localhost:3000") # the domain of the client is the only one allowed to make requests

  if (any(grepl(pattern = paste0(safe_domains, collapse = "|"), req$HTTP_REFERER, ignore.case = TRUE))) {
    # Have to remove last slash, for some reason
    res$setHeader("Access-Control-Allow-Origin", sub("/$", "", req$HTTP_REFERER))

    if (req$REQUEST_METHOD == "OPTIONS") {
      res$setHeader("Access-Control-Allow-Methods", "GET,HEAD,PUT,PATCH,POST,DELETE") # This is how node.js does it
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

#* Run a simulation for the specified gender and list of US team members for that gender
#* @post /simulate
#* @param body:object
function(req) {
  body_list <- jsonlite::fromJSON(req$postBody)
  body <- body_list$body

  gender_t <- body$gender[1]
  count_t <- body$count[1]
  apparatuses <- apparatuses_g[[gender_t]]

  # load the data
  df_g <- df %>%
    filter(gender == gender_t)

  # the 36 alternates
  alternates_df <- alternates[[gender_t]]
  # the 55 non usa team people
  other_options <- non_usa_team[[gender_t]]

  # get the 5 USA people & their data
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

  other_sample <- other_options %>%
    group_by(country, name, apparatus, gender) %>%
    summarise(all_avg_d_score = mean(all_avg_d_score),
              .groups = "keep") %>%
    group_by(country, apparatus, gender) %>%
    sample_n(4, replace = FALSE) %>%
    ungroup()

  sample_records <- other_sample %>% dplyr::select(name, country, apparatus)

  country_competitors <- bind_rows(usa_options, other_sample)

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
                                            models,
                                            predict_scores_from_models)

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
                                                           models,
                                                           predict_scores_from_models)

    # athletes that qualified for the apparatus for each apparatus final
    apparatus_final_qualifiers <- get_apparatus_final_qualifiers(bind_rows(sim_team, sim_alternates))
    apparatus_medalists <- get_apparatus_final_medalists(apparatus_final_qualifiers,
                                                         models,
                                                         predict_scores_from_models)

    return(list(
      team_medalists,
      individual_aa_medalists,
      apparatus_medalists
    ))
  }

  return(list(
    team_medalists = results[[1]],
    individual_aa_medalists = results[[2]],
    apparatus_medalists = results[[3]],
    other_options = other_options %>% distinct(name, country),
    sample_records = sample_records
  ))
}

#* Get simulations for a gender and team of 5
#* @get /explore
#* @param gender_t
#* @param team
function(gender_t, team) {
  team_usa_f <- team_usa %>%
    filter(gender == gender_t) %>%
    group_by(run) %>%
    summarize(competitors = list(name)) %>%
    filter(sapply(competitors, function(x) setequal(x, team)))

  total_runs_with_team <- length(team_usa_f$run)

  usa_samples_f <- usa_samples %>%
    filter(run %in% team_usa_f$run)
  other_samples_f <- other_samples %>%
    filter(run %in% team_usa_f$run)

  other_options <- non_usa_team[[gender_t]]
  total_samples_per_run_f <- length(unique(usa_samples_f$sample))

  team_medalists_f <- team_medalists %>%
    filter(run %in% team_usa_f$run, gender == gender_t) %>%
    group_by(country, medal, run, sample) %>%
    summarise(count = n(),
              .groups = "keep")
  individual_aa_medalists_f <- individual_aa_medalists %>%
    filter(run %in% team_usa_f$run, gender == gender_t) %>%
    group_by(name, medal, country, run, sample) %>%
    summarise(count = n(),
              .groups = "keep")
  apparatus_medalists_f <- apparatus_medalists %>%
    filter(run %in% team_usa_f$run, gender == gender_t) %>%
    group_by(name, country, apparatus, medal, run, sample) %>%
    summarise(count = n(),
              .groups = "keep")

  list(usa_samples = usa_samples_f,
       other_samples = other_samples_f,
       team_medalists = team_medalists_f,
       other_options = other_options %>% distinct(name, country),
       individual_aa_medalists = individual_aa_medalists_f,
       apparatus_medalists = apparatus_medalists_f,
       total_samples_per_run = total_samples_per_run_f,
       total_runs_with_team = total_runs_with_team)
}

#* @plumber
function(pr) {
  pr %>%
    # Overwrite the default serializer to return unboxed JSON
    pr_set_serializer(serializer_unboxed_json())
}
