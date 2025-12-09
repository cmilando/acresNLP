library(readr)
library(tidyverse)
library(ggforce)
library(janitor)
library(sf)
library(gtable)
library(grid)
library(gridExtra)
library(tigris)
library(leaflet)

### NOTES

# * STONEHAM HAS NO CLIMATE REPORTS
# * NOT A LOT OF ADJACENCY IN HAZARDS
#
# * 
# * allison: for both hazards and outreach, for some towns the totals are < 100%
# * chad: expanding heat search terms and seeing if that changes things, manual search

# Needs:
# * Map
# * table of the heatmap with %s and n

# * REVERE AND LEXINGTON DON'T HAVE 100% in relevancy table
# * WHY ISNT HEAT MORE ** SEARCH TERMS
#
# * WHAT ABOUT THE COMMUNITY CONCERNS

# ----------------------------------------------------------------------------
#### create dataframe of hazard counts and proportions by town ####

#adjust based on your computer
#my_dir <- "/Users/alliej/Library/CloudStorage/OneDrive-BostonUniversity/ACRES NLP/acresNLP/"
my_dir <- "/Users/cwm/Documents/GitHub/acresNLP/"
# my_dir <- "C:/Users/ncesare/Downloads/"

create_df <- function(filename){
  data <- read_delim(filename)
  return(data)
}


#combined table missing all arlington/belmont and some chelsea/everett
combined_table <- create_df(paste0(my_dir, "combined_output_v8.tsv"))
problems(combined_table)
colnames(combined_table)
combined_table <- combined_table %>% clean_names()
combined_table$town_name <- gsub("url\\d+|\\d+|\\.json", "",
                                 combined_table$file_name)
combined_table$town_name <- toupper(combined_table$town_name)

# *********************
towns_remove <- c(
  "burlington", "lexington",  "winchester", "woburn",     "reading",
  "stoneham",   "wakefield",  "wilmington"
)
combined_table$towns_to_scrub <- FALSE
for(tt in towns_remove) {
  rr <- which(grepl(paste0("^", tt), combined_table$file_name))
  combined_table$towns_to_scrub[rr] <- TRUE
}
table(combined_table$towns_to_scrub)
head(combined_table)
# *********************

#View(combined_table)

mystic_towns_list = c(
  "Burlington",
  "Lexington",
  "Belmont",
  "Watertown",
  "Arlington",
  "Winchester",
  "Woburn",
  "Reading",
  "Stoneham",
  "Medford",
  "Somerville",
  "Cambridge",
  "Everett",
  "Malden",
  "Melrose",
  "Wakefield",
  "Chelsea",
  "Revere",
  "Winthrop",
  "Wilmington"
)

INNER_CORE <- read.table("INNER_CORE.txt", header = F)
head(INNER_CORE)

##
combined_table <- combined_table %>% 
  mutate(is_ACRES_town = (most_common_town %in% tolower(mystic_towns_list)),
         is_INNER_CORE = (most_common_town %in% tolower(INNER_CORE$V1)),
         is_MASS = (most_common_state == 'massachusetts'))

# duplicated
combined_table$duplicated = duplicated(combined_table$first100words)

# write_tsv(combined_table[, c('file_name', 'duplicated')] %>%
#             arrange(file_name), 'duplicated.tsv')

combined_table <- combined_table %>%
  mutate(pass_checks2 = (
    duplicated == F &
      (is_INNER_CORE == T | is_ACRES_town == T) &
      is_MASS == T &
      has_climate == 1 &
      has_community == 1
  ))

xx <- combined_table[, c('file_name', 'most_common_town','is_INNER_CORE',
                         'is_ACRES_town', 'duplicated', 'is_MASS',
                         'has_climate','has_community')] %>%
  arrange(file_name)

# write.table(xx, file = 'is_inner_core.txt',  sep = "|",
#             quote = F, row.names = F)

##

table(combined_table$most_common_town, combined_table$pass_checks2)
table(combined_table$pass_checks2)

mancx <- read.csv(paste0(my_dir, "manual_checks_2.csv"), header = T,
                  sep = "|")[,c('Manual.Check', "file_name")]
head(mancx)

dim(combined_table)

combined_table <- combined_table %>% left_join(mancx)

dim(combined_table)
data.frame(head(combined_table))

# write_tsv(combined_table, 'combined_table_v8.tsv')
