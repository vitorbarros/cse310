# Utility functions for the Gapminder analysis

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

ensure_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
}

load_gapminder <- function(csv_path) {
  if (!file.exists(csv_path)) {
    stop("Data file not found. Run scripts/download_data.R first.")
  }

  readr::read_csv(
    csv_path,
    show_col_types = FALSE,
    progress = FALSE
  )
}

clean_gapminder <- function(df) {
  df %>%
    filter(
      !is.na(country),
      !is.na(continent),
      !is.na(year),
      !is.na(lifeExp),
      !is.na(pop),
      !is.na(gdpPercap)
    ) %>%
    mutate(
      year = as.integer(year),
      lifeExp = as.numeric(lifeExp),
      pop = as.numeric(pop),
      gdpPercap = as.numeric(gdpPercap),
      gdp = pop * gdpPercap,
      log_gdp_per_cap = log10(gdpPercap)
    )
}

summarize_by_continent <- function(df, year_target) {
  df %>%
    filter(year == year_target) %>%
    group_by(continent) %>%
    summarise(
      avg_lifeExp = mean(lifeExp),
      avg_gdpPercap = mean(gdpPercap),
      total_pop = sum(pop),
      .groups = "drop"
    ) %>%
    arrange(desc(avg_lifeExp))
}

plot_lifeexp_trends <- function(df, countries, out_path) {
  p <- df %>%
    filter(country %in% countries) %>%
    ggplot(aes(x = year, y = lifeExp, color = country)) +
    geom_line(linewidth = 1) +
    geom_point(size = 1.5) +
    labs(
      title = "Life Expectancy Over Time",
      x = "Year",
      y = "Life Expectancy (years)",
      color = "Country"
    ) +
    theme_minimal()

  ggsave(out_path, p, width = 9, height = 5, dpi = 150)
}

plot_lifeexp_vs_gdp <- function(df, year_target, out_path) {
  p <- df %>%
    filter(year == year_target) %>%
    ggplot(aes(x = gdpPercap, y = lifeExp, color = continent)) +
    geom_point(alpha = 0.8) +
    scale_x_log10() +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    labs(
      title = paste("Life Expectancy vs GDP per Capita (", year_target, ")"),
      x = "GDP per Capita (log scale)",
      y = "Life Expectancy (years)",
      color = "Continent"
    ) +
    theme_minimal()

  ggsave(out_path, p, width = 9, height = 5, dpi = 150)
}

plot_continent_bar <- function(summary_df, out_path) {
  p <- summary_df %>%
    ggplot(aes(x = reorder(continent, avg_lifeExp), y = avg_lifeExp, fill = continent)) +
    geom_col(show.legend = FALSE) +
    coord_flip() +
    labs(
      title = "Average Life Expectancy by Continent",
      x = "Continent",
      y = "Average Life Expectancy (years)"
    ) +
    theme_minimal()

  ggsave(out_path, p, width = 8, height = 5, dpi = 150)
}

write_summary <- function(summary_df, model, out_path) {
  lines <- c(
    "Gapminder Analysis Summary",
    "===========================",
    "",
    "Average life expectancy and GDP per capita by continent (latest year):",
    ""
  )

  table_lines <- capture.output(print(summary_df))

  model_lines <- c(
    "",
    "Linear model: lifeExp ~ log10(gdpPercap)",
    ""
  )
  model_lines <- c(model_lines, capture.output(summary(model)))

  writeLines(c(lines, table_lines, model_lines), out_path)
}
