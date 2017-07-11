# Plot University of Miami aerosol data and comparison with model

# Load station locations
source("define_UMiami_stations.R")

# Load observational data
obsdata <- read.csv(paste(obs_dir, "/UMiami_unified.csv", sep=""))
modeldata <- read.csv(paste(csv_dir, "/", model_name,
                            "_UMiami_stations.csv", sep=""))

# Load model data interpolated to station locations

# Append model and obs data to dataframe for each site
umiami.model.obs <- list()
umiami.model.obs[[sitename]] <- list(modeldata=modeldata, obsdata=obsdata,
                                     # Calculate monthly mean at each site
                                     obsdata.monthmean=aggregate(obsdata,
                                                                 by=list(obsdata$month),
                                                                 FUN="mean", na.rm=TRUE))

# Make world map with station locations
# Get boundaries of continents

# Method 1
#library(maptools)
library(maps)
library(mapproj)
png(paste(plotdir, "/Station_map_1.png", sep=""),
    width = 1500, height = 800, pointsize=18)
  boundaries <- map(projection="vandergrinten", parameters = NULL, orient=c(90,0,0),
                  wrap=TRUE)
  map.grid(col="black", lty=1)
  #  map.grid(col="black", lty=0)
  projected.coords <- mapproject(umiami.coords$lon, umiami.coords$lat,
                                 projection="vandergrinten", parameters = NULL,
                                 orient=c(90,0,0))
  points(projected.coords, col = 1:31,
         pch=(c(1:31) %% 25), cex = 1.5)
  legend("left", legend=umiami.coords$site.name,
          col=1:31, pch=(c(1:31) %% 25),
          box.lwd=0, lwd=0, ncol=1, xpd=NA, xjust=0.5, yjust=0,
       cex=0.7, text.width=24, y.intersp = 1.3, pt.lwd=1, bty="n",
       bg=NA)
dev.off()

# Method 2
library(rworldmap)
library(rgdal)

newmap <- getMap(resolution = "low")
transformed.map <- spTransform(newmap, CRS("+proj=longlat +datum=NAD27"))

png(paste(plotdir, "/Station_map_2.png", sep=""),
    width = 1200, height = 900, pointsize=18)
  plot(transformed.map)
  points(umiami.coords$lon, umiami.coords$lat, col = 1:31,
         pch=(c(1:31) %% 25), cex = 1.5)
  legend(x=0, y=90, legend=umiami.coords$site, col=1:31, pch=(c(1:31) %% 25),
        box.lwd=0, lwd=0, ncol=7, xpd=NA, xjust=0.5, yjust=0,
         cex=0.7, text.width=50, y.intersp = 1.3, pt.lwd=1, bty="n",
         bg=NA)
dev.off()

# # Quick plot of total aerosol
# png(paste("aerosol_mass_ts_", sitename, ".png", sep=""))
# plot(data.in$DATE, data.in$total_aerosol, type='l',
#      xlab="Date",
#      ylab=expression(paste("Total aerosol concentration", mu, "g ", m^-3, "]", sep="")),
#      main=sitename)
# points(data.in$DATE, data.in$total_aerosol)
# dev.off()

# Compare total aerosol seasonal cycles
png(paste("surf_monthly_mean_aerosol_comparison_total_allsites.png", sep=""),
    width=1200, height=1200, pointsize=24)
par(mfrow=c(8,4), oma=c(2, 3, 1, 1), mar=c(1, 2, 1, 1))
for (i in 1:31) {
  sitename <- umiami.files[i]
  matplot(1:12,
          cbind(umiami.model.obs[[sitename]]$obsdata.monthmean$total_aerosol,
                umiami.model.obs[[sitename]]$modeldata$total.aerosol,
                umiami.model.obs[[sitename]]$modeldata$total.aerosol.no.moa),
          type='l', axes=FALSE,
          main=sitename, xlab="", ylab="", lwd=4, col=c("black", "red", "blue"))
  box()
  axis(2)
  if (i >= 28) {
    title(xlab="Month")
    axis(1, labels=monthnames, at=1:12, par(las=2))
  }
  if (i == 1) {title(ylab=expression(
    paste("Monthly mean total aerosol concentration (model) [",
          mu, "g ", m^{-3}, "]", sep="")),
    outer=TRUE, line=1)}
}
plot.new()
legend("bottom", c("observations", "model", "model-MOA"), lty=1:3,
       col=c("black", "red", "blue"), lwd=4, box.lwd = 0, bty="n", xpd=NA)
