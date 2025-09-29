setup_edit_logic <- function(input, output, session, con, profit_centers_data, programs_data, pipelines_data, datasets_data, data_changed) {

  # This will store the ID of the row being edited
  editing_id <- reactiveVal(NULL)

  # Show Edit Modal
  observeEvent(input$last_edit_button, {
    if (startsWith(input$last_edit_button, "edit_pc_")) {
      pc_id <- as.integer(sub("edit_pc_", "", input$last_edit_button))
      editing_id(pc_id)
      pc_data <- profit_centers_data() |> dplyr::filter(profit_center_id == pc_id)
      
      showModal(modalDialog(
        title = "Edit Profit Center",
        textInput("pc_name_input_edit", "Profit Center Name", value = pc_data$profit_center_name),
        textInput("pc_code_input_edit", "Profit Center Code", value = pc_data$profit_center_code),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("save_pc_edit_btn", "Save")
        )
      ))
    } else if (startsWith(input$last_edit_button, "edit_program_")) {
      program_id <- as.integer(sub("edit_program_", "", input$last_edit_button))
      editing_id(program_id)
      program_data <- programs_data() |> dplyr::filter(program_id == program_id)
      
      profit_centers <- dbGetQuery(con, "SELECT profit_center_name FROM profit_centers ORDER BY profit_center_name")
      
      showModal(modalDialog(
        title = "Edit Program",
        selectInput("program_pc_input_edit", "Profit Center", choices = profit_centers$profit_center_name, selected = dbGetQuery(con, "SELECT profit_center_name FROM profit_centers WHERE profit_center_id = ?", params = list(program_data$profit_center_id))[[1]]),
        textInput("program_name_input_edit", "Program Name", value = program_data$program_name),
        radioButtons("program_status_input_edit", "Status", choices = c("Active", "Inactive"), selected = program_data$status, inline = TRUE),
        textInput("program_actuary_input_edit", "Actuary", value = program_data$actuary),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("save_program_edit_btn", "Save")
        )
      ))
    } else if (startsWith(input$last_edit_button, "edit_pipeline_")) {
      pipeline_id <- as.integer(sub("edit_pipeline_", "", input$last_edit_button))
      editing_id(pipeline_id)
      pipeline_data <- pipelines_data() |> dplyr::filter(pipeline_id == pipeline_id)
      
      profit_centers <- dbGetQuery(con, "SELECT profit_center_name FROM profit_centers ORDER BY profit_center_name")
      programs <- dbGetQuery(con, "SELECT program_id, program_name FROM programs WHERE profit_center_id = (SELECT profit_center_id FROM programs WHERE program_id = ?)", params = list(pipeline_data$program_id))
      program_choices <- setNames(programs$program_id, programs$program_name)
      
      showModal(modalDialog(
        title = "Edit Pipeline",
        selectInput("pipeline_profit_center_input_edit", "Profit Center", choices = c("", profit_centers$profit_center_name), selected = pipeline_data$profit_center_name),
        selectInput("pipeline_program_input_edit", "Program", choices = program_choices, selected = pipeline_data$program_id),
        textInput("pipeline_name_input_edit", "Pipeline Name", value = pipeline_data$pipeline_name),
        radioButtons("pipeline_dev_status_input_edit", "Development Status", choices = c("Planning", "In Development", "Active", "Inactive"), selected = pipeline_data$development_status),
        textInput("pipeline_storage_input_edit", "Storage Location", value = pipeline_data$storage_location),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("save_pipeline_edit_btn", "Save")
        )
      ))
    } else if (startsWith(input$last_edit_button, "edit_dataset_")) {
      dataset_id <- as.integer(sub("edit_dataset_", "", input$last_edit_button))
      editing_id(dataset_id)
      dataset_data <- datasets_data() |> dplyr::filter(dataset_id == dataset_id)
      
      # Get current selections
      pipeline_id <- dbGetQuery(con, "SELECT pipeline_id FROM datasets WHERE dataset_id = ?", params = list(dataset_id))[[1]]
      program_id <- dbGetQuery(con, "SELECT program_id FROM pipelines WHERE pipeline_id = ?", params = list(pipeline_id))[[1]]
      profit_center_id <- dbGetQuery(con, "SELECT profit_center_id FROM programs WHERE program_id = ?", params = list(program_id))[[1]]
      profit_center_name <- dbGetQuery(con, "SELECT profit_center_name FROM profit_centers WHERE profit_center_id = ?", params = list(profit_center_id))[[1]]

      # Choices for dropdowns
      profit_centers <- dbGetQuery(con, "SELECT profit_center_name FROM profit_centers ORDER BY profit_center_name")
      programs <- dbGetQuery(con, "SELECT program_id, program_name FROM programs WHERE profit_center_id = ? ORDER BY program_name", params = list(profit_center_id))
      program_choices <- setNames(programs$program_id, programs$program_name)
      pipelines <- dbGetQuery(con, "SELECT pipeline_id, pipeline_name FROM pipelines WHERE program_id = ? ORDER BY pipeline_name", params = list(program_id))
      pipeline_choices <- setNames(pipelines$pipeline_id, pipelines$pipeline_name)

      showModal(modalDialog(
        title = "Edit Dataset",
        selectInput("dataset_profit_center_input_edit", "Profit Center", choices = profit_centers$profit_center_name, selected = profit_center_name),
        selectInput("dataset_program_input_edit", "Program", choices = program_choices, selected = program_id),
        selectInput("dataset_pipeline_input_edit", "Pipeline", choices = pipeline_choices, selected = pipeline_id),
        textInput("dataset_name_input_edit", "Dataset Name", value = dataset_data$dataset_name),
        selectInput("dataset_file_type_input_edit", "File Type", choices = c("SQL Table", "Parquet"), selected = dataset_data$file_type),
        dateInput("dataset_as_of_date_input_edit", "As Of Date", value = dataset_data$as_of_date),
        selectInput("dataset_status_input_edit", "Status", choices = c("Source", "Clean", "Output"), selected = dataset_data$status),
        dateInput("dataset_created_at_input_edit", "Creation Date", value = dataset_data$created_at),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("save_dataset_edit_btn", "Save")
        )
      ))
    }
  })

  # When a profit center is selected in the edit dataset modal, update the program choices
  observeEvent(input$dataset_profit_center_input_edit, {
    req(input$dataset_profit_center_input_edit) # require a selection
    
    # Get profit_center_id from name
    pc_id_df <- dbGetQuery(con, "SELECT profit_center_id FROM profit_centers WHERE profit_center_name = ?", params = list(input$dataset_profit_center_input_edit))
    pc_id <- pc_id_df$profit_center_id
    
    if (length(pc_id) > 0) {
      # Fetch programs for the selected profit center
      programs <- dbGetQuery(con, "SELECT program_id, program_name FROM programs WHERE profit_center_id = ? ORDER BY program_name", params = list(pc_id))
      program_choices <- setNames(programs$program_id, programs$program_name)
    } else {
      program_choices <- NULL
    }
    
    updateSelectInput(session, "dataset_program_input_edit", choices = program_choices)
    updateSelectInput(session, "dataset_pipeline_input_edit", choices = NULL) # Clear pipeline selection
  }, ignoreInit = TRUE)

  # When a program is selected in the edit dataset modal, update the pipeline choices
  observeEvent(input$dataset_program_input_edit, {
    req(input$dataset_program_input_edit) # require a selection
    
    # Fetch pipelines for the selected program
    pipelines <- dbGetQuery(con, "SELECT pipeline_id, pipeline_name FROM pipelines WHERE program_id = ? ORDER BY pipeline_name", params = list(input$dataset_program_input_edit))
    pipeline_choices <- setNames(pipelines$pipeline_id, pipelines$pipeline_name)
    
    updateSelectInput(session, "dataset_pipeline_input_edit", choices = pipeline_choices)
  }, ignoreInit = TRUE)

  # Save Edited Profit Center
  observeEvent(input$save_pc_edit_btn, {
    pc_id <- editing_id()
    if (!is.null(pc_id)) {
      tryCatch({
        dbExecute(con, "UPDATE profit_centers SET profit_center_name = ?, profit_center_code = ? WHERE profit_center_id = ?",
                  param = list(input$pc_name_input_edit, input$pc_code_input_edit, pc_id))
        data_changed(data_changed() + 1)
        removeModal()
        showNotification("Profit center updated successfully!", type = "message")
      }, error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
      })
    }
  })

  # Save Edited Program
  observeEvent(input$save_program_edit_btn, {
    program_id <- editing_id()
    if (!is.null(program_id)) {
      tryCatch({
        pc_id_df <- dbGetQuery(con, "SELECT profit_center_id FROM profit_centers WHERE profit_center_name = ?", params = list(input$program_pc_input_edit))
        pc_id <- pc_id_df$profit_center_id
        
        dbExecute(con, "UPDATE programs SET profit_center_id = ?, program_name = ?, status = ?, actuary = ? WHERE program_id = ?",
                  param = list(pc_id, input$program_name_input_edit, input$program_status_input_edit, input$program_actuary_input_edit, program_id))
        data_changed(data_changed() + 1)
        removeModal()
        showNotification("Program updated successfully!", type = "message")
      }, error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
      })
    }
  })

  # Save Edited Pipeline
  observeEvent(input$save_pipeline_edit_btn, {
    pipeline_id <- editing_id()
    if (!is.null(pipeline_id)) {
      tryCatch({
        dbExecute(con, "UPDATE pipelines SET program_id = ?, pipeline_name = ?, development_status = ?, storage_location = ? WHERE pipeline_id = ?",
                  param = list(input$pipeline_program_input_edit, input$pipeline_name_input_edit, input$pipeline_dev_status_input_edit, input$pipeline_storage_input_edit, pipeline_id))
        data_changed(data_changed() + 1)
        removeModal()
        showNotification("Pipeline updated successfully!", type = "message")
      }, error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
      })
    }
  })
  
  # Save Edited Dataset
  observeEvent(input$save_dataset_edit_btn, {
    dataset_id <- editing_id()
    if (!is.null(dataset_id)) {
      tryCatch({
        dbExecute(con, "UPDATE datasets SET pipeline_id = ?, dataset_name = ?, file_type = ?, as_of_date = ?, status = ?, created_at = ? WHERE dataset_id = ?",
                  param = list(input$dataset_pipeline_input_edit, 
                               input$dataset_name_input_edit, 
                               input$dataset_file_type_input_edit, 
                               as.character(input$dataset_as_of_date_input_edit),
                               input$dataset_status_input_edit, 
                               as.character(input$dataset_created_at_input_edit), 
                               dataset_id))
        data_changed(data_changed() + 1)
        removeModal()
        showNotification("Dataset updated successfully!", type = "message")
      }, error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
      })
    }
  })
}