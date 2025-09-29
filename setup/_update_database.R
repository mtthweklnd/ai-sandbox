library(DBI)
library(RSQLite)
library(here)

# Define the name of the database file
db_file <- here::here("database.sqlite")

# Create a connection to the database
con <- dbConnect(RSQLite::SQLite(), dbname = db_file)

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

# Validate that all tables were created successfully
cat("Tables created or updated successfully:\n")
print(dbListTables(con))

# Disconnect from the database
dbDisconnect(con)


