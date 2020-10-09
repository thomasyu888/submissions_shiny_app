
ui <- dashboardPage(
  skin = "purple",
  dashboardHeader(
    titleWidth = 260,
    title = "Submission Overview"
  ),

  dashboardSidebar(
    width = 260,
    sidebarMenu(
      id = "tabs",
      menuItem("Submissions", tabName = "Submissions", icon = icon("book-open")),
      br(),
      menuItem("Source Code", href = "https://github.com/thomasyu888/submissions_shiny_app", icon = icon("github"))
    ),
    HTML('<footer>
            Powered by Sage Bionetworks
        </footer>')
  ),

  dashboardBody(
    useShinyjs(),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
      singleton(
        includeScript("www/readCookie.js")
      )
    ),

    tabItems(
      # First tab content
      tabItem(
        tabName = "Submissions",
        fluidRow(
          box(
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            title = "Choose a Challenge:",
            selectizeInput(
              inputId = "challenges", label = "Challenges:",
              choices = c())
          ),
          box(
            solidHeader = TRUE,
            width = 10,
            title = "Number of Submissions",
            plotlyOutput('queue_submissions_query')
          ),
          box(
            solidHeader = TRUE,
            width = 10,
            title = "Number of Submitters",
            plotlyOutput('queue_submitters_query')
          )
        )
      )
    ),

    ## waiter loading screen
    use_waiter(),
    waiter_show_on_load(
      html = tagList(
        img(src = "loading.gif"),
        h4("Retrieving Synapse information...")
      ),
      color = "#424874"
    )
  )
)
