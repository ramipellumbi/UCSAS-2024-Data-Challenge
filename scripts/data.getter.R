library(readr)

get_data <- function() {
  data <- read_csv("./raw_data/data_2022_2023.csv",
                   show_col_types = FALSE)

  return(data)
}