dev.off()

# Scatterplot of total aerosol
png("surf_monthly_mean_aerosol_comparison_total_scatter.png",
    width = 800, height = 800, pointsize = 24)
#  par(oma=c(0, 0, 6, 0)+0.1)
par(oma=c(0, 0, 0, 0)+0.1)
plot(umiami.model.obs[[1]]$obsdata.monthmean$total_aerosol,
     umiami.model.obs[[1]]$modeldata$total.aerosol,
     xlim=c(0.1, 250), ylim=c(0.1, 250),
     col=1, pch=1, log="xy",
     xlab=expression(paste("Monthly mean total aerosol concentration (observed) [", mu, "g ", m^-3, "]", sep="")),
     ylab=expression(paste("Monthly mean total aerosol concentration (model) [", mu, "g ", m^-3, "]", sep="")))

total.aerosol <- data.frame(modeldata=umiami.model.obs[[1]]$modeldata$total.aerosol,
                            obsdata=umiami.model.obs[[1]]$obsdata.monthmean$total_aerosol)

for (i in 2:31) {
  points(umiami.model.obs[[i]]$obsdata.monthmean$total_aerosol,
         umiami.model.obs[[i]]$modeldata$total.aerosol,
         col=i, pch=(i %% 25))
  total.aerosol <- rbind(total.aerosol,
                         data.frame(modeldata=umiami.model.obs[[i]]$modeldata$total.aerosol,
                                    obsdata=umiami.model.obs[[i]]$obsdata.monthmean$total_aerosol))
}
abline(0, 1)
abline(0, 10, untf=TRUE, lty=2)
abline(0, 0.1, untf=TRUE, lty=2)
#  legend(x=5, y=300, legend=umiami.files, col=1:31, pch=(c(1:31) %% 25),
#         box.lwd=0, lwd=0, ncol=4, xpd=NA, xjust=0.5, yjust=0,
#         cex=0.7, y.intersp = 1.3, pt.lwd=1, bty = "n")
mtext(text = paste("Model-observation correlation = ",
                   cor(total.aerosol$modeldata, total.aerosol$obsdata),
                   sep=""),
      side=3, line=0)
dev.off()


# Compare sea salt seasonal cycles
png(paste("surf_monthly_mean_aerosol_comparison_NCL_allsites.png", sep=""),
    width=1200, height=1200, pointsize=24)
par(mfrow=c(8,4), oma=c(2, 3, 1, 1), mar=c(1, 2, 1, 1))
for (i in 1:31) {
  sitename <- umiami.files[i]
  matplot(1:12,
          cbind(umiami.model.obs[[sitename]]$obsdata.monthmean$avg_na*58.44/22.9898,
                umiami.model.obs[[sitename]]$modeldata$NCL),
          type='l', axes=FALSE, lwd=4,
          main=sitename, xlab="", ylab="")
  box()
  axis(2)
  if (i > 28) {
    title(xlab="Month")
    axis(1, labels=monthnames, at=1:12, par(las=2))
  }
  if (i == 1) {title(ylab=expression(
    paste("Monthly mean sea salt aerosol concentration (model) [",
          mu, "g ", m^{-3}, "]", sep="")),
    outer=TRUE, line=1)}
}
plot.new()
legend("left", c("observations", "model"), lty=c(1, 2), col=c(1, 2),
       lwd=4, box.lwd = 0, bty="n", xpd=NA)
dev.off()

# Scatterplot of NCL aerosol
png("surf_monthly_mean_aerosol_comparison_NCL_scatter.png",
    width = 800, height = 800, pointsize = 24)
#  par(oma=c(0, 0, 6, 0)+0.1)
par(oma=c(0, 0, 0, 0)+0.1)
plot(umiami.model.obs[[1]]$obsdata.monthmean$NCL,
     umiami.model.obs[[1]]$modeldata$NCL,
     xlim=c(0.1, 250), ylim=c(0.1, 250),
     col=1, pch=1, log="xy",
     xlab=expression(paste("Monthly mean sea salt aerosol concentration (observed) [", mu, "g ", m^-3, "]", sep="")),
     ylab=expression(paste("Monthly mean sea salt aerosol concentration (model) [", mu, "g ", m^-3, "]", sep="")))

ncl.model.obs <- data.frame(modeldata=umiami.model.obs[[1]]$modeldata$NCL,
                            obsdata=umiami.model.obs[[1]]$obsdata.monthmean$NCL)

