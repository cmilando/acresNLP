

source("01_make_passchecks.R")

dim(combined_table)

table(combined_table$most_common_town, combined_table$pass_checks2)
table(combined_table$pass_checks2)

mancx <- read.csv(paste0(my_dir, "manual_checks_1202.csv"), header = T,
                  sep = "|")
head(mancx)

combined_table <- combined_table %>% left_join(mancx)

dim(combined_table)
data.frame(head(combined_table))
 
 # ----------------------------------------------------------------------------
# get the new pdfs to 'INCLUDE'



# ----------------------------------------------------------------------------
# ma.url omitted

## NC Notes: We're reading in combined_table_v9_final.tsv" for this file, right? 
##           Finally, I noticed we were dropping Malden and Waltham in the code below. 
##           There are NA values in the manual checks, which I think come from duplicate reports? I think we just want to remove EXCLUDE. 
##           The modified code below for the creation of pass_checks3 seems to add 4 malden and 3 Waltham reports back in...
##           Also, there are 21 GBA IC communities (I mis-counted earlier!). We'll have to update the flowchart.


#`%!in%` <- function(x, y) !(x %in% y) # NC: Added function

combined_table <- combined_table %>%
  mutate(pass_checks3 = (
    Manual.Check.11.19 %in% c("INCLUDE") & 
    duplicated == F &
      (is_INNER_CORE == T | is_ACRES_town == T) & 
      is_MASS == T &
      has_climate == 1 &
      has_community == 1
  ))

# # malden 63
 r1 <- which(combined_table$file_name == 'maldenurl63.json')
 r1
 combined_table$pass_checks3[r1] <- TRUE
# 
# # burlington 85
# r1 <- which(combined_table$file_name == 'burlingtonurl85.json')
# r1
# combined_table$pass_checks3[r1] <- TRUE
# 
# # reading 60
# r1 <- which(combined_table$file_name == 'readingurl60.json')
# r1
# combined_table$pass_checks3[r1] <- TRUE
# 
# # wilmington
# r1 <- which(combined_table$file_name == 'wilmingtonurl47.json')
# r1
# combined_table$pass_checks3[r1] <- TRUE
# 
# # waltham 82
 r1 <- which(combined_table$file_name == 'walthamurl82.json')
 length(r1)
 combined_table$pass_checks3[r1] <- TRUE


# and any with url that starts with https://www.mass.gov/doc/
r1 <- which(grepl("https://www.mass.gov/doc/", combined_table$url))
length(r1)
table(combined_table$pass_checks3[r1])
combined_table$pass_checks3[r1] <- TRUE

##
### WHICH ONE IS NONE
which(combined_table$most_common_town == 'None' & 
        combined_table$pass_checks3)

pass_checks <- combined_table %>%
  filter(pass_checks3) %>%
  group_by(most_common_town) %>% tally()

sum(pass_checks$n)

# write_tsv(pass_checks, 'pass_checks_0220.tsv')

# num_irrelevant <- combined_table %>% 
#   group_by(town_name) %>% 
#   summarize(
#     total_pdfs = n(),
#     total_relevant = sum(relevant),
#     percent_relevant = total_relevant / n(),
#     total_towns_match = sum(towns_match),
#     percent_match = total_towns_match / n(),
#     relevant_and_match = sum(relevant & towns_match)
#     )
# 
# View(num_irrelevant)

#only filter for relevant and matching

# write_tsv(combined_table, 'combined_table_v8_final.tsv')

# ----------------------------------------------------------------------------

### make flowchart
nrow(combined_table)
# 27 Original from 



##
combined_table <- combined_table %>% filter(is_INNER_CORE == T)
nrow(combined_table)

# not duplicated
table(combined_table$duplicated)

# in MA
table(combined_table %>% 
        filter(duplicated == F) %>% select(is_MASS))

# -- Already doing this --
# table(combined_table %>% 
#         filter(duplicated == F, is_MASS == T) %>% 
#         select(is_INNER_CORE))

# climate
table(combined_table %>% 
        filter(duplicated == F, is_MASS == T, is_INNER_CORE == T) %>% 
        select(has_climate))

# community
table(combined_table %>% 
        filter(duplicated == F, is_MASS == T, is_INNER_CORE == T,
               has_climate == 1) %>% 
        select(has_community))

# pass checks
table(combined_table %>% 
        filter(duplicated == F, is_MASS == T, is_INNER_CORE == T,
               has_climate == 1, has_community == 1) %>% 
        select(pass_checks3))

