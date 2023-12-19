# In the team all-around, all athletes' scores from the qualifying
# round are thrown out.
# The medalists are determined by the sum of the 3 scores on each apparatus.
# Any 3 of the 5 on the team can compete on each apparatus in the finals.
get_team_aa_medalists <- function(qualifier_team_sim,
                                  team_qualifiers,
                                  lm_models,
                                  predict_scores_from_models) {
  countries <- team_qualifiers %>%
    pull(country)

  # we select the top 3 performers from the qual round
  filtered_data <- qualifier_team_sim %>%
    filter(country %in% countries) %>%
    group_by(country, apparatus) %>%
    slice_max(predicted_score, n = 3) %>%
    ungroup() %>%
    dplyr::select(-predicted_score, -predicted_e_score)

  predictions <- predict_scores_from_models(filtered_data, lm_models)
  medalists <- predictions %>%
    group_by(country, apparatus) %>%
    slice_max(predicted_score, n = 3) %>%
    group_by(country) %>%
    summarize(total_score = sum(predicted_score)) %>%
    slice_max(total_score, n = 3) %>%
    mutate(rank = row_number(),
           medal = case_when(
             rank == 1 ~ "Gold",
             rank == 2 ~ "Silver",
             rank == 3 ~ "Bronze",
             TRUE ~ "NA"
           ))


  return(medalists)
}