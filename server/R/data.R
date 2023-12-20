library(purrr)
library(dplyr)
library(readr)
library(snakecase)
library(stringr)
library(stringi)

get_data <- function() {
  data <- read_csv("./raw_data/data_2022_2023.csv",
                   show_col_types = FALSE)

  return(data)
}

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
    mutate(apparatus = toupper(apparatus)) %>%
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
    mutate(country = ifelse(country %in% c("ENG", "SCO", "WAL"), "GBR", country)) %>%
    mutate(country = ifelse(country %in% c("GE1", "GE2"), "GER", country)) %>%
    # Northern Ireland athletes were all made a part of IRL since they get a choice I made it for them
    mutate(country = ifelse(country == "NIR", "IRL", country)) %>%
    dplyr::select(name, gender, country,
                  date, apparatus, d_score,
                  e_score, penalty, score,
                  round)

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

  # get global average on score and d_score for each gender, apparatus, name
  df_final <- prepared_data %>%
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
  m_t <- dataframe %>%
    filter(gender == gender_t) %>%
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