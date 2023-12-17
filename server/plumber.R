library(doParallel)
library(foreach)
library(plumber)
library(tidyverse)

source("../R/model.R")

numCores <- detectCores() - 1
registerDoParallel(cores = numCores)

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

#* Run a simulation for the specified gender and list of US team members for that gender
#* @post /simulate
function(req) {
  bodyList <- jsonlite::fromJSON(req$postBody)
  body <- bodyList$body

  gender_t <- body$gender[1]
  
  filename <- paste0(gender_t, '.csv')
  non_usa_competitors <- read.csv(filename)
  usa_competitors <- body$team
  all_competitor_names <- c(usa_competitors, non_usa_competitors$name)
  
  df <- readRDS("df.rds")
  models <- readRDS("models.rds")
  df <- df %>%
    filter(name %in% all_competitor_names & gender == gender_t) %>%
    dplyr::select(country, gender, name, apparatus, all_avg_d_score)
  
  predictions <- predict_scores_from_models(df, models)
  
  results <- foreach(i = 1:100) %dopar% {
    predictions <- predict_scores_from_models(df, models)
 
  }
}

# Programmatically alter your API
#* @plumber
function(pr) {
    pr %>%
        # Overwrite the default serializer to return unboxed JSON
        pr_set_serializer(serializer_unboxed_json())
}
