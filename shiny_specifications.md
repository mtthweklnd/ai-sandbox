
# Specifications for Shiny App: Actuarial Data Manager

## 1. Overview & Purpose

This document outlines the specifications for a proposed R Shiny application, the "Actuarial Data Manager." The primary purpose of this application is to provide a user-friendly graphical interface for interacting with the actuarial project metadata stored in the `database.sqlite` database.

The app will allow users to view, add, and modify records in the core metadata tables, ensuring data integrity and providing a centralized management console for pipelines, datasets, and related entities.

## 2. Target Audience

The primary users of this application will be:

*   **Actuaries:** Who need to look up information about programs and pipelines.
*   **Data Engineers & Developers:** Who are responsible for creating, managing, and maintaining the data pipelines and their metadata.

## 3. Core Features

The application will be organized into tabs, with each tab corresponding to a major table in the database.

### Profit Centers

Table Specifications:

*   **profit_center_id:** The profit center UID, not displayed to user.
*   **profit_center_name:** Text Input for logging, and other text elements
*   **profit_center_code:** Text Input for the profit center code

UI Elements:

*   **View:** Display all records from the `profit_centers` table.
*   **Add:** An "Add New Profit Center" button will open a form.
*   **Edit:** An "Edit" button will open a form to modify an existing record.

### Programs 

Table Specifications:

*   **program_id:**  The program UID, not displayed to user.
*   **profit_center_id:** UID from `profit_centers` tables
*   **program_name:** Text Input for logging, and other text elemnts
*   **status:** Options `Active`, `Inactive`
*   **actuary:** Text Input for Actuary Name
*   **created_at** Time of entry, formatted as `%Y-%m-%d %H:%M:%S`

UI Elements:

*   **View:** Display all records from the `programs` table.
*   **Add:** An "Add New Program" button will open a form. The form should include a `profit_center` dropdown populated from the `profit_centers` table. Other form fields should be as described in the Specifications. New entries shhould be added to the data with a date_created column. 
*   **Edit:** An "Edit" button will open a form to modify an existing record.

### Pipelines 

Table Specifications:

*   **pipeline_id:**  The pipeline UID, not displayed to user.
*   **program_id:** UID from `programs` tables
*   **pipeline_name:** Name for logging, and other text elemnts
*   **development_status:** Options `Planning`, `In Development`, `Active`, `Inactive`
*   **storage_location:** Name of blob storage container

UI Elements:

*   **View:** Display all records from the `pipelines` table.
*   **Add:** An "Add New Pipeline" button will open a form. The form should include a profit center dropdown, and a program dropdown dependent on the profit center choice. Other form fields should be as described in the Specifications.
*   **Edit:** An "Edit" button will open a form to modify an existing record.

### Datasets

Table Specifications:

*   **dataset_id:** The dataset UID, not displayed to user.
*   **pipeline_id:** UID from `pipelines` table.
*   **dataset_name:** Text input for the name of the dataset.
*   **file_type:** Options `SQL Table`, `Parquet`.
*   **as_of_date:** Date input for the as of date of the dataset.
*   **status:** Options `Source`, `Clean`, `Output`.
*   **created_at:** Date of entry, formatted as `%Y-%m-%d`.

UI Elements:

*   **View:** Display all records from the `datasets` table.
*   **Add:** An "Add New Dataset" button will open a form. The form should include a series of dependent dropdowns for profit center, program, and pipeline. Other form fields should be as described in the Specifications.
*   **Edit:** An "Edit" button will open a form to modify an existing record.

## 4. User Interface (UI) & User Experience (UX)

*   **Layout:** The app will use a `page_navbar` layout, with each tab dedicated to one of the database tables.
*   **Theming:** The visual theme will be managed by the `bslib` package, allowing for easy and modern customization (e.g., using the `minty` theme).
*   **Interactivity:**
    *   Tables will be rendered using the `reactable` package for any displayed dataframes.
    *   Adding and editing data will be handled through modal dialogs (`showModal()`) to avoid navigating away from the main view.
    *   Dropdown menus will be used for foreign key relationships (e.g., selecting a Profit Center when creating a Program) to ensure data integrity.
*   **Feedback:** The app will provide user feedback (e.g., "Record added successfully") upon completion of actions.

## 5. Technical Specifications

*   **Backend:** R, Shiny
*   **Database Interaction:** `DBI` and `RSQLite` packages to connect to and manipulate the `database.sqlite` file.
*   **Frontend/UI:** `shiny` for the core framework, `bslib` for theming, `reactable` for interactive tables.

## 6. Proposed Directory Structure

The application will be housed in a dedicated `app/` directory with the following structure:

```
app/
├── R/              # For shiny modules and utility functions
|  ├── add-logic.R    # Server-side logic for adding new records
|  ├── edit-logic.R   # Server-side logic for editing existing records
|  └── load-data.R  # Loading SQL tables, joining related tables, creating dependencies
├── www/            # For CSS, images, and other static assets
├── server.R        # server logic
├── ui.R
└── global.R           # library loading, functions, connections
```

The main `database.sqlite` file will remain in the project root for this implementation.

## 7. Database Tables Creation Code (for reference)

This is the SQL code used to generate the tables in `database.sqlite`, taken from the `setup/_create_database.R` file.

### Profit Centers
```sql
CREATE TABLE IF NOT EXISTS profit_centers (
  profit_center_id INTEGER PRIMARY KEY AUTOINCREMENT,
  profit_center_name TEXT NOT NULL,
  profit_center_code TEXT
);
```

### Programs
```sql
CREATE TABLE IF NOT EXISTS programs (
  program_id INTEGER PRIMARY KEY AUTOINCREMENT,
  profit_center_id INTEGER,
  program_name TEXT,
  status TEXT,
  actuary TEXT,
  created_at DATETIME,
  FOREIGN KEY (profit_center_id) REFERENCES profit_centers(profit_center_id)
);
```

### Pipelines
```sql
CREATE TABLE IF NOT EXISTS pipelines (
  pipeline_id INTEGER PRIMARY KEY AUTOINCREMENT,
  program_id INTEGER,
  pipeline_name TEXT,
  development_status TEXT,
  storage_location TEXT,
  FOREIGN KEY (program_id) REFERENCES programs(program_id)
);
```

### Datasets
```sql
CREATE TABLE IF NOT EXISTS datasets (
  dataset_id INTEGER PRIMARY KEY AUTOINCREMENT,
  pipeline_id INTEGER,
  dataset_name TEXT,
  file_type TEXT,
  as_of_date DATE,
  status TEXT,
  created_at DATE,
  FOREIGN KEY (pipeline_id) REFERENCES pipelines(pipeline_id)
);
```
