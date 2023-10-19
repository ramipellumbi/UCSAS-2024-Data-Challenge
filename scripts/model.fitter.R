library(dplyr)
library(MASS)

fit_lm_model <- function(data, rounds) {
  column_names <- colnames(data)

  columns_exist_fit_lm <- "apparatus" %in% column_names &
    "gender" %in% column_names &
    "score" %in% column_names &
    "d_score" %in% column_names &
    "e_score" %in% column_names

  stopifnot(columns_exist_fit_lm)

  data <- data[!is.na(data$score), !(names(data) %in% c("name"))] %>%
    filter(round %in% rounds)

  split_data <- data %>%
    split(., list(.$apparatus, .$gender))
  split_data <- split_data[sapply(split_data, nrow) > 0]

  # Delete gender and apparatus columns in each subset
  split_data <- lapply(split_data, function(sub_df) {
    sub_df$gender <- NULL
    sub_df$apparatus <- NULL
    return(sub_df)
  })

  # variable selection + stepwise regression
  models <- lapply(split_data, function(sub_df) {
    model <- lm(score ~ d_score + e_score, data = sub_df)
    selected_models <- stepAIC(model, direction = "both", trace = FALSE)
    return(selected_models)
  })

  return(models)
}
