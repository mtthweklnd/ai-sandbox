library(AzureStor)


endp <- blob_endpoint(
  paste0("http://127.0.0.1:10000/", Sys.getenv("AZURE_ACCOUNT")),
  key = Sys.getenv("AZURE_KEY")
)

# Container names to create
container_names <- c("data-store", "dev-store", "archive-store")

# Get existing containers
existing_containers <- list_blob_containers(endp)
existing_container_names <- sapply(existing_containers, function(x) x$name)

# Loop through container names and create if they don't exist
for (container_name in container_names) {
  if (!container_name %in% existing_container_names) {
    cat(paste("Creating container:", container_name, "\n"))
    create_blob_container(endp, container_name)
  } else {
    cat(paste("Container already exists:", container_name, "\n"))
  }
}

cat("Container setup complete.\n")


