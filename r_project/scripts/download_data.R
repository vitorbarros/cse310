# Download the Gapminder dataset

suppressPackageStartupMessages({
  library(readr)
})

url <- "https://raw.githubusercontent.com/resbaz/r-novice-gapminder-files/master/data/gapminder-FiveYearData.csv"
output_path <- file.path("data", "gapminder.csv")

if (file.exists(output_path)) {
  message("Data file already exists: ", output_path)
  quit(save = "no")
}

message("Downloading dataset...")
utils::download.file(url, output_path, mode = "wb", quiet = TRUE)

# Basic validation
if (!file.exists(output_path)) {
  stop("Download failed. Check your internet connection and try again.")
}

readr::read_csv(output_path, show_col_types = FALSE, progress = FALSE)
message("Download complete: ", output_path)
