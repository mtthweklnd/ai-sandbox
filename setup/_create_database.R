library(DBI)
library(RSQLite)
library(here)

# Define the name of the database file
db_file <- here::here("database.sqlite")

# Create a connection to the database
# This will create the database file if it doesn't exist
con <- dbConnect(RSQLite::SQLite(), dbname = db_file)

profit_centers <- data.frame(
  profit_center_id = c(1,2,3),
  profit_center_name = c("InsureMart", "AltRisk", "CompGuys"),
  profit_center_code = c("012", "345", "567")
)

# --- Insert Program Details ---
programs <- data.frame(
  program_id = c(1:6),
  profit_center_id = c(1,1,1,2,2,3),
  program_name = c("Personal Property", "Personal Auto", "Commercial Liability", "Professional Liability", "Executive Liability", "Worker's Compensation"),
  status = c("Active", "Active", "Active", "Inactive", "Active", "Inactive"),
  actuary = c("John Johnson", "John Johnson", "Katie Smith", "Rebecca Jones", "Rebecca Jones", "Katie Smith"),
  created_at = Sys.time()
)

pipelines <- data.frame(
  pipeline_id = c(1, 2, 3, 4),
  program_id = c(2, 3, 4, 5),
  pipeline_name = c("insuremart-auto", "commliab-pilot", "proliab-dev", "execliab-archive"),
  development_status = c("Active", "Planning", "In Development", "Inactive"),
  storage_location = c("data-store", "data-store", "dev-store", "archive-store")
)

# -- Table: profit_centers --
# This is the parent table with no external dependencies.
sql_create_profit_centers <- "
CREATE TABLE IF NOT EXISTS profit_centers (
  profit_center_id INTEGER PRIMARY KEY AUTOINCREMENT,
  profit_center_name TEXT NOT NULL UNIQUE,
  profit_center_code TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL DEFAULT 'Active' -- Added status column
);
" 
DBI::dbExecute(con, sql_create_profit_centers)
DBI::dbWriteTable(con, "profit_centers", profit_centers, append = TRUE)

# -- Table: program_list --
# This table links to profit_centers.
sql_create_program_list <- "
CREATE TABLE IF NOT EXISTS programs (
  program_id INTEGER PRIMARY KEY AUTOINCREMENT,
  profit_center_id INTEGER,
  program_name TEXT,
  status TEXT,
  actuary TEXT,
  created_at DATETIME,
  FOREIGN KEY (profit_center_id) REFERENCES profit_centers(profit_center_id)
);
"
dbExecute(con, sql_create_program_list)
DBI::dbWriteTable(con, "programs", programs, append = TRUE)

# -- Table: pipeline_list --
# This table links to program_list.
sql_create_pipeline_list <- "
CREATE TABLE IF NOT EXISTS pipelines (
  pipeline_id INTEGER PRIMARY KEY AUTOINCREMENT,
  program_id INTEGER,
  pipeline_name TEXT,
  development_status TEXT,
  storage_location TEXT,
  status TEXT NOT NULL DEFAULT 'Active',
  FOREIGN KEY (program_id) REFERENCES programs(program_id)
);
"
dbExecute(con, sql_create_pipeline_list)
DBI::dbWriteTable(con, "pipelines", pipelines, append = TRUE)


# -- Table: datasets --
sql_create_datasets <- "
CREATE TABLE IF NOT EXISTS datasets (
  dataset_id INTEGER PRIMARY KEY AUTOINCREMENT,
  pipeline_id INTEGER,
  dataset_name TEXT,
  file_type TEXT,
  as_of_date DATE,
  status TEXT,
  created_at DATETIME,
  FOREIGN KEY (pipeline_id) REFERENCES pipelines(pipeline_id)
);
"
dbExecute(con, sql_create_datasets)

# -- Table: dataset_attributes --
sql_create_dataset_attributes <- "
CREATE TABLE IF NOT EXISTS dataset_attributes (
  attribute_id INTEGER PRIMARY KEY AUTOINCREMENT,
  dataset_id INTEGER,
  column_name TEXT,
  data_type TEXT,
  description TEXT,
  FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id)
);
"
dbExecute(con, sql_create_dataset_attributes)

# Step 3: Validate that all tables were created successfully.
cat("Tables created successfully:\n")
print(dbListTables(con))

# Step 4: Disconnect from the database.
dbDisconnect(con)
