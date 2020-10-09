library(shiny)
library(shinyjs)
library(plyr)
library(dplyr)
library(shinythemes)
library(shinydashboard)
library(stringr)
library(DT)
library(jsonlite)
library(reticulate)
library(ggplot2)
library(purrr)
library(plotly)
library(waiter)

#########global
use_condaenv('synapse', required = TRUE)
reticulate::import("sys")

source_python("syn_login_func.py")


get_evaluation_names <- function(evaluationids) {
  eval_names <- c()
  for (evaluation in unique(evaluationids)) {
    eval_names = c(eval_names, syn_getEvaluation(evaluation)$name)
  }
  evaluation_names = plyr::mapvalues(evaluationids,
                                     from=unique(evaluationids),
                                     to=eval_names)
  evaluation_names
}
