library(shiny)

source("movie_data.R")
source("movie_recommendations.R")

load_error <- NULL
movies <- tryCatch(
  load_movies(),
  error = function(e) {
    load_error <<- conditionMessage(e)
    NULL
  }
)

genres <- character(0)

if (!is.null(movies)) {
  genres <- sort(unique(trimws(unlist(strsplit(
    movies$genres[!is.na(movies$genres)],
    "|",
    fixed = TRUE
  )))))
  genres <- genres[nzchar(genres)]
}

ui <- fluidPage(
  tags$head(
    tags$title("Movie Night | Find Your Next Movie"),

    tags$style(HTML('
      body {
        background: #10121d;
        color: #f5f4fa;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }

      .container-fluid {
        max-width: 1100px;
        padding: 26px 22px 55px;
      }

      .hero {
        background: linear-gradient(120deg, #31204c, #172137 75%);
        border: 1px solid #4c3c65;
        border-radius: 22px;
        padding: 42px 38px;
        margin-bottom: 26px;
      }

      .eyebrow {
        color: #c4a5ff;
        font-size: 12px;
        font-weight: 800;
        letter-spacing: 2px;
        text-transform: uppercase;
        margin-bottom: 13px;
      }

      .hero h1 {
        color: white;
        font-size: 43px;
        font-weight: 800;
        margin: 0 0 10px;
      }

      .hero p {
        color: #d1cde0;
        font-size: 17px;
        margin: 0;
        max-width: 550px;
      }

      .panel-box {
        background: #1b1e2d;
        border: 1px solid #34374b;
        border-radius: 18px;
        padding: 26px;
        min-height: 310px;
        margin-bottom: 18px;
      }

      .section-tag {
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 1.8px;
        color: #bca0ff;
        font-weight: 800;
        margin-bottom: 7px;
      }

      .panel-box h2 {
        color: #fff;
        font-size: 24px;
        font-weight: 750;
        margin: 0 0 24px;
      }

      label {
        color: #dedbea;
        font-weight: 600;
        margin-bottom: 9px;
      }

      /* Dark dropdown styling */
      .selectize-control.single .selectize-input,
      .selectize-input,
      .form-control {
        background: #29283d !important;
        background-color: #29283d !important;
        color: #ffffff !important;
        border: 1px solid #565073 !important;
        border-radius: 10px !important;
        box-shadow: none !important;
      }

      .selectize-control.single .selectize-input {
        min-height: 44px;
        padding: 11px 12px;
      }

      .selectize-input input,
      .selectize-input .item {
        color: #ffffff !important;
      }

      .selectize-control.single .selectize-input:after {
        border-color: #c4a5ff transparent transparent transparent;
      }

      .selectize-control.single .selectize-input.dropdown-active:after {
        border-color: transparent transparent #c4a5ff transparent;
      }

      .selectize-input.focus,
      .form-control:focus {
        border-color: #a581fa !important;
        box-shadow: 0 0 0 2px rgba(165,129,250,0.2) !important;
      }

      .selectize-dropdown,
      .selectize-dropdown-content {
        background: #29283d !important;
        color: #ffffff !important;
        border-color: #565073 !important;
      }

      .selectize-dropdown .option {
        color: #ffffff !important;
        padding: 10px 12px;
      }

      .selectize-dropdown .active,
      .selectize-dropdown .selected {
        background: #48376b !important;
        color: #ffffff !important;
      }

      select.form-control option {
        background: #29283d;
        color: white;
      }

      /* Rating slider */
      .irs--shiny .irs-bar,
      .irs--shiny .irs-single {
        background: #a581fa;
        border-color: #a581fa;
      }

      .irs--shiny .irs-handle {
        background: #eee7ff;
        border-color: #a581fa;
      }

      .irs--shiny .irs-line {
        background: #3b3e51;
        border-color: #3b3e51;
      }

      .irs-min,
      .irs-max {
        color: #c9c5d5;
        background: #303347;
      }

      .irs-grid-text {
        color: #aaa7bf;
      }

      /* Recommendation button */
      #recommend {
        width: 100%;
        margin-top: 17px;
        background: #a581fa;
        color: #171023;
        font-size: 15px;
        font-weight: 800;
        border: none;
        border-radius: 11px;
        padding: 13px 16px;
        transition: background 0.2s;
      }

      #recommend:hover,
      #recommend:focus {
        background: #c5aaff;
        color: #171023;
      }

      /* Recommendation results */
      .result-empty {
        border: 1px dashed #58566c;
        border-radius: 14px;
        padding: 35px 22px;
        text-align: center;
        color: #bebbd1;
      }

      .result-empty .big {
        font-size: 34px;
        display: block;
        margin-bottom: 10px;
      }

      .movie-card {
        background: linear-gradient(135deg, #29283d, #20253a);
        border: 1px solid #565073;
        border-radius: 15px;
        padding: 25px;
      }

      .movie-card .pill {
        display: inline-block;
        border-radius: 30px;
        background: #48376b;
        color: #e4d5ff;
        padding: 6px 12px;
        font-size: 12px;
        font-weight: 700;
        margin-bottom: 14px;
      }

      .movie-card h3 {
        color: white;
        font-size: 29px;
        font-weight: 800;
        margin: 0 0 18px;
      }

      .detail-row {
        display: flex;
        justify-content: space-between;
        gap: 12px;
        border-top: 1px solid #464359;
        padding: 13px 0;
      }

      .detail-label {
        color: #b7b3c8;
      }

      .detail-value {
        color: #f7f3ff;
        font-weight: 650;
        text-align: right;
      }

      .rating-value {
        color: #d6b9ff;
        font-size: 19px;
        font-weight: 800;
      }

      .notice {
        background: #302839;
        border: 1px solid #6b4d73;
        border-radius: 12px;
        padding: 18px;
        color: #f2dbea;
      }

      .footer-note {
        color: #898aa3;
        text-align: center;
        font-size: 12px;
        margin-top: 14px;
      }

      @media (max-width: 767px) {
        .hero {
          padding: 29px 23px;
        }

        .hero h1 {
          font-size: 32px;
        }

        .panel-box {
          min-height: 0;
        }
      }
    '))
  ),

  div(
    class = "hero",
    div(class = "eyebrow", "YOUR MOVIE NIGHT STARTS HERE"),
    h1("Find your next favorite movie."),
    p("Not sure what to watch? Pick a genre and rating, and let us find something for you.")
  ),

  fluidRow(
    column(
      5,
      div(
        class = "panel-box",
        div(class = "section-tag", "STEP 01"),
        h2("Choose your preferences"),

        selectInput(
          "genre",
          "Movie genre",
          choices = c("Any genre" = "", genres),
          selectize = TRUE
        ),

        sliderInput(
          "rating",
          "Minimum average rating",
          min = 0.5,
          max = 5,
          value = 3,
          step = 0.5
        ),

        actionButton("recommend", "Find my movie")
      )
    ),

    column(
      7,
      div(
        class = "panel-box",
        div(class = "section-tag", "STEP 02"),
        h2("Your recommendation"),
        uiOutput("movie_result")
      )
    )
  ),

  div(
    class = "footer-note",
    "Powered by R Shiny + MovieLens data"
  )
)

server <- function(input, output, session) {
  recommendation <- reactiveVal(NULL)

  observeEvent(input$recommend, {
    if (is.null(movies)) {
      recommendation(list(
        error = paste("Could not load the movie data:", load_error)
      ))
      return()
    }

    selected_genre <- if (nzchar(input$genre)) {
      input$genre
    } else {
      NULL
    }

    result <- tryCatch(
      recommend_movie(
        movies,
        genre = selected_genre,
        min_rating = input$rating
      ),
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
      return(div(
        class = "result-empty",
        span(class = "big", "✦"),
        p("Your next movie is one click away."),
        p("Choose your filters and hit Find my movie.")
      ))
    }

    if (!is.null(result$error)) {
      return(div(class = "notice", result$error))
    }

    if (nrow(result$movie) == 0) {
      return(div(
        class = "result-empty",
        p("No movies match those filters."),
        p("Try another genre or a lower rating.")
      ))
    }

    movie <- result$movie[1, , drop = FALSE]

    movie_year <- if (is.na(movie$year)) {
      "Unknown"
    } else {
      as.character(movie$year)
    }

    movie_genres <- if (is.na(movie$genres)) {
      "Not listed"
    } else {
      gsub("|", ", ", movie$genres, fixed = TRUE)
    }

    div(
      class = "movie-card",
      span(class = "pill", "✦ YOUR MOVIE PICK"),
      h3(movie$title),

      div(
        class = "detail-row",
        span(class = "detail-label", "Release year"),
        span(class = "detail-value", movie_year)
      ),

      div(
        class = "detail-row",
        span(class = "detail-label", "Genres"),
        span(class = "detail-value", movie_genres)
      ),

      div(
        class = "detail-row",
        span(class = "detail-label", "Average rating"),
        span(
          class = "rating-value",
          sprintf("★ %.2f / 5", movie$avg_rating)
        )
      )
    )
  })
}

shinyApp(ui, server)
