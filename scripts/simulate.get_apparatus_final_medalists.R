source("./scripts/model.predictor.R")

# The individual all around medalists are chosen by selecting the top 3
# summed scores of all events
get_apparatus_final_medalists <- function(simulation_data,
                                          apparatus_final_qualifiers,
                                          lm_models) {
  result_list <- list()

  for (gender_t in c("m", "w")) {
    names <- apparatus_final_qualifiers$name

    filtered_data <- simulation_data %>%
      filter(name %in% names,
             gender == gender_t)

    predictions <- predict_scores(filtered_data, lm_models)
    medalists <- predictions %>%
      group_by(apparatus) %>%
      slice_max(predicted_score, n = 3) %>%
      mutate(rank = row_number(),
             medal = case_when(
               rank == 1 ~ "Gold",
               rank == 2 ~ "Silver",
               rank == 3 ~ "Bronze",
               TRUE ~ "NA"
             ))

    result_list[[gender_t]] <- medalists
  }

  combined_result <- bind_rows(result_list, .id = "gender") %>%
    dplyr::select(name,
                  gender,
                  country,
                  apparatus,
                  medal,
                  predicted_score)

  return(combined_result)
}