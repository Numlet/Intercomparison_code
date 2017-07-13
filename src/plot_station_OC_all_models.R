# Plot modelled vs observed OM and OC
library(ggplot2)

# Directory paths and definitions
source("path_definitions.R")

# Read model and obs data from .csv files
models <- c("ACMEv0-OCEANFILMS_mix3", "GLOMAP")

OA.station <- data.frame()
for (model_name in models) {
  tmp <- read.csv(paste(csv_dir, "/", model_name, "_TOA_station",
               ".csv", sep=""))


    for (station in unique(tmp$station)) {
      for (month in unique(tmp$month)) {
        # For ACME model, calculate TOC=MOC+POC+SOC
        if (model_name=="ACMEv0-OCEANFILMS_mix3") {
          # Add TOC (total organic carbon)
          helper <- tmp[tmp$station==station & tmp$month==month & tmp$OCtype=="SOC", ] +
                    tmp[tmp$station==station & tmp$month==month & tmp$OCtype=="POC", ] +
                    tmp[tmp$station==station & tmp$month==month & tmp$OCtype=="MOC", ]
          helper$OAtype <- "TOA"
          helper$OCtype <- "TOC"
          helper$aerosoltype <- "TOA"
          helper$month <- month
          helper$station <- station
          helper$model <- model_name
          tmp <- rbind(tmp, helper)
        }
        # Add COC (Continental organic carbon); COC := TOC - MOC
          helper <- tmp[tmp$station==station & tmp$month==month & tmp$OCtype=="TOC", ] -
            tmp[tmp$station==station & tmp$month==month & tmp$OCtype=="MOC", ]
          helper$OAtype <- "COA"
          helper$OCtype <- "COC"
          helper$aerosoltype <- "COA"
          helper$month <- month
          helper$station <- station
          helper$model <- model_name
          tmp <- rbind(tmp, helper)
      }
    }
  
  # append to data frame
  OA.station <- rbind(OA.station, tmp)
}
TOA.station <- OA.station[OA.station$OCtype=="TOC", ]
filter_obs_sel_stations_TOA <- read.csv(paste(obs_dir, "/", "filter_obs_sel_stations_TOA",
                                        ".csv", sep=""))

# Construct subsampled data frame with model data that matches obs data
obs_vs_model_TOA <- data.frame()
for (i in 1:dim(filter_obs_sel_stations_TOA)[1]) {
  tmp <- TOA.station[as.character(TOA.station$station)==as.character(filter_obs_sel_stations_TOA[i, ]$station) &
                       TOA.station$month==filter_obs_sel_stations_TOA[i, ]$month, ]
  if (sum(tmp$OCtype=="TOC")==0) {
    if (dim(tmp)[1]!=3) {print("Warning: expected to select three values from TOA.station, got wrong number")}
    tmp <- rbind.data.frame(tmp,
                            data.frame(model=tmp$model[1],
                                       OA=sum(tmp$OA), OAtype="TOA",
                                       OC=sum(tmp$OC), OCtype="TOC",
                                       aerosol=sum(tmp$aerosol),aerosoltype="TOC",
                                       month=tmp$month[1], station=tmp$station[1],
                                       lat=tmp$lat[1], lon=tmp$lon[1])
    )
  }
  tmp$obs_OC   <- filter_obs_sel_stations_TOA[i, ]$OC
  tmp$obs_lbnd <- filter_obs_sel_stations_TOA[i, ]$lbnd
  tmp$obs_ubnd <- filter_obs_sel_stations_TOA[i, ]$ubnd
  obs_vs_model_TOA <- rbind.data.frame(obs_vs_model_TOA, tmp)
}

# Construct panel plot: seasonal cycle of OA partitioning
sel_stations_TOA_lim <- c("west of Portugal", "west of Namibia", "La Reunion Island",
                          "Bermuda", "Amsterdam Island", "Gulf of Mexico (north)",
                          "Gulf of Mexico (west)", "southwest of Australia",
                          "Philippines", "south of South Korea", "North Pacific Ocean 1",
                          "North Pacific Ocean 2",
                          "New Caledonia", "Finokalia",
                          "Azores")

p <- ggplot(subset(OA.station,
                   (station %in% sel_stations_TOA_lim) &
                   (OCtype %in% c("TOC", "COC"))),
            aes(x=month, y=OC, group=interaction(model, OCtype),
                color=model, linetype=OCtype)
) + geom_line()  + geom_point(mapping = aes(pch=OCtype)) +
  scale_x_continuous(breaks = 1:12) +
  facet_wrap(~station, scales="free") +
  xlab("Month of year") +
  ylab(expression(paste("Organic carbon mass [ng", m^{-3}, "]",
                        sep=""))) +
  geom_point(data=subset(filter_obs_sel_stations_TOA,
                         station %in% sel_stations_TOA_lim),
             inherit.aes = FALSE,
             mapping=aes(x=month, y=OC), show.legend=FALSE) +
  geom_errorbar(data=subset(filter_obs_sel_stations_TOA,
                            station %in% sel_stations_TOA_lim),
                inherit.aes = FALSE,
                mapping=aes(x=month, ymin=lbnd, ymax=ubnd),
                color="black", alpha=1,
                linetype=1, width=0.2, na.rm=TRUE) +
  theme_minimal() +
  theme(legend.position = c(0.9, 0.1))

png(paste(plotdir, "/",
          "compare_models_Station_OC_seasonal.png", sep=""),
          pointsize = 24, width=900, height=1200)
  print(p)
dev.off()
# TODO: Add lat, lon to labels under name of location

# Make plot comparing MOC in models at same locations.
pMOC <- ggplot(subset(OA.station,
                   (station %in% sel_stations_TOA_lim) &
                     (OCtype=="MOC")),
            aes(x=month, y=OC, group=interaction(model, OCtype),
                color=model, linetype=OCtype)
) + geom_line()  + geom_point(mapping = aes(pch=OCtype)) +
  scale_x_continuous(breaks = 1:12) +
  facet_wrap(~station, scales="free") +
  xlab("Month of year") +
  ylab(expression(paste("Organic carbon mass [ng", m^{-3}, "]",
                        sep=""))) +
  theme_minimal() +
  theme(legend.position = c(0.9, 0.1))
pMOC
