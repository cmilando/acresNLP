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
library(forcats)
library(ggplot2)
library(ggpubr)

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
combined_table <- read_tsv("C:/Users/ncesare/OneDrive - Boston University/ACRES/combined_table_v8_final.tsv")

combined_table_relevant <- combined_table %>% 
  filter(pass_checks3)

dim(combined_table)
dim(combined_table_relevant)


myrwa <- read.table("C:/Users/ncesare/OneDrive - Boston University/ACRES/MYRWA_towns.txt")


combined_table$in_myrwa <- 0
combined_table$in_myrwa[which(combined_table$most_common_town %in% tolower(myrwa$V1))] <- 1

combined_table_relevant <- combined_table %>% 
  filter(pass_checks2)

dim(combined_table)
dim(combined_table_relevant)

## Check that we have the correct towns 

alltowns <- read.table("C:/Users/ncesare/OneDrive - Boston University/ACRES/COMBINED_TOWNS.txt")

setdiff(unique(tolower(combined_table_relevant$most_common_town)), unique(tolower(alltowns$V1)))
setdiff(unique(tolower(alltowns$V1)),unique(tolower(combined_table_relevant$most_common_town))) # Only stoneham, which legitimately had no entries


 #### Figure 1 #####


## Hazard plot prep

hazard_overall_1 <- combined_table_relevant %>% 
  dplyr::group_by(in_myrwa) %>%
  dplyr::summarize(flood_avg = mean(flood_percent),
            storm_avg = mean(storm_percent),
            heat_avg = mean(heat_percent),
            air_pollution_avg = mean(air_pollution_percent),
            indoor_air_avg = mean(indoor_air_quality_percent),
            chem_hazard_avg = mean(chemical_hazards_percent),
            extreme_precip_avg = mean(extreme_precipitation_percent),
            fire_avg = mean(fire_percent))
            
hazard_overall_2 <- combined_table_relevant %>% 
  dplyr::group_by(in_myrwa) %>%
  dplyr::summarize(flood_upper = mean(flood_percent) + (1.96 * std.error(flood_percent)),
            storm_upper = mean(storm_percent) + (1.96 * std.error(storm_percent)),
            heat_upper = mean(heat_percent) + (1.96 * std.error(heat_percent)),
            air_pollution_upper = mean(air_pollution_percent) + (1.96 * std.error(air_pollution_percent)),
            indoor_air_upper = mean(indoor_air_quality_percent) + (1.96 * std.error(indoor_air_quality_percent)),
            chem_hazard_upper = mean(chemical_hazards_percent) + (1.96 * std.error(chemical_hazards_percent)),
            extreme_precip_upper = mean(extreme_precipitation_percent) + (1.96 * std.error(extreme_precipitation_percent)),
            fire_upper = mean(fire_percent) + (1.96 * std.error(fire_percent)))
            
            
hazard_overall_3 <- combined_table_relevant %>% 
  dplyr::group_by(in_myrwa) %>%
  dplyr::summarize(flood_lower = mean(flood_percent) - (1.96 * std.error(flood_percent)),
            storm_lower = mean(storm_percent) - (1.96 * std.error(storm_percent)),
            heat_lower = mean(heat_percent) - (1.96 * std.error(heat_percent)),
            air_pollution_lower = mean(air_pollution_percent) - (1.96 * std.error(air_pollution_percent)),
            indoor_air_lower = mean(indoor_air_quality_percent) - (1.96 * std.error(indoor_air_quality_percent)),
            chem_hazard_lower = mean(chemical_hazards_percent) - (1.96 * std.error(chemical_hazards_percent)),
            extreme_precip_lower = mean(extreme_precipitation_percent) - (1.96 * std.error(extreme_precipitation_percent)),
            fire_lower = mean(fire_percent) - (1.96 * std.error(fire_percent)))


hazard_overall_1 <- reshape2::melt(hazard_overall_1, id = "in_myrwa")

hazard_overall_2 <- reshape2::melt(hazard_overall_2, id = "in_myrwa")

hazard_overall_3 <- reshape2::melt(hazard_overall_3, id = "in_myrwa")


hazard_overall <- cbind(hazard_overall_1, hazard_overall_2[,-c(1,2)], hazard_overall_3[,-c(1,2)])
names(hazard_overall)[c(3:5)] <- c("Mean","Upper","Lower")

hazard_overall$hazard[grep("flood", hazard_overall$variable)] <-"Flood"
hazard_overall$hazard[grep("storm", hazard_overall$variable)] <-"Storm"
hazard_overall$hazard[grep("heat", hazard_overall$variable)] <-"Heat"
hazard_overall$hazard[grep("precip", hazard_overall$variable)] <-"Extreme\n Precipitation"
hazard_overall$hazard[grep("pollution", hazard_overall$variable)] <-"Air\n Pollution"
hazard_overall$hazard[grep("indoor", hazard_overall$variable)] <-"Indoor\n Air"
hazard_overall$hazard[grep("fire", hazard_overall$variable)] <-"Fire"
hazard_overall$hazard[grep("chem", hazard_overall$variable)] <-"Chemical\n Hazards"

