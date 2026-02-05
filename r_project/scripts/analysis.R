# Main analysis script for the Gapminder project

source(file.path("R", "utils.R"))

ensure_dir("output")

csv_path <- file.path("data", "gapminder.csv")

# Load and clean
raw_df <- load_gapminder(csv_path)
clean_df <- clean_gapminder(raw_df)

# Define target year and example countries
latest_year <- max(clean_df$year)
focus_countries <- c("Brazil", "China", "Germany", "Nigeria", "United States")

# Summaries
continent_summary <- summarize_by_continent(clean_df, latest_year)

# Model
model <- lm(lifeExp ~ log_gdp_per_cap, data = clean_df)

# Visualizations
plot_lifeexp_trends(
  clean_df,
  focus_countries,
  file.path("output", "life_expectancy_trends.png")
)

plot_lifeexp_vs_gdp(
  clean_df,
  latest_year,
  file.path("output", "lifeexp_vs_gdp.png")
)

plot_continent_bar(
  continent_summary,
  file.path("output", "continent_lifeexp.png")
)

# Write summary report
write_summary(
  continent_summary,
  model,
  file.path("output", "summary.txt")
)

message("Analysis complete. Outputs saved in output/.")