for (i in 2:31) {
  points(umiami.model.obs[[i]]$obsdata.monthmean$NCL,
         umiami.model.obs[[i]]$modeldata$NCL,
         col=i, pch=(i %% 25))
  ncl.model.obs <- rbind(ncl.model.obs,
                         data.frame(modeldata=umiami.model.obs[[i]]$modeldata$NCL,
                                    obsdata=umiami.model.obs[[i]]$obsdata.monthmean$NCL))
}
abline(0, 1)
abline(0, 10, untf=TRUE, lty=2)
abline(0, 0.1, untf=TRUE, lty=2)
#  legend(x=5, y=300, legend=umiami.files, col=1:31, pch=(c(1:31) %% 25),
#         box.lwd=0, lwd=0, ncol=4, xpd=NA, xjust=0.5, yjust=0,
#         cex=0.7, y.intersp = 1.3, pt.lwd=1)
mtext(text = paste("Model-observation correlation = ",
                   cor(ncl.model.obs$modeldata, ncl.model.obs$obsdata),
                   sep=""),
      side=3, line=0)
dev.off()


# Compare dust seasonal cycles
png("surf_monthly_mean_aerosol_comparison_DST_allsites.png")
par(mfrow=c(8,4), oma=c(2, 2, 1, 1), mar=c(1, 1, 1, 1))
for (i in 1:31) {
  sitename <- umiami.files[i]
  matplot(1:12,
          cbind(umiami.model.obs[[sitename]]$obsdata.monthmean$avg_dust,
                umiami.model.obs[[sitename]]$modeldata$DST),
          type='l', axes=FALSE,
          main=sitename, xlab="", ylab="")
  box()
  axis(2)
  if (i > 28) {
    title(xlab="Month")
    axis(1)
  }
  if (i %% 4 == 0) {title(ylab=expression(paste("Monthly mean dust aerosol concentration (model) [", mu, "g ", m^-3, "]", sep="")))}
}
plot.new()
mtext("Concentrations [ug m^-3]", side=3, cex=0.6, line=-0.5)
legend("left", c("observations", "model"), lty=c(1, 2), col=c(1, 2), lwd=1, box.lwd = 0, bty="n", xpd=NA)
dev.off()

# Scatterplot of DST aerosol
png("surf_monthly_mean_aerosol_comparison_DST_scatter.png",
    width = 800, height = 800, pointsize = 24)
#  par(oma=c(0, 0, 6, 0)+0.1)
par(oma=c(0, 0, 0, 0)+0.1)
plot(umiami.model.obs[[1]]$obsdata.monthmean$avg_dust,
     umiami.model.obs[[1]]$modeldata$DST,
     xlim=c(0.1, 250), ylim=c(0.1, 250),
     col=1, pch=1, log="xy",
     xlab=expression(paste("Monthly mean dust aerosol concentration (observed) [",
                           mu, "g ", m^-3, "]", sep="")),
     ylab=expression(paste("Monthly mean seadust aerosol concentration (model) [",
                           mu, "g ", m^-3, "]", sep="")))

dst.model.obs <- data.frame(modeldata=umiami.model.obs[[1]]$modeldata$DST,
                            obsdata=umiami.model.obs[[1]]$obsdata.monthmean$avg_dust)

for (i in 2:31) {
  try(points(umiami.model.obs[[i]]$obsdata.monthmean$avg_dust,
             umiami.model.obs[[i]]$modeldata$DST,
             col=i, pch=(i %% 25)), silent = TRUE)
  try(dst.model.obs <- rbind(dst.model.obs,
                             data.frame(modeldata=umiami.model.obs[[i]]$modeldata$DST,
                                        obsdata=umiami.model.obs[[i]]$obsdata.monthmean$avg_dust)),
      silent=TRUE)
}
abline(0, 1)
abline(0, 10, untf=TRUE, lty=2)
abline(0, 0.1, untf=TRUE, lty=2)
#  legend(x=5, y=300, legend=umiami.files, col=1:31, pch=(c(1:31) %% 25),
#         box.lwd=0, lwd=0, ncol=4, xpd=NA, xjust=0.5, yjust=0,
#         cex=0.7, y.intersp = 1.3, pt.lwd=1)
mtext(text = paste("Model-observation correlation = ",
                   cor(dst.model.obs$modeldata, dst.model.obs$obsdata,
                       use="pairwise.complete.obs"),
                   sep=""),
      side=3, line=0)
dev.off()
