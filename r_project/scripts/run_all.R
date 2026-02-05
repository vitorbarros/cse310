# Run full pipeline: download data (if needed) + analysis

if (!file.exists(file.path("data", "gapminder.csv"))) {
  source(file.path("scripts", "download_data.R"))
}

source(file.path("scripts", "analysis.R"))
