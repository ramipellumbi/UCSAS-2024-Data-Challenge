library(doParallel)
library(foreach)
library(plumber)
library(tidyverse)

source("../R/model.R")
source("./scripts/simulate.get_team_final_qualifiers.R")

options("plumber.port" = 7138)

#* @apiTitle Gymnastics API
#* @apiDescription API for running simulations

# Enable CORS Filtering to allow requests from the client
#' @filter cors
cors <- function(req, res) {
  safe_domains <- c("http://localhost:3000")
  
  if (any(grepl(pattern = paste0(safe_domains,collapse="|"), req$HTTP_REFERER,ignore.case=T))) {
    res$setHeader("Access-Control-Allow-Origin", sub("/$","",req$HTTP_REFERER)) # Have to remove last slash, for some reason
    
    if (req$REQUEST_METHOD == "OPTIONS") {
      res$setHeader("Access-Control-Allow-Methods","GET,HEAD,PUT,PATCH,POST,DELETE") # This is how node.js does it
      res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
      res$status <- 200
      return(list())
    } else {
      plumber::forward()
    }
  } else {
    plumber::forward()
  }
} 

apparatuses_g <- list(m = c("FX", "PH", "SR", "VT", "PB", "HB"),
                      w = c("VT", "UB", "BB", "FX"))

#* Run a simulation for the specified gender and list of US team members for that gender
#* @post /simulate
function(req) {
  bodyList <- jsonlite::fromJSON(req$postBody)
  body <- bodyList$body

  gender_t <- body$gender[1]
  apparatuses <- apparatuses_g[[gender_t]]
  
  # load the data
  df <- readRDS("df.rds")
  df <- df %>%
    filter(gender == gender_t) %>%
    dplyr::select(name, gender, country, apparatus, all_avg_d_score)
  
  # load the competitors
  filename <- paste0(gender_t, '.csv')
  non_usa_competitors <- read.csv(filename)
  usa_competitors <- body$team
  
  usa_df <- data.frame()
  for (apparatus_t in apparatuses) {
    apparatus_names <- body[[apparatus_t]]
    df_temp <- data.frame(name = apparatus_names, country = "USA", apparatus = apparatus_t, gender = gender_t)

        # for each athlete, get their all_avg_d_score for this apparatus from df
    df_temp <- df_temp %>%
      left_join(df, by = c("name", "gender", "apparatus", "country")) %>%
      group_by(name, country, apparatus, gender) %>%
      summarise(all_avg_d_score = first(all_avg_d_score)) %>%
      ungroup()
    
    usa_df <- bind_rows(usa_df, df_temp)
  }
  # the country teams
  countries_df <- read.csv("top_countries.csv")
  countries <- countries_df[[gender_t]]

  models <- readRDS("models.rds")
  
  country_competitors_names <- read.csv(paste0("team_", gender_t, ".csv"))
  alternate_competitors_names <- read.csv(paste0("alt_", gender_t, ".csv"))
  
  country_competitors_df <- df %>%
    filter(name %in% country_competitors_names$name)
  country_competitors_df <- bind_rows(country_competitors_df, usa_df)

  # for each apparatus, for team usa, select only the people who are competing on that apparatus
  for (apparatus in apparatuses) {
    apparatus_names_usa <- body[[apparatus]]
    # remove competitors from USA in country_competitors_df that are not present in body[[apparatus]]
    country_competitors_df <- country_competitors_df %>%
      filter(!(name %in% usa_competitors) | name %in% apparatus_names_usa)
  }
  temp <- country_competitors_df %>%
    filter(country == "USA")

  alternate_competitors_df <- df %>%
    filter(name %in% alternate_competitors_names$name)
  
  print(country_competitors_df)
  
  numCores <- detectCores() - 1
  registerDoParallel(cores = numCores)
  results <- foreach(i = iter(1:1), .combine = rbind) %dopar% {
    predictions_c <- predict_scores_from_models(country_competitors_df, models)

    team_final_qualifiers <- get_team_final_qualifiers(predictions_c)
    print(team_qualifiers)
  }
}

# Programmatically alter your API
#* @plumber
function(pr) {
    pr %>%
        # Overwrite the default serializer to return unboxed JSON
        pr_set_serializer(serializer_unboxed_json())
}
