# Plot modelled vs observed OM and OC
library(ggplot2)

# Directoyr paths and definitions
source("path_definitions.R")

# Read data from .csv files
TOA.station <- read.csv(paste(csv_dir, "/", csv_name_root, "_TOA_station",
                       ".csv", sep=""))

write.csv(obs_vs_model_TOA,
          file = paste(csv_dir, "/", csv_name_root, "_obs_vs_model_TOA",
                       ".csv", sep=""), row.names=FALSE)


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
             mapping=aes(x=month, y=OA, fill=NA), show.legend=FALSE) +
  geom_errorbar(data=filter_obs_sel_stations_TOA, inherit.aes = FALSE,
                mapping=aes(x=month, ymin=lbnd, ymax=ubnd),
                color="black", alpha=1,
                linetype=1, width=0.2, na.rm=TRUE)

png("Station_OC_partitioning.png", pointsize = 24, width=900, height=1200)
  p
dev.off()
# TODO: Add lat, lon to labels under name of location

#p <- ggplot(TOA.station, aes(x=month, y=aerosol, fill=aerosoltype),
#            xlab="Month of year",
#            ylab="Organic aerosol mass [ng m^-3]"
#) + geom_area() + facet_grid(station ~ ., scales="free", drop=TRUE) +
#  theme(strip.text.y=element_text(angle=0)) +
#  scale_x_continuous(breaks = 1:12)
#
#png("Station_OA_NCL_partitioning.png", pointsize = 16)
#p
#dev.off()

# Plot model vs obs
# Calculate R-squared statistic
cor_with_marine <- round(cor(obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$aerosoltype=="TOC"],
                             obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="TOC"]),
                         digits = 2)
cor_no_marine   <- round(cor(obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$aerosoltype=="TOC"],
                             obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="SOC"] +
                               obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="POC"]),
                         digits = 2)
rmse_with_marine <- round(sqrt(mean((obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$aerosoltype=="TOC"] -
                                       obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="TOC"])^2)),
                          digits = 2)
rmse_no_marine <- round(sqrt(mean((obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$aerosoltype=="TOC"] -
                                     obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="SOC"] -
                                     obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="POC"])^2)),
                        digits = 2)

# Scatterplot of model vs obs
png("model_vs_obs_TOC_scatter.png", pointsize = 16)
  par(mar=c(4.2, 4.5, 1, 1))
  
  plot(obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$aerosoltype=="TOC"],
       obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="TOC"],
       xlab = expression(paste("Observed organic aerosol mass [ng", m^{-3}, "]",
                               sep="")),
       ylab = expression(paste("Modelled organic aerosol mass [ng", m^{-3}, "]",
                               sep="")), log="xy", xlim=c(10, 6000), ylim=c(10, 6000)
  )
  points(obs_vs_model_TOA$obs_OC[obs_vs_model_TOA$aerosoltype=="TOC"],
         obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="SOC"] +
           obs_vs_model_TOA$OC[obs_vs_model_TOA$OCtype=="POC"],
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
