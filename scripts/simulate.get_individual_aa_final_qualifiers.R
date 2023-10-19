# The top 24 athletes qualify for the individual all around final,
# with a maximum of 2 gymnasts per country.
get_individual_aa_final_qualifiers <- function(eligible_individuals)
{
  result_list <- list()
  
  for (gender_t in c("m", "w"))
  {
    top_qualifiers = eligible_individuals %>%
      filter(gender == gender_t) %>%
      group_by(name, country) %>%
      summarize(predicted_score = sum(predicted_score), .groups = "keep") %>%
      group_by(country) %>%
      slice_max(predicted_score, n = 2) %>%
      ungroup() %>%
      slice(1:24)
    
    result_list[[gender_t]] <- top_qualifiers
  }
  
  combined_result <- bind_rows(result_list, .id = "gender")
  
  return (combined_result)

}