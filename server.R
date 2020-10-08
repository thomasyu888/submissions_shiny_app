
server <- function(input, output, session) {

  ########### session global variables

  ### logs in and gets list of projects they have access to
  # synStore_obj <- NULL

  submission_viewdf <- NULL
  projects_namedlist <- c()
  # proj_folder_manifest_cells <- c()
  #
  # folder_synID <- NULL
  # filename_list <- c()
  ############

  ### synapse cookies
  session$sendCustomMessage(type = "readCookie", message = list())

  ### initial login front page items
  observeEvent(input$cookie, {

    ### login and update session; otherwise, notify to login to Synapse first
    tryCatch({
      syn_login(sessionToken = input$cookie, rememberMe = FALSE)
      submission_viewdf <<- syn_tableQuery("select distinct(projectId) as projectId from syn22252115")$asDataFrame()
      temp_projects_namedlist <- c()
      for (project in submission_viewdf$projectId) {
        tryCatch({
          project_name = syn_get(project)$name
          temp_projects_namedlist[[project_name]] = project
        }, error = function(err) {
          print(err)
        })
      }
      projects_namedlist <<- temp_projects_namedlist
      updateSelectInput(session, "challenges", label = "Challenges", choices = names(projects_namedlist))


      ### update waiter loading screen once login successful
      waiter_update(
        html = tagList(
          img(src = "synapse_logo.png", height = "120px"),
          h3(sprintf("Welcome, %s!", syn_getUserProfile()$userName))
        )
      )
      Sys.sleep(2)
      waiter_hide()
    }, error = function(err) {
      print(err)
      Sys.sleep(2)
      waiter_update(
        html = tagList(
          img(src = "synapse_logo.png", height = "120px"),
          h3("Looks like you're not logged in!"),
          span("Please ", a("login", href = "https://www.synapse.org/#!LoginPlace:0", target = "_blank"),
            " to Synapse, then refresh this page.")
        )
      )
    })
  })

  observeEvent(ignoreNULL = TRUE, ignoreInit = TRUE, input$challenges, {
    output$queue_participation = renderPlotly({
      selected_project <- input$challenges
      # if selected_project not empty
      if (!is.null(selected_project)) {
        project_synid <- projects_namedlist[[selected_project]] ### get synID of selected project
        challenge_viewdf <<- syn_tableQuery(
          glue::glue("select * from syn22252115 ",
                     "where projectId = '{project_synid}'")
        )$asDataFrame()
        evalnames = c()
        for (evaluation in unique(challenge_viewdf$evaluationid)) {
          evalnames = c(evalnames, syn_getEvaluation(evaluation)$name)
        }
        evaluation_names = plyr::mapvalues(challenge_viewdf$evaluationid,
                                           from=unique(challenge_viewdf$evaluationid),
                                           to=evalnames)
        submission_dist = sort(table(evaluation_names), decreasing = T)
        submission_dist = as.data.frame(submission_dist)
        x <- list(
          title = "Queues",
          showticklabels=F
        )
        y <- list(
          title = "Number of Submissions"
        )
        plot_ly(data = submission_dist,
                x = ~evaluation_names,
                y = ~Freq,
                name = "Submissions per queue",
                type = "bar") %>% layout(xaxis = x, yaxis = y)
      }
    })
  })

}
