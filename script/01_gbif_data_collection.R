# Retrieve GBIF occurrence data for distribution analysis 
# updated by K. de Sousa 
# Inland Norway University
#..........................................
#..........................................
# Packages ####
library("rgbif")
library("data.table")

sessioninfo::session_info()
# write session info
capture.output(sessioninfo::session_info(),
               file = "script/session_info/01_gbif_data_collection.txt")

#..........................................
#..........................................
# Data ####
df <- fread("data/species_names.csv")

taxa <- df$taxa

taxa <- gsub("  ", " ", taxa)

# ....................................
# ....................................
# Data collection ####

# use that taxonconceptkey to get occurrence data for spp and its synonyms
# fields that will be retrieved by rgbif::occ_search
fields <- c("name","scientificName",
           "countryCode","decimalLongitude",
           "decimalLatitude","key",
           "basisOfRecord","publishingOrg",
           "year","gbifID")

gbif <- NULL

# run over species names
for (i in seq_along(taxa)){
  cat(i, "out of", length(taxa), taxa[i],"\n")
  
  # check for all scientific names that include the species names  
  name <- name_suggest(q = taxa[i])
  
  name <- name$data
  
  # remove subspecies
  name <- name[name$rank != "SUBSPECIES", ]
  
  name <- na.omit(name)
  
  
  g <- NULL
  
  if (nrow(name) == 0) next 
  
  cat("fetching GBIF data...\n")
  
  for (j in seq_len(nrow(name))) {  
    
    o <- occ_search(taxonKey = name[[j,1]],
                    hasCoordinate = TRUE, 
                    fields = fields)
    
    if (length(o$data) == 0) next
    
    o$data$taxa <- taxa[i]
    
    o$data$acronym <- df$acronym[i]
    
    # sometimes it dont come with all desired field 
    # create an empty data.frame and match which fields
    # are provided by the source
    p <- as.data.frame(matrix(NA, nrow=nrow(o$data), ncol=12))
    names(p) <- c(fields,"taxa","acronym")
    index <- match(names(o$data), names(p))
    
    p[,index] <- o$data
    
    g <- rbind(g, p)
  
  } 
    
  gbif <- rbind(gbif, g)

}

# keep these occurrences as raw data
write.csv(gbif, 
          "data/raw/gbif_occurrences.csv",
          row.names = FALSE)

