ui <- page_navbar( 
  title = "Actuarial Data Manager",
  theme = bslib::bs_theme(version = 5, bootswatch = "minty"),
    
    nav_panel("Profit Centers",
             h3("Profit Center Management"),
             actionButton("add_profit_center_btn", "Add New Profit Center", class = "btn-primary mb-3"),
             reactable::reactableOutput("profit_centers_table")
    ),
    nav_panel("Programs",
             h3("Program List Management"),
             actionButton("add_program_btn", "Add New Program", class = "btn-primary mb-3"),
             reactable::reactableOutput("programs_table")
    ),
    nav_panel("Pipelines",
             h3("Pipeline List Management"),
             actionButton("add_pipeline_btn", "Add New Pipeline", class = "btn-primary mb-3"),
             reactable::reactableOutput("pipelines_table")
    ),
    nav_panel("Datasets",
             h3("Dataset Management"),
             actionButton("add_dataset_btn", "Add New Dataset", class = "btn-primary mb-3"),
             reactable::reactableOutput("datasets_table")
    )
  )

