# This R script is designed to output the non USA competitors that will be present 
# in the 2024 Paris Olympics for men and women.

# The main part of the script involves fitting linear models for each (apparatus, gender) pair,
# followed by predicting execution scores for every athlete. These predictions are then used to
# select competitors for countries that have not named their competitors via the criteria.

# The script outputs a csv file for the non men and women competitors.
# The script outputs a JSON file to the client of all possible USA competitors, sorted by "total score".

# Note: This script assumes that all required data is available and correctly formatted in the specified paths.
# It also assumes the presence of specific functions and data in the sourced R scripts.

library(tidyverse)

source("./data.R")
source("./model.R")
source("./utilities.R")

na_pad <- function(x, len) {
  x[1:len]
}

make_padded_dataframe <- function(l, ...) {
  maxlen <- max(sapply(l, length))
  data.frame(lapply(l, na_pad, len = maxlen), ...)
}

df <- prepare_data(get_data())
top_countries <- read_csv("./raw_data/top_countries.csv",
                          show_col_types = FALSE)
c3_countries <- read_csv("./raw_data/criteria3.csv", 
                         show_col_types = FALSE)
c45_competitors <- read_csv("./raw_data/criteria4_5.csv",
                            show_col_types = FALSE)
hu_competitors <- read_csv("./raw_data/host_universality.csv",
                           show_col_types = FALSE)
named_competitors <- bind_rows(
  c45_competitors,
  hu_competitors
)

# get a model for each (apparatus, gender) pair
lm_models <- fit_model(df)
# using whole data frame, get predictions of every athlete's e_score now
predictions <- predict_scores_from_models(df, lm_models)

# Criteria 1: WCH 2022 Team Final
# Criteria 2: WCH 2023 Team Qualifications
w12 <- process_team_competitors(predictions, top_countries, named_competitors, "w")
m12 <- process_team_competitors(predictions, top_countries, named_competitors, "m")

# Criteria 3: the three countries in c3[[gender]] each get to send one qualifier
w3 <- get_top_non_usa(predictions, c3_countries, named_competitors, "w", n = 1)
m3 <- get_top_non_usa(predictions, c3_countries, named_competitors, "m", n = 1)

# Criteria 4: WCH 2023 All-Around Qualification (8 men, 8 women)
# Criteria 5: WCH 2023 Apparatus Final Qualification (6 men, 6 women)
w45 <- get_exact_names(predictions, c45_competitors[["w"]])
m45 <- get_exact_names(predictions, c45_competitors[["m"]])

# Host Country Place and Universality Place
# as of 2023-12-11 only has been determined for women
whu <- get_exact_names(predictions, hu_competitors[["w"]])
mhu <- get_exact_names(predictions, hu_competitors[["m"]])

women <- bind_rows(w12, w3, w45, whu)
men <- bind_rows(m12, m3, m45, mhu)

all_named <- make_padded_dataframe(list(w = women$name, m = men$name))

# Criteria 6 and 7 yet to be determined as of 2023-12-11
# COMPETITORS NOT IN LIST RANDOMLY CHOSEN FOR CRITERIA 6 AND 7

# Pick 96 - 77 = 19 men
m67 <- get_top_remaining(predictions, top_countries, all_named, "m", n = 19)

# Pick 96 - 82 = 14 women
w67 <- get_top_remaining(predictions, top_countries, all_named, "w", n = 14)

women <- bind_rows(women, w67)
men <- bind_rows(men, m67)

write.csv(women, "./data/w.csv", row.names = FALSE)
write.csv(men, "./data/m.csv", row.names = FALSE)

usa_m_all_ordered <- order_country(predictions, "USA", "m")
usa_w_all_ordered <- order_country(predictions, "USA", "w")
gender_list <- list(m = usa_m_all_ordered$name, w = usa_w_all_ordered$name)
usa_json <- jsonlite::toJSON(gender_list, pretty = TRUE, auto_unbox = TRUE, dataframe = "columns", rownames = FALSE)
write(usa_json, file = "./client/public/usa.json")
