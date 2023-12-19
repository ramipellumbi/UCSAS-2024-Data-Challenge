# The individual all around medalists are chosen by selecting the top 3
# summed scores of all events
get_individual_aa_medalists <- function(simulation_data,
                                        individual_final_qualifiers,
                                        lm_models,
                                        predict_scores_from_models) {
  predictions <- predict_scores_from_models(simulation_data, lm_models)
  medalists <- predictions %>%
    group_by(name, country) %>%
    summarize(total_score = sum(predicted_score), .groups = "keep") %>%
    ungroup() %>%
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