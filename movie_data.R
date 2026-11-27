load_movies <- function() {
  prepare_movie_data(dslabs::movielens)
}

prepare_movie_data <- function(ratings) {
  metadata_columns <- c("movieId", "title", "year", "genres")

  # Remove exact duplicate records before counting ratings toward the average.
  ratings <- unique(ratings[!is.na(ratings$movieId), , drop = FALSE])
  valid_rating <- is.finite(ratings$rating) &
    ratings$rating >= 0.5 & ratings$rating <= 5
  ratings_by_movie <- split(ratings$rating[valid_rating], ratings$movieId[valid_rating])
  movie_averages <- vapply(ratings_by_movie, mean, numeric(1))

  # A movie needs a title and a valid average to be recommended.
  movies <- ratings[metadata_columns]
  movies$title <- trimws(as.character(movies$title))
  has_title <- !is.na(movies$title) & nzchar(movies$title)
  movies <- movies[has_title, , drop = FALSE]
  movies <- movies[!duplicated(movies$movieId), , drop = FALSE]
  movies$avg_rating <- unname(movie_averages[as.character(movies$movieId)])
  movies <- movies[!is.na(movies$avg_rating), , drop = FALSE]

  movies$genres <- trimws(as.character(movies$genres))
  movies$genres[movies$genres %in% c("", "(no genres listed)")] <- NA_character_

  movies <- movies[order(movies$movieId), , drop = FALSE]
  rownames(movies) <- NULL
  movies
}
