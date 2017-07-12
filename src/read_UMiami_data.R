library(stringr)

# Load station locations
source("define_UMiami_stations.R")

# Get U. Miami file names
umiami.files <- grep("txt", list.files(paste(obs_dir, "/UMiami_dataset/",
                                             sep="")), value = TRUE)
umiami.files <- umiami.files[umiami.files!="readme.txt"]
umiami.files <- gsub(".txt", "", umiami.files)

# Read input data for each site and append data frame
obsdata.all <- data.frame()
for (sitename in umiami.files) {

  data.in <- read.delim(paste(obs_dir, "/UMiami_dataset/", sitename, ".txt", sep=""))
  
  # DATE exists
  if (any(names(data.in)=="DATE")) {
    tmp <- as.Date(as.character(data.in$DATE),format = "%d.%m.%Y")
    if (all(is.na(tmp))) {
      tmp <- as.Date(as.character(data.in$DATE),format = "%m-%d-%Y")
    }
    data.in$DATE <- tmp
  }
  
  # BEGIN and END exist
  if (any(names(data.in)=="BEGIN")) {
    begindate <- as.Date(as.character(data.in$BEGIN),format = "%d.%m.%Y")
    if (all(is.na(begindate))) {
      begindate <- as.Date(as.character(data.in$BEGIN),format = "%m-%d-%Y")
    }
    
    enddate <- as.Date(as.character(data.in$END),format = "%d.%m.%Y")
    if (all(is.na(enddate))) {
      enddate <- as.Date(as.character(data.in$END),format = "%m-%d-%Y")
    }
    if (all(is.na(enddate))) {
      enddate <- as.Date(as.character(data.in$END),format = "%d-%b-%Y")
    }
    tmp <- rowMeans(cbind(begindate, enddate))
    tmp <- as.Date(tmp, origin="1970-01-01")
    
    data.in$DATE <- tmp
  }

  # Load data fields required
  
  # non-sea-salt Sulfate: AVG_NSSSO4
  # Sulfate: AVG_SO4
  # Dust: AVG_DUST
  # Sodium: AVG_NA
  # Chlorine: AVG_CL
  # MSA: AVG_MSA
  # Nitrate: AVG_NO3
  # Ammonium: AVG_NH4
  
# Construct obs data frame including all average aerosol fields
  obsdata <- data.frame(date=data.in$DATE, site=sitename)
  if (any(names(data.in)=="AVG_CL")) {
    obsdata[["avg_cl"]] <- as.numeric(as.character(data.in$AVG_CL))
  } else {
    obsdata[["avg_cl"]]<-array(NA, dim(obsdata)[1])
  }
  if (any(names(data.in)=="AVG_NA")) {
    obsdata[["avg_na"]] <- as.numeric(as.character(data.in$AVG_NA))
  } else {
    obsdata[["avg_na"]]<-array(NA, dim(obsdata)[1])
  }
  if (any(names(data.in)=="AVG_SO4")) {
    obsdata[["avg_so4"]] <- as.numeric(as.character(data.in$AVG_SO4))
  } else {
    obsdata[["avg_so4"]]<-array(NA, dim(obsdata)[1])
  }
  if (any(names(data.in)=="AVG_DUST")) {
    obsdata[["avg_dust"]] <- as.numeric(as.character(data.in$AVG_DUST))
  } else {
    obsdata[["avg_dust"]]<-array(NA, dim(obsdata)[1])
  }
  if (any(names(data.in)=="AVG_NO3")) {
    obsdata[["avg_no3"]] <- as.numeric(as.character(data.in$AVG_NO3))
  } else {
    obsdata[["avg_no3"]]<-array(NA, dim(obsdata)[1])
  }
  if (any(names(data.in)=="AVG_MSA")) {
    obsdata[["avg_msa"]] <- as.numeric(as.character(data.in$AVG_MSA))
  } else {
    obsdata[["avg_msa"]]<-array(NA, dim(obsdata)[1])
  }
  if (any(names(data.in)=="AVG_NH4")) {
    obsdata[["avg_nh4"]] <- as.numeric(as.character(data.in$AVG_NH4))
  } else {
    obsdata[["avg_nh4"]]<-array(NA, dim(obsdata)[1])
  }
  
  # Total (average) salt mass (Na+Cl), estimate using Na as conservative tracer.
  obsdata[["avg_ncl"]] <- obsdata$avg_na*58.44/22.9898

  # Total (average) aerosol mass for model comparison -- only compare so4+dust+ncl
  obsdata[["total_aerosol"]] <- rowSums(cbind(obsdata$avg_so4,
                                              obsdata$avg_dust,
                                              obsdata$avg_ncl),
                                              na.rm=TRUE)

  obsdata[["month"]] <- factor(str_to_upper(months(obsdata$date, abbreviate = TRUE)) ,
                                        ordered=TRUE,
                                        levels=monthnames)

  obsdata.all <- rbind(obsdata.all, obsdata)
}

# Write out unified table of UMiami obs data (selected columns)
write.csv(obsdata.all, paste(obs_dir, "/UMiami_unified.csv", sep=""),
          row.names = FALSE)
