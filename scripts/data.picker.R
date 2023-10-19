prepare_competitors <- function(df, gender_pc) {
  data <- df %>%
    filter(gender == gender_pc)

  # Get the unique apparatuses for this gender_t
  known_apparatus <- unique(data$apparatus)

  # For each person, fill in missing apparatuses with NA values
  data_expanded <- data %>%
    group_by(name, country, round) %>%
    complete(apparatus = known_apparatus) %>%
    ungroup() %>%
    group_by(name) %>%
    fill(gender) %>%
    fill(gender, .direction = "up") %>%
    fill(country) %>%
    fill(country, .direction = "up") %>%
    fill(round) %>%
    fill(round, .direction = "up") %>%
    ungroup()

  # Calculate 5th percentile each apparatus
  percentile_5th <- data %>%
    group_by(apparatus) %>%
    summarize(score_5th_percentile = quantile(score, 0.05, na.rm = TRUE),
              d_score_5th_percentile = quantile(d_score, 0.05, na.rm = TRUE),
              e_score_5th_percentile = quantile(e_score, 0.05, na.rm = TRUE),
              p_score_5th_percentile = quantile(penalty, 0.05, na.rm = TRUE),
              .groups = "keep")

  # Replace NA scores with bottom 5th percentile for that apparatus
  data_filled <- data_expanded %>%
    left_join(percentile_5th, by = "apparatus") %>%
    mutate(d_score = ifelse(is.na(d_score), d_score_5th_percentile, d_score)) %>%
    mutate(e_score = ifelse(is.na(e_score), e_score_5th_percentile, e_score)) %>%
    mutate(penalty = ifelse(is.na(penalty), p_score_5th_percentile, penalty)) %>%
    # TODO: maybe floor this to max score
    mutate(score = d_score + e_score - penalty) %>%
    dplyr::select(-score_5th_percentile, 
                  -d_score_5th_percentile, 
                  -e_score_5th_percentile, 
                  -p_score_5th_percentile)

  # Calculate the average score for each apparatus for each country
  # and compute each individuals performance difference from that average
  stats <- data_filled %>%
    group_by(country, apparatus) %>%
    # this is the average score on this apparatus for all members of the country
    # and the standard deviation
    mutate(avg_score = mean(score, na.rm = TRUE)) %>%
    ungroup() %>%
    # for each individuals performance get their difference from the group avg
    mutate(difference_from_group_average = score - avg_score) %>%
    group_by(name, country, apparatus) %>%
    mutate(avg_difference_from_group_average =
             mean(difference_from_group_average, na.rm = TRUE)) %>%
    ungroup() %>%
    dplyr::select(name, 
                  country, 
                  apparatus, 
                  gender,
                  d_score, 
                  e_score,
                  score,
                  avg_score, difference_from_group_average, 
                  avg_difference_from_group_average, 
                  round)

  return(stats)
}

sample_five <- function(data) {
  if (nrow(data) <= 5) {
    return(data)
  }
  
  positive_data <- data %>% filter(avg_across_aparatus > 0)
  
  if (nrow(positive_data) >= 5) {
    return(positive_data %>% slice_sample(n = 5))
  } else {
    return(data %>% slice_head(n = 5))
  }
}


select_5_competitors_for_countries <- function(stats, df_top_countries, gender_t) {
  top_countries_m <- df_top_countries[[gender_t]]

  top_5_non_usa <- stats %>%
    filter(country %in% top_countries_m & country != "USA") %>%
    group_by(country, name) %>%
    summarize(avg_across_aparatus = mean(avg_difference_from_group_average,
                                         na.rm = TRUE), .groups = "keep") %>%
    group_by(country) %>%
    slice_max(avg_across_aparatus, n =5) %>%
    ungroup()
  
  
  top_5_usa <- stats %>%
    filter(country == "USA") %>%
    group_by(country, name) %>%
    summarize(avg_across_aparatus = mean(avg_difference_from_group_average,
                                         na.rm = TRUE), .groups = "keep") %>%
    group_by(country) %>%
    nest() %>%
    mutate(data = map(data, sample_five)) %>%
    unnest(data)
  
  
  top_5 <- bind_rows(top_5_non_usa, top_5_usa)
  
  top_5$gender = gender_t

  return(top_5)
}

get_alternate <- function(all_data, top_countries, gendered_data, gender_t) {
  alternate <- df_filled %>%
    filter(gender == gender_t) %>%
    anti_join(qualified_m, by = c("country", "gender")) %>%
    filter(!(country %in% top_countries[[gender_t]])) %>%
    group_by(name, country, gender) %>%
    summarize(avg_across_aparatus = mean(avg_difference_from_group_average), .groups = "drop") %>%
    arrange(desc(avg_across_aparatus)) %>%
    slice_head(n = 36)
  

  return(alternate)
}