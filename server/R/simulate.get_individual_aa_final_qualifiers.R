# The top 24 athletes qualify for the individual all around final,
# with a maximum of 2 gymnasts per country.
get_individual_aa_final_qualifiers <- function(eligible_individuals) {
  top_qualifiers <- eligible_individuals %>%
    group_by(name, country) %>%
    summarize(ts = sum(predicted_score), .groups = "keep") %>%
    group_by(country) %>%
    slice_max(ts, n = 2) %>%
    ungroup() %>%
    slice(1:24)

  top_qualifiers <- top_qualifiers %>%
    left_join(eligible_individuals, by = c("name", "country")) %>%
    dplyr::select(-predicted_e_score, -predicted_score)

  return(top_qualifiers)
}