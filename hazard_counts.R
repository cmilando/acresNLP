
library(tidyverse)
library(ggforce)
library(janitor)
library(sf)


#create dataframe of hazard counts and proportions by town

my_dir <- "/Users/allisonjames/Desktop/blackout/NLP"
setwd(my_dir)

create_df <- function(filename){
  data <- read_tsv(filename)
  return(data)
}


somerville <- create_df("somerville.tsv")
somerville5 <- create_df("somerville5.tsv")
revere2 <- create_df("revere2.tsv")
revere6 <- create_df("revere6.tsv")
everett2 <- create_df("everett2.tsv")
everett5 <- create_df("everett5.tsv")

# combined_table <- rbind(somerville, somerville5, revere2, revere6,
#                         everett2, everett5)

combined_table <- rbind(somerville, revere2,
                        everett2)
combined_table <- combined_table %>% clean_names()
combined_table$town_name <- toupper(combined_table$town_name)


# combined_table_means <- combined_table %>% 
#   group_by(town_name) %>% 
#   summarize(across(everything(), mean))

hazard_data <-  combined_table %>% 
  gather(key = "hazard_type", value = "proportion", 
         flood_percent:fire_percent) %>% 
  mutate(id = row_number())
  


#load in town polygons (but just somerville, revere, everett)

towns_to_include <- c("REVERE", "SOMERVILLE", "EVERETT")

ma_towns <- read_sf("/Users/allisonjames/Library/CloudStorage/OneDrive-BostonUniversity/02_Blackouts/Viz/towns_fixed.shp")

hazard_towns <- ma_towns %>% 
  filter(TOWN20 %in% towns_to_include)

hazard_towns$centroid <- st_centroid(hazard_towns$geometry)
centroids_coords <- st_coordinates(hazard_towns$centroid)
hazard_towns <- hazard_towns %>%
  mutate(x = centroids_coords[,1], y = centroids_coords[,2])

# add centroid coordinates to the hazard data

hazard_data <- hazard_data %>%
  left_join(hazard_towns %>% st_drop_geometry() %>% select(TOWN20, x, y), 
            by = join_by(town_name == TOWN20)) %>% 
  arrange(town_name, hazard_type) %>%
  group_by(town_name) %>%
  mutate(start_angle = lag(cumsum(proportion * 2 * pi), default = 0),
         end_angle = cumsum(proportion * 2 * pi)) %>%
  ungroup()


#create base map 

base_map <- hazard_towns %>% 
  ggplot() + 
  geom_sf(mapping = aes(),
          color = "black",
          fill = "white") + 
  theme_bw() +
  theme(axis.text.x = element_blank(),  # remove x-axis labels
        axis.text.y = element_blank(),  # remove y-axis labels
        axis.ticks.x = element_blank(),  # remove x-axis ticks
        axis.ticks.y = element_blank(),  # remove y-axis ticks
        panel.grid.major = element_blank(),  # remove major grid lines
        panel.grid.minor = element_blank())
            
  
base_map


#separately create pie charts

add_pie <- function(proportions){
  
  slices <- proportions
  labels <- c("Flood", "Storm", "Heat", "Air pollution", "Indoor air quality",
              "Chemical hazards", "Extreme precipitation", "Fire")
  pie(slices, labels = labels, radius = 1, cex = 0.7, 
      col = rainbow(length(labels))
  )
  
}

unique_towns <- unique(hazard_data$town_name)
for (town in unique_towns) {
  town_data <- hazard_data %>% filter(town_name == town)
  pie_chart <- add_pie(town_data$proportion)
  pie_charts[[town]] <- pie_chart
}

#combine


add_pie(somerville_data$proportion)



