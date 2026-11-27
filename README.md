# Movie Recommendation Program Using R

## Movie dataset

The project uses GroupLens MovieLens Latest (Small), bundled with the R package [`dslabs`](https://search.r-project.org/CRAN/refmans/dslabs/html/movielens.html). In `dslabs` 0.9.1, the raw data contains 100,004 individual ratings from 0.5 to 5 stars. The prepared table contains 9,061 movies with release years spanning 1902–2016.

Install the dependency once with `install.packages("dslabs")`. Then run this from the project directory in an R session:

```r
source("movie_data.R")
movies <- load_movies()
head(movies)
```

The recommender and Shiny interface can use the same `load_movies()` function. It returns one row per `movieId`, sorted by ID.

| Column | Meaning |
| --- | --- |
| `movieId` | Unique MovieLens ID. Movie titles can repeat. |
| `title` | Movie title with outer whitespace removed. |
| `year` | Release year, or `NA` if unavailable. |
| `genres` | Genre names separated by `\|`, or `NA` if no genre is listed. |
| `avg_rating` | Mean of the movie's valid user ratings, on the original 0.5–5 scale. The value is kept at full precision for filtering. |

The loader ignores exact duplicate rating records, records without a movie ID, and missing or out-of-range ratings. It uses the metadata from the first row with a nonblank title for each movie. Movies without a usable title or any valid rating are omitted. A movie with an unknown genre or year can still appear when that filter is unset.

For example, movie ID `1` is **Toy Story** (1995), with genres `Adventure`, `Animation`, `Children`, `Comedy`, and `Fantasy` and an average rating of about `3.87`. Filters can split `movies$genres` into individual names with `strsplit(movies$genres, "|", fixed = TRUE)`.