# save the result
combined_table <- combined_table %>%
        mutate(pass_checks4 = duplicated == F & is_MASS == T &
                 is_INNER_CORE == T &
               has_climate == 1 & has_community == 1 & pass_checks3)

table(combined_table$pass_checks4)


# ----------------------------------------------------------------------------
#90% or over for all towns
combined_table_relevant <- combined_table %>% 
  filter(pass_checks4)

nrow(combined_table_relevant)

#
# combined_table %>%
#   filter(duplicated == F, is_MASS == T, is_INNER_CORE == T,
#          has_climate == 1, has_community == 1)


dim(combined_table_relevant)

write_tsv(combined_table_relevant, 'combined_table_relevant_v10.tsv')

dim(combined_table)
dim(combined_table_relevant)

# Charlestown removed
ALL_TOWNS <- read.table("COMBINED_TOWNS.txt", header = F)
head(ALL_TOWNS)
ALL_TOWNS_list <- tolower(ALL_TOWNS$V1)

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


ALL_TOWNS_list_sub <- setdiff(ALL_TOWNS_list,  
                                 unique(hazard_by_town$most_common_town))

hazard_by_town_blank <- data.frame(most_common_town = ALL_TOWNS_list_sub,
                                   n = rep(0, length(ALL_TOWNS_list_sub)),
                                   flood_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   storm_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   heat_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   air_pollution_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   indoor_air_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   chem_hazard_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   extreme_precip_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   fire_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   mod_sum = rep(0, length(ALL_TOWNS_list_sub)))

hazard_by_town$mod_sum

hazard_by_town <- rbind(hazard_by_town, hazard_by_town_blank)

## LOOK AT REVERE AND LEXINGTON

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

# Example usage:
capitalizeFirstLetter(c("convert_text to camel_case", "another_example_here", "hello world"))
# Output: "Convert_text to camel_case" "Another_example_here" "Hello world"
# Output: "convertTextToCamelCase" "anotherExampleHere" "helloWorld"


hazard_by_town

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

#dev.size()

ggsave(filename = 'hazplot_v6.png', 
       width = 13.375000 * 0.8, 
       height = 4.361111 * 0.8,
       dpi = 600)

#this figure no longer looks good because there are too many towns
# hazard_by_town %>%
#   pivot_longer(cols = flood_avg:fire_avg) %>%
#   ggplot(aes(x = name,
#              y = value,
#              fill = town_name)) +
#   geom_col(position = "dodge")+
#   stat_summary(geom = "errorbar", fun.data = mean_se, position = "dodge")
#add sd bars
#do same thing with outreach types



# hazard_data <-  hazard_by_town %>% 
#   gather(key = "hazard_type", value = "proportion", 
#          flood_avg:fire_avg) %>% 
#   mutate(id = row_number())
#   

# ----------------------------------------------------------------------------
#90% or over for all towns
# combined_table_relevant <- combined_table %>% 
#   filter(towns_match & relevant)
# 
# colnames(combined_table_relevant)

outreach_by_town <- combined_table_relevant %>% 
  group_by(most_common_town) %>% 
  summarize(n = n(),
            workshop_avg = mean(workshop_percent),
            mapping_avg = mean(mapping_percent),
            survey_avg = mean(survey_percent),
            conversation_avg = mean(conversation_percent),
            community_meeting_avg = mean(community_meeting_percent),
            small_group_discussion_avg = mean(small_group_discussion_percent),
            inform_avg = mean(inform_percent)
  ) %>%
  mutate(mod_sum = rowSums(across(workshop_avg:inform_avg)))

## LOOK AT REVERE AND LEXINGTON
##View(outreach_by_town)
outreach_by_town$mod_sum

ALL_TOWNS_list_sub <- setdiff(ALL_TOWNS_list,  unique(outreach_by_town$most_common_town))

outreach_by_town_blank <- data.frame(most_common_town = ALL_TOWNS_list_sub,
                                   n = rep(0, length(ALL_TOWNS_list_sub)),
                                   workshop_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   mapping_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   survey_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   conversation_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   community_meeting_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   small_group_discussion_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   inform_avg = rep(NA, length(ALL_TOWNS_list_sub)),
                                   mod_sum = rep(0, length(ALL_TOWNS_list_sub)))

outreach_by_town$mod_sum

