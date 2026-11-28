library(shiny)

source("movie_data.R")
source("movie_recommendations.R")

# Load the same MovieLens data used by the command-line program.
load_error <- NULL
movies <- tryCatch(
  load_movies(),
  error = function(e) {
    load_error <<- conditionMessage(e)
    NULL
  }
)

# Build the genre menu from the actual dataset.
genres <- character(0)
if (!is.null(movies)) {
  genres <- sort(unique(trimws(unlist(strsplit(
    movies$genres[!is.na(movies$genres)], "|", fixed = TRUE
  )))))
  genres <- genres[nzchar(genres)]
}

ui <- fluidPage(
  titlePanel("Movie Recommendation Program"),
  p("Choose a genre and a minimum rating to find a movie to watch."),
  sidebarLayout(
    sidebarPanel(
      selectInput("genre", "Genre:",
                  choices = c("Any genre" = "", genres)),
      sliderInput("rating", "Minimum average rating:",
                  min = 0.5, max = 5, value = 3, step = 0.5),
      actionButton("recommend", "Recommend a Movie")
    ),
    mainPanel(
      h3("Your Recommendation"),
      uiOutput("movie_result")
    )
  )
)

server <- function(input, output, session) {
  recommendation <- reactiveVal(NULL)

  observeEvent(input$recommend, {
    if (is.null(movies)) {
      recommendation(list(error = paste("Could not load the movie data:", load_error)))
      return()
    }

    selected_genre <- if (nzchar(input$genre)) input$genre else NULL
    result <- tryCatch(
      recommend_movie(movies,
                      genre = selected_genre,
                      min_rating = input$rating),
      error = function(e) e
    )

    if (inherits(result, "error")) {
      recommendation(list(error = conditionMessage(result)))
    } else {
      recommendation(list(movie = result))
    }
  })

  output$movie_result <- renderUI({
    result <- recommendation()

    if (is.null(result)) {
      return(p("Pick your filters and click the button to get started."))
    }
    if (!is.null(result$error)) {
      return(p(result$error))
    }
    if (nrow(result$movie) == 0) {
      return(p("No movies match your filters. Try another genre or a lower rating."))
    }

    movie <- result$movie[1, , drop = FALSE]
    movie_year <- if (is.na(movie$year)) "Unknown" else as.character(movie$year)
    movie_genres <- if (is.na(movie$genres)) "Not listed" else movie$genres

    tagList(
      h4(movie$title),
      p(strong("Year: "), movie_year),
      p(strong("Genres: "), gsub("|", ", ", movie_genres, fixed = TRUE)),
      p(strong("Average rating: "), sprintf("%.2f / 5", movie$avg_rating))
    )
  })
}

shinyApp(ui, server)
