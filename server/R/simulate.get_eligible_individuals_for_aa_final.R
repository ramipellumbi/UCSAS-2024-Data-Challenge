# Get names of people that are eligible for individual all around final.
# Athletes MUST compete on all apparatus in qualifying to be eligible
# for the individual all-around final.
get_eligible_individuals_for_aa_final <- function(data) {
  num_apparatuses <- length(unique(data$apparatus))

  individual_qualifiers <- data %>%
    # grab the people who competed in all apparatus
    group_by(name, gender, country) %>%
    summarize(num_apparatus = n(), .groups = "keep") %>%
    filter(num_apparatus == num_apparatuses) %>%
    dplyr::select(-num_apparatus)

  individual_qualifiers <- individual_qualifiers %>%
    left_join(data, by = c("name", "gender", "country"))

  return(individual_qualifiers)
}
