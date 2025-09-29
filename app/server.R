server <- function(input, output, session) {
  source("R/load-data.R")
  source("R/add-logic.R")
  source("R/edit-logic.R")
  
  # Reactive value to trigger table refresh
  data_changed <- reactiveVal(0)

  # Load data and render tables
  loaded_data <- load_data(input, output, session, con, data_changed)
  
  # Initialize the add logic
  setup_add_logic(input, output, session, con, data_changed)

  # Initialize the edit logic
  setup_edit_logic(input, output, session, con, loaded_data$profit_centers_data, loaded_data$programs_data, loaded_data$pipelines_data, loaded_data$datasets_data, data_changed)
  
}
