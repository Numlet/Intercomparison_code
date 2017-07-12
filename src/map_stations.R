# Create maps of station and filter sample locations
require(mapproj) # needed for mapproject
require(RColorBrewer)

# Set up station and sample locations
source("define_stations.R")

# Read paths and definitions
source("path_definitions.R")

# Make map of filter sample locations
filter.lons.wrap <- filter_samples$Longitude
filter.lons.wrap[filter_samples$Longitude > 180] <- filter_samples$Longitude[filter_samples$Longitude>180] - 360.0

projected.coords <- mapproject(c(filter.lons.wrap, filter_samples_WACSII$Lon),
                               c(filter_samples$Latitude, filter_samples_WACSII$Lat),
                               projection="vandergrinten", parameters = NULL,
                               orient=c(90,0,0))
sample.labels <- c(as.numeric(filter_samples$campaign),
                   array(max(as.numeric(filter_samples$campaign))+1,
                         dim=length(filter_samples_WACSII$Lon)))

plotcolors <- rev(brewer.pal(8, name="Dark2"))

png(paste(plotdir, "/Field_campaign_filter_sample_locations.png", sep=""),
    width = 1200, height = 800,
    pointsize=18)
boundaries <- map(projection="vandergrinten", parameters = NULL,
                  orient=c(90,0,0), wrap=TRUE)
map.grid(col="black", lty=1)
points(projected.coords, col=plotcolors[sample.labels],
       pch=sample.labels, lwd=2)
legend("left", ncol=1, legend = c(levels(filter_samples$campaign), "WACS-II"),
       lwd=0, pt.lwd=2, pch=as.numeric(levels(as.factor(sample.labels))),
       col=plotcolors[as.numeric(levels(as.factor(sample.labels)))],
       xpd=NA, bty="n")
dev.off()

# Make world map with UMiami station locations

# Read UMiamie station locations
source("define_UMiami_stations.R")

# Method 1
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
#
# # Quick plot of total aerosol
# png(paste("aerosol_mass_ts_", sitename, ".png", sep=""))
# plot(data.in$DATE, data.in$total_aerosol, type='l',
#      xlab="Date",
#      ylab=expression(paste("Total aerosol concentration", mu, "g ", m^-3, "]", sep="")),
#      main=sitename)
# points(data.in$DATE, data.in$total_aerosol)
# dev.off()