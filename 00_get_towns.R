# Install and load the required libraries
library(tidycensus)
library(dplyr)

# Set your Census API key (get one from https://api.census.gov/data/key_signup.html)
census_api_key("840a4b0cd2dce4a1c58a9375612945f9f14ac5d9")

# Download data for all US places
places_data <- get_acs(
  geography = "place", 
  #state = 'MA',
  variables = "B01001_001", # Total population is used as a proxy
  year = 2020,
  survey = "acs5"
)

dim(places_data)

# View the unique place names
place_names <- places_data %>% 
  select(NAME) %>% 
  distinct()

# Preview the place names
length(place_names[[1]])

ll <- strsplit(place_names[[1]], ",", fixed = T)
length(ll[[1]])

which(sapply(ll, length) > 2)

ll[[4806]] <- c("Islamorada", " Florida")
ll[[26254]] <- c("Lynchburg", " Tennessee")

ll <- do.call(rbind, ll)

ll2 <- strsplit(ll[, 1], " ", fixed = T)
ll3 <- sapply(ll2, function(l) l[1])

#
ll3
all_unique_towns <- unique(ll3)
all_unique_towns
write.table(all_unique_towns, 'all_towns.txt', col.names = F, row.names = F,
            quote = F)

#
# ll2 <- strsplit(ll[, 2], " ", fixed = T)
# ll3 <- sapply(ll2, function(l) l[2])
# 
# all_states <- unique(ll3)
# write.table(all_states, 'all_states.txt', col.names = F, row.names = F,
#             quote = F)
