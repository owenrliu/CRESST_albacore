# Make projection dataframes for different OIF scenarios
# Extending the data processing done for the main covariates in `fdms w cov.qmd`
# We need to:
# Load
# Project
# Extract
# Scale (relative to scenario 1)

library(tidyverse)
library(sf)
library(terra)
library(here)

# pre-processed and filterd logbook data
datm <- read_rds(here('data','logbook_data_sdmTMB_ready.rds'))

# projection grid
gr <- read_rds(here('data','predgrid.rds'))
aeqd_crs <- st_crs("+proj=aeqd +lat_0=45 +lon_0= -127 +datum=WGS84 +units=m +no_defs")
# prediction grid coords in lat/lon, to match to SDM rasters
grll <- gr |>
  st_as_sf(coords=c("X","Y"),crs=aeqd_crs) |>
  st_transform(4326) |> 
  # get grid cell centers
  st_centroid() |> st_coordinates() |> 
  as_tibble() |> 
  mutate(X=X %% 360)

# all pre-processed covariate rasters
scens <- paste0("scen",1:8)
covn <- map(scens,\(x){
  paste(x,c("mean_suit","max_suit","int_suit","wdepth"),sep = "_")
})

alb_covs <- map(covn, \(x) {
  out <- map(x,\(y) rast(here('data','albacore sdm',paste0('alb_sdm_',y,'.tif'))))
  names(out) <- x
  out
})

names(alb_covs) <- scens

# function to pull together a list of raster layers for a given year month
# and extract them to a given set of points

# Inputs: chr vector of covariate names, month-year (e.g., "March_2013") and pred points
extract_covariates_my <- function(scen,my,pp){
  cov_names <- names(alb_covs[[scen]])
  covl <- map(cov_names,\(x){
    d <- alb_covs[[scen]][[x]][my] |> 
      terra::extract(pp,method='bilinear',ID=F)
    names(d) <- x
    d})
  out <- covl |>
    bind_cols() |> 
    mutate(my=my)
  out
}

# implement function for all year/months in the data to extract all the data
grmy <- map(scens,\(x){
  map(unique(datm$my),\(y){
    covs <- extract_covariates_my(x,y,grll)
    gr |> bind_cols(covs)
  }) |> bind_rows()
})
            
            map(unique(datm$my), \(x){
  covs <- extract_covariates_my(covn,x,grll)
  gr |> bind_cols(covs)
}) |> bind_rows()

# clean up and scale variables
grpred <- map(grmy,\(x){
  
  names(x)<- str_remove_all(names(x),"scen\\d_")
  
  x |> 
    # remove scenario names from variable titles
    separate(my, into = c("month", "year"), sep = "_") |> 
    mutate(year = as.numeric(year)) |> 
    # scale covariates relative to scenario 1 data
    # to put them on the same scale as the fit
    mutate(scaled_year=(year - mean(datm$year)) / 10) |> 
    # scale depth
    mutate(scaled_depth=(wdepth-mean(datm$wdepth))/sd(datm$wdepth)) |>
    mutate(scaled_sst=(wdepth-mean(datm$sst))/sd(datm$sst)) |> 
    filter(!is.na(mean_suit)) |> 
    # add season factor again
    mutate(season=case_when(
      month%in%c("June","July") ~ "JJ",
      month%in%c("August","September") ~ "AS",
      month %in% c("October","November") ~ "ON"
    )) |> 
    mutate(seasonfct=factor(season,levels=c("JJ","AS","ON")),
           monthfct=factor(month,levels=c("June","July","August","September","October","November")))
})

write_rds(grpred,here('data','predgrid_all_OIF_scenarios.rds'))
