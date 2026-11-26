library(dslabs)
library(optparse)

df <- movielens

#this dataset only goes up to 2016

option_list <- list(
  make_option(c("-g", "--genre"), type=str_interp, default=FALSE,
    help="Examples include Action, Thriller"),
  make_option(c("-y", "--year"), type=integer, default=FALSE), 
    help="Year format xxxx. Dataset only spans to 2016", 
  make_option(c("-r", "--rating"), type=double, default=FALSE), 
    help="Movie rating, format x.x from 0.5 to 5.0"
)

parser <- OptionParser(usage="%prog [options]", option_list=option_list)

args <- parse_args(parser, positional_arguments = 1)
opt <- args$options
#file <- args$args







