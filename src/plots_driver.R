# Loop over models and create plots.

# Load definitions including list of model names
source("path_definitions.R")

for (model_name in models) {
  source("plot_station_OA.R")
  source("plot_UMiami_data.R")
}

source("plot_station_OC_all_models.R")
source("plot_UMiami_all_models.R")
