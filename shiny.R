library(shiny)
library(DBI)
library(RMySQL)
library(DT)

# Define UI ----
ui <- fluidPage(
  
  # App title
  titlePanel("Rshiny and MySQL connect and operate"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    
    # Move sidebar to the right
    #position = "right",
    
    # Sidebar panel for inputs
    sidebarPanel(
      
      DT::dataTableOutput(outputId = "selected_table")
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      DT::dataTableOutput(outputId = "main_table")
    )
  )
)

# Define server ----
server <- function(input, output) {
  
  # Connect shiny and MySQL
  mydb = dbConnect(MySQL(),user='root',password='password',host='127.0.0.1',port=3306,dbname='sample')
  
  # Insert
  dbGetQuery(mydb, "INSERT INTO sample_table (DBID, Name, target_name, Gene_name) VALUE('DB00162', 'vitamin a','Short-chain dehydrogenase/reductase 3', 'RDH13')")
  
  # Delete
  dbGetQuery(mydb, "DELETE FROM sample_table WHERE Gene_name = 'RDH13'")
  
  # Search
  dbGetQuery(mydb, "SELECT COUNT(*) FROM sample_table WHERE Gene_name='ADH5'")
  
  # Define two tables
  full_table <- dbGetQuery(mydb, "SELECT * FROM sample_table")
  selected_table <- dbGetQuery(mydb, "SELECT * FROM sample_table WHERE Gene_name='ADH5'")
  
  # Output tables
  output$selected_table = DT::renderDataTable(full_table)
  output$main_table = DT::renderDataTable(selected_table)
  
  # Close the connection
  dbDisconnect(mydb)
}

# Run the app ----
shinyApp(ui = ui, server = server)