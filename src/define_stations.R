# Define sampling locations
require(chron)

# Set up paths and definitions
source("path_definitions.R")

# Get filter sample data
filter_samples <- read.csv(paste(obs_dir, "MarineOM.csv", sep="/"))
filter_samples_WACSII <- read.csv(paste(obs_dir, "WACSII_FTIR_MarineOrigin.csv", sep="/"))

# Set month
filter_samples$month <- NA
for (i in 1:length(filter_samples$StartUTC)) {
  datestring <- strsplit(as.character(filter_samples$StartUTC[i]), split=" ")[[1]][1]
  filter_samples$month[i] <- months(chron(datestring, format="m/d/y"))
}

# Apply ordered factor labels to months
filter_samples$month <- ordered(filter_samples$month, levels=1:12, labels=monthnames)

# Wrap longitude
filter_samples$Longitude[which(filter_samples$Longitude < 0)] <-
  360.0 + filter_samples$Longitude[which(filter_samples$Longitude < 0)]

# Tag by field campaign
filter_samples$campaign <- as.character(filter_samples$FilterID)
filter_samples$campaign[grep("ML", filter_samples$FilterID)]  <- "E-PEACE"
filter_samples$campaign[grep("ICE", filter_samples$FilterID)] <- "ICEALOT"
filter_samples$campaign[grep("VX", filter_samples$FilterID)]  <- "VOCALS"
filter_samples$campaign[grep("CA", filter_samples$FilterID)] <- "CalNex"
filter_samples$campaign[grep("WA", filter_samples$FilterID)] <- "WACS-I"
filter_samples$campaign[filter_samples$campaign=="WACS-I" & filter_samples$Latitude > 40.] <- "WACS-I - George's Bank"
filter_samples$campaign[filter_samples$campaign=="WACS-I" & filter_samples$Latitude < 37.] <- "WACS-I - Sargasso Sea"
filter_samples$campaign <- as.factor(filter_samples$campaign)

# TODO -- still need to add WACSII data

# Define "station" locations for data subsampling.
station.lons <- c(360.0-11.25, 11.25, 56.25, 360.0-63.75, 78.75,
                  360.0-88.75, 360.0-96.25, 111.25, 121.25, 128.75,
                  158.75, 161.25, 171.25, 9.904, 360.0-122.91,
                  360.0-20.30, 360.0-80.25, 360.0-59.43, 360.0-60,
                  18.48, 306.0-64.05, 144.68, 62.50, 360.0-67.4, 360.0-64.7,
                  360.-130., 360.0-62.5, 360.0-62.953, 25.67, 360.0-27.35,
                  filter_samples$Longitude)
station.lats <- c(41., -19., -21., 33., -37., 27., 25.,
                  -41., 7., 33., 37., 21., -23., 53.326, 38.12,
                  63.40, 25.75, 13.17, -51.75,
                  -34.35, -64.77, -40.68, -67.60, 41.9, 36.3,
                  10., 82.46, 37.88261, 35.33, 38.683333,
                  filter_samples$Latitude)
station.names <- c("west of Portugal", "west of Namibia", "La Reunion Island",
                   "Bermuda", "Amsterdam Island", "Gulf of Mexico (north)",
                   "Gulf of Mexico (west)", "southwest of Australia",
                   "Philippines", "south of South Korea", "North Pacific Ocean 1",
                   "North Pacific Ocean 2", "New Caledonia", "Mace Head", "Point Reyes",
                   "Heimaey, Iceland", "Miami, Florida", "Ragged Point; Barbados",
                   "Falkland Islands", "Cape Point, South Africa", "Palmer Station, Antarctica",
                   "Cape Grim, Tasmania", "Mawson - Antarctica",
                   "WACS-I - George's Bank", "WACS-I - Sargasso Sea",
                   "SPURS-2", "Alert", "WACS-II", "Finokalia", "Azores",
                   as.character(filter_samples$FilterID))

# Selected stations for subselected plots
sel_stations <- c("west of Namibia", "Bermuda", "Amsterdam Island",
                  "Mace Head", "Point Reyes", "Cape Grim",
                  "WACS-I - George's Bank", "WACS-I - Sargasso Sea",
                  "Falkland Islands", "Heimaey, Iceland",
                  "Mawson - Antarctica", "WACS-II")

# Add sanity check that all are same length
if (length(station.lats) != length(station.lons)) {
  print("Warning: number of station latitudes and longitudes differs")
}
if (length(station.lats) != length(station.names)) {
  print("Warning: number of station latitudes and names differs")
}