outreach_by_town <- rbind(outreach_by_town, outreach_by_town_blank)

outreach_name_map = c(
   "workshop_avg"= 'Workshop',
   "mapping_avg" = 'Mapping',
   "survey_avg" = "Survey",
   "conversation_avg"= "Conversation",
   "community_meeting_avg" = "Community meeting",
   "small_group_discussion_avg" = "Small group meeting",
   "inform_avg" = "Information"
)

xyz <- outreach_by_town %>%
  pivot_longer(cols = workshop_avg:inform_avg) 
unique(xyz$name)

p2 <- outreach_by_town %>%
  pivot_longer(cols = workshop_avg:inform_avg) %>%
  mutate(value = ifelse(value == 0, NA, value),
         name_nice = outreach_name_map[name],
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
  ylab('Outreach') + xlab('Town') + 
  theme(axis.text.x = element_blank()) +
  #theme(axis.text.x = element_text(angle = 35, hjust = 0)) +
  scale_x_discrete(position = 'top')


library(patchwork)

p1 + p2 + 
  plot_layout(ncol = 1, heights = c(0.52, 0.48),
              axis_titles = 'collect_x', 
              guides = 'collect')

dev.size()

ggsave(filename = 'tileplot_v5.png', 
       width = 12.9/1.5, height = 6.67/1.5,
       #width = 10.5/2, height = 5.9/2,
       dpi = 600)

# ----------------------------------------------------------------------------
#### load in and filter town polygons ####

towns_to_include <- toupper(c("Burlington", "Lexington", "Belmont", "Watertown",
                     "Arlington", "Winchester", "Woburn", "Reading",
                     "Stoneham", "Medford", "Somerville", "Cambridge",
                     "Boston", "Everett", "Malden", "Melrose",
                     "Wakefield", "Chelsea", "Revere", "Winthrop", "Wilmington"))

#adjust based on your computer 
#(put this in the acresnlp folder - should not be in blackouts)
ma_towns <- read_sf(paste0(my_dir, "towns_fixed.shp"))
ACRES_towns_plot <- ma_towns %>% 
  filter(TOWN20 %in% towns_to_include)
# ACRES_towns_plot$centroid <- st_centroid(ACRES_towns_plot$geometry)
# centroids_coords <- st_coordinates(ACRES_towns_plot$centroid)
# ACRES_towns_plot <- ACRES_towns_plot %>%
#   mutate(x = centroids_coords[,1], y = centroids_coords[,2])

#make background blue to represent water
ma_outline <- states(cb = T) %>% filter(NAME == "Massachusetts")
ma_counties <- counties(state = "MA", cb = T)
ma_counties_no_suffolk <- ma_counties %>% filter(NAME != "Suffolk")
ma_outline_wgs84 <- st_transform(ma_outline, crs = 4326)

bbox <- st_bbox(ACRES_towns_plot)
bbox_sf <- st_as_sfc(bbox)
ma_outline_bbox <- st_crop(ma_outline_wgs84, bbox_sf)
bbox_coords <- st_bbox(ma_outline_bbox)


#ma_towns <- read_sf(paste0(my_dir, "towns_fixed.shp"))



####
ACRES_hazard_town_plot <- ACRES_towns_plot %>%
  left_join(hazard_by_town %>% pivot_longer(cols = flood_avg:fire_avg) %>%
              mutate(most_common_town = toupper(most_common_town)), 
            by = join_by(TOWN20 == most_common_town))

hazard_by_town %>% pivot_longer(cols = flood_avg:fire_avg) %>%
  mutate(most_common_town = toupper(most_common_town))

library(ggpubr)
library(lemon)

hazard_name_map = c(
  "air_pollution_avg" = 'Air Pollution',
  'chem_hazard_avg' = 'Chemical Hazards',
  'extreme_precip_avg' = 'Extreme Precip.',
  'fire_avg' = 'Fire',
  'flood_avg' = 'Flood',
  'heat_avg' = 'Heat',
  'indoor_air_avg' = 'Indoor Air',
  'storm_avg' = 'Storm'
)

ACRES_hazard_town_plot$haz_name_plot = hazard_name_map[ACRES_hazard_town_plot$name]

ACRES_hazard_town_plot$value

ggplot(ACRES_hazard_town_plot #%>%
              #filter(!is.na(value))
       ) + theme_classic2() +
  geom_sf(data = ma_counties_no_suffolk,
          color = "black", linetype = '11',
          fill = "grey") +
  geom_sf(aes(fill = value)) +
  coord_sf(xlim = c(bbox_coords$xmin - 0.01, bbox_coords$xmax + 0.01), 
           ylim = c(bbox_coords$ymin - 0.01, bbox_coords$ymax + 0.01), 
           expand = FALSE) +  # Set plot bounds
  scale_fill_binned(type = 'viridis',breaks = seq(20, 80, by = 20),
                    name = 'Average per-document\nproportion of\nhazard words\nreferencing each hazard') +
  facet_rep_wrap(~haz_name_plot, nrow = 2, repeat.tick.labels = 'x') +
  xlab(NULL) + ylab(NULL) +
  theme(strip.background = element_blank(),
        strip.text = element_text(size = 12),
        panel.background = element_rect(color = 'black'),
        axis.text = element_blank(),
        axis.ticks = element_blank()) 

ggsave(device = 'png', dpi = 600, file = 'fig1.png',
       width = 8, height = 6)

####
ACRES_outreach_towns_plot <- ACRES_towns_plot %>%
  left_join(outreach_by_town %>% 
              mutate(most_common_town = toupper(most_common_town)) %>% 
              pivot_longer(cols = workshop_avg:inform_avg),
            by = join_by(TOWN20 == most_common_town))

# ggplot(ACRES_outreach_towns_plot) +
#   geom_sf(aes(fill = value)) +
#   scale_fill_binned(type = 'viridis',
#                     name = 'Percent\nof documents\nreferencing\nhazard X') + 
#   facet_wrap(~name, nrow = 2)

#outreach_name_map <-
#ACRES_hazard_town_plot$outr_name_plot = outreach_name_map[ACRES_outreach_towns_plot$name]


ggplot(ACRES_outreach_towns_plot %>%
         filter(!is.na(value))) + theme_classic2() +
  geom_sf(data = ma_counties_no_suffolk,
          color = "black", linetype = '11',
          fill = "grey") +
  geom_sf(aes(fill = value)) +
  coord_sf(xlim = c(bbox_coords$xmin - 0.01, bbox_coords$xmax + 0.01), 
           ylim = c(bbox_coords$ymin - 0.01, bbox_coords$ymax + 0.01), 
           expand = FALSE) +  # Set plot bounds
  scale_fill_binned(type = 'viridis',breaks = seq(20, 80, by = 20),
                    name = 'Average per-document\nproportion of\noutreach words\nreferencing each hazard') +
  facet_rep_wrap(~name, nrow = 2, repeat.tick.labels = 'x') +
  xlab(NULL) + ylab(NULL) +
  theme(strip.background = element_blank(),
        strip.text = element_text(size = 12),
        panel.background = element_rect(color = 'black'),
        axis.text = element_blank(),
        axis.ticks = element_blank())


# ----------------------------------------------------------------------------
ACRES_towns_plot$centroid <- st_centroid(ACRES_towns_plot$geometry)
centroids_coords <- st_coordinates(ACRES_towns_plot$centroid)
ACRES_towns_plot <- ACRES_towns_plot %>%
  mutate(x = centroids_coords[,1], y = centroids_coords[,2])

# add centroid coordinates to the hazard data

hazard_data <- hazard_by_town %>%
  gather(key = "hazard_type", value = "proportion", flood_avg:fire_avg) %>%
  mutate(id = row_number()) %>% 
  mutate(town_name = toupper(most_common_town)) %>%
  left_join(ACRES_towns_plot %>% st_drop_geometry() %>% select(TOWN20, x, y), 
            by = join_by(town_name == TOWN20)) %>% 
  arrange(town_name, hazard_type) %>%
  group_by(town_name) %>%
  mutate(start_angle = lag(cumsum(proportion / 100 * 360), default = 0),
         end_angle = round(cumsum(proportion / 100 * 360)), 0) %>%
  ungroup()


#### create base map ####

#make background blue to represent water
ma_outline <- states(cb = T) %>% filter(NAME == "Massachusetts")
ma_counties <- counties(state = "MA", cb = T)
ma_counties_no_suffolk <- ma_counties %>% filter(NAME != "Suffolk")
ma_outline_wgs84 <- st_transform(ma_outline, crs = 4326)
bbox <- st_bbox(ACRES_towns_plot)
bbox_sf <- st_as_sfc(bbox)
ma_outline_bbox <- st_crop(ma_outline_wgs84, bbox_sf)
bbox_coords <- st_bbox(ma_outline_bbox)

base_map <- ACRES_towns_plot %>% 
  ggplot() + 
  # geom_sf(data = ma_outline_bbox,
  #         color = "black",
  #         fill = "white")+
  geom_sf(data = ma_counties_no_suffolk,
          color = "black",
          fill = "grey")+
  geom_sf(mapping = aes(),
          color = "black",
          fill = "white") + 
  coord_sf(xlim = c(bbox_coords$xmin, bbox_coords$xmax), 
           ylim = c(bbox_coords$ymin, bbox_coords$ymax), 
           expand = FALSE) +  # Set plot bounds
  theme_bw() +
  theme(axis.text.x = element_blank(),  # remove x-axis labels
        axis.text.y = element_blank(),  # remove y-axis labels
        axis.ticks.x = element_blank(),  # remove x-axis ticks
        axis.ticks.y = element_blank(),  # remove y-axis ticks
        panel.grid.major = element_blank(),  # remove major grid lines
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "dodgerblue"))  # set plot background to blue
            
  
base_map


