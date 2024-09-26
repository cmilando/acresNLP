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
my_dir <- "/Users/alliej/Library/CloudStorage/OneDrive-BostonUniversity/ACRES NLP/acresNLP/"
#my_dir <- "/Users/cwm/Documents/GitHub/acresNLP/"

create_df <- function(filename){
  data <- read_delim(filename)
  return(data)
}


#combined table missing all arlington/belmont and some chelsea/everett
combined_table <- create_df(paste0(my_dir, "combined_output_v4.tsv"))
combined_table <- combined_table %>% clean_names()
combined_table$town_name <- gsub("url\\d+|\\d+|\\.json", "",
                                 combined_table$file_name)
combined_table$town_name <- toupper(combined_table$town_name)

#View(combined_table)

mystic_towns_list = c("Burlington", "Lexington", "Belmont", "Watertown",
                     "Arlington", "Winchester", "Woburn", "Reading",
                     "Stoneham", "Medford", "Somerville", "Cambridge",
                     "Boston", "Charlestown", "Everett", "Malden", "Melrose",
                     "Wakefield", "Chelsea", "Revere", "Winthrop", "Wilmington")

##
combined_table <- combined_table %>% 
  mutate(is_ACRES_town = (most_common_town %in% tolower(mystic_towns_list)),
         is_MASS = (most_common_state == 'massachusetts'))

# duplicated
combined_table$duplicated = duplicated(combined_table$first100words)

# write_tsv(combined_table[, c('file_name', 'duplicated')] %>%
#             arrange(file_name), 'duplicated.tsv')

combined_table <- combined_table %>%
  mutate(pass_checks2 = (
    duplicated == F &
    is_ACRES_town == T &
    is_MASS == T &
    has_climate == 1 &
    has_community == 1
  ))

write_tsv(combined_table, 'combined_table_v4.tsv')


combined_table

table(combined_table$most_common_town, combined_table$pass_checks2)
table(combined_table$pass_checks2)

mancx <- read.csv(paste0(my_dir, "manual_checks_2.csv"), header = T,
                  sep = "|")[,c('Manual.Check', "file_name")]
head(mancx)

combined_table <- combined_table %>% left_join(mancx)

dim(combined_table)
data.frame(head(combined_table))


# ----------------------------------------------------------------------------
# ma.url omitted

combined_table <- combined_table %>%
  mutate(pass_checks2 = (
    Manual.Check == 'INCLUDE' &
    duplicated == F &
      is_ACRES_town == T &
      is_MASS == T &
      has_climate == 1 &
      has_community == 1
  ))

pass_checks <- combined_table %>%
  filter(pass_checks2) %>%
  group_by(most_common_town) %>% tally()

pass_checks


write_tsv(pass_checks, 'pass_checks.tsv')

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

# ----------------------------------------------------------------------------
#90% or over for all towns
combined_table_relevant <- combined_table %>% 
  filter(pass_checks2)

#write_tsv(combined_table_relevant, 'combined_table_relevant.tsv')

dim(combined_table)
dim(combined_table_relevant)

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

hazard_by_town$mod_sum

## LOOK AT REVERE AND LEXINGTON

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
         town_name_nice = capitalizeFirstLetter(most_common_town)) %>%
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
  theme(axis.text.x = element_text(angle = 35, hjust = 0))

p1
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
            community_meeting_avg = mean(community_meeting_percent),
            small_group_discussion_avg = mean(small_group_discussion_percent),
            inform_avg = mean(inform_percent)
  ) %>%
  mutate(mod_sum = rowSums(across(workshop_avg:inform_avg)))

## LOOK AT REVERE AND LEXINGTON
##View(outreach_by_town)
outreach_by_town$mod_sum

outreach_name_map = c(
   "workshop_avg"= 'Workshop',
   "mapping_avg" = 'Mapping',
   "focus_group_avg" = 'Focus group',
   "interview_avg"= "Interview",
   "survey_avg" = "Survey",
   "community_meeting_avg" = "Community meeting",
   "small_group_meeting_avg" = "Small group meeting",
   "information_avg" = "Information"
)

p2 <- outreach_by_town %>%
  pivot_longer(cols = workshop_avg:inform_avg) %>%
  mutate(value = ifelse(value == 0, NA, value),
         name_nice = outreach_name_map[name],
         town_name_nice = capitalizeFirstLetter(most_common_town)) %>%
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
  scale_x_discrete(position = 'top')


library(patchwork)

p1 + p2 + 
  plot_layout(ncol = 1, heights = c(0.52, 0.48),
              axis_titles = 'collect_x', 
              guides = 'collect')

dev.size()

ggsave(filename = 'tileplot_v4.png', 
       width = 12.9/2, height = 6.67/2,
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

