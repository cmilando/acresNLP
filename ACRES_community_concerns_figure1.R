########################################################################################
# PROJECT       :	ACRES community concerns spreadsheet
# SPONSOR/PI    :
# PROGRAM NAME  :  
# DESCRIPTION   : Figure 1 code
#                 
#                 
# PROGRAMMER    : Nina Cesare
# DATE WRITTEN  : 01/27/2024
########################################################################################
# INPUT FILES   :
# OUTPUT FILES  :
#######################################################################################
# MODIFICATIONS : 
# DATE          : 
# PROGRAMMER    : 
# DESCRIPTION   : 
#######################################################################################


library(readr)
library(plotrix)

capitalizeFirstLetter <- function(textVector) {
  # Helper function to capitalize the first letter of a single string
  singleCapitalize <- function(text) {
    # Capitalize the first letter and leave the rest unchanged
    paste0(toupper(substr(text, 1, 1)), substr(text, 2, nchar(text)))
  }
  
  # Apply the singleCapitalize function to each string in the vector
  result <- sapply(textVector, singleCapitalize)
  
  return(result)
}


### Load and filter data ####
combined_table <- read_tsv("C:/Users/ncesare/OneDrive - Boston University/ACRES/combined_table_v5_final.tsv")

combined_table_relevant <- combined_table %>% 
  filter(pass_checks2)

dim(combined_table)
dim(combined_table_relevant)

mystic_towns_list <- tolower(c("Burlington", "Lexington", "Belmont", "Watertown",
                               "Arlington", "Winchester", "Woburn", "Reading",
                               "Stoneham", "Medford", "Somerville", "Cambridge",
                               "Boston", "Charlestown", "Everett", "Malden", "Melrose",
                               "Wakefield", "Chelsea", "Revere", "Winthrop", "Wilmington"))




#### Plot: Hazards by town ####

hazard_by_town <- combined_table_relevant %>% 
  group_by(most_common_town) %>% 
  summarize(n = n(),
            flood_avg = mean(flood_percent),
            storm_avg = mean(storm_percent),
            heat_avg = mean(heat_percent),
            air_pollution_avg = mean(air_pollution_percent),
            indoor_air_avg = mean(indoor_air_quality_percent),
            chem_hazard_avg = mean(chemical_hazards_percent),
            extreme_precip_avg = mean(extreme_precipitation_percent),
            fire_avg = mean(fire_percent)
  ) %>%
  mutate(mod_sum = rowSums(across(flood_avg:fire_avg)))


mystic_towns_list_sub <- setdiff(mystic_towns_list,  unique(hazard_by_town$most_common_town))

hazard_by_town_blank <- data.frame(most_common_town = mystic_towns_list_sub,
                                   n = rep(0, length(mystic_towns_list_sub)),
                                   flood_avg = rep(NA, length(mystic_towns_list_sub)),
                                   storm_avg = rep(NA, length(mystic_towns_list_sub)),
                                   heat_avg = rep(NA, length(mystic_towns_list_sub)),
                                   air_pollution_avg = rep(NA, length(mystic_towns_list_sub)),
                                   indoor_air_avg = rep(NA, length(mystic_towns_list_sub)),
                                   chem_hazard_avg = rep(NA, length(mystic_towns_list_sub)),
                                   extreme_precip_avg = rep(NA, length(mystic_towns_list_sub)),
                                   fire_avg = rep(NA, length(mystic_towns_list_sub)),
                                   mod_sum = rep(0, length(mystic_towns_list_sub)))

hazard_by_town$mod_sum

hazard_by_town <- rbind(hazard_by_town, hazard_by_town_blank)


hazard_name_map = c(
  "air_pollution_avg" = 'Air Pollution',
  'chem_hazard_avg' = 'Chemical Hazards',
  'extreme_precip_avg' = 'Extreme Precipitation',
  'fire_avg' = 'Fire',
  'flood_avg' = 'Flood',
  'heat_avg' = 'Heat',
  'indoor_air_avg' = 'Indoor Air',
  'storm_avg' = 'Storm'
)



p1 <- hazard_by_town %>%
  pivot_longer(cols = flood_avg:fire_avg) %>%
  mutate(value = ifelse(value == 0, NA, value),
         name_nice = hazard_name_map[name],
         town_name_nice = paste0(capitalizeFirstLetter(most_common_town), " (", n, ")")) %>%
  ggplot() +
  geom_tile(aes(y = reorder(name_nice, value, na.rm = T), 
                x = town_name_nice, 
                fill = value),
            color = 'white') +
  scale_fill_binned(type = 'viridis', 
                    name = 'Average proportion\nof per-document\nreferences',
                    limits = c(0, 100),
                    breaks = c(seq(20, 80, by = 20))) +
  ylab('Hazard') + xlab('Town') + 
  scale_x_discrete(position = 'top') +
  theme(axis.text.x = element_text(angle = 35, hjust = 0, size = 11),
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 14))