#### separately create pie charts ####

add_pie <- function(town_data, town_name){
  
  
  labels <- c("Flood", "Storm", "Heat", "Air pollution", "Indoor air quality",
              "Chemical hazards", "Extreme precipitation", "Fire")
  
  #the pie charts are bar charts made circular with polar coordinaites
  pie <- town_data %>% 
    ggplot(aes(x = "", y = proportion, fill = hazard_type)) + 
    geom_bar(stat = "identity", width = 0.3,
             color = "black") + 
    coord_polar("y", start = 0) +
    theme_void() + 
    #ggtitle(town_name) + 
    #add title to base map with ggrepel??
    #theme(plot.title = element_text(hjust = 0.5, vjust = -2)) +
    theme(legend.position = "none") +
    scale_fill_brewer(name = "Hazard Type", labels = labels,
                      palette = "Set2")
  
  return(pie)
  
}

pie_charts <- list()
#create a pie chart for each town
unique_towns <- unique(hazard_data$town_name)
for (town in unique_towns) {
  town_data <- hazard_data %>% filter(town_name == town)
  pie_chart <- add_pie(town_data, town)
  pie_charts[[town]] <- pie_chart
}



#create a overall legend for the pie charts by creating a generic pie
labels <- c("Air pollution", "Chemical hazards", "Extreme precipitation", 
            "Fire", "Flood", "Heat", "Indoor air quality", "Storm")
  
