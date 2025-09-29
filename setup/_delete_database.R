library(DBI)
library(RSQLite)
library(here)

# Define the name of the database file
db_file <- here::here("database.sqlite")

# Create a connection to the database
con <- dbConnect(RSQLite::SQLite(), dbname = db_file)
dbDisconnect(con)
file.remove(db_file)
