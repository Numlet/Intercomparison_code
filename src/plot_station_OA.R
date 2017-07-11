# Plot modelled vs observed OM and OC
library(ggplot2)

# Directory paths and definitions
source("path_definitions.R")

# Read model and obs data from .csv files
TOA.station <- read.csv(paste(csv_dir, "/", csv_name_root, "_TOA_station",
                       ".csv", sep=""))

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
p <- ggplot(subset(TOA.station,
                   station %in% sel_stations_TOA),
            aes(x=month, y=OC, fill=OCtype)
) + geom_area()  +
  theme(strip.text.y=element_text(angle=0)) +
  scale_x_continuous(breaks = 1:12) +
  facet_grid(station ~ ., scales="free", drop=TRUE) +
  xlab("Month of year") +
  ylab(expression(paste("Organic carbon mass [ng", m^{-3}, "]",
                        sep=""))) +
  geom_point(data=filter_obs_sel_stations_TOA, inherit.aes = FALSE,
             mapping=aes(x=month, y=OC, fill=NA), show.legend=FALSE) +
  geom_errorbar(data=filter_obs_sel_stations_TOA, inherit.aes = FALSE,
                mapping=aes(x=month, ymin=lbnd, ymax=ubnd),
                color="black", alpha=1,
                linetype=1, width=0.2, na.rm=TRUE)

png(paste(plotdir, "/", plot_name_root,
          "_Station_OC_partitioning.png", sep=""),
          pointsize = 24, width=900, height=1200)
  print(p)
dev.off()
# TODO: Add lat, lon to labels under name of location

#p <- ggplot(TOA.station, aes(x=month, y=aerosol, fill=aerosoltype),
#            xlab="Month of year",
#            ylab="Organic aerosol mass [ng m^-3]"
#) + geom_area() + facet_grid(station ~ ., scales="free", drop=TRUE) +
#  theme(strip.text.y=element_text(angle=0)) +
#  scale_x_continuous(breaks = 1:12)
#
#png(paste(plotdir, "/", plot_name_root,
#          "_Station_OA_NCL_partitioning.png", sep=""),
#    pointsize = 16)
#p
#dev.off()

# Plot model vs obs
# Calculate R-squared statistic
# Note GLOMAP model output file has only TOC and MOC
cor_with_marine <- round(cor(obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$OCtype=="TOC"],
                             obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="TOC"]),
                         digits = 2)
cor_no_marine   <- round(cor(obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$OCtype=="TOC"],
                             obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="TOC"] -
                               obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="MOC"]),
                         digits = 2)
rmse_with_marine <- round(sqrt(mean((obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$OCtype=="TOC"] -
                                       obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="TOC"])^2)),
                          digits = 2)
rmse_no_marine <- round(sqrt(mean((obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$OCtype=="TOC"] -
                                     (obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="TOC"] -
                                      obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="MOC"]))^2)),
                        digits = 2)
# Scatterplot of model vs obs
png(paste(plotdir, "/", plot_name_root,
          "_model_vs_obs_TOC_scatter.png", sep=""),
    pointsize = 16)
  par(mar=c(4.2, 4.5, 1, 1))

  plot(obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$OCtype=="TOC"],
       obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="TOC"],
       xlab = expression(paste("Observed organic aerosol mass [ng", m^{-3}, "]",
                               sep="")),
       ylab = expression(paste("Modelled organic aerosol mass [ng", m^{-3}, "]",
                               sep="")), log="xy", xlim=c(10, 6000), ylim=c(10, 6000)
  )
  points(obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$OCtype=="TOC"],
         obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="TOC"] -
           obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="MOC"],
         xlab = expression(paste("Observed organic aerosol mass [ng", m^{-3}, "]",
                                 sep="")),
         ylab = expression(paste("Modelled organic aerosol mass [ng", m^{-3}, "]",
                                 sep="")),
         col="red", pch=2
  )
  abline(0, 1)
  abline(0, 10, untf=TRUE, lty=2)
  abline(0, 0.1, untf=TRUE, lty=2)

  # Add legend
  legend("topleft",
         legend=c(expression(paste("With marine OA", sep="")),
                  bquote(rho==.(cor_with_marine)),
                  bquote("RMSE"==.(rmse_with_marine)),
                  "Without marine OA",
                  bquote(rho==.(cor_no_marine)),
                  bquote("RMSE"==.(rmse_no_marine))),
         pch=c(1, NA, NA, 2, NA, NA),
         col=c("black", "black", "black", "red", "red", "red"),
         text.col=c("black", "black", "black", "red", "red", "red"),
         bty="n")
dev.off()
