
library("Taxonstand")
library("readxl")
library("tidyverse")
library("magrittr")
library("janitor")

list.files("data/raw/")

df <- read_excel("data/raw/TargetSpeciesForages.xlsx")

sp <- df$input_taxon

# check names
sp_check <- TPL(sp)


# keep accep
sp_check %<>% 
  as_tibble(.name_repair = janitor::make_clean_names)


names(sp_check)


sp_check %<>% 
  select(taxon, taxonomic_status, 
         family, new_genus, new_hybrid_marker, 
         new_species, new_infraspecific_rank, new_infraspecific, 
         new_authority, new_taxonomic_status)

sp_check %<>% 
  rename(input_taxon = taxon,
         input_status = taxonomic_status)

names(sp_check) <- gsub("new_","", names(sp_check))

sp_check


# create an id using species genus and name
id <- paste0(substr(sp_check$genus, start = 1, stop = 3),
             substr(sp_check$species, start = 1, stop = 3),
             substr(sp_check$infraspecific, start = 1, stop = 1))

id <- toupper(id)

length(unique(id)) == length(id)

sp_check$acronym <- id

# vector with full name
sp_check %>% 
  select(genus:infraspecific) %>% 
  as.matrix() ->
  taxa

sp <- apply(taxa[,1:3], 1, function(x) {
  x <- paste0(x, collapse = " ")
  x <- gsub("NA ", "", x)
})

sp <- ifelse(!is.na(taxa[,4]), 
             paste(sp, taxa[,4], taxa[,5], sep = " "),
             sp)

sp_check$taxa <- sp

write.csv(sp_check, "data/species_names.csv",
          row.names = FALSE)


