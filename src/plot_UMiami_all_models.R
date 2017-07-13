# Plot University of Miami aerosol data and comparison with model

# Load station locations
source("define_UMiami_stations.R")

# Load path definitions
source("path_definitions.R")

# Load observational data
obsdata <- read.csv(paste(obs_dir, "/UMiami_unified.csv", sep=""))
obsdata$month <- ordered(obsdata$month, levels=monthnames, labels=monthnames)

# Aggregate obs data by monthly mean, per site
obsdata.monthmean <- data.frame()
for (sitename in unique(obsdata$site)) {
  tmp <- aggregate(obsdata[obsdata$site==sitename, ],
                   by=list(obsdata$month[obsdata$site==sitename]),
                   FUN="mean", na.rm=TRUE)
  tmp$site <- sitename
  tmp$month <- tmp$Group.1
  obsdata.monthmean <- rbind(obsdata.monthmean,
                             # Drop "date" column, which is meaningless for aggregated data
                             tmp[ , !(names(tmp) %in% c("date", "Group.1"))])
}

# Read model and obs data from .csv files

# Construct Na+ dataframe
sodium <- data.frame(site=obsdata.monthmean$site,
                     month=obsdata.monthmean$month,
                     Na=obsdata.monthmean$avg_na,
                     model="Obs")
for (model_name in models) {
  tmp <- read.csv(paste(csv_dir, "/", model_name,
                        "_UMiami_stations.csv", sep=""))
  sodium <- rbind(sodium,
                  data.frame(site=tmp$site,
                             month=ordered(tmp$month, levels=monthnames, labels=monthnames),
                             Na=tmp$NCL*.3077,
                             model=model_name)
                  )
}

# Make numeric month
sodium$month <- as.numeric(sodium$month)

# Plot sodium seasonal cycle at all stations
png(paste(plotdir, "/",
          "compare_models_Station_Na_seasonal.png", sep=""),
    width = 1200, height = 900, pointsize = 24)
  par(oma=c(0, 0, 0, 0)+0.1)
  p <- ggplot(sodium, aes(x=month, y=Na, group=model,
                          color=model)) +
              geom_line(size=2) +
              facet_wrap(~site, scales="free") +
              theme_minimal(base_size=24) +
              theme(legend.position = c(0.3, 0.05)) +
              xlab("Month of year") +
              ylab(expression(paste(Na^{'+'},
                    " mass [ng", m^{-3}, "]", sep="")))
  print(p)
dev.off()