hazard_overall$in_myrwa[which(hazard_overall$in_myrwa == 1)] <- "MyRWA"
hazard_overall$in_myrwa[which(hazard_overall$in_myrwa == 0)] <- "Rest of Inner Core"


hazard_overall <- hazard_overall %>% mutate(hazard2 = fct_reorder(hazard, .x = Mean, .fun = max, .desc = TRUE))


## Community concerns plot prep

community_overall_1 = combined_table_relevant %>% 
  dplyr::group_by(in_myrwa) %>%
  dplyr::summarize(workshop_avg = mean(workshop_percent),
            mapping_avg = mean(mapping_percent),     
            survey_avg = mean(survey_percent),
            conversation_avg = mean(conversation_percent),
            community_meeting_avg = mean(community_meeting_percent),
            small_group_discussion_avg = mean(small_group_discussion_percent),
            inform_avg = mean(inform_percent))

community_overall_2 = combined_table_relevant %>% 
  dplyr::group_by(in_myrwa) %>%
  dplyr::summarize(workshop_upper = mean(workshop_percent) + (1.96* std.error(workshop_percent)),
            mapping_upper = mean(mapping_percent) + (1.96* std.error(mapping_percent)),        
            survey_upper = mean(survey_percent) + (1.96* std.error(survey_percent)),
            conversation_upper = mean(conversation_percent) + (1.96* std.error(conversation_percent)),
            community_meeting_upper = mean(community_meeting_percent) + (1.96* std.error(community_meeting_percent)),
            small_group_discussion_upper = mean(small_group_discussion_percent) + (1.96* std.error(small_group_discussion_percent)),
            inform_upper = mean(inform_percent) + (1.96* std.error(inform_percent)))


community_overall_3 = combined_table_relevant %>% 
  dplyr::group_by(in_myrwa) %>%
  dplyr::summarize(workshop_lower = mean(workshop_percent) - (1.96* std.error(workshop_percent)),
            mapping_lower = mean(mapping_percent) - (1.96* std.error(mapping_percent)),        
            survey_lower = mean(survey_percent) - (1.96* std.error(survey_percent)),
            conversation_lower = mean(conversation_percent) - (1.96* std.error(conversation_percent)),
            community_meeting_lower = mean(community_meeting_percent) - (1.96* std.error(community_meeting_percent)),
            small_group_discussion_lower = mean(small_group_discussion_percent) - (1.96* std.error(small_group_discussion_percent)),
            inform_lower = mean(inform_percent) - (1.96* std.error(inform_percent)))
            


community_overall_1 <- reshape2::melt(community_overall_1, id = "in_myrwa")

community_overall_2 <- reshape2::melt(community_overall_2, id = "in_myrwa")

community_overall_3 <- reshape2::melt(community_overall_3, id = "in_myrwa")


community_overall <- cbind(community_overall_1, community_overall_2[,-c(1,2)], community_overall_3[,-c(1,2)])
names(community_overall)[c(3:5)] <- c("Mean","Upper","Lower")

community_overall$community[grep("workshop", community_overall$variable)] <-"Workshop"
community_overall$community[grep("mapping", community_overall$variable)] <-"Mapping"
community_overall$community[grep("survey", community_overall$variable)] <-"Survey"
community_overall$community[grep("conversation", community_overall$variable)] <-"Conversation"
community_overall$community[grep("community", community_overall$variable)] <-"Community\n meeting"
community_overall$community[grep("small_group", community_overall$variable)] <-"Small group\n discussion"
community_overall$community[grep("inform", community_overall$variable)] <-"Inform"

community_overall$in_myrwa[which(community_overall$in_myrwa == 1)] <- "MyRWA"
community_overall$in_myrwa[which(community_overall$in_myrwa == 0)] <- "Rest of Inner Core"


community_overall <- community_overall %>% mutate(community2 = fct_reorder(community, .x = Mean, .fun = max, .desc = TRUE))


# skeleton is up - we can add colors and make pretty later
p2a <- ggplot(hazard_overall, aes(hazard2, Mean, color = as.factor(in_myrwa))) + 
  geom_point(position = position_dodge(width = 0.8), cex = 3) +
  geom_errorbar(aes(ymin = Lower, ymax = Upper),position = position_dodge(width = 0.8)) +
  ylab("Average proportion of keyword\n terms per document\n representing category") +
  scale_color_manual(name = "Geography:", values = c("#7f3b08","#542788")) +
  ggtitle("Hazards") +
  xlab("Keyword category") +
  theme_pubr() +
  theme(legend.position = "none") 


p2b <- ggplot(community_overall, aes(community2, Mean, color = as.factor(in_myrwa))) + 
  geom_point(position = position_dodge(width = 0.8), cex = 3) +
  geom_errorbar(aes(ymin = Lower, ymax = Upper),position = position_dodge(width = 0.8)) +
  ylab("Average proportion of keyword\n terms per document\n representing category") +
  scale_color_manual(name = "Geography:", values = c("#7f3b08","#542788")) +
  ggtitle("Community engagement strategies") +
  xlab("Keyword category") +
  theme_pubr() + 
  theme(legend.position = "bottom")



png("C:/Users/ncesare/OneDrive - Boston University/ACRES/figure_1.png", units="in", width=10, height=10, res=600)
Rmisc::multiplot(p2a, p2b)
dev.off()



