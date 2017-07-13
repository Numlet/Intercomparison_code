# Loop over models and create plots.

models <- c("ACMEv0-OCEANFILMS_mix3", "GLOMAP")

for (model_name in models) {
  source("plot_station_OA.R")
  source("plot_UMiami_data.R")
}

source("plot_station_OC_all_models.R")
source("plot_UMiami_all_models.R")
