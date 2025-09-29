setup_add_logic <- function(input, output, session, con, data_changed) {

  # --- Profit Center Add Logic ---

  # Show Add Modal
  observeEvent(input$add_profit_center_btn, {
    showModal(modalDialog(
      title = "Add New Profit Center",
      textInput("pc_name_input", "Profit Center Name", placeholder = "e.g., Specialty Casualty"),
      textInput("pc_code_input", "Profit Center Code", placeholder = "e.g., SC123"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("save_profit_center_btn", "Save")
      )
    ))
  })

  # Save New Profit Center
  observeEvent(input$save_profit_center_btn, {
    tryCatch({
      dbExecute(con, "INSERT INTO profit_centers (profit_center_name, profit_center_code) VALUES (?, ?)", 
                param = list(input$pc_name_input, input$pc_code_input))
      data_changed(data_changed() + 1)
      removeModal()
      showNotification("Profit center added successfully!", type = "message")
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error")
    })
  })

  # --- Program List Management ---

  # Show Add Program Modal
  observeEvent(input$add_program_btn, {
    # Fetch profit centers for the dropdown
    profit_centers <- dbGetQuery(con, "SELECT profit_center_name FROM profit_centers ORDER BY profit_center_name")

    showModal(modalDialog(
      title = "Add New Program",
      selectInput("program_pc_input", "Profit Center", choices = profit_centers$profit_center_name),
      textInput("program_name_input", "Program Name", placeholder = "e.g., Commercial Auto Liability"),
      radioButtons("program_status_input", "Status", choices = c("Active", "Inactive"), inline = TRUE),
      textInput("program_actuary_input", "Actuary", placeholder = "e.g., John Doe"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("save_program_btn", "Save")
      )
    ))
  })

  # Save New Program
  observeEvent(input$save_program_btn, {
    tryCatch({
      # Get profit_center_id from name
      pc_id_df <- dbGetQuery(con, "SELECT profit_center_id FROM profit_centers WHERE profit_center_name = ?", params = list(input$program_pc_input))
      pc_id <- pc_id_df$profit_center_id

      query <- "INSERT INTO programs (profit_center_id, program_name, status, actuary, created_at) VALUES (?, ?, ?, ?, ?)"
      params <- list(pc_id, input$program_name_input, input$program_status_input, input$program_actuary_input, Sys.time())
      
      dbExecute(con, query, param = params)
      
      data_changed(data_changed() + 1)
      removeModal()
      showNotification("Program added successfully!", type = "message")
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error")
    })
  })

  # --- Pipeline List Management ---

  # Show Add Pipeline Modal
  observeEvent(input$add_pipeline_btn, {
    profit_centers <- dbGetQuery(con, "SELECT profit_center_name FROM profit_centers ORDER BY profit_center_name")
    
    showModal(modalDialog(
      title = "Add New Pipeline",
      selectInput("pipeline_profit_center_input", "Profit Center", choices = c("", profit_centers$profit_center_name)),
      selectInput("pipeline_program_input", "Program", choices = NULL), # Initially empty
      textInput("pipeline_name_input", "Pipeline Name", placeholder = "e.g., Quarterly Loss Data Refresh"),
      radioButtons("pipeline_dev_status_input", "Development Status", choices = c("Planning", "In Development", "Active", "Inactive"), selected = "Planning"),
      selectInput("pipeline_storage_input", "Storage Container", choices = storage_containers),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("save_pipeline_btn", "Save")
      )
    ))
  })

  # When a profit center is selected in the add pipeline modal, update the program choices
  observeEvent(input$pipeline_profit_center_input, {
    req(input$pipeline_profit_center_input) # require a selection
    
    # Get profit_center_id from name
    pc_id_df <- dbGetQuery(con, "SELECT profit_center_id FROM profit_centers WHERE profit_center_name = ?", params = list(input$pipeline_profit_center_input))
    pc_id <- pc_id_df$profit_center_id
    
    if (length(pc_id) > 0) {
      # Fetch programs for the selected profit center
      programs <- dbGetQuery(con, "SELECT program_id, program_name FROM programs WHERE profit_center_id = ? ORDER BY program_name", params = list(pc_id))
      program_choices <- setNames(programs$program_id, programs$program_name)
    } else {
      program_choices <- NULL
    }
    
    updateSelectInput(session, "pipeline_program_input", choices = program_choices)
  }, ignoreInit = TRUE)

  # Save New Pipeline
  observeEvent(input$save_pipeline_btn, {
    tryCatch({
      query <- "INSERT INTO pipelines (program_id, pipeline_name, development_status, storage_location) VALUES (?, ?, ?, ?)"
      params <- list(input$pipeline_program_input, input$pipeline_name_input, input$pipeline_dev_status_input, input$pipeline_storage_input)
      
      dbExecute(con, query, param = params)
      
      data_changed(data_changed() + 1)
      removeModal()
      showNotification("Pipeline added successfully!", type = "message")
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error")
    })
  })
  
  # --- Dataset Management ---
  
  # Show Add Dataset Modal
  observeEvent(input$add_dataset_btn, {
    profit_centers <- dbGetQuery(con, "SELECT profit_center_name FROM profit_centers ORDER BY profit_center_name")
    
    showModal(modalDialog(
      title = "Add New Dataset",
      selectInput("dataset_profit_center_input", "Profit Center", choices = c("", profit_centers$profit_center_name)),
      selectInput("dataset_program_input", "Program", choices = NULL), # Initially empty
      selectInput("dataset_pipeline_input", "Pipeline", choices = NULL), # Initially empty
      textInput("dataset_name_input", "Dataset Name", placeholder = "e.g., Raw Claims Data"),
      selectInput("dataset_file_type_input", "File Type", choices = c("SQL Table", "Parquet")),
      dateInput("dataset_as_of_date_input", "As Of Date", value = Sys.Date()),
      selectInput("dataset_status_input", "Status", choices = c("Source", "Clean", "Output")),
      dateInput("dataset_created_at_input", "Creation Date", value = Sys.Date()),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("save_dataset_btn", "Save")
      )
    ))
  })

  # When a profit center is selected in the add dataset modal, update the program choices
  observeEvent(input$dataset_profit_center_input, {
    req(input$dataset_profit_center_input) # require a selection
    
    # Get profit_center_id from name
    pc_id_df <- dbGetQuery(con, "SELECT profit_center_id FROM profit_centers WHERE profit_center_name = ?", params = list(input$dataset_profit_center_input))
    pc_id <- pc_id_df$profit_center_id
    
    if (length(pc_id) > 0) {
      # Fetch programs for the selected profit center
      programs <- dbGetQuery(con, "SELECT program_id, program_name FROM programs WHERE profit_center_id = ? ORDER BY program_name", params = list(pc_id))
      program_choices <- setNames(programs$program_id, programs$program_name)
    } else {
      program_choices <- NULL
    }
    
    updateSelectInput(session, "dataset_program_input", choices = program_choices)
    updateSelectInput(session, "dataset_pipeline_input", choices = NULL) # Clear pipeline selection
  }, ignoreInit = TRUE)

  # When a program is selected in the add dataset modal, update the pipeline choices
  observeEvent(input$dataset_program_input, {
    req(input$dataset_program_input) # require a selection
    
    # Fetch pipelines for the selected program
    pipelines <- dbGetQuery(con, "SELECT pipeline_id, pipeline_name FROM pipelines WHERE program_id = ? ORDER BY pipeline_name", params = list(input$dataset_program_input))
    pipeline_choices <- setNames(pipelines$pipeline_id, pipelines$pipeline_name)
    
    updateSelectInput(session, "dataset_pipeline_input", choices = pipeline_choices)
  }, ignoreInit = TRUE)
  
  # Save New Dataset
  observeEvent(input$save_dataset_btn, {
    tryCatch({
      query <- "INSERT INTO datasets (pipeline_id, dataset_name, file_type, as_of_date, status, created_at) VALUES (?, ?, ?, ?, ?, ?)"
      params <- list(
        input$dataset_pipeline_input, 
        input$dataset_name_input, 
        input$dataset_file_type_input, 
        as.character(input$dataset_as_of_date_input),
        input$dataset_status_input, 
        as.character(input$dataset_created_at_input)
      )
      
      dbExecute(con, query, param = params)
      
      data_changed(data_changed() + 1)
      removeModal()
      showNotification("Dataset added successfully!", type = "message")
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error")
    })
  })
}