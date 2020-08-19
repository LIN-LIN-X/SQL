library(shiny)
library(DBI)
library(RMySQL)
library(DT)
library(dplyr)

# Define UI ----
ui <- fluidPage(
  
  # App title
  titlePanel("Shiny App Conditional Filter Demo"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    
    # Sidebar panel for inputs
    sidebarPanel(
      selectInput("Drug","Select a Drug Name", choices = NULL, multiple = TRUE),
      selectInput("Gene","Select a Gene Name",choices = NULL)
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      DT::dataTableOutput(outputId = "main_table")
    )
  )
)

# Define server ----
server <- function(input, output, session) {
  
  # Connect shiny and MySQL
  mydb = dbConnect(MySQL(),user='root',password='password',host='127.0.0.1',port=3306,dbname='sample')
  
  # Read table
  dta_SQL <- dbReadTable(conn = mydb,  name = 'sample_table', value = as.data.frame(dta_SQL))
  
  
  drug_choices <- dbGetQuery(mydb, "SELECT distinct Name FROM sample_table")
  gene_choices <- dbGetQuery(mydb, "SELECT distinct Gene_name FROM sample_table")
  
  
  updateSelectInput(session,"Drug","Select a Drug Name",choices = c(drug_choices))
  updateSelectInput(session,"Gene","Select a Gene Name",choices = c(gene_choices))
  
  
  #
  gene <- reactive({
    filter(dta_SQL, Name %in% input$Drug)
  })
  
  observeEvent(gene(), {
    choices <- unique(gene()$Gene)
    updateSelectInput(session, "Gene","Select a Gene Name", choices = choices) 
  })
  
  
    
  # Output tables
  output$main_table = DT::renderDataTable(
    dta_SQL <- dta_SQL[which(dta_SQL$'Name' %in% input$Drug 
                             & dta_SQL$'Gene_name' %in% input$Gene),]
  )
  
  # Close the connection
  dbDisconnect(mydb)
}

# Run the app ----
shinyApp(ui = ui, server = server)