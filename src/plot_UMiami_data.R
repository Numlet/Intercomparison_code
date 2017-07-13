# Plot University of Miami aerosol data and comparison with model

# Load station locations
source("define_UMiami_stations.R")

# Load path definitions
source("path_definitions.R")

# Load observational data
obsdata <- read.csv(paste(obs_dir, "/UMiami_unified.csv", sep=""))
modeldata <- read.csv(paste(csv_dir, "/", model_name,
                            "_UMiami_stations.csv", sep=""))

# Load model data interpolated to station locations

# Append model and obs data to dataframe for each site
umiami.model.obs <- list()
for (sitename in umiami.coords$site) {
  umiami.model.obs[[sitename]] <- list(modeldata=modeldata[modeldata$site==sitename, ],
                                       # Calculate monthly mean of obs at each site
                                       obsdata.monthmean=aggregate(obsdata[obsdata$site==sitename, ],
                                                                   by=list(obsdata$month[obsdata$site==sitename]),
                                                                   FUN="mean", na.rm=TRUE))
}


# Compare total aerosol seasonal cycles
png(paste(plotdir, "/", model_name,
          "_surf_monthly_mean_aerosol_comparison_total_allsites.png", sep=""),
    width=1200, height=1200, pointsize=24)
  par(mfrow=c(8,4), oma=c(2, 3, 1, 1), mar=c(1, 2, 1, 1))
  for (i in 1:31) {
    sitename <- umiami.coords$site[i]
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
png(paste(plotdir, "/", model_name,
          "_surf_monthly_mean_aerosol_comparison_total_scatter.png", sep=""),
    width = 800, height = 800, pointsize = 24)
  #  par(oma=c(0, 0, 6, 0)+0.1)
  par(mfrow=c(1,1), oma=c(0, 0, 0, 0)+0.1)
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
  #  legend(x=5, y=300, legend=umiami.corods$site, col=1:31, pch=(c(1:31) %% 25),
  #         box.lwd=0, lwd=0, ncol=4, xpd=NA, xjust=0.5, yjust=0,
  #         cex=0.7, y.intersp = 1.3, pt.lwd=1, bty = "n")
  mtext(text = paste("Correlation = ",
                     signif(cor(total.aerosol$modeldata, total.aerosol$obsdata), digits=2),
                     sep=""),
        side=3, line=0)
  mtext(text = paste("RMSE = ",
                     signif(sqrt(mean((total.aerosol$modeldata - total.aerosol$obsdata)^2,
                                      na.rm=TRUE)), digits=2),
                     sep=""),
        side=3, line=1)
dev.off()


# Compare sea salt seasonal cycles
png(paste(plotdir, "/", model_name,
          "_surf_monthly_mean_aerosol_comparison_Na_allsites.png", sep=""),
    width=1200, height=1200, pointsize=24)
  par(mfrow=c(8,4), oma=c(2, 3, 1, 1), mar=c(1, 2, 1, 1))
  for (i in 1:31) {
    sitename <- umiami.coords$site[i]
    matplot(1:12,
            cbind(umiami.model.obs[[sitename]]$obsdata.monthmean$avg_na,
                  # Compare Na+ mass: assume Na+ is 30.77% of SSA mass
                  # Ferguson, 1982; Gong et al., 1997
                  umiami.model.obs[[sitename]]$modeldata$NCL*0.3077),
            type='l', axes=FALSE, lwd=4,
            main=sitename, xlab="", ylab="")
    box()
    axis(2)
    if (i > 28) {
      title(xlab="Month")
      axis(1, labels=monthnames, at=1:12, par(las=2))
    }
    if (i == 1) {title(ylab=expression(
      paste("Monthly mean ", Na^{'+'},"aerosol concentration (model) [",
            mu, "g ", m^{-3}, "]", sep="")),
      outer=TRUE, line=1)}
  }
  plot.new()
  legend("left", c("observations", "model"), lty=c(1, 2), col=c(1, 2),
         lwd=4, box.lwd = 0, bty="n", xpd=NA)
dev.off()

# Scatterplot of NCL aerosol
png(paste(plotdir, "/", model_name,
          "_surf_monthly_mean_aerosol_comparison_NCL_scatter.png",
          sep=""),
    width = 800, height = 800, pointsize = 24)
  #  par(oma=c(0, 0, 6, 0)+0.1)
  par(oma=c(0, 0, 0, 0)+0.1)
  plot(umiami.model.obs[[1]]$obsdata.monthmean$avg_na,
       # Compare Na+ mass: assume Na+ is 30.77% of SSA mass
       # Ferguson, 1982; Gong et al., 1997
       umiami.model.obs[[1]]$modeldata$NCL*.3077,
       xlim=c(0.0001, 250), ylim=c(0.0001, 250),
       col=1, pch=1, log="xy",
       xlab=expression(paste("Monthly mean ", Na^{'+'},
                             "aerosol concentration (observed) [", mu, "g ", m^-3, "]", sep="")),
       ylab=expression(paste("Monthly mean ", Na^{'+'},
                             "aerosol concentration (model) [", mu, "g ", m^-3, "]", sep="")))
  
  na.model.obs <- data.frame(modeldata=umiami.model.obs[[1]]$modeldata$NCL*.3077,
                              obsdata=umiami.model.obs[[1]]$obsdata.monthmean$avg_na)
  
  for (i in 2:31) {
    points(umiami.model.obs[[i]]$obsdata.monthmean$avg_na,
           umiami.model.obs[[i]]$modeldata$NCL*.3077,
           col=i, pch=(i %% 25))
    na.model.obs <- rbind(na.model.obs,
                           data.frame(modeldata=umiami.model.obs[[i]]$modeldata$NCL*.3077,
                                      obsdata=umiami.model.obs[[i]]$obsdata.monthmean$avg_na))
  }
  abline(0, 1)
  abline(0, 10, untf=TRUE, lty=2)
  abline(0, 0.1, untf=TRUE, lty=2)
  #  legend(x=5, y=300, legend=umiami.coords$site, col=1:31, pch=(c(1:31) %% 25),
  #         box.lwd=0, lwd=0, ncol=4, xpd=NA, xjust=0.5, yjust=0,
  #         cex=0.7, y.intersp = 1.3, pt.lwd=1)
  mtext(text = paste("Correlation = ",
                     signif(cor(ncl.model.obs$modeldata, ncl.model.obs$obsdata),
                            digits=2),
                     sep=""),
        side=3, line=0)
  mtext(text = paste("RMSE = ",
                     signif(sqrt(mean((ncl.model.obs$modeldata - ncl.model.obs$obsdata)^2,
                               na.rm=TRUE)),
                            digits=2),
                     sep=""),
        side=3, line=1)
dev.off()


# Compare dust seasonal cycles
png(paste(plotdir, "/", model_name,
          "_surf_monthly_mean_aerosol_comparison_DST_allsites.png", sep=""))
  par(mfrow=c(8,4), oma=c(2, 2, 1, 1), mar=c(1, 1, 1, 1))
  for (i in 1:31) {
    sitename <- umiami.coords$site[i]
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
png(paste(plotdir, "/", model_name,
          "_surf_monthly_mean_aerosol_comparison_DST_scatter.png", sep=""),
    width = 800, height = 800, pointsize = 24)
  #  par(oma=c(0, 0, 6, 0)+0.1)
  par(oma=c(0, 0, 0, 0)+0.1)
  plot(umiami.model.obs[[1]]$obsdata.monthmean$avg_dust,
       umiami.model.obs[[1]]$modeldata$DST,
       xlim=c(0.001, 1000), ylim=c(0.0001, 1000),
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
  #  legend(x=5, y=300, legend=umiami.coords$site, col=1:31, pch=(c(1:31) %% 25),
  #         box.lwd=0, lwd=0, ncol=4, xpd=NA, xjust=0.5, yjust=0,
  #         cex=0.7, y.intersp = 1.3, pt.lwd=1)
  mtext(text = paste("Correlation = ",
                     signif(cor(dst.model.obs$modeldata, dst.model.obs$obsdata,
                         use="pairwise.complete.obs"),
                         digits=2),
                     sep=""),
        side=3, line=0)
  mtext(text = paste("RMSE = ",
                     signif(sqrt(mean((dst.model.obs$modeldata - dst.model.obs$obsdata)^2,
                                      na.rm=TRUE)),
                            digits=2),
                     sep=""),
        side=3, line=1)
  dev.off()
