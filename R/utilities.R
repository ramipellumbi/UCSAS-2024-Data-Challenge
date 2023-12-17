# Selects top `n` athletes from each specified non-USA country based on total predicted score
# across all apparatuses. Excludes athletes already qualified through other means.
# Args:
#   dataframe: A dataframe containing athlete information.
#   top_countries: A list specifying top countries for each gender.
#   named_competitors: A list of already qualified competitors for each gender.
#   gender_t: Gender to filter the athletes by.
#   n: Number of top athletes to select from each country (default is 5).
# Returns:
#   A dataframe of top `n` athletes from each specified non-USA country.
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

# Retrieves the top `n` athletes not from specified top countries, based on total predicted score.
# Excludes already named competitors.
# Args:
#   dataframe: A dataframe containing athlete information.
#   top_countries: A list specifying top countries for each gender.
#   named_competitors: A list of already qualified competitors for each gender.
#   gender_t: Gender to filter the athletes by.
#   n: Number of top athletes to select.
# Returns:
#   A dataframe of top `n` athletes not from the specified top countries.
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

# Randomly selects 5 athletes from the USA for a given gender.
# Useful for simulation purposes.
# Args:
#   dataframe: A dataframe containing athlete information.
#   gender_t: Gender to filter the athletes by.
# Returns:
#   A dataframe with 5 randomly selected USA athletes of the specified gender.
get_usa_five <- function(dataframe, gender_t) {
  team_usa <- dataframe %>%
    filter(country == "USA", gender == gender_t) %>%
    slice_sample(n = 5) %>%
    dplyr::select(name) %>%
    distinct()
  
  return(team_usa)
}

# Filters athletes whose names are in the provided list.
# Args:
#   dataframe: A dataframe containing athlete information.
#   names: A list of athlete names to filter by.
# Returns:
#   A dataframe containing only the athletes whose names are in the list.
get_exact_names <- function(dataframe, names) {
  exact_names <- dataframe %>%
    filter(name %in% names) %>%
    dplyr::select(name) %>%
    distinct()
  
  return(exact_names)
}

# Wrapper function for get_top_non_usa. Processes and returns top non-USA athletes for a given gender.
# Args:
#   dataframe: A dataframe containing athlete information.
#   top_countries: A list specifying top countries for each gender.
#   named_competitors: A list of already qualified competitors for each gender.
#   gender: Gender to filter the athletes by.
# Returns:
#   A dataframe of top non-USA athletes for the given gender.
process_team_competitors <- function(dataframe, top_countries, named_competitors, gender) {
  other_countries <- get_top_non_usa(predictions, top_countries, named_competitors, gender)
  return(other_countries)
}

# Sorts athletes from a specified country and gender by their total predicted scores.
# Args:
#   dataframe: A dataframe containing athlete information.
#   country_t: Country to filter the athletes by.
#   gender_t: Gender to filter the athletes by.
# Returns:
#   A dataframe of sorted athletes from the specified country and gender.
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