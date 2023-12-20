# Server

The server is a [Plumber](https://www.rplumber.io/) API that runs simulations on behalf of the client. Code for
running simulations in an isolated setting is also included.

## Prerequisites

You must have the following installed:

- [R](https://www.r-project.org/)
- [RStudio](https://rstudio.com/)

Moreover, assuming no preprocessing has been done, for the server to run, the following scripts must be executed:

- [`server/R/script.prepare_data_and_models.R`](./R/script.prepare_data_and_models.R)

The repostitory includes preprocessing so this step may be omitted.

## Getting Started

- To run the API, open the project in RStudio, open [`server/api.R`](./api.R), and click the "Run API" button in the top right.
- To run simulations in an isolated setting, open the project in RStudio, open [`server/run_simulations.R`](./run_simulations.R), and source the file.
- To process the results of simulations run in an isolated setting, open the project in RStudio, open [`server/process_simulations.R`](./process_simulations.R), and source the file.

## API

### Documentation

The API is run on port 7138 and the documentation can be viewed at [http://127.0.0.1:7138/**docs**/](http://127.0.0.1:7138/__docs__/) when the API is running.

### Endpoints

#### `POST /simulate`

Given a team, apparatus assignment, and simulation parameters, run a simulation and return the results.

#### `GET /explore`

Explore all simulation results for a specified team of 5 for a given gender.

## Code Explanation

- [`server/api.R`](./api.R) is the entry point for the API.
- [`server/api-data-load.R`](./api-data-load.R) contains code for loading data used by the API endpoints (output from [`server/R/script.prepare_data_and_models.R`](./R/script.prepare_data_and_models.R)).
- [`server/R/`](./R/) contains the R code for data preprocessing, model training, utility functions, and simulation round logic in [`data.R`](./R/data.R), [`model.R`](./R/model.R), [`utilities.R`](./R/utilities.R), and the remaining files, respectively.
- [`server/run_simulations.R`](./run_simulations.R) is a script for running simulations in an isolated setting.
- [`server/process_simulations.R`](./process_simulations.R) is a script for processing the results of simulations into a database format for the API.

## Outputs

- Outputs of simulations are stored in [`server/simulation_results/`](./simulation_results/).
- Outputs of processing are stored in [`server/processed_data`](./processed_data/).
