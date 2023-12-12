# The top 8 teams in qualifying advance to the team final based on the sum
# of the top 3 out of 5 scores on each apparatus
get_team_final_qualifiers <- function(data, countries_df) {
  result_list <- list()

  for (gender_t in c("m", "w")) {
    qualifiers <- data %>% 
      filter(gender == gender_t, 
             country %in% countries_df[[gender_t]]) %>% 
      group_by(country, apparatus) %>% 
      slice_max(predicted_score, n = 3) %>%
      group_by(country) %>% 
      summarize(ts = sum(predicted_score)) %>%
      slice_max(ts, n = 8)

    result_list[[gender_t]] <- qualifiers
  }

  combined_result <- bind_rows(result_list, .id = "gender")

  return(combined_result)
}