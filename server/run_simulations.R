# PREREQUISITE: must have generated the models and date by sourcing R/script.prepare_data_and_models
library(doParallel)
library(doRNG)

source("server/R/model.R")

source("server/R/simulate.get_team_final_qualifiers.R")
source("server/R/simulate.get_team_aa_medalists.R")

source("server/R/simulate.get_eligible_individuals_for_aa_final.R")
source("server/R/simulate.get_individual_aa_final_qualifiers.R")
source("server/R/simulate.get_individual_aa_medalists.R")

source("server/R/simulate.get_apparatus_final_qualifiers.R")
source("server/R/simulate.get_apparatus_final_medalists.R")

# set seed and RNGkind for reproducibility
set.seed(123)
RNGkind("Mersenne-Twister")

# utility function for dopar
combine <- function(x, ...) {
  mapply(rbind, x, ..., SIMPLIFY = FALSE)
}

# utility function for checkpoints
save_results <- function(results, filename) {
  saveRDS(results, file = filename)
}

# constants for simulations
TEAM_SIM <- 90 # number of different teams of 5 to try for USA
SAMPLE_SIM <- 15 # number of different samples of 4 to try for each apparatus (for the chosen team of 5)
RUN <- 5  # number of runs to do in each simulation

# set up parallel execution
num_cores <- detectCores() - 1
registerDoParallel(cores = num_cores)

# data preparation
df <- readRDS("server/processed_data/df.rds")
models <- readRDS("server/processed_data/models.rds")
df <- df %>%
  dplyr::select(name, gender, country, apparatus, all_avg_d_score)

# read the men and women teams and place into list
non_usa_m <- read.csv("server/processed_data/team_m.csv")
non_usa_w <- read.csv("server/processed_data/team_w.csv")

non_usa_df_m <- df %>%
  filter(gender == "m", name %in% non_usa_m$name) %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup()

non_usa_df_w <- df %>%
  filter(gender == "w", name %in% non_usa_w$name) %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup()

non_usa_team <- list(m = non_usa_df_m, w = non_usa_df_w)

# read the men and women alternates and place into list
alternates_m <- read.csv("server/processed_data/alt_m.csv")
alternates_w <- read.csv("server/processed_data/alt_w.csv")

alternates_df_m <- df %>%
  filter(name %in% alternates_m$name) %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup()

alternates_df_w <- df %>%
  filter(name %in% alternates_w$name) %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup()

alternates <- list(m = alternates_df_m, w = alternates_df_w)

# get possible USA competitors - IMPORTANT: this is restricted to people who could compete on every apparatus
usa_df_m <- df %>%
  filter(gender == "m", country == "USA") %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup() %>%
  group_by(name, gender) %>%
  filter(length(unique(apparatus)) == 6) %>%
  ungroup()

usa_df_w <- df %>%
  filter(gender == "w", country == "USA") %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup() %>%
  group_by(name, gender) %>%
  filter(length(unique(apparatus)) == 4) %>%
  ungroup()


usa <- list(m = usa_df_m, w = usa_df_w)

results <- results <- lapply(c("m", "w"), function(gender_t) {
  # dorng makes sure sound random numbers (read: reproducible) are generated in parallel. Otherwise, even with
  # the same seed you will get different simulation results. It wraps dopar so this is parallel execution
  team_results <- foreach(team_sim = 1:TEAM_SIM,
                          .export = c("alternates", "usa", "non_usa_team", "models"),
                          .combine = "c") %dorng% {
    alternates_df <- alternates[[gender_t]]
    usa_df <- usa[[gender_t]]
    other_options <- non_usa_team[[gender_t]]

    # sample team of 5 for team USA
    usa_options <- usa_df %>%
      sample_n(5, replace = FALSE) %>%
      mutate(run = team_sim)

    # sample different pairings of 4 for each apparatus (for USA and non USA)
    sample_results <- foreach(sample_sim = 1:SAMPLE_SIM, .combine = "c") %do% {
      usa_sample <- usa_df %>%
        filter(name %in% usa_options$name) %>%
        group_by(apparatus) %>%
        sample_n(4, replace = FALSE) %>%
        ungroup()
      other_sample <- other_options %>%
        group_by(country, name, apparatus, gender) %>%
        summarise(all_avg_d_score = mean(all_avg_d_score),
                  .groups = "keep") %>%
        group_by(country, apparatus, gender) %>%
        sample_n(4, replace = FALSE) %>%
        ungroup()

      usa_sample$run <- team_sim
      usa_sample$sample <- sample_sim
      other_sample$run <- team_sim
      other_sample$sample <- sample_sim

      country_competitors <- bind_rows(usa_sample, other_sample)

      # run multiple simulations for this pairing
      run_results <- foreach(run = 1:RUN, .combine = combine) %do% {
        # all 96 men and women compete in qualifications -
        # this is the 36 alternates AND the

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

        apparatus_medalists$simulation_num <- run
        apparatus_medalists$sample <- sample_sim
        apparatus_medalists$run <- team_sim
        apparatus_medalists$gender <- gender_t

        individual_aa_medalists$simulation_num <- run
        individual_aa_medalists$sample <- sample_sim
        individual_aa_medalists$run <- team_sim
        individual_aa_medalists$gender <- gender_t

        team_medalists$simulation_num <- run
        team_medalists$sample <- sample_sim
        team_medalists$run <- team_sim
        team_medalists$gender <- gender_t

        list(team_medalists = team_medalists,
             individual_aa_medalists = individual_aa_medalists,
             apparatus_medalists = apparatus_medalists)
      }
      list(sample_sim_results = run_results,
           usa_sample = usa_sample %>% dplyr::select(name, apparatus, gender, run, sample),
           other_sample = other_sample %>% dplyr::select(name, apparatus, country, gender, run, sample))
    }
    results_filename <- paste0("server/simulation_results/results_team_sim_", gender_t, "_", team_sim, ".rds")
    save_results(list(team_sim_results = sample_results,
                      usa_team = usa_options %>% dplyr::select(name, run, gender)),
                 results_filename)

    list(team_sim_results = sample_results,
         usa_team = usa_options %>% dplyr::select(name))
  }
  final_results <- setNames(list(team_results), gender_t)
  final_results
})
