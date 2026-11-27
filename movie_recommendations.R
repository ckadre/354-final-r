filter_movies <- function(movies, genre = NULL, min_rating = NULL, year = NULL) {
  matches <- rep(TRUE, nrow(movies))

  if (!is.null(genre)) {
    if (!is.character(genre) || length(genre) != 1L || is.na(genre)) {
      stop("Genre must be a single name.", call. = FALSE)
    }
    genre <- tolower(trimws(genre))
    if (nzchar(genre)) {
      movie_genres <- strsplit(tolower(movies$genres), "|", fixed = TRUE)
      matches <- matches & vapply(movie_genres, function(genres) {
        genre %in% trimws(genres)
      }, logical(1))
    }
  }

  if (!is.null(min_rating)) {
    if (!is.numeric(min_rating) || length(min_rating) != 1L ||
        !is.finite(min_rating) || min_rating < 0.5 || min_rating > 5) {
      stop("Minimum rating must be a number from 0.5 to 5.", call. = FALSE)
    }
    matches <- matches & !is.na(movies$avg_rating) & movies$avg_rating >= min_rating
  }

  if (!is.null(year)) {
    if (!is.numeric(year) || length(year) != 1L || !is.finite(year) || year != trunc(year)) {
      stop("Year must be a whole number.", call. = FALSE)
    }
    known_years <- movies$year[!is.na(movies$year)]
    if (length(known_years) > 0L) {
      year_range <- range(known_years)
      if (year < year_range[1L] || year > year_range[2L]) {
        stop(sprintf("Year must be between %d and %d for this dataset.",
                     year_range[1L], year_range[2L]), call. = FALSE)
      }
    }
    matches <- matches & !is.na(movies$year) & movies$year == year
  }

  movies[matches, , drop = FALSE]
}

recommend_movie <- function(movies, genre = NULL, min_rating = NULL, year = NULL) {
  candidates <- filter_movies(movies, genre, min_rating, year)
  ranked_rows <- order(-candidates$avg_rating, candidates$movieId, na.last = NA)
  candidates[head(ranked_rows, 1L), , drop = FALSE]
}
