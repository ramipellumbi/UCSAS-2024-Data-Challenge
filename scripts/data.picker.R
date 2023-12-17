# for non USA countries assume they send the "best" athletes where 
# "best" is determined by total predicted score across all apparatuses
# and somebody who did NOT qualify through other means
get_top_non_usa <- function (dataframe, top_countries, named_competitors, gender_t, n = 5) {
  top_five_non_usa <- dataframe %>%
    filter(gender == gender_t & 
             country != "USA" & 
             country %in% top_countries[[gender_t]] & 
             !(name %in% named_competitors[[gender_t]])) %>%
    group_by(country, name, apparatus) %>%
    summarize(avg_for_apparatus = mean(predicted_score), .groups = "keep") %>%
    group_by(country, name) %>%
    summarize(total_score = sum(avg_for_apparatus), .groups = "keep") %>%
    arrange(country, desc(total_score)) %>%
    group_by(country) %>%
    slice_head(n = n) %>%
    dplyr::select(name) %>%
    distinct()
  
  return(top_five_non_usa)
}

get_top_remaining <- function(dataframe, top_countries, named_competitors, gender_t, n) {
  top_n_remaining <- dataframe %>%
    filter(gender == gender_t &
             !(country %in% top_countries[[gender_t]]) &
             !(name %in% named_competitors[[gender_t]])) %>%
    group_by(name, apparatus) %>%
    summarize(avg_for_apparatus = mean(predicted_score), .groups = "keep") %>%
    group_by(name) %>%
    summarize(total_score = sum(avg_for_apparatus)) %>%
    arrange(desc(total_score)) %>%
    slice_head(n = n) %>%
    dplyr::select(name) %>%
    distinct()
  
  return(top_n_remaining)
}

# For USA, we sample 5 randomly (to allow for simulations)
get_usa_five <- function(dataframe, gender_t) {
  # randomly sample 5 for this gender for USA
  team_usa <- dataframe %>%
    filter(country == "USA", gender == gender_t) %>%
    slice_sample(n = 5) %>%
    dplyr::select(name) %>%
    distinct()
  
  return(team_usa)
}

get_exact_names <- function(dataframe, names) {
  exact_names <- dataframe %>%
    filter(name %in% names) %>%
    dplyr::select(name) %>%
    distinct()
  
  return(exact_names)
}

process_team_competitors <- function(dataframe, top_countries, named_competitors, gender) {
  other_countries <- get_top_non_usa(predictions, top_countries, named_competitors, gender)
  return(other_countries)
}

order_country <- function(dataframe, country_t, gender_t) {
  sorted_country <- dataframe %>%
    filter(gender == gender_t & country == country_t) %>%
    group_by(name, apparatus) %>%
    summarize(avg_for_apparatus = mean(predicted_score), .groups = "keep") %>%
    ungroup() %>%
    group_by(name) %>%
    summarize(total_score = sum(avg_for_apparatus)) %>%
    arrange(desc(total_score)) %>%
    ungroup() %>%
    dplyr::select(name)
  
  return(sorted_country)
}

