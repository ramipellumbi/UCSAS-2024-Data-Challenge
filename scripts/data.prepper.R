library(dplyr)
library(snakecase)
library(stringr)
library(stringi)

prepare_data <- function(data_frame) {
  colnames(data_frame) <- to_snake_case(colnames(data_frame))
  column_names <- colnames(data_frame)

  columns_exist_prepper <- "first_name" %in% column_names &
    "last_name" %in% column_names &
    "apparatus" %in% column_names &
    "gender" %in% column_names &
    "competition" %in% column_names &
    "round" %in% column_names &
    "date" %in% column_names &
    "score" %in% column_names &
    "d_score" %in% column_names &
    "e_score" %in% column_names &
    "penalty" %in% column_names

  stopifnot(columns_exist_prepper)

  prepared_data <- data_frame %>%
    mutate(name = tolower(paste(first_name, last_name, sep = " ")),
           apparatus = str_replace_all(.data$apparatus, "_", ""),
           apparatus = ifelse(apparatus == "UE", "UB", apparatus)) %>%
    mutate(name = stri_trans_general(name, "Latin-ASCII")) %>%
    mutate(apparatus = ifelse(apparatus %in% c("VT1", "VT2"),
                              "VT",
                              apparatus)) %>%
    mutate(apparatus = tolower(apparatus)) %>%
    mutate(name = ifelse(name == "frederick richard", "frederick nathaniel richard", name)) %>%
    mutate(name = ifelse(name == "ian skirkey", "ian hunter skirkey", name)) %>%
    mutate(country = ifelse(country %in% c("ENG", "SCO"), "GBR", country)) %>%
    mutate(country = ifelse(country %in% c("GE1", "GE2"), "GER", country))
    

  return(clean_dates(prepared_data))
}

# Convert categorical variables to factors
convert_to_factors <- function(data_frame) {
  for (col_name in colnames(data_frame)) {
    if (is.character(data_frame[[col_name]])) {
      data_frame[[col_name]] <- as.factor(data_frame[[col_name]])
    }
  }
  return(data_frame)
}

# Helper function to remove empty strings from a list
remove_empty_str <- function(lst) {
  lst[lst != ""]
}

# Helper function to create a date string
create_date_str <- function(parts) {
  paste(parts, collapse = "-")
}

clean_dates <- function(data) {
  column_names <- colnames(data)
  columns_exist <- "date" %in% column_names

  stopifnot(columns_exist)

  # Pre-calculate cleaned_dates and lengths
  cleaned_dates <- str_split(str_replace_all(data$date, "-|,", " "), " ")
  cleaned_dates <- lapply(cleaned_dates, remove_empty_str)
  lengths_cleaned_dates <- sapply(cleaned_dates, length)

  # Initialize start_date and end_date vectors
  start_date <- rep(NA_character_, length(cleaned_dates))
  end_date <- rep(NA_character_, length(cleaned_dates))

  # Handling dates with format "Day Month Year"
  idx <- which(lengths_cleaned_dates == 3)
  start_date[idx] <- cleaned_dates[idx]
  end_date[idx] <- cleaned_dates[idx]

  # Handling dates with format "Day1 Day2 Month Year"
  idx <- which(lengths_cleaned_dates == 4)
  start_date[idx] <- sapply(cleaned_dates[idx], function(d) paste(d[4], d[3], d[1], sep = "-"))
  end_date[idx] <- sapply(cleaned_dates[idx], function(d) paste(d[4], d[3], d[2], sep = "-"))

  # Handling dates with format "Day1 Month1 Day2 Month2 Year"
  idx <- which(lengths_cleaned_dates == 5)
  start_date[idx] <- sapply(cleaned_dates[idx], function(d) paste(d[5], d[2], d[1], sep = "-"))
  end_date[idx] <- sapply(cleaned_dates[idx], function(d) paste(d[5], d[4], d[3], sep = "-"))

  # Handling dates with format "Day1 Month2 Year Day2 Month2 Year"
  idx <- which(lengths_cleaned_dates == 6)
  start_date[idx] <- sapply(cleaned_dates[idx], function(d) paste(d[3], d[2], d[1], sep = "-"))
  end_date[idx] <- sapply(cleaned_dates[idx], function(d) paste(d[6], d[5], d[4], sep = "-"))

  # Replace the columns in the original data
  data$start_date <- sapply(start_date, paste, collapse = " ")
  data$end_date <- sapply(end_date, paste, collapse = " ")

  return(data)
}
