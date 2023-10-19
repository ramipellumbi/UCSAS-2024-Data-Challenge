library(readr)

get_data <- function() {
  data <- read_csv("./cleandata/data_2022_2023.csv",
                    show_col_types = FALSE)

  return(data)
}