p1



 #### Plot: Hazards overall #####


hazard_overall_1 <- combined_table_relevant %>% 
  summarize(flood_avg = mean(flood_percent),
            storm_avg = mean(storm_percent),
            heat_avg = mean(heat_percent),
            air_pollution_avg = mean(air_pollution_percent),
            indoor_air_avg = mean(indoor_air_quality_percent),
            chem_hazard_avg = mean(chemical_hazards_percent),
            extreme_precip_avg = mean(extreme_precipitation_percent),
            fire_avg = mean(fire_percent))
            
hazard_overall_2 <- combined_table_relevant %>% 
  summarize(flood_upper = mean(flood_percent) + (1.96 * std.error(flood_percent)),
            storm_upper = mean(storm_percent) + (1.96 * std.error(storm_percent)),
            heat_upper = mean(heat_percent) + (1.96 * std.error(heat_percent)),
            air_pollution_upper = mean(air_pollution_percent) + (1.96 * std.error(air_pollution_percent)),
            indoor_air_upper = mean(indoor_air_quality_percent) + (1.96 * std.error(indoor_air_quality_percent)),
            chem_hazard_upper = mean(chemical_hazards_percent) + (1.96 * std.error(chemical_hazards_percent)),
            extreme_precip_upper = mean(extreme_precipitation_percent) + (1.96 * std.error(extreme_precipitation_percent)),
            fire_upper = mean(fire_percent) + (1.96 * std.error(fire_percent)))
            
            
hazard_overall_3 <- combined_table_relevant %>% 
  summarize(flood_lower = mean(flood_percent) - (1.96 * std.error(flood_percent)),
            storm_lower = mean(storm_percent) - (1.96 * std.error(storm_percent)),
            heat_lower = mean(heat_percent) - (1.96 * std.error(heat_percent)),
            air_pollution_lower = mean(air_pollution_percent) - (1.96 * std.error(air_pollution_percent)),
            indoor_air_lower = mean(indoor_air_quality_percent) - (1.96 * std.error(indoor_air_quality_percent)),
            chem_hazard_lower = mean(chemical_hazards_percent) - (1.96 * std.error(chemical_hazards_percent)),
            extreme_precip_lower = mean(extreme_precipitation_percent) - (1.96 * std.error(extreme_precipitation_percent)),
            fire_lower = mean(fire_percent) - (1.96 * std.error(fire_percent)))


hazard_overall_1 <- reshape2::melt(hazard_overall_1)

hazard_overall_2 <- reshape2::melt(hazard_overall_2)

hazard_overall_3 <- reshape2::melt(hazard_overall_3)


hazard_overall <- cbind(hazard_overall_1, hazard_overall_2[,-c(1)], hazard_overall_3[,-c(1)])
names(hazard_overall)[c(2:4)] <- c("Mean","Upper","Lower")

hazard_overall$hazard[grep("flood", hazard_overall$variable)] <-"Flood"
hazard_overall$hazard[grep("storm", hazard_overall$variable)] <-"Storm"
hazard_overall$hazard[grep("heat", hazard_overall$variable)] <-"Heat"
hazard_overall$hazard[grep("precip", hazard_overall$variable)] <-"Extreme\n Precipitation"
hazard_overall$hazard[grep("pollution", hazard_overall$variable)] <-"Air\n Pollution"
hazard_overall$hazard[grep("indoor", hazard_overall$variable)] <-"Indoor\n Air"
hazard_overall$hazard[grep("fire", hazard_overall$variable)] <-"Fire"
hazard_overall$hazard[grep("chem", hazard_overall$variable)] <-"Chemical\n Hazards"

hazard_overall <- hazard_overall %>% mutate(hazard2 = fct_reorder(hazard, .x = Mean, .fun = max, .desc = TRUE))

# skeleton is up - we can add colors and make pretty later
p2 <- ggplot(hazard_overall, aes(hazard2, Mean)) + 
  geom_point() +
  geom_errorbar(aes(ymin = Lower, ymax = Upper)) +
  ylab("Average proportion of hazard terms per document\n representing hazard") +
  xlab("Hazard") +
  theme_pubr() 


