# Connection Details

This document provides technical details for connecting to various services used in this project.

## Azurite Storage Emulator

The project uses the Azurite emulator for local development of Azure Storage.

### Connection Example

```r
endp <- blob_endpoint(
  paste0("http://127.0.0.1:10000/", Sys.getenv("AZURE_ACCOUNT")),
  key = Sys.getenv("AZURE_KEY")
)

```
*   **Blob Service Endpoint**: `http://127.0.0.1:10000`
*   **Account Name**: `devstoreaccount1`
*   **Account Key**: `Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==`

These values should be set as environment variables. For local development, you can add them to an `.Renviron` file in the project root.

### Storage Containers

The following storage containers are created by the `setup/_create_containers.R` script:

*   `data-store`
*   `dev-store`
*   `archive-store`
