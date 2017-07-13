library(RNetCDF)
library(ncdf.tools)

# Read paths
source("path_definitions.R")

# Define station locations and names
source("define_stations.R")

# Open file
filehandle <- open.nc(paste(ncfile_dir, ncfile_name, sep="/"))
source("./read_vars_from_file.R")

## AEROSOL MODE AND SPECIES PROPERTIES

  # Define names of modes
  mode_names <- c("accu", "aitk", "coarse", "porg")
      
  # Assign sigma (fixed width of lognormal bin) for each mode. [-]
  # (see Liu et al., 2016; physprops files)
    sigma_g <- c(1.8, 1.6, 1.8, 1.6)

  # Assign minimum and maximum dry geometric mean diameter for each mode [m]
  # (see Liu et al., 2016; physprops files)

    # Lower bound
    dgnumlo <- c(5.35e-8, 8.70e-9, 1.00e-6, 1.00e-8)

    # Upper bound
    dgnumhi <- c(4.40e-7, 5.20e-8, 4.00e-6, 1.00e-7)
    
    # Default/nominal value of dgnum for each mode? (can get from physprops file)

    # Default volume-to-number ratio for each mode? (can get from physprops file)
    
  # Density of aerosol components as assigned in the model [kg m^-3]
    density_mom <- 1601.
    density_ncl <- 1900.
    density_pom <- 1000.
    density_soa <- 1000.
    density_so4 <- 1770.
    density_dst <- 2600.
    density_bc  <- 1700.

  # Hygroscopicity of aerosol components as assigned in the model [-]
    kappa_mom <- 0.1
    kappa_ncl <- 1.16
    kappa_pom <- 1.0e-10
    kappa_soa <- 0.14
    kappa_so4 <- 0.507
    kappa_dst <- 0.068
    kappa_bc  <- 1.0e-10
    
  # Molecular weights of aerosol components [g/mol]
  # NOTE: not clear if relevant?
  
### TOTAL MASS, VOLUME, KAPPA of each mode

  # Calculate (moist) air density, currently surface air only  
  # Better would be to use (level pressure difference) / gravity
    vapor.pressure <- Q[, , 30, ]/(Q[, , 30, ] + 0.622) * PS
    
    # Dry air density [kg/m3]
    dry.density <- PS / (287.0531 * T[, , 30, ])

    # Moist air density [kg/m3]
    moist.density <- (PS - vapor.pressure) / (287.0531 * T[, , 30, ]) +
      vapor.pressure/(461.4964 * T[, , 30, ])
    
  # Calculate total mass in each mode
    
  # Interstitial aerosol mass mixing ratio [kg/kg]
    mmr_a1 <- mom_a1 + ncl_a1 + pom_a1 + soa_a1 + so4_a1 + dst_a1 + bc_a1
    mmr_a2 <- mom_a2 + ncl_a2 + soa_a2 + so4_a2
    mmr_a3 <- mom_a3 + ncl_a3 + pom_a3 + soa_a3 + so4_a3 + dst_a3 + bc_a3
    mmr_a4 <- mom_a4 + pom_a4 + bc_a4
    
  # Cloud-borne aerosol mass mixing ratio [kg/kg]
    mmr_c1 <- mom_c1 + ncl_c1 + pom_c1 + soa_c1 + so4_c1 + dst_c1 + bc_c1
    mmr_c2 <- mom_c2 + ncl_c2 + soa_c2 + so4_c2
    mmr_c3 <- mom_c3 + ncl_c3 + pom_c3 + soa_c3 + so4_c3 + dst_c3 + bc_c3
    mmr_c4 <- mom_c4 + pom_c4 + bc_c4
  
  # Calculate volume mixing ratio in each mode [m3/kg]
    vol_per_kg_a1 <- (mom_a1/density_mom + ncl_a1/density_ncl + pom_a1/density_pom +
      soa_a1/density_soa + so4_a1/density_so4 + dst_a1/density_dst + bc_a1/density_bc)
    vol_per_kg_a2 <- (mom_a2/density_mom + ncl_a2/density_ncl +
      soa_a2/density_soa + so4_a2/density_so4)
    vol_per_kg_a3 <- (mom_a3/density_mom + ncl_a3/density_ncl + pom_a3/density_pom +
      soa_a3/density_soa + so4_a3/density_so4 + dst_a3/density_dst + bc_a3/density_bc)
    vol_per_kg_a4 <- (mom_a4/density_mom + pom_a4/density_pom + bc_a4/density_bc)
    
    # Cloud-borne aerosol volume mixing ratio [m3/kg]
    vol_per_kg_c1 <- (mom_c1/density_mom + ncl_c1/density_ncl + pom_c1/density_pom +
      soa_c1/density_soa + so4_c1/density_so4 + dst_c1/density_dst + bc_c1/density_bc)
    vol_per_kg_c2 <- (mom_c2/density_mom + ncl_c2/density_ncl +
      soa_c2/density_soa + so4_c2/density_so4)
    vol_per_kg_c3 <- (mom_c3/density_mom + ncl_c3/density_ncl + pom_c3/density_pom +
      soa_c3/density_soa + so4_c3/density_so4 + dst_c3/density_dst + bc_c3/density_bc)
    vol_per_kg_c4 <- (mom_c4/density_mom + pom_c4/density_pom + bc_c4/density_bc)

  # Convert from [kg/kg] to [ng/m3] (in boundary layer only for now)
    
    # Interstitial
    mass_a1 <- mmr_a1[, , 30, ]*1.e12*moist.density
    mass_a2 <- mmr_a2[, , 30, ]*1.e12*moist.density
    mass_a3 <- mmr_a3[, , 30, ]*1.e12*moist.density
    mass_a4 <- mmr_a4[, , 30, ]*1.e12*moist.density

    # Cloud-borne
    mass_c1 <- mmr_c1[, , 30, ]*1.e12*moist.density
    mass_c2 <- mmr_c2[, , 30, ]*1.e12*moist.density
    mass_c3 <- mmr_c3[, , 30, ]*1.e12*moist.density
    mass_c4 <- mmr_c4[, , 30, ]*1.e12*moist.density

    # Convert from [m3/kg] to [m3/m3]
    # Convert to (cm^3/mol_air)
    
    # This is possibly not quite right / consistent due to dry vs. moist issues?
    # double-check by cross-referencing with modal_aero_calcsize.F90, l.663
    mol_air_per_m3 <- moist.density
    
    vol_a1 <- vol_per_kg_a1[, , 30, ]*moist.density
    vol_a2 <- vol_per_kg_a2[, , 30, ]*moist.density
    vol_a3 <- vol_per_kg_a3[, , 30, ]*moist.density
    vol_a4 <- vol_per_kg_a4[, , 30, ]*moist.density

    # Convert from [m3/kg] to [m3/m3]
    # Convert to (cm^3/mol_air)
    vol_c1 <- vol_per_kg_c1[, , 30, ]*moist.density
    vol_c2 <- vol_per_kg_c2[, , 30, ]*moist.density
    vol_c3 <- vol_per_kg_c3[, , 30, ]*moist.density
    vol_c4 <- vol_per_kg_c4[, , 30, ]*moist.density