legend_pie <- ggplot(hazard_data, aes(x = "", y = proportion, fill = hazard_type)) +
  geom_bar(stat = "identity", width = 0.3, color = "black", linewidth = 0.3) +
  coord_polar("y", start = 0) +
  theme_void() +
  theme(legend.position = "bottom") +
  scale_fill_brewer(name = "Hazard Type", labels = labels, 
                    palette = "Set2")

#duplicate the base map before adding new elements to it
base_map2 <- base_map


#### combine the base map and the pie charts ####
pie_radius <- 0.02

for (town in unique_towns) {
  town_data <- hazard_data %>% filter(town_name == town)
  
  x_offset <- 0
  y_offset <- 0
  
  # Conditional adjustments for specific towns
  if (town == "CAMBRIDGE") {
    x_offset <- -0.005  # Move slightly to the left
    y_offset <- -0.005  # Move slightly down
  } else if (town == "CHELSEA") {
    x_offset <- 0.01  # Move slightly to the right
    y_offset <- -0.01  # Move slightly down
  }
  
  base_map2 <- base_map2 +
    annotation_custom(
      grob = ggplotGrob(pie_charts[[town]]),
      xmin = town_data$x[1] + x_offset - pie_radius,
      xmax = town_data$x[1] + x_offset + pie_radius,
      ymin = town_data$y[1] + y_offset - pie_radius,
      ymax = town_data$y[1] + y_offset + pie_radius
    )
}


# to adjust: 
# chelsea (right and down)
# cambridge (slightly left and down)


legend <- gtable_filter(ggplotGrob(legend_pie),
                        "guide-box")
  

#base_map2


plot_size <- dev.size()
png(paste0(my_dir,"output_map.png"), width = plot_size[1], height = plot_size[2], units = "in", res = 300)
#put everything together on a new page
grid.newpage()
grid.draw(arrangeGrob(base_map2, legend, ncol = 1, heights = c(9, 1)))
dev.off()

