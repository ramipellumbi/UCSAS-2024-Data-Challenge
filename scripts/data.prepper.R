library(purrr)
library(dplyr)
library(snakecase)
library(stringr)
library(stringi)

prepare_data <- function(data_frame) {
  colnames(data_frame) <- to_snake_case(colnames(data_frame))
  
  # clean column names, some countries, and some names
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
    mutate(country = ifelse(country %in% c("GE1", "GE2"), "GER", country)) %>%
    dplyr::select(name, gender, country, date, apparatus, d_score, e_score, penalty, score)
  
  # get a start and end date of each competition
  cleaned_data <- clean_dates(prepared_data)
  
  # for each athlete, get their first start date
  df_first_date <- cleaned_data %>%
    group_by(name, apparatus) %>%
    summarise(first_date = min(start_date), .groups = "keep")
  
  # left join the first date to the original data
  cleaned_data <- cleaned_data %>%
    left_join(df_first_date, by = c("name", "apparatus"))
  
  # get summary of performance
  df_summary <- cleaned_data %>%
    arrange(name, apparatus, start_date) %>%
    group_by(name, apparatus) %>%
    mutate(is_first_date = start_date == first_date,
           cumulative_score = cumsum(score),
           count = row_number()) %>%
    ungroup() %>%
    mutate(cumulative_score = ifelse(is_first_date, 0, cumulative_score),
           count = ifelse(is_first_date, 1, count))
  
  # return dataframe computes average up to date for each athlete
  df_final <- cleaned_data %>%
    group_by(name, apparatus) %>%
    mutate(avg_score_up_to = map_dbl(start_date, ~ {
      current_date <- .x
      subset_df <- df_summary %>%
        filter(name == name & apparatus == apparatus & start_date < current_date)
      if (nrow(subset_df) == 0) {
        NA_real_
      } else {
        last(subset_df$cumulative_score) / last(subset_df$count)
      }
    })) %>%
    ungroup() %>%
    mutate(avg_score_up_to = ifelse(avg_score_up_to == 0, NA, avg_score_up_to)) %>%
    arrange(name, start_date, apparatus)
  
  # get global average on score and d_score for each gender, apparatus, name
  df_final <- df_final %>% 
    group_by(gender, apparatus, name) %>%
    mutate(all_avg_score = mean(score, na.rm = TRUE),
           all_avg_d_score = mean(d_score, na.rm = TRUE)) %>%
    ungroup()

  return(df_final)
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
  data$start_date <- gsub("Sept", "Sep", data$start_date)
  data$end_date <- sapply(end_date, paste, collapse = " ")
  data$end_date <- gsub("Sept", "Sep", data$end_date)
  
  # Dates in Date form 
  data$start_date <- as.Date(data$start_date, format = "%Y-%b-%d")
  data$end_date <- as.Date(data$end_date, format = "%Y-%b-%d")

  return(data)
}
