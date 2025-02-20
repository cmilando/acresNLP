# "B01003_001","B19013_001","B08303_001","B08301_001"

# Install and load the required libraries
library(tidycensus)
library(tidyverse)
library(dplyr)

# Set your Census API key (get one from https://api.census.gov/data/key_signup.html)
census_api_key("840a4b0cd2dce4a1c58a9375612945f9f14ac5d9")

# Download data for all US places
VARS <- c("B01003_001","B19013_001")  #,"B08303_001","B08301_001"), 

places_data <- get_acs(
  geography = "place", 
  state = 'MA',
  variables = VARS,
  year = 2020,
  survey = "acs5"
)

dim(places_data)
head(places_data)

INNER_CORE <- read.table("COMBINED_TOWNS.txt", header = F)
INNER_CORE_data <- vector("list", nrow(INNER_CORE))

for(i in 1:nrow(INNER_CORE)) {
  
  # i = 1
  
  this_sub <- which(grepl(paste0(INNER_CORE[i, 1], " "), places_data$NAME))
  
  stopifnot(length(this_sub) == length(VARS))  
  
  INNER_CORE_data[[i]] <- places_data[this_sub,]
  
}

INNER_CORE_df <- do.call(rbind, INNER_CORE_data)
dim(INNER_CORE_df)

o <-INNER_CORE_df %>% pivot_wider(id_cols = NAME, 
                                  names_from = variable,
                              values_from = estimate)

write.table(o, quote = F, sep = "|", row.names = F, file = 'TOWNS_CENSUS.txt')
