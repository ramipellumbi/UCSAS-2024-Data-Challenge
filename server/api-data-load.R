# THIS FILE CAN ONLY BE EXECUTED FROM api.R being started

# global data loads
df <- readRDS("./processed_data/df.rds")
df <- df %>%
  dplyr::select(name, gender, country, apparatus, all_avg_d_score)
models <- readRDS("./processed_data/models.rds")

non_usa_m <- read.csv("./processed_data/team_m.csv")
non_usa_w <- read.csv("./processed_data/team_w.csv")

# read the men and women teams and place into list
non_usa_df_m <- df %>%
  filter(gender == "m", name %in% non_usa_m$name) %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup()

non_usa_df_w <- df %>%
  filter(gender == "w", name %in% non_usa_w$name) %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup()

non_usa_team <- list(m = non_usa_df_m, w = non_usa_df_w)

# read the men and women alternates and place into list
alternates_m <- read.csv("./processed_data/alt_m.csv")
alternates_w <- read.csv("./processed_data/alt_w.csv")

alternates_df_m <- df %>%
  filter(name %in% alternates_m$name) %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup()

alternates_df_w <- df %>%
  filter(name %in% alternates_w$name) %>%
  group_by(name, gender, country, apparatus) %>%
  summarise(all_avg_d_score = first(all_avg_d_score),
            .groups = "keep") %>%
  ungroup()

alternates <- list(m = alternates_df_m, w = alternates_df_w)

apparatuses_g <- list(m = c("FX", "PH", "SR", "VT", "PB", "HB"),
                      w = c("VT", "UB", "BB", "FX"))


# load in memory database so the competition judges don't need to install psql
apparatus_medalists <- readRDS("./sim_database/apparatus_medalists.rds")
individual_aa_medalists <- readRDS("./sim_database/individual_aa_medalists.rds")
other_samples <- readRDS("./sim_database/other_samples.rds")
team_medalists <- readRDS("./sim_database/team_medalists.rds")
team_usa <- readRDS("./sim_database/team_usa.rds")
usa_samples <- readRDS("./sim_database/usa_samples.rds")
