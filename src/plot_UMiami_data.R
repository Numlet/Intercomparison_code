# Plot University of Miami aerosol data and comparison with model

# Load station locations
source("define_UMiami_stations.R")

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
