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

# Construct obs data frame
  obsdata <- data.frame(date=data.in$DATE, site=sitename)
  try(obsdata[["avg_cl"]] <- avg_cl, silent=TRUE)
  try(obsdata[["avg_na"]] <- avg_na, silent=TRUE)
  try(obsdata[["avg_so4"]] <- avg_so4, silent=TRUE)
  try(obsdata[["avg_dust"]] <- avg_dust, silent=TRUE)
  try(obsdata[["total_aerosol"]] <- data.in$total_aerosol, silent=TRUE)
  # Total (average) salt mass (Na+Cl), estimate using Na as conservative tracer.
  try(obsdata[["NCL"]] <- avg_na*58.44/22.9898, silent=TRUE)
  
  try(obsdata[["month"]] <- factor(str_to_upper(months(obsdata$date, abbreviate = TRUE)) ,
                                   ordered=TRUE,
                                   levels=monthnames))

  obsdata.all <- rbind(obsdata.all, obsdata)
}

# Write out unified table of UMiami obs data (selected columns)
write.csv(obsdata, paste(obs_dir, "/UMiami_unified.csv", sep=""),
          row.names = FALSE)
