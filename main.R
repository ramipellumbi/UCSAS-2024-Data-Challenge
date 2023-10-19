library(tidyverse)

setwd("/Users/zihanwang/Documents/GitHub/case-studies/1-Gymnastics")

source("./scripts/data.getter.R")
source("./scripts/data.picker.R")
source("./scripts/data.prepper.R")
source("./scripts/data.saver.R")

source("./scripts/model.fitter.R")
source("./scripts/model.predictor.R")

source("./scripts/simulate.get_apparatus_final_qualifiers.R")
source("./scripts/simulate.get_apparatus_final_medalists.R")
source("./scripts/simulate.get_eligible_individuals_for_aa_final.R")
source("./scripts/simulate.get_individual_aa_final_qualifiers.R")
source("./scripts/simulate.get_individual_aa_medalists.R")
source("./scripts/simulate.get_team_aa_medalists.R")
source("./scripts/simulate.get_team_final_qualifiers.R")

df <- prepare_data(get_data())
top_countries <- read_csv("./cleandata/top_countries.csv",
                          show_col_types = FALSE)

df_filled_m <- prepare_competitors(df, "m")
df_filled_w <- prepare_competitors(df, "w")
df_filled <- bind_rows(df_filled_m, df_filled_w)

# get a model for each (apparatus, gender) pair
lm_model_qual <- fit_lm_model(df_filled, c("AAqual", "qual")) # all qual data
lm_model_teamqual <- fit_lm_model(df_filled, "qual") # team qual
lm_model_final <- fit_lm_model(df_filled, c("TeamFinal", "final", "AAfinal")) # Finals

for (run_simulation in 1:200)
{
  if (run_simulation %% 2 == 0 || run_simulation == 1)
  {
    cat("On simulation", run_simulation, "\n")
  }
  # Getting all competitors
  qualified_m <- select_5_competitors_for_countries(df_filled_m, top_countries, "m")
  qualified_w <- select_5_competitors_for_countries(df_filled_w, top_countries, "w")
  qualified   <- bind_rows(qualified_m, qualified_w)
  alternate_m <- get_alternate(df_filled_m, top_countries, qualified_m, "m")
  alternate_w <- get_alternate(df_filled_w, top_countries, qualified_w, "w")
  alternates  <- bind_rows(alternate_m, alternate_w)

  # these are the 96 men and 96 women competing in the olympics
  qualified_competitors <- bind_rows(qualified_m,
                                     qualified_w,
                                     alternate_m,
                                     alternate_w)

  qualified_competitors$run_simulation = run_simulation

  # 5-person team
  write_simulation_result(qualified_competitors %>%
                            filter(country == "USA") %>%
                            dplyr::select(-avg_across_aparatus), "usa_qualified_competitors.csv")

  for (sample_simulation in 1:5)
  {
    # extracting from the filled in data frame all the data for our 182 competitors
    simulation_data <- df_filled %>%
      filter(name %in% unique(qualified_competitors$name)) %>%
      group_by(name,
               gender,
               country,
               apparatus) %>%
      summarize(score = mean(score),
                d_score = mean(d_score),
                e_score = mean(e_score),
                difference_from_group_average = mean(difference_from_group_average),
                .groups = "keep")

    # select 4 people for each apparatus from the qualifying countries
    # all alternates can compete in every apparatus
    country_competitors_usa <- simulation_data %>%
      filter(country == "USA" ,
             name %in% qualified$name) %>%
      group_by(gender, country, apparatus) %>%
      sample_n(4, replace = FALSE)


    country_competitors_non_usa <- simulation_data %>%
      filter(country %in% top_countries[["m"]] |
               country %in% top_countries[["w"]] ,
             country != "USA",
             name %in% qualified$name) %>%
      group_by(gender, country, apparatus) %>%
      arrange(desc(difference_from_group_average)) %>%
      slice_head(n = 4)

    country_competitors <- bind_rows(country_competitors_usa, country_competitors_non_usa)

    alternate_competitors <- simulation_data %>%
      filter(name %in% alternates$name,
             country %in% alternates$country)

    country_competitors$run_simulation = run_simulation
    country_competitors$sample_simulation = sample_simulation

    # 4-person chosen for each apparatus
    write_simulation_result(country_competitors %>%
                              dplyr::select(-score, -d_score,-e_score,-difference_from_group_average),
                            "apparatus_country_competitors.csv")


    for (score_simulation in c(1:5))
    {
      # Get the predicted scores of each competitor on each apparatus
      qual_data_for_country_competitors <-  predict_scores(country_competitors, lm_model_teamqual)
      qual_data_for_alternate_competitors <- predict_scores(alternate_competitors, lm_model_teamqual)

      # qualifying teams
      team_qualifiers <- get_team_final_qualifiers(qual_data_for_country_competitors,
                                                   top_countries)

      # team final medalists
      team_aa_medalists <- get_team_aa_medalists(simulation_data,
                                                 team_qualifiers,
                                                 lm_model_final)


      # athletes eligible for the individual aa qualifiers
      eligible_individuals_aa_final <- get_eligible_individuals_for_aa_final(qual_data_for_country_competitors)


      # these individuals compete in the aa qualifiers
      competitors_to_simulate_individual <- bind_rows(eligible_individuals_aa_final,
                                                      qual_data_for_alternate_competitors)

      # athletes that qualified for the individual aa final from the eligible for aa finals list
      individual_aa_final_qualifiers <- get_individual_aa_final_qualifiers(competitors_to_simulate_individual)

      # athletes that received a medal in the individual aa
      individual_aa_medalists <- get_individual_aa_medalists(competitors_to_simulate_individual,
                                                             individual_aa_final_qualifiers,
                                                             lm_model_final)

      # the people from each country who competed plus alternates
      competitors_to_simulate_apparatus <- bind_rows(
        country_competitors,
        alternate_competitors
      )
      qual_data_apparatus <- predict_scores(competitors_to_simulate_apparatus, lm_model_qual)

      # athletes that qualified for the apparatus finals
      apparatus_final_qualifiers <- get_apparatus_final_qualifiers(qual_data_apparatus)

      # athletes that received a medal in the apparatus finals
      apparatus_medalists <- get_apparatus_final_medalists(competitors_to_simulate_apparatus,
                                                           apparatus_final_qualifiers,
                                                           lm_model_final)



      apparatus_medalists$run_simulation <- run_simulation
      apparatus_medalists$sample_simulation <- sample_simulation
      apparatus_medalists$score_simulation <- score_simulation
      write_simulation_result(apparatus_medalists, "apparatus_medalists_simulations_results.csv")

      individual_aa_medalists$run_simulation <- run_simulation
      individual_aa_medalists$sample_simulation <- sample_simulation
      individual_aa_medalists$score_simulation <- score_simulation
      write_simulation_result(individual_aa_medalists, "individual_aa_medalists_simulations_results.csv")

      team_aa_medalists$run_simulation <- run_simulation
      team_aa_medalists$sample_simulation <- sample_simulation
      team_aa_medalists$score_simulation <- score_simulation
      write_simulation_result(team_aa_medalists, "team_aa_medalists_simulations_results.csv")
    }
  }
}

write_simulation_result(qualified_competitors %>%
                          filter(country != "USA") %>%
                          dplyr::select(-avg_across_aparatus, -run_simulation), "non_usa_qualified_competitors.csv")

write_simulation_result(alternates %>%
                          dplyr::select(-avg_across_aparatus),
                        "alternate_competitors.csv")
