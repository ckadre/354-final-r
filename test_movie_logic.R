source("movie_data.R")
source("movie_recommendations.R")

example_movies <- data.frame(
  movieId = c(1L, 2L, 3L, 4L, 5L),
  title = c("Funny Movie", "Action Movie", "Funny Adventure",
            "Drama Movie", "Mystery Movie"),
  year = c(2000L, 2001L, 2002L, 2003L, NA_integer_),
  genres = c("Comedy", "Action", "Comedy|Adventure", "Drama", NA_character_),
  avg_rating = c(3.5, 4.5, 4.0, 4.0, 5.0),
  stringsAsFactors = FALSE
)

check <- function(condition, description) {
  if (!isTRUE(condition)) stop(paste("FAILED:", description), call. = FALSE)
  cat("PASS:", description, "\n")
}

produces_error <- function(expression) {
  inherits(tryCatch(expression, error = function(e) e), "error")
}

comedy <- filter_movies(example_movies, genre = "comedy")
check(identical(comedy$movieId, c(1L, 3L)), "Genre filtering ignores capitalization")
check(nrow(filter_movies(example_movies, genre = "Adventure")) == 1L,
      "Multi-genre movies can be found")
check(nrow(filter_movies(example_movies, genre = "Comedy|Action")) == 0L,
      "Genre filtering matches individual genre names")

high_rated <- filter_movies(example_movies, min_rating = 4)
check(all(high_rated$avg_rating >= 4) && nrow(high_rated) == 4L,
      "Minimum rating is inclusive")

combined <- filter_movies(example_movies, genre = "Comedy", min_rating = 4)
check(identical(combined$movieId, 3L), "Genre and rating work together")
check(nrow(filter_movies(example_movies, year = 2002)) == 1L,
      "Year filter matches the exact year")

# Without filters, all movies are returned.
check(nrow(filter_movies(example_movies)) == 5L, "No filters returns all movies")
check(nrow(filter_movies(example_movies, genre = "")) == 5L,
      "A blank genre skips genre filtering")
check(nrow(filter_movies(example_movies, genre = "Horror")) == 0L,
      "No matching movies returns an empty data frame")

best_comedy <- recommend_movie(example_movies, genre = "Comedy")
check(nrow(best_comedy) == 1L && best_comedy$movieId == 3L,
      "Recommendation returns the highest-rated matching movie")
check(recommend_movie(example_movies, min_rating = 4)$movieId == 5L,
      "Recommendation chooses the best rating")
check(nrow(recommend_movie(example_movies, genre = "Horror")) == 0L,
      "No match returns an empty recommendation")

tied_movies <- example_movies
tied_movies$avg_rating[1] <- 4
check(recommend_movie(tied_movies, genre = "Comedy")$movieId == 1L,
      "Matching ratings break ties using the lowest movie ID")

check(produces_error(filter_movies(example_movies, genre = NA_character_)),
      "Missing genre is rejected")
check(produces_error(filter_movies(example_movies, min_rating = 6)),
      "Ratings above 5 are rejected")
check(produces_error(filter_movies(example_movies, min_rating = "high")),
      "Non-numeric ratings are rejected")
check(produces_error(filter_movies(example_movies, min_rating = NA_real_)),
      "Missing ratings are rejected")
check(produces_error(filter_movies(example_movies, year = 2000.5)),
      "Non-whole-number years are rejected")
check(produces_error(filter_movies(example_movies, year = 1800)),
      "Years outside the dataset range are rejected")

# Test the original data preparation function with duplicate and invalid rows.
raw_ratings <- data.frame(
  movieId = c(1L, 1L, 1L, 2L, 2L, 3L, 4L),
  title = c(" First Movie ", " First Movie ", " First Movie ",
            "Second Movie", "Second Movie", " ", "Fourth Movie"),
  year = c(2000L, 2000L, 2000L, 2001L, 2001L, 2002L, 2003L),
  genres = c("Comedy", "Comedy", "Comedy", "Action", "Action", "Drama", ""),
  rating = c(4, 4, 2, 5, 8, 3, NA_real_),
  userId = c(1L, 1L, 2L, 1L, 2L, 1L, 1L),
  timestamp = c(1L, 1L, 2L, 3L, 4L, 5L, 6L),
  stringsAsFactors = FALSE
)
prepared <- prepare_movie_data(raw_ratings)
check(identical(prepared$movieId, c(1L, 2L)),
      "Movies without titles or valid ratings are removed")
check(prepared$title[1] == "First Movie", "Movie titles are trimmed")
check(isTRUE(all.equal(prepared$avg_rating[1], 3)),
      "Exact duplicate ratings are only counted once")
check(isTRUE(all.equal(prepared$avg_rating[2], 5)),
      "Out-of-range ratings are ignored")
check(!anyDuplicated(prepared$movieId), "Prepared movie IDs are unique")

cat("\nAll movie recommendation unit tests passed!\n")