#  # Back out mode median diameter
#  # Compare subroutine modal_aero_calcsize_sub() in modal_aero_calcsize.F90

    # Loop over modes
    for (i in 1:4) {
#      dumfac <- exp(4.5*sigma_g[i]^2)*pi/6.

#      # dgn = (dryvol / (dumfac*num))^1/3
      
      # Loop over interstitial and cloudborne
      for (phase in c("a", "c")) {
        
        # Use model's diagnosed dry particle size for both dry and cloudborne aerosol
        assign(paste("dgn_", phase, i, sep=""),
               get(paste("dgnd_", "a0", i, sep=""))[ , , 30, ] )
#        assign(paste("dgn_", phase, i, sep=""),
#               (get(paste("vol_per_kg_", phase, i, sep=""))[ , , 30, ] /
#                  (dumfac*
#                     get(paste("num_", phase, i, sep=""))[ , , 30, ]))^(1./3.))

#        tmp <- get(paste("dgn_", phase, i, sep=""))

#        # Where infinite, set to NA
#        where_infinite <- which(is.infinite(tmp),
#                                arr.ind = TRUE)
#        tmp[where_infinite] <- NA
#        
#        # Where greater than upper bound, set to upper bound
#        where_too_big <- which(tmp > dgnumhi[i],
#                                arr.ind = TRUE)
#        tmp[where_too_big] <- dgnumhi[i]
#        
#        # Where less than lower bound, set to lower bound
#        where_too_small <- which(tmp < dgnumlo[i],
#                                 arr.ind = TRUE)
#        tmp[where_too_small] <- dgnumlo[i]
#        
#        # Assign adjusted values (within range) to dgn_PI
#        assign(paste("dgn_", phase, i, sep=""), tmp)
        
        # Compute [dry] volume-to-number ratio [cm^3 m^-3] / 
        assign(paste("v2n_", phase, i, sep=""),
               get(paste("vol_", phase, i, sep="")) /
                 get(paste("dgnd_a0", i, sep=""))[, , 30, ])
      }
    }

  # TODO Possibly add sanity check here: Check that dgn is within bounds
  # for mode (it had better be!):
