source("./scripts/model.predictor.R")

# In the team all-around, all athletes' scores from the qualifying
# round are thrown out.
# The medalists are determined by the sum of the 3 scores on each apparatus.
get_team_aa_medalists <- function(simulation_data,
                                  team_qualifiers,
                                  lm_models)
{
  result_list <- list()
  
  for (gender_t in c("m", "w"))
  {
    countries <- team_qualifiers %>% 
      filter(gender == gender_t) %>% 
      pull(country)
    
    filtered_data <- simulation_data %>%
      filter(country %in% countries, 
             gender == gender_t)
    
    predictions <- predict_scores(filtered_data, lm_models)
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
    
    result_list[[gender_t]] <- medalists
  }
  
  combined_result <- bind_rows(result_list, .id = "gender")  %>%
    dplyr::select(-rank)
  
  return(combined_result)
}