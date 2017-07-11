library(RNetCDF)

# Open file and read variables
filehandle <- open.nc(paste(ncfile_dir, ncfile_name, sep="/"))
source("./read_vars_from_file.R")

# Create model latitude and longitude arrays
latitude <- var.get.nc(filehandle, "lat")
longitude <- var.get.nc(filehandle, "lon")

# Load station locations
source("define_UMiami_stations.R")

# Get U. Miami file names
umiami.files <- grep("txt", list.files(paste(obs_dir, "/UMiami_dataset/",
                                       sep="")), value = TRUE)
umiami.files <- umiami.files[umiami.files!="readme.txt"]
umiami.files <- gsub(".txt", "", umiami.files)

# Subselect model data

# non-sea-salt Sulfate: AVG_NSSSO4
# Sulfate: AVG_SO4
# Dust: AVG_DUST
# Sodium: AVG_NA
# Chlorine: AVG_CL
# MSA: AVG_MSA
# Nitrate: AVG_NO3
# Ammonium: AVG_NH4

# Total (average) aerosol mass. Unclear if organics are captured.
avg_cl <- as.numeric(as.character(data.in$AVG_CL))
avg_na <- as.numeric(as.character(data.in$AVG_NA))
avg_so4 <- as.numeric(as.character(data.in$AVG_SO4))
avg_dust <- as.numeric(as.character(data.in$AVG_DUST))
avg_no3 <- as.numeric(as.character(data.in$AVG_NO3))
avg_msa <- as.numeric(as.character(data.in$AVG_MSA))

#  aerosol <- cbind(avg_so4, avg_dust, avg_na, avg_cl, avg_no3, avg_msa)
aerosol <- cbind(avg_so4, avg_dust, avg_ncl=avg_na*58.44/22.9898)
data.in$total_aerosol <- rowSums(aerosol, na.rm=TRUE)

# Get model data at lat/lon
sitelat <- umiami.coords[umiami.coords$site==sitename, ]$lat
sitelon <- umiami.coords[umiami.coords$site==sitename, ]$lon
# wrap longitudes
if (sitelon < 0) {
  sitelon <- 360.0 + sitelon
}

modeldata <- data.frame(month=factor(monthnames, ordered = TRUE))
for (phase in c("a", "c")) {
  for (amode in 1:4) {
    for (varname in c(paste("dgn_",  phase, amode, sep=""),
                      paste("v2n_",  phase, amode, sep=""),
                      paste("mass_", phase, amode, sep=""),
                      paste("mmr_",  phase, amode, sep=""),
                      paste("vol_",  phase, amode, sep=""),
                      paste("num_",  phase, amode, sep=""),
                      paste("mom_",  phase, amode, sep=""),
                      paste("ncl_",  phase, amode, sep=""),
                      paste("pom_",  phase, amode, sep=""),
                      paste("soa_",  phase, amode, sep=""),
                      paste("so4_",  phase, amode, sep=""),
                      paste("dst_",  phase, amode, sep=""),
                      paste("bc_",   phase, amode, sep=""),
                      paste("wat_",  phase, amode, sep=""),
                      paste("vol_per_kg_",  phase, amode, sep="")
    )) {
      
      # Print information (for debugging)
      #              print(paste(station.names[station], varname, sep=", "))
      
      if (exists(varname)) {
        var <- get(varname)
        if (length(dim(var)) == 4) {
          var <- var[, , 30, ]
        }
        modeldata[[varname]] <- select_var_at_station(var, 
                                                      latitude, longitude,
                                                      stationlat = sitelat,
                                                      stationlon = sitelon)
      }
    } # end loop varname
  } # end loop amode
} # end loop phase
modeldata[["site"]]=sitename
modeldata[["site.long.name"]]=umiami.coords[umiami.coords$site==sitename, ]$site.name
modeldata[["lat"]]=sitelat
modeldata[["lon"]]=sitelon
modeldata[["moist.density"]] <- select_var_at_station(moist.density, 
                                                      latitude, longitude,
                                                      stationlat=sitelat,
                                                      stationlon=sitelon)
# Marine organic aerosol mass (MOA); ug/m3
modeldata$MOA <- (modeldata$mom_a1 + modeldata$mom_c1 +
                    modeldata$mom_a2 + modeldata$mom_c2 +
                    modeldata$mom_a3 + modeldata$mom_c3 +
                    modeldata$mom_a4 + modeldata$mom_c4 )*
  modeldata$moist.density*1e9 # ug/m3

# Secondary organic aerosol mass (SOA); ug/m3
modeldata$SOA <- (modeldata$soa_a1 + modeldata$soa_c1 +
                    modeldata$soa_a2 + modeldata$soa_c2 +
                    modeldata$soa_a3 + modeldata$soa_c3 )*
  modeldata$moist.density*1e9 # ug/m3

# Primary organic aerosol mass (POA); ug/m3
modeldata$POA <- (modeldata$pom_a1 + modeldata$pom_c1 +
                    modeldata$pom_a3 + modeldata$pom_c3 +
                    modeldata$pom_a4 + modeldata$pom_c4 )*
  modeldata$moist.density*1e9 # ug/m3

# Sulfate aerosol mass (SO4); ug/m3
modeldata$SO4 <- (modeldata$so4_a1 + modeldata$so4_c1 +
                    modeldata$so4_a2 + modeldata$so4_c2 +
                    modeldata$so4_a3 + modeldata$so4_c3 )*
  modeldata$moist.density*1e9 # ug/m3

# Black carbon aerosol mass (BC); ug/m3
modeldata$BC  <- (modeldata$bc_a1 + modeldata$bc_c1 +
                    modeldata$bc_a3 + modeldata$bc_c3 +
                    modeldata$bc_a4 + modeldata$bc_c4 )*
  modeldata$moist.density*1e9 # ug/m3

# Sea salt aerosol mass (NCL); ug/m3
modeldata$NCL <- (modeldata$ncl_a1 + modeldata$ncl_c1 +
                    modeldata$ncl_a2 + modeldata$ncl_c2 +
                    modeldata$ncl_a3 + modeldata$ncl_c3 )*
  modeldata$moist.density*1e9 # ug/m3

# Dust aerosol mass (DST); ug/m3
modeldata$DST <- (modeldata$dst_a1 + modeldata$dst_c1 +
                    modeldata$dst_a3 + modeldata$dst_c3 )*
  modeldata$moist.density*1e9 # ug/m3

# Sum up total aerosol
#  modeldata[["total.aerosol"]] <- modeldata$MOA + modeldata$SOA + modeldata$POA +
#                                  modeldata$SO4 + modeldata$BC  + modeldata$NCL +
#                                  modeldata$DST
# Sum up total aerosol -- refractory components only
modeldata[["total.aerosol"]] <- modeldata$MOA + modeldata$POA + modeldata$DST +
  modeldata$SO4 + modeldata$BC  + modeldata$NCL
modeldata[["total.aerosol.no.moa"]] <- modeldata$POA + modeldata$DST +
  modeldata$SO4 + modeldata$BC  + modeldata$NCL

# Write out model data at UMiami sites to .csv file.
write.csv(modeldata, paste(csv_dir, "/", model_name,
                           "_UMiami_stations.csv", sep=""),
          row.names = FALSE)
