# The top 8 teams in qualifying advance to the team final based on the sum
# of the top 3 out of 5 scores on each apparatus
get_team_final_qualifiers <- function(data) {
  qualifiers <- data %>% 
    group_by(country, apparatus) %>% 
    slice_max(predicted_score, n = 3) %>%
    group_by(country) %>% 
    summarize(ts = sum(predicted_score)) %>%
    slice_max(ts, n = 8)

  return(qualifiers)
}