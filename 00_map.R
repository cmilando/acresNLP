
library(cityHeatHealth)
library(sf)
library(dplyr)
library(ggpubr)
library(ggspatial)

data(ma_towns)

inner_core <- read.table("INNER_CORE.txt")


ICC <- ma_towns %>% filter(TOWN20 %in% toupper(inner_core$V1))

ICC_centroids <- st_centroid(ICC) %>% st_coordinates() %>%
  data.frame()
ICC_centroids$TOWN20 = ICC$TOWN20

bb <- st_bbox(ICC)

ICC_crop <- st_crop(ma_towns, bb)

ggplot() + theme_classic2() +
  geom_sf(data = ICC_crop) +
  geom_sf(data = ICC, fill = 'lavender') +
  geom_label(data = ICC_centroids, 
          mapping = aes(x = X, y = Y, label = TOWN20),
          size = 2, fill = 'white') +
  # Add Scale Bar (bottom right default)
  annotation_scale(location = "br", width_hint = 0.5) +
  # Add North Arrow (top right default)
  annotation_north_arrow(location = "tr", which_north = "true",
                         style = north_arrow_fancy_orienteering) +
  theme(axis.line.y = element_blank(),
        axis.line.x = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank())

ggsave('map_v10.png', width = 7, height = 7, dpi = 300)
