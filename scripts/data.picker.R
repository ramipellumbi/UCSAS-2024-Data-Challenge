get_top_five_non_usa <- function (dataframe, top_countries, gender_t) {
  top_five_non_usa <- dataframe %>%
    filter(gender == gender_t & 
             country != "USA" & 
             country %in% top_countries[[gender_t]]) %>%
    group_by(country, name, apparatus) %>%
    summarize(avg_for_apparatus = mean(predicted_score), .groups = "keep") %>%
    group_by(country, name) %>%
    summarize(total_score = sum(avg_for_apparatus), .groups = "keep") %>%
    arrange(country, desc(total_score)) %>%
    group_by(country) %>%
    slice_head(n = 5)
  
  return(top_five_non_usa)
}

get_usa_five <- function(dataframe, gender_t) {
  # randomly sample 5 for this gender for USA
  team_usa <- dataframe %>%
    filter(country == "USA", gender == gender_t) %>%
    slice_sample(n = 5)
  
  return(team_usa)
}

process_team_competitors <- function(dataframe, top_countries, gender) {
  team_usa <- get_usa_five(predictions, gender)
  other_countries <- get_top_five_non_usa(predictions, top_countries, gender)
  combined <- bind_rows(team_usa, other_countries)
  return(combined)
}

