write_simulation_result <- function(simulation_result, file_name) {
  if (!file.exists(file_name)) {
    write.csv(simulation_result, file_name, row.names = FALSE)
  } else {
    write.table(simulation_result, file_name, sep = ",", col.names = FALSE,
                row.names = FALSE, append = TRUE)
  }
}