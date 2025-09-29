load_data <- function(input, output, session, con, data_changed) {
  # Fetch Profit Centers data
  profit_centers_data <- reactive({
    data_changed()
    dbReadTable(con, "profit_centers") |> mutate(Actions = "")
  })

  # Render Profit Centers table
  output$profit_centers_table <- reactable::renderReactable({
    reactable(
      profit_centers_data(),
      columns = list(
        profit_center_id = colDef(show = FALSE),
        Actions = colDef(name = "", width = 80, cell = function(value, index) {
          actionButton(paste0("edit_pc_", profit_centers_data()$profit_center_id[index]), 
                       "Edit", 
                       class = "btn-sm",
                       onclick = 'Shiny.setInputValue("last_edit_button", this.id, {priority: "event"})')
        })
      )
    )
  })

  # Fetch Program List data
  programs_data <- reactive({
    data_changed()
    dbReadTable(con, "programs") |> 
      mutate(created_at = format(as.POSIXct(created_at, origin = "1970-01-01"), "%Y-%m-%d %H:%M:%S"),
             Actions = "")
  })

  # Render Program List table
  output$programs_table <- reactable::renderReactable({
    reactable(
      programs_data(),
      columns = list(
        program_id = colDef(show = FALSE),
        profit_center_id = colDef(show = FALSE),
        Actions = colDef(name = "", width = 80, cell = function(value, index) {
          actionButton(paste0("edit_program_", programs_data()$program_id[index]), 
                       "Edit", 
                       class = "btn-sm",
                       onclick = 'Shiny.setInputValue("last_edit_button", this.id, {priority: "event"})')
        })
      )
    )
  })

  # Fetch Pipeline List data
  pipelines_data <- reactive({
    data_changed()
    query <- "
      SELECT
        pl.pipeline_id,
        pc.profit_center_name,
        prg.program_name,
        pl.pipeline_name,
        pl.development_status,
        pl.storage_location
      FROM pipelines AS pl
      LEFT JOIN programs AS prg ON pl.program_id = prg.program_id
      LEFT JOIN profit_centers AS pc ON prg.profit_center_id = pc.profit_center_id
    "
    dbGetQuery(con, query) |> mutate(Actions = "")
  })

  # Render Pipeline List table
  output$pipelines_table <- reactable::renderReactable({
    reactable(
      pipelines_data(),
      columns = list(
        pipeline_id = colDef(show = FALSE),
        Actions = colDef(name = "", width = 80, cell = function(value, index) {
          actionButton(paste0("edit_pipeline_", pipelines_data()$pipeline_id[index]), 
                       "Edit", 
                       class = "btn-sm",
                       onclick = 'Shiny.setInputValue("last_edit_button", this.id, {priority: "event"})')
        })
      )
    )
  })
  
  # Fetch Datasets data
  datasets_data <- reactive({
    data_changed()
    query <- "
      SELECT
        d.dataset_id,
        p.pipeline_name,
        d.dataset_name,
        d.file_type,
        d.as_of_date,
        d.status,
        d.created_at
      FROM datasets AS d
      LEFT JOIN pipelines AS p ON d.pipeline_id = p.pipeline_id
    "
    dbGetQuery(con, query) |> 
      mutate(as_of_date = format(as.Date(as_of_date), "%Y-%m-%d")) |>
      mutate(Actions = "")
  })
  
  # Render Datasets table
  output$datasets_table <- reactable::renderReactable({
    reactable(
      datasets_data(),
      columns = list(
        dataset_id = colDef(show = FALSE),
        Actions = colDef(name = "", width = 80, cell = function(value, index) {
          actionButton(paste0("edit_dataset_", datasets_data()$dataset_id[index]),
                       "Edit",
                       class = "btn-sm",
                       onclick = 'Shiny.setInputValue("last_edit_button", this.id, {priority: "event"})')
        })
      )
    )
  })

  return(list(
    profit_centers_data = profit_centers_data,
    programs_data = programs_data,
    pipelines_data = pipelines_data,
    datasets_data = datasets_data
  ))
}