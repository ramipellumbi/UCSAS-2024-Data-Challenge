# Get names of people that are eligible for individual all around final.
# Athletes MUST compete on all apparatus in qualifying to be eligible
# for the individual all-around final.
get_eligible_individuals_for_aa_final <- function(data) {
  result_list <- list()
  
  for (gender_t in c("m", "w"))
  {
    apparatuses <- data %>% 
      filter(gender == gender_t) %>% 
      pull(apparatus)
    num_apparatus_for_gender = length(unique(apparatuses))
    
    individual_qualifiers <- data %>% 
      filter(gender == gender_t) %>%
      # grab the people who competed in all apparatus
      group_by(name, gender) %>% 
      summarize(num_apparatus = n(), .groups = "keep") %>%
      filter(num_apparatus == num_apparatus_for_gender) %>%
      dplyr::select(-num_apparatus)
    
    result_list[[gender_t]] <- individual_qualifiers
  }
  
  # The names in this df are ELIGIBLE for the individual all around final
  combined_result <- bind_rows(result_list)
  
  # Get the data for the selected names
  qual_data_filtered <- combined_result %>%
    inner_join(data, by = c("name", "gender"))
  
  return(qual_data_filtered)
}
