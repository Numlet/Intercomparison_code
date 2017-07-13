library(ggplot2)

# Set default "base" font size for plots
theme_set(theme_gray(base_size = 24))

# Calculate size distribution data tables
#source("construct_station_data_frames.R")
source("plot_functions.R")

# Get selected station names
source("define_stations.R")

# Make a plot for a particular station, for each month
#p <- ggplot(subset(dNdlogDp, station %in% c("Bermuda")),
#            aes(x=Dp_um_um, y=dNdlogDp, fill=type)) +
#  theme(strip.text.y=element_text(angle=90)) +
#  scale_x_log10(limits=c(0.01, 10))
#p + geom_area() + facet_grid(month ~.)
##p + geom_line()

#p <- ggplot(subset(subset(dNdlogDp, station %in% sel_stations),
#                   month %in% "FEB"),
#            aes(x=Dp_um_um, y=dNdlogDp, fill=type)) +
#  theme(strip.text.y=element_text(angle=90)) +
#  scale_x_log10(limits=c(0.01, 10)) +
#  xlab("Dry particle diameter (Dp) [um]") + ylab("Number concentration\ndN/dlogDp [cm^-3]")
#p + geom_area(position = 'stack') + facet_grid(.~station) +
#  ggtitle("Particle number size distribution\nSelected stations, February")

# OMF -- monthly plots, selected stations
OMF_plots(station_OMF_dp, sel_stations,
          monthnames)

# Plot at Alert
OMF_plots(station_OMF_dp, c("Alert"),
          monthnames)

# OMF -- seasonal plots, selected stations
OMF_plots(station_OMF_dp, sel_stations,
          c("FEB", "MAY", "AUG", "NOV"),
          months_filenametag = "seasons")

# OMF -- selected months, selected stations
for (imonth in c("FEB", "MAY", "AUG", "NOV")) {
  OMF_plots(station_OMF_dp, sel_stations, imonth)
}

# OMF -- monthly cycle, by station
#for (istation in station.names) {
#  OMF_plots(station_OMF_dp, istation, monthnames)
#}


p <- ggplot(subset(subset(station_OMF_dp,
                          station %in% sel_stations),
                   month %in% c("FEB")),
            aes(x=Dp_um, y=partial_kappa, fill=type)) +
  theme(strip.text.y=element_text(angle=90),
        strip.text.x=element_text(angle=90)) +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Hygroscopicity (kappa)") +
  xlab("Dry particle diameter [um]")
png("kappa_marine_vs_Dp_sel_stations_FEB.png", width = 1200, height = 1200, pointsize=24)
p + geom_area(position = 'stack') + facet_grid(.~station) +
  ggtitle("Size-resolved hygroscopicity (kappa) of sea spray aerosol\nSelected stations, February")
dev.off()


p <- ggplot(subset(subset(station_OMF_dp,
                          station %in% sel_stations),
                   month %in% c("FEB", "MAY", "AUG", "NOV")),
            aes(x=Dp_um, y=partial_kappa, fill=type)) +
  theme(strip.text.y=element_text(angle=90),
      strip.text.x=element_text(angle=90)) +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Hygroscopicity (kappa)") +
  xlab("Dry particle diameter [um]")
png("kappa_marine_vs_Dp_sel_stations_seasons.png", width = 1200, height = 1200, pointsize=24)
  p + geom_area(position = 'stack') + facet_grid(month~station) +
    ggtitle("Size-resolved hygroscopicity (kappa) of sea spray aerosol\nSelected stations, February")
dev.off()


p <- ggplot(subset(station_OMF_dp,
                   month %in% c("FEB", "MAY", "AUG", "NOV")),
            aes(x=Dp_um, y=partial_kappa, fill=type)) +
  theme(strip.text.y=element_text(angle=0),
        strip.text.x=element_text(angle=90)) +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Hygroscopicity (kappa)") +
  xlab("Dry particle diameter [um]")
png("kappa_marine_vs_Dp_all_stations_seasons.png", width = 1200, height = 1200, pointsize=24)
  p + geom_area(position = 'stack') + facet_grid(month~station) +
    ggtitle("Size-resolved hygroscopicity (kappa) of sea spray aerosol\nSelected stations, February")
dev.off()


