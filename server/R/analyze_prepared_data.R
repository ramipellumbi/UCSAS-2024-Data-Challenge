# scrap work file for plot generation

library(pubtheme)
library(ggplot2)
library(GGally)

df <- readRDS("./server/processed_data/df.RDS")
lm_models <- readRDS("./server/processed_data/models.RDS")


for (name in names(lm_models)) {
  print(name)
  print(summary(lm_models[[name]])$r.squared)
}

coef(lm_models$SR.m)

# for each model get r^2 and store in dataframe with columns (apparatus, gender, r2)
r2_df <- lapply(lm_models, function(x) {
  summary(x)$r.squared
})
# Extract names and values
names_list <- names(r2_df)
values_list <- unlist(r2_df)

# Parse the names to extract apparatus and gender
parsed_names <- strsplit(names_list, "\\.")
apparatus <- sapply(parsed_names, `[`, 1)
gender <- sapply(parsed_names, `[`, 2)

# Create a data frame
r2_df <- data.frame(Apparatus = apparatus, Gender = gender, R_squared = values_list)

cor(df$e_score, log(df$d_score))

g_r2_m <- r2_df %>%
  filter(Gender == "m") %>%
  ggplot(aes(x = Apparatus, y = R_squared)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_pub(type = "bar") + 
  labs(title = "R^2 by Apparatus(m)")
ggsave(g_r2_m, file = "plots/m_r2.png", width = 12, height = 4)

g_r2_w <- r2_df %>%
  filter(Gender == "w") %>%
  ggplot(aes(x = Apparatus, y = R_squared)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_pub(type = "bar") + 
  labs(title = "R^2 by Apparatus(w)")
ggsave(g_r2_w, file = "plots/w_r2.png", width = 12, height = 4)



ggpairs(df[,c('e_score', 'd_score')])


gen <- "w"
apparatuses <- df %>%
  filter(gender == gen) %>%
  pull(apparatus)
apparatuses <- unique(apparatuses)
for (a in apparatuses) {
  df_g <- df %>%
    filter(gender == gen, apparatus == a) %>%
    mutate(bin = cut_interval(d_score, length=0.3))
  
  g <- df_g %>%
    ggplot(aes(x = e_score)) +
    geom_histogram(binwidth = 0.5) +
    facet_wrap(~bin, scales = "free_y") + 
    theme_pub(type = "bar") +
    # add title, x label, y label 
    labs(title = paste0("Execution Score Distribution for ", a, " (", gen, ")"),
         x = "Execution Score", y = "Count")
  
  ggsave(g, file = paste0("./plots/", gen, "_", a, ".png"), width = 12, height = 8)
}

g_temp <- df %>% 
  filter(d_score > 2.1) %>%
  filter(apparatus == "FX", gender == "m") %>%
  ggplot(aes(x = d_score, y = e_score)) +
  geom_point() + 
  geom_smooth(method = "lm", se = FALSE, color = 'steelblue') + 
  theme_pub(type = "scatter") + 
  labs(title = "FX(m) Execution Score vs Difficulty Score",
       x = "Difficulty Score", y = "Execution Score")
ggsave(g_temp, file = "plots/fx_m_d_e.png", width = 12, height = 4)