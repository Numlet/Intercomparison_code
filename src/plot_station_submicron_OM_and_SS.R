# Plot modelled vs observed OM and OC
library(ggplot2)

# Directory paths and definitions
source("path_definitions.R")

# Read model and obs data from .csv files
models <- c("ACMEv0-OCEANFILMS_mix3", "GLOMAP")

aerosol.station <- data.frame()
for (model_name in models) {
  tmp <- read.csv(paste(csv_dir, "/", model_name,
                        "_UMiami_stations.csv", sep=""))
  helper <- data.frame(month=ordered(tmp$month, levels=monthnames, labels=monthnames),
                       station=tmp$site,
                       station.long.name=tmp$site.long.name,
                       lat=tmp$lat,
                       lon=tmp$lon,
                       MOA=tmp$MOA,
                       MOC=tmp$MOA/OM_to_OC,
                       BC=tmp$BC,
                       SO4=tmp$SO4,
                       NCL=tmp$NCL,
                       Na=tmp$NCL*0.3077,
                       smSS=tmp$smSS,
                       DST=tmp$DST,
                       OMF=tmp$MOA/(tmp$MOA+tmp$smSS),
                       total.aerosol=tmp$total.aerosol,
                       model=model_name)
  if (model_name=="ACMEv0-OCEANFILMS_mix3") {
    helper["TOA"] <- tmp$MOA + tmp$SOA + tmp$POA
    helper["COA"] <- tmp$SOA + tmp$POA
  } else if (model_name=="GLOMAP") {
    helper["TOA"] <- tmp$TOA
    helper["COA"] <- tmp$TOA - tmp$MOA
  }
  helper$TOC <- helper$TOA/OM_to_OC
  helper$COC <- helper$COA/OM_to_OC
  helper$OMF <- helper$MOA/(helper$MOA + helper$smSS)
  aerosol.station <- rbind(aerosol.station,
                           helper)
}

filter_obs_sel_stations_TOA <- read.csv(paste(obs_dir, "/", "filter_obs_sel_stations_TOA",
                                        ".csv", sep=""))
# Convert from ng per m3 to ug per m3
filter_obs_sel_stations_TOA$OC <- filter_obs_sel_stations_TOA$OC*1e-3
filter_obs_sel_stations_TOA$lbnd <- filter_obs_sel_stations_TOA$lbnd*1e-3
filter_obs_sel_stations_TOA$ubnd <- filter_obs_sel_stations_TOA$ubnd*1e-3

# Construct panel plot: seasonal cycle of OA partitioning
sel_stations_TOA_lim <- c("west of Portugal", "west of Namibia", "La Reunion Island",
                          "Bermuda", "Amsterdam Island", "Gulf of Mexico (north)",
                          "Gulf of Mexico (west)", "southwest of Australia",
                          "Philippines", "south of South Korea", "North Pacific Ocean 1",
                          "North Pacific Ocean 2",
                          "New Caledonia", "Finokalia",
                          "Azores")

aerosol.sel_stations <- aerosol.station[aerosol.station$station %in% sel_stations_TOA_lim, ]
filter_obs <- filter_obs_sel_stations_TOA[filter_obs_sel_stations_TOA$station %in% sel_stations_TOA_lim, ]

# Make plot comparing submicron (Accumulation and Aitken mode)
# sea spray seasonal cycle at stations that have TOC measurements.
p <- ggplot(aerosol.sel_stations,
            aes(x=month, y=smSS, group=model,
                color=model)) +
  geom_line(size=2)  + geom_point() +
  #scale_x_continuous(breaks = 1:12) +
  facet_wrap(~station, scales="free") +
  xlab("Month of year") +
  ylab(expression(paste("Submicron SSA mass [", mu, "g", m^{-3}, "]",
                        sep=""))) +
  theme_minimal(base_size=24) +
  theme(legend.position = c(0.9, 0.1))

png(paste(plotdir, "/",
          "compare_models_Station_NCL_seasonal.png", sep=""),
          pointsize = 24, width=900, height=1200)
  print(p)
dev.off()
# TODO: Add lat, lon to labels under name of location

# Make plot comparing TOC in models at same locations, with obs.
pTOC <- ggplot(aerosol.sel_stations,
               aes(x=month, y=TOC,
                   group=model, color=model)) +
  geom_line(size=2, linetype=1)  +
  geom_line(mapping = aes(x=month, y=COC,
                          group=model, color=model),
            size=2, linetype=2) +
  facet_wrap(~station, scales="free") +
  xlab("Month of year") +
  ylab(expression(paste("Organic carbon aerosol mass [", mu, "g", m^{-3}, "]",
                        sep=""))) +
  geom_point(data=filter_obs,
             inherit.aes = FALSE,
             mapping=aes(x=month, y=OC), show.legend=FALSE) +
  geom_errorbar(data=filter_obs,
                inherit.aes = FALSE,
                mapping=aes(x=month, ymin=lbnd, ymax=ubnd),
                color="black", alpha=1,
                linetype=1, width=0.2, na.rm=TRUE) +
  theme_minimal(base_size=24) +
  theme(legend.position = c(0.9, 0.1))

png(paste(plotdir, "/",
          "compare_models_Station_TOC_seasonal.png", sep=""),
    pointsize = 24, width=900, height=1200)
  print(pTOC)
dev.off()

# Make plot comparing MOC in models at same locations.
pMOC <- ggplot(aerosol.sel_stations,
               aes(x=month, y=MOC, group=model, color=model)) +
  geom_line(size=2)  +
  facet_wrap(~station, scales="free") +
  xlab("Month of year") +
  ylab(expression(paste("Marine organic carbon mass [", mu, "g", m^{-3}, "]",
                        sep=""))) +
  theme_minimal(base_size=24) +
  theme(legend.position = c(0.9, 0.1))

png(paste(plotdir, "/",
          "compare_models_Station_MOC_seasonal.png", sep=""),
    pointsize = 24, width=900, height=1200)
  print(pMOC)
dev.off()

# Make plot comparing submicron OMF in models at same locations.
pOMF <- ggplot(aerosol.sel_stations,
               aes(x=month, y=OMF, group=model, color=model)) +
  geom_line(size=2)  +
  facet_wrap(~station) +
  xlab("Month of year") +
  ylab(expression(paste("Submicron organic mass fraction",
                        sep=""))) +
  theme_minimal(base_size=24) +
  theme(legend.position = c(0.9, 0.1))

png(paste(plotdir, "/",
          "compare_models_Station_OMF_seasonal.png", sep=""),
    pointsize = 24, width=900, height=1200)
  print(pOMF)
dev.off()
