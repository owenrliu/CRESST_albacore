library(rvest)
library(dplyr)
library(readr)

url <- "https://iattc.org/en-US/Data/Reference-codes"

# Read all tables from the page
page   <- read_html(url)
tables <- page |> html_elements("table") |> html_table(header = TRUE)
headings <- page |> html_elements("h2, h3, h4") |> html_text2()

cat("Found", length(tables), "tables\n")

# Save each table as a CSV
for (i in seq_along(tables)) {
  # Try to use a heading as filename, fall back to index
  name <- if (i <= length(headings)) {
    headings[i] |>
      tolower() |>
      trimws() |>
      gsub("[^a-z0-9]+", "_", x = _) |>
      gsub("^_|_$", "", x = _)
  } else {
    paste0("table_", i)
  }
  
  filename <- here('data',paste0(name, ".csv"))
  write_csv(tables[[i]], filename)
  cat("Saved:", filename, "\n")
}
