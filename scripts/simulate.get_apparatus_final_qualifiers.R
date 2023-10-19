# The top 8 athletes on each apparatus qualify for the final in that apparatus, 
# again with a maximum of 2 gymnasts per country.
get_apparatus_final_qualifiers <- function(data)
{
  apparatus_final_qualifiers <- data %>% 
    group_by(apparatus, country, gender) %>%
    slice_max(predicted_score, n = 2) %>%
    ungroup() %>%
    group_by(apparatus, gender) %>%
    slice_max(predicted_score, n = 8) %>%
    ungroup()
  
  return(apparatus_final_qualifiers)
}