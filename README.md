# Actuarial Data Manager

## Overview

The Actuarial Data Manager is a metadata-driven system designed to unify, manage, and automate actuarial data pipelines. It provides a centralized solution for handling fragmented data from various sources, enabling transparent, auditable, and maintainable workflows for actuarial analysis.

The core of the project is an R Shiny application that serves as a user-friendly interface for managing the metadata of data pipelines, datasets, profit centers, and insurance programs.

## Features

-   **Centralized Metadata:** A single SQLite database (`database.sqlite`) acts as the source of truth for all data pipeline and dataset metadata.
-   **Shiny UI:** An intuitive web application for viewing, adding, and editing metadata records.
-   **Data Pipeline Management:** A structured framework for defining and managing ETL (Extract, Transform, Load) processes.
-   **Local Development Environment:** Utilizes the Azurite emulator for local Azure Storage development and testing.
-   **Reproducibility:** Uses `renv` for R package management to ensure a reproducible environment.

## Getting Started

### Prerequisites

-   R and RStudio
-   [Azurite](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite) for local Azure Storage emulation.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    ```

2.  **Set up the R Environment:**
    Open the project in RStudio. The `renv` package will automatically prompt you to restore the project's dependencies from the `renv.lock` file. Run `renv::restore()` if not prompted.

3.  **Set up Environment Variables:**
    Create an `.Renviron` file in the project root and add the following lines for the Azurite storage connection:
    ```
    AZURE_ACCOUNT=devstoreaccount1
    AZURE_KEY=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==
    ```

4.  **Create the Database and Storage Containers:**
    Run the following scripts from the `setup/` directory in the specified order:
    ```R
    source("setup/_create_database.R")
    source("setup/_create_containers.R")
    ```
    This will create the `database.sqlite` file and the necessary Azure Storage containers in your local Azurite instance.

## Usage

To launch the Actuarial Data Manager application, run the following command in the R console:

```R
shiny::runApp("app")
```

The application will open in your default web browser, allowing you to interact with the metadata tables.

## Project Structure

```
.
├── app/                # R Shiny application files
│   ├── R/              # Shiny modules and utility functions
│   ├── www/            # Static assets (CSS, images)
│   ├── global.R        # Global settings, library loading
│   ├── server.R        # Server-side logic
│   └── ui.R            # User interface definition
├── setup/              # Scripts for setting up the project environment
│   ├── _create_containers.R
│   ├── _create_database.R
│   └── ...
├── storage/            # Local storage emulator files (Azurite)
├── .Rprofile           # R profile script (e.g., for renv)
├── renv.lock           # R environment lockfile
├── database.sqlite     # (Created by setup script)
└── README.md
```

## Dependencies

The project relies on the following core R packages:

-   `shiny` & `bslib`: For the web application framework and UI theming.
-   `tidyverse`: For data manipulation and utility functions.
-   `DBI` & `RSQLite`: For database interaction.
-   `AzureStor`: For connecting to Azure Blob Storage (and the Azurite emulator).
-   `reactable`: For creating interactive data tables.
-   `renv`: For package management.
