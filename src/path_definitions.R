# Directories with obs, model data, etc.

# netCDF data location
ncfile_dir <- "../../"
ncfile_name <- "reduced_chem_MOA_code.FC5PLMOD.ne30_ne30.edison.MOA_mix3.nc"

# Output file location
csv_dir <- "../station_data_frames/ACMEv0-OCEANFILMS_mix3"
csv_name_root <- "ACMEv0-OCEANFILMS_mix3"

# Observations file path
obs_dir <- "../obs_data/"

# Graphics output directory
plotdir="../graphics"
plot_name_root <- csv_name_root

# Define month names
monthnames <- c("JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                "JUL", "AUG", "SEP", "OCT", "NOV", "DEC")

# Set OM:OC ratio
OM_to_OC = 1.9 # for marine organics
OM_to_OC_soa = 1.9 # Check literature
OM_to_OC_poa = 1.9 # For consistency with GLOMAP comparison
#OM_to_OC_poa = 1.4 # e.g. Aiken et al., 2008

# Selected stations to use in plotting

# selected stations for TOA comparison
sel_stations_TOA <- c("west of Portugal", "west of Namibia", "La Reunion Island",
                      "Bermuda", "Amsterdam Island", "Gulf of Mexico (north)",
                      "Gulf of Mexico (west)", "southwest of Australia",
                      "Philippines", "south of South Korea", "North Pacific Ocean 1",
                      "North Pacific Ocean 2",
                      "New Caledonia", "Finokalia",
                      "Azores")
