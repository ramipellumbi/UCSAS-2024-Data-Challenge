source("./R/model.R")

# The individual all around medalists are chosen by selecting the top 3
# summed scores of all events
get_apparatus_final_medalists <- function(simulation_data,
                                          lm_models) {
  predictions <- predict_scores_from_models(simulation_data, lm_models)
  medalists <- predictions %>%
    group_by(apparatus) %>%
    slice_max(predicted_score, n = 3) %>%
    mutate(rank = row_number(),
           medal = case_when(
             rank == 1 ~ "Gold",
             rank == 2 ~ "Silver",
             rank == 3 ~ "Bronze",
             TRUE ~ "NA"
           )) %>%
    dplyr::select(name, gender, country, apparatus, rank, medal, predicted_score)

  return(medalists)
}