p <- ggplot(subset(subset(station_chemistry_dp,
                          station %in% sel_stations),
                   month %in% c("FEB")),
            aes(x=Dp_um, y=partial_kappa, fill=type)) +
  theme(strip.text.y=element_text(angle=0)) +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Hygroscopicity (kappa)") +
  xlab("Dry particle diameter [um]") + ylim(0, 1.16) +
  scale_fill_brewer(palette="Set1") +
  geom_area(position = 'stack') + facet_grid(station~.) +
  ggtitle("Size-resolved hygroscopicity (kappa) of aerosol, all sources
          Selected stations, February")
png("kappa_all_vs_Dp_sel_stations_FEB.png", width = 1200, height = 1200, pointsize=24)
p
dev.off()

p <- ggplot(subset(subset(station_chemistry_dp,
                          station %in% sel_stations),
                   month %in% c("FEB")),
            aes(x=Dp_um, y=vol_frac, fill=type)) +
  theme(strip.text.y=element_text(angle=0)) +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Volume fraction") +
  xlab("Dry particle diameter [um]") + ylim(0, 1)
scale_fill_brewer(palette="Set1")

png("volume_fraction_sel_stations_FEB.png", width = 1200, height = 1200, pointsize=24)
  p + geom_area(position = 'stack') + facet_grid(station~.) +
    ggtitle("Volume fractional chemical composition of aerosol, all sources\nSelected stations, February")
dev.off()

#### Plots of size-resolved chemical composition
p <- ggplot(subset(subset(station_chemistry_dp,station %in% sel_stations),
                   month %in% c("FEB")),
            aes(x=Dp_um, y=vol, fill=type)) +
  theme(strip.text.y=element_text(angle=90)) +
  ## TODO: double-check units
  scale_x_log10(limits=c(0.01, 10)) + ylab("Volume concentration, dVdlogdP [m^3/m^3]") +
  xlab("Dry particle diameter, Dp [um]") +
  scale_fill_brewer(palette="Set1")
png("Volume_size_distribution_stations.png", width = 1200, height = 1200, pointsize=24)
p + geom_area(position = 'stack') + facet_grid(.~station) +
  ggtitle("Chemically-resolved volume size distribution\nSelected stations, February")
dev.off()

for (imonth in c("FEB", "MAY", "AUG", "NOV")) {
  p <- ggplot(subset(subset(station_chemistry_dp,station %in% sel_stations),
                     month %in% imonth),
              aes(x=Dp_um, y=num, fill=type)) +
    theme(strip.text.y=element_text(angle=0)) +
    scale_x_log10(limits=c(0.01, 10)) + ylab("Number concentration, dN/dlogDp [cm^-3]") +
    xlab("Dry particle diameter, Dp [um]") +
    scale_fill_brewer(palette="Set1")
  png(paste("Number_size_distribution_stations_", imonth, ".png", sep=""), width = 1200, height = 1200, pointsize=24)
    p + geom_area(position = 'stack') + facet_grid(.~station) +
      ggtitle("Chemically-resolved number size distribution\nSelected stations, February")
  dev.off()
}

p <- ggplot(subset(subset(station_chemistry_dp,
                          station %in% c(sel_stations)),
                   month %in% c("FEB", "MAY", "AUG", "NOV")),
            aes(x=Dp_um, y=num, fill=type)) +
  theme(strip.text.y=element_text(angle=0)) +
  scale_fill_brewer(palette="Set1") +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Number concentration, dN/dlogDp [cm^-3]") +
  xlab("Dry particle diameter, Dp [um]")
png("Number_size_distribution_sel_stations_seasons.png", width = 1200, height = 1200, pointsize=24)
  p + geom_area(position = 'stack') + facet_grid(station~month, scales = "free_y") +
    ggtitle("Chemically-resolved number size distribution\nSelected stations, seasonal cycle")
dev.off()

p <- ggplot(subset(station_chemistry_dp,
                   month %in% c("FEB", "MAY", "AUG", "NOV")),
            aes(x=Dp_um, y=num, fill=type)) +
  theme(strip.text.y=element_text(angle=0)) +
  scale_fill_brewer(palette="Set1") +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Number concentration, dN/dlogDp [cm^-3]") +
  xlab("Dry particle diameter, Dp [um]")

png("Number_size_distribution_stations_seasons.png", width = 1200, height = 1200, pointsize=24)
  p + geom_area(position = 'stack') + facet_grid(station~month, scales = "free_y") +
    ggtitle("Chemically-resolved number size distribution\nSelected stations, seasonal cycle")
dev.off()

p <- ggplot(subset(station_chemistry_dp,station %in% c("Amsterdam Island")),
            aes(x=Dp_um, y=num, fill=type)) +
  theme(strip.text.y=element_text(angle=0)) +
  scale_fill_brewer(palette="Set1") +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Number concentration, dN/dlogDp [cm^-3]") +
  xlab("Dry particle diameter, Dp [um]")

png("Number_size_distribution_Amsterdam_Island_months.png", width = 1200, height = 400, pointsize=24)
p + geom_area(position = 'stack') + facet_grid(.~month) +
  ggtitle("Chemically-resolved number size distribution\nAmsterdam Island")
dev.off()

p <- ggplot(subset(station_chemistry_dp,station %in% c("Amsterdam Island")),
            aes(x=Dp_um, y=num_frac, fill=type)) +
  theme(strip.text.y=element_text(angle=90)) +
  scale_fill_brewer(palette="Set1") +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Number concentration, dN/dlogDp [cm^-3]") +
  xlab("Dry particle diameter, Dp [um]")

png("Number_size_distribution_Amsterdam_Island_months.png", width = 1200, height = 1200, pointsize=24)
  p + geom_area(position = 'stack') + facet_grid(month~.) +
    ggtitle("Fractional contribution of chemical species to particle number\nAmsterdam Island")
dev.off()

p <- ggplot(subset(subset(station_chemistry_dp,station %in% sel_stations,
                          months %in% c("FEB", "MAY", "AUG", "NOV"))),
            aes(x=Dp_um, y=num_frac, fill=type)) +
  theme(strip.text.y=element_text(angle=90)) +
  scale_fill_brewer(palette="Set1") +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Number concentration, dN/dlogDp [cm^-3]") +
  xlab("Dry particle diameter, Dp [um]")

png("Fractional_size_distribution_sel_stations_seasons.png", width = 1200, height = 1200, pointsize=24)
  p + geom_area(position = 'stack') + facet_grid(month~station) +
    ggtitle("Fractional contribution of chemical species to particle number
            Selected stations, seasonal cycle")
dev.off()

p <- ggplot(subset(station_chemistry_dp,station %in% c(sel_stations)),
            aes(x=Dp_um, y=num_frac, fill=type)) +
  theme(strip.text.y=element_text(angle=90), strip.text.x=element_text(angle=90)) +
  scale_x_log10(limits=c(0.01, 10)) + ylab("Number concentration, dN/dlogDp [cm^-3]") +
  xlab("Dry particle diameter, Dp [um]") + scale_fill_brewer(palette="Set1")

png("Fractional_size_distribution_sel_stations_months.png", width = 1200, height = 1200, pointsize=24)
  p + geom_area(position = 'stack') + facet_grid(month~station) +
    ggtitle("Fractional contribution of chemical species to particle number and mass\nSelected stations, seasonal cycle")
dev.off()

p <- ggplot(subset(station_chemistry_dp,station %in% c("Alert")),
            aes(x=Dp_um, y=num, fill=type)) +
  theme(strip.text.y=element_text(angle=0), strip.text.x=element_text(angle=0)) +
  scale_x_log10(limits=c(0.01, 10)) + ylab("dN/dlogDp [cm^-3]") +
  xlab("Dry particle diameter, Dp [um]") + scale_fill_brewer(palette="Set1")

png("Number_size_distribution_Alert_months.png", width = 1200, height = 400, pointsize=24)
p + geom_area(position = 'stack') + facet_grid(station~month) + theme_gray(base_size = 18) +
  ggtitle("Chemically-speciated number size distributions\nSelected stations, seasonal cycle")
dev.off()

num_stations <- (station.aerosols$num_a1+station.aerosols$num_a2+station.aerosols$num_a3+
                 station.aerosols$num_a4+station.aerosols$num_c1+station.aerosols$num_c2+
                 station.aerosols$num_c3+station.aerosols$num_c4)*station.aerosols$moist.density*1e-6 # #/cc

ncl_mass_stations <- (station.aerosols$ncl_a1+station.aerosols$ncl_a2+station.aerosols$ncl_a3+
                      station.aerosols$ncl_c1+station.aerosols$ncl_c2+station.aerosols$ncl_c3)*
                      station.aerosols$moist.density*1e9 # ug/m3

png("Seasonal_cycle_sodium_number_Alert.png")
plot(num_stations[station.aerosols$station_name=="Alert"],
     type='l', xlab="Month", ylab="Total particle number [#/cc]",
     main="Seasonal cycle of aerosol number concentration, Alert")
dev.off()

png("Seasonal_cycle_sodium_mass_Alert.png")
plot(ncl_mass_stations[station.aerosols$station_name=="Alert"]*22.989/(22.989+35.453),
     type='l', xlab="Month", ylab="Sodium mass [ug/m^3]",
     main="Seasonal cycle of sodium mass, Alert")
dev.off()
