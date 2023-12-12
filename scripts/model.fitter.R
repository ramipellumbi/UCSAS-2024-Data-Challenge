library(dplyr)
library(lme4)

fit_lm_model <- function(data) {
  data <- data %>%
    filter(!is.na(d_score), !is.na(e_score), !is.na(country))
  split_data <- data %>%
    split(., list(.$apparatus, .$gender))
  split_data <- split_data[sapply(split_data, nrow) > 0]

  # Delete gender and apparatus columns in each subset
  split_data <- lapply(split_data, function(sub_df) {
    sub_df$gender <- NULL
    sub_df$apparatus <- NULL
    return(sub_df)
  })

  # variable selection + step wise regression
  models <- lapply(split_data, function(sub_df) {
    # the idea is that d_score for an athlete is essentially fixed
    model <- lm(e_score ~ d_score + name,
                data = sub_df)

    selected_model <- stepAIC(model, direction = "both", trace = FALSE)
    return(selected_model)
  })

  return(models)
}
