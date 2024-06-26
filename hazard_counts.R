
library(tidyverse)
library(ggforce)
library(janitor)
library(sf)
library(gtable)
library(grid)
library(gridExtra)


#### create dataframe of hazard counts and proportions by town ####

#adjust based on your computer
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
chelsea <- create_df("chelsea.tsv")

combined_table2 <- rbind(somerville, somerville5, revere2, revere6,
                        everett2, everett5)

combined_table <- rbind(somerville, revere2,
                        everett2, chelsea)
combined_table <- combined_table %>% clean_names()
combined_table$town_name <- toupper(combined_table$town_name)


# combined_table_means <- combined_table %>% 
#   group_by(town_name) %>% 
#   summarize(across(everything(), mean))

hazard_data <-  combined_table %>% 
  gather(key = "hazard_type", value = "proportion", 
         flood_percent:fire_percent) %>% 
  mutate(id = row_number())
  


#### load in and filter town polygons ####

towns_to_include <- c("REVERE", "SOMERVILLE", "EVERETT", "CHELSEA")

#adjust based on your computer
sf_url <- "/Users/allisonjames/Library/CloudStorage/OneDrive-BostonUniversity/02_Blackouts/Viz/towns_fixed.shp"

ma_towns <- read_sf(sf_url)

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


#### create base map ####

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


#### separately create pie charts ####

add_pie <- function(town_data, town_name){
  
  
  labels <- c("Flood", "Storm", "Heat", "Air pollution", "Indoor air quality",
              "Chemical hazards", "Extreme precipitation", "Fire")
  
  #the pie charts are bar charts made circular with polar coordinaites
  pie <- town_data %>% 
    ggplot(aes(x = "", y = proportion, fill = hazard_type)) + 
    geom_bar(stat = "identity", aes(width = 0.3)) + 
    coord_polar("y", start = 0) +
    theme_void() + 
    ggtitle(town_name) + 
    theme(plot.title = element_text(hjust = 0.5, vjust = -2)) +
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

for (town in unique_towns) {
  town_data <- hazard_data %>% filter(town_name == town)
  base_map2 <- base_map2 +
    annotation_custom(
      grob = ggplotGrob(pie_charts[[town]]),
      xmin = town_data$x[1] - 0.02,
      xmax = town_data$x[1] + 0.02,
      ymin = town_data$y[1] - 0.02,
      ymax = town_data$y[1] + 0.02
    )
}

legend <- gtable_filter(ggplotGrob(legend_pie),
                        "guide-box")
  

base_map2


grid.newpage()
grid.draw(arrangeGrob(base_map2, legend, ncol = 1, heights = c(9, 1)))




# todo:

#   keep code tidy
#  change palette of pie charts (qual)
# download that other somerville pdf
# scrape just the top ~10 for each town (and rename where appropriate)
# table (columns are pdf's, rows are percentages by hazard)
