# Load required libraries
library(shiny)
library(bslib)
library(DT)
library(DBI)
library(RSQLite)
library(here)
library(dplyr)
library(reactable)
library(stringr)
library(AzureStor)

# Establish database connection
# here::here() ensures the path is relative to the project root
con <- dbConnect(RSQLite::SQLite(), dbname = here::here("database.sqlite"))

# Connect to Azurite Emulator
# This uses environment variables for the endpoint and key.
# Make sure AZURE_BLOB_ENDPOINT and AZURE_KEY are set in your .Renviron or environment.
# Default for Azurite:
# AZURE_ACCOUNT="http://127.0.0.1:10000/devstoreaccount1"
# AZURE_KEY="Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw=="

endp <- blob_endpoint(
  paste0("http://127.0.0.1:10000/", Sys.getenv("AZURE_ACCOUNT")),
  key = Sys.getenv("AZURE_KEY")
)

# Get storage container names
storage_containers <- sapply(
  list_blob_containers(endp),
  function(x) x$name
)

# Close the connection when the app stops
onStop(function() {
  dbDisconnect(con)
})
