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
    # manual duplicate fixes ...
    mutate(name = ifelse(name == "frederick richard", "frederick nathaniel richard", name)) %>%
    mutate(name = ifelse(name == "ian skirkey", "ian hunter skirkey", name)) %>%
    mutate(name = ifelse(name == "pauline schafer", "pauline schaefer betz", name)) %>%
    mutate(name = ifelse(name == "alexa citlali moreno medina", "alexa moreno", name)) %>%
    mutate(name = ifelse(name == "alexa moreno medina", "alexa moreno", name)) %>%
    mutate(name = ifelse(name == "hillary alexandra heron soto", "hillary heron", name)) %>%
    mutate(name = ifelse(name == "hillary heron soto", "hillary heron", name)) %>%
    mutate(name = ifelse(name == "ahtziri viridiana sandoval", "ahtziri sandoval", name)) %>%
    mutate(name = ifelse(name == "luka keybus", "luka van den keybus", name)) %>%
    mutate(name = ifelse(name == "andrei muntean", "andrei vasile muntean", name)) %>%
    mutate(name = ifelse(name == "carlos yulo", "carlos edriel yulo", name)) %>%
    mutate(name = ifelse(name == "mc rhys clenaghan", "rhys mc clenaghan", name)) %>%
    mutate(name = ifelse(name == "rhys mcclenaghan", "rhys mc clenaghan", name)) %>%
    mutate(name = ifelse(name == "anya pilgrim", "anya kaelin pilgrim", name)) %>%
    mutate(name = ifelse(name == "areti paraskevi pagoni", "areti pagoni", name)) %>%
    mutate(name = ifelse(name == "zachary nathaniel clay", "zachary clay", name)) %>%
    mutate(name = ifelse(name == "yunus emre gundogdu", "yunus gundogdu", name)) %>%
    mutate(name = ifelse(name == "yul kyung tae moldauer", "yul moldauer", name)) %>%
    mutate(name = ifelse(name == "yuan-hsi hung", "yuan hsi hung", name)) %>%
    mutate(name = ifelse(name == "yu-jan shiao", "yu shiao", name)) %>%
    mutate(name = ifelse(name == "yu jan shiao", "yu shiao", name)) %>%
    mutate(name = ifelse(name == "yohendry villaverde mederos", "yohendry villaverde", name)) %>%
    mutate(name = ifelse(name == "yen-chang  huang", "yen chang huang", name)) %>%
    mutate(name = ifelse(name == "yefferson gregorio anton yeguez", "yefferson anton", name)) %>%
    mutate(name = ifelse(name == "xingyu  lan", "xingyu lan", name)) %>%
    mutate(name = ifelse(name == "wout johan alexander teillers", "wout teillers", name)) %>%
    mutate(name = ifelse(name == "william fu-allen", "william fuallen", name)) %>%
    mutate(name = ifelse(name == "william fu allen", "william fuallen", name)) %>%
    mutate(name = ifelse(name == "wilfry manuel contreras", "wilfry contreras", name)) %>%
    mutate(name = ifelse(name == "wei-sheng tseng", "wei tseng", name)) %>%
    mutate(name = ifelse(name == "wei sheng tseng", "wei tseng", name)) %>%
    mutate(name = ifelse(name == "victor manuel betancourt quintana", "victor betancourt", name)) %>%
    mutate(name = ifelse(name == "vinzenz johann hock", "vinzenz hoeck", name)) %>%
    mutate(name = ifelse(name == "vinzenz hock", "vinzenz hoeck", name)) %>%
    mutate(name = ifelse(name == "tomas rodrigues florencio", "tomas florencio", name)) %>%
    mutate(name = ifelse(name == "toma modoianu-zseder", "toma modoianu zseder", name)) %>%
    mutate(name = ifelse(name == "toma roland modoianu zseder", "toma modoianu zseder", name)) %>%
    mutate(name = ifelse(name == "thanh tung  le", "thanh tung le", name)) %>%
    mutate(name = ifelse(name == "tarmo tuomas kanerva", "tarmo kanerva", name)) %>%
    mutate(name = ifelse(name == "taylor troy christopulos", "taylor christopulos", name)) %>%
    mutate(name = ifelse(name == "shane michael wiskus", "shane wiskus", name)) %>%
    mutate(name = ifelse(name == "severin kranzlmuller", "severin kranzlmueller", name)) %>%
    mutate(name = ifelse(name == "samual dick", "samuel dick", name)) %>%
    mutate(name = ifelse(name == "sam dick", "samuel dick", name)) %>%
    mutate(name = ifelse(name == "sebastian norbert gawronski", "sebastian gawronski", name)) %>%
    mutate(name = ifelse(name == "ruoteng  xiao", "ruoteng xiao", name)) %>%
    mutate(name = ifelse(name == "razvan-denis marc", "razvan denis marc", name)) %>%
    mutate(name = ifelse(name == "richard ameth atencio higinio", "richard atencio", name)) %>%
    mutate(name = ifelse(name == "ruoteng  xiao", "ruoteng xiao", name)) %>%
    mutate(name = ifelse(name == "rakan al harithi", "rakan alharith", name)) %>%
    mutate(name = ifelse(name == "rakah al harithi", "rakan alharith", name)) %>%
    mutate(name = ifelse(name == "peder funderud skogvang", "peder skogvang", name)) %>%
    mutate(name = ifelse(name == "pavel karnejenko", "pavel karenejenko", name)) %>%
    mutate(name = ifelse(name == "pau jimenez i fernandez", "pau jimenez", name)) %>%
    mutate(name = ifelse(name == "patrick sampaio correa", "patrick sampaio", name)) %>%
    mutate(name = ifelse(name == "oriol rifa pedreno", "oriol rifa", name)) %>%
    mutate(name = ifelse(name == "noe samuel seifert", "noe seifert", name)) %>%
    mutate(name = ifelse(name == "nicolau mir rossello", "nicolau mir", name)) %>%
    mutate(name = ifelse(name == "nelson guilbe morales", "nelson guilbe", name)) %>%
    mutate(name = ifelse(name == "nelson alberto guilbe morales", "nelson guilbe", name)) %>%
    mutate(name = ifelse(name == "dilan andres jimenez giraldo", "dilan jimenez giraldo", name)) %>%
    mutate(name = ifelse(name == "dilan jimenez", "dilan jimenez giraldo", name)) %>%
    mutate(name = ifelse(name == "man hin frankie lee", "frankie lee man hin", name)) %>%
    mutate(name = ifelse(name == "man hin lee", "frankie lee man hin", name)) %>%
    mutate(name = ifelse(name == "li wen yeoh", "rachel yeoh li wen", name)) %>%
    mutate(name = ifelse(name == "li wen rachel yeoh", "rachel yeoh li wen", name)) %>%
    mutate(name = ifelse(name == "adickxon gabriel trejo basalo", "adickxon trejo", name)) %>%
    mutate(name = ifelse(name == "adickxon trejo basalo", "adickxon trejo", name)) %>%
    mutate(name = ifelse(name == "andres josue perez gines", "andres perez", name)) %>%
    mutate(name = ifelse(name == "fabian de luna", "fabian luna", name)) %>%
    mutate(name = ifelse(name == "fabian de luna hernandez", "fabian luna", name)) %>%
    mutate(name = ifelse(name == "jose carlos escandon", "jose escandon", name)) %>%
    mutate(name = ifelse(name == "jose carlos escandon marin", "jose escandon", name)) %>%
    mutate(name = ifelse(name == "jose martinez", "jose manuel martinez moreno", name)) %>%
    mutate(name = ifelse(name == "manuel martinez", "jose manuel martinez moreno", name)) %>%
    mutate(name = ifelse(name == "aberdeen o'driscol", "aberdeen odriscol", name)) %>%
    mutate(country = ifelse(country %in% c("ENG", "SCO"), "GBR", country)) %>%
    mutate(country = ifelse(country %in% c("GE1", "GE2"), "GER", country)) %>%
    dplyr::select(name, gender, country, date, apparatus, d_score, e_score, penalty, score)

  # duplicate name cleaning that can be done simply
  dm <- get_duplicate_names_for_gender(prepared_data, "m")
  dm <- dm[-length(dm)]
  dw <- get_duplicate_names_for_gender(prepared_data, "w")
  dw <- dw[-length(dw)]

  name_mapping <- unlist(lapply(dw, function(names) {
    first_name <- names[1]
    setNames(rep(first_name, length(names)), names)
  }))
  prepared_data$name <- map_chr(prepared_data$name, function(name) {
    if (name %in% names(name_mapping)) {
      return(name_mapping[name])
    } else {
      return(name)
    }
  })

  name_mapping <- unlist(lapply(dm, function(names) {
    first_name <- names[1]
    setNames(rep(first_name, length(names)), names)
  }))
  prepared_data$name <- map_chr(prepared_data$name, function(name) {
    if (name %in% names(name_mapping)) {
      return(name_mapping[name])
    } else {
      return(name)
    }
  })

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

find_duplicates <- function(name1_words, idx, split_names) {
  # Compare with subsequent names only
  comparisons <- sapply(split_names[(idx + 1):length(split_names)], function(name2_words) {
    all(name1_words %in% name2_words) || all(name2_words %in% name1_words)
  })
  
  # Return indices of matches
  return(which(comparisons) + idx)
}

get_duplicate_names_for_gender <- function(dataframe, gender_t) {
  potential_duplicates <- list()
  m_t <- dataframe %>% filter(gender == gender_t) %>% 
    dplyr::select(name) %>% 
    distinct()
  split_names <- strsplit(m_t$name, " ")
  
  for (i in seq_along(split_names)) {
    matches <- find_duplicates(split_names[[i]], i, split_names)
    if (length(matches) > 0) {
      matched_names <- m_t$name[matches]
      new_i <- length(potential_duplicates) + 1
      potential_duplicates[[new_i]] <- c(m_t$name[i], matched_names)
    }
  }
  
  return(potential_duplicates)
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
