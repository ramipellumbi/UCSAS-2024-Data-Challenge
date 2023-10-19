# Split data based on gender and apparatus
split_data <- data %>%
  split(., list(.$apparatus, .$gender))
split_data <- split_data[sapply(split_data, nrow) > 0]

# Delete gender and apparatus columns in each subset
split_data <- lapply(split_data, function(sub_df) {
  sub_df$gender <- NULL
  sub_df$apparatus <- NULL
  return(sub_df)
})

linear_models <- lapply(split_data, function(sub_df) {
  lm(score ~ country + competition + round + name + start_date + end_date,
     data = sub_df)
})

model_summaries <- lapply(linear_models, summary)

# Vaiable selection
## Stepwise Regression
selected_models <- lapply(linear_models, function(model) {
  step(model, direction = "both", trace = 0)
})
selected_model_summaries <- lapply(selected_models, summary)

## LASSO Regression
lasso_models <- lapply(list_of_dfs, function(sub_df) {
  y <- sub_df$score
  x <- model.matrix(score ~ country + competition + round
                    + name + start_date + end_date, data = sub_df)
  lasso_model <- cv.glmnet(x, y, alpha=1)
})

### Inspect the coefficients for FX.m
coef.FX.m <- coef(lasso_cv_models$FX.m, s = lasso_cv_models$FX.m$lambda.min)


# Logistic Regression
data <- data %>%
  group_by(apparatus, gender) %>%
  mutate(highest_score = ifelse(score == max(score), 1, 0))

logistic_model <- glm(highest_score ~ country + competition + round
                      + name + start_date + end_date,
                      family = binomial, data = data)
summary(logistic_model)
