predict_scores <- function(data, lm_models) {
  # Initialize a column for the predicted scores
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
      # Get the prediction and prediction intervals
      prediction <- predict(model, newdata = data[idx, ], 
                            interval = "prediction", 
                            level = 0.95)
      prediction <- as.data.frame(prediction)
      
      # Randomly sample within the prediction interval for each index
      random_points <- rnorm(n = nrow(prediction), 
                             mean = prediction$fit, 
                             sd = (prediction$fit - prediction$lwr) / 1.96)
      
      # Assign these random points to the predicted_score column at the correct indices
      data$predicted_score[idx] <- random_points
    }
  }
  
  return(data)
}