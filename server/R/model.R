library(dplyr)
library(MASS)

# Fits linear models to subsets of data based on apparatus and gender combinations.
# Performs filtering of missing scores and countries, and variable selection using stepwise regression.
# Args:
#   data: A dataframe containing athlete scores and other relevant information.
# Returns:
#   A list of linear models, each corresponding to a unique combination of apparatus and gender.
fit_model <- function(data) {
  data <- data %>%
    filter(!is.na(d_score), !is.na(e_score), !is.na(name))
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
    # the idea is that d_score for an athlete is essentially fixed for an apparatus
    model <- lm(e_score ~ d_score + name,
                data = sub_df)

    selected_model <- stepAIC(model, direction = "both", trace = FALSE)
    return(selected_model)
  })

  return(models)
}

# Predicts execution scores and total scores for athletes using fitted linear models.
# Iterates through each gender and apparatus combination, applying the models to calculate scores.
# Args:
#   data: A dataframe containing athlete information and scores.
#   lm_models: A list of linear models fitted to different gender and apparatus combinations.
# Returns:
#   The original dataframe with two additional columns: predicted execution scores and total predicted scores.
predict_scores_from_models <- function(data, lm_models) {
  data$predicted_e_score <- NA
  data$predicted_score <- NA

  # Loop through each gender and apparatus combination
  for (gender_apparatus in names(lm_models)) {
    # Get the corresponding linear model
    model <- lm_models[[gender_apparatus]]

    # Extract gender and apparatus from the name
    split_values <- unlist(strsplit(gender_apparatus, split = "\\."))
    gender_t <- split_values[2]
    apparatus_t <- split_values[1]

    # Find the indices that match the current gender and apparatus
    idx <- which(data$gender == gender_t &
                   data$apparatus == apparatus_t)

    # Check if there are any matching rows
    if (length(idx) > 0) {
      newdata <- data[idx, c("all_avg_d_score", "name")]
      names(newdata)[names(newdata) == "all_avg_d_score"] <- "d_score"

      # Get the prediction and prediction intervals
      prediction <- predict(model, newdata = newdata,
                            interval = "prediction",
                            level = 0.95)
      prediction <- as.data.frame(prediction)

      # Randomly sample within the prediction interval for each index
      random_points <- rnorm(n = nrow(prediction),
                             mean = prediction$fit,
                             sd = (prediction$fit - prediction$lwr) / 1.96)

      # Assign these random points to the predicted_score column at the correct indices
      data$predicted_e_score[idx] <- random_points

      data$predicted_score[idx] <- data$predicted_e_score[idx] + data$all_avg_d_score[idx]
    }
  }

  return(data)
}