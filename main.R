library(optparse)

option_list <- list(
  make_option(c("-g", "--genre"), type = "character",
              help = "Genre name, for example Action"),
  make_option(c("-y", "--year"), type = "double",
              help = "Exact release year"),
  make_option(c("-r", "--rating"), type = "double",
              help = "Minimum average rating from 0.5 to 5")
)

parser <- OptionParser(usage = "%prog [options]", option_list = option_list)
filters <- parse_args(parser)

script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script_dir <- if (length(script_arg)) dirname(sub("^--file=", "", script_arg[1L])) else "."
source(file.path(script_dir, "movie_data.R"))
source(file.path(script_dir, "movie_recommendations.R"))

recommendation <- recommend_movie(load_movies(), genre = filters$genre,
                                  min_rating = filters$rating, year = filters$year)
if (nrow(recommendation) == 0L) {
  cat("No movies match those filters. Try changing or removing a filter.\n")
} else {
  year <- if (is.na(recommendation$year)) "Unknown" else recommendation$year
  genres <- if (is.na(recommendation$genres)) "Unlisted" else recommendation$genres
  cat(sprintf("%s (%s)\nGenres: %s\nAverage rating: %.2f/5\n",
              recommendation$title, year, genres, recommendation$avg_rating))
}
