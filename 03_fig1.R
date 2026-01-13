library(tidyverse)
library(ggpubr)
library(lemon)

setwd("C:/Users/ncesare/OneDrive - Boston University/ACRES")
combined_tbl <- read_tsv("combined_table_relevant_v10.tsv")

# remove the winthrop unscannable
# combined_tbl <- xx %>% filter(file_name != 'winthropurl35.json' & pass_checks3 == T)
# 
# View(combined_tbl %>%
#   filter(most_common_town == 'chelsea'))

MyRW_town <- read.table("MYRWA_towns.txt")
myrw_town <- tolower(MyRW_town$V1)

combined_tbl <- combined_tbl  %>% mutate(is_ACRES_town = most_common_town %in% myrw_town)

#### Supplemental Table 4 ####

sTab_4 <- combined_tbl %>% summarize(flood_n = length(which(flood_count > 0)),
                           flood_pct = length(which(flood_count > 0))/length(flood_count),
                           storm_n = length(which(storm_count > 0)),
                           storm_pct = length(which(storm_count > 0))/length(storm_count),
                           heat_n = length(which(heat_count > 0)),
                           heat_pct = length(which(heat_count > 0))/length(heat_count),
                           air_pollution_n = length(which(air_pollution_count > 0)),
                           air_pollution_pct = length(which(air_pollution_count > 0))/length(air_pollution_count),
                           indoor_air_quality_n = length(which(indoor_air_quality_count > 0)),
                           indoor_air_quality_pct = length(which(indoor_air_quality_count > 0))/length(indoor_air_quality_count),
                           chemical_hazards_n = length(which(chemical_hazards_count > 0)),
                           chemical_hazards_pct = length(which(chemical_hazards_count > 0))/length(chemical_hazards_count),
                           extreme_precipitation_n = length(which(extreme_precipitation_count > 0)),
                           extreme_precipitation_pct = length(which(extreme_precipitation_count > 0))/length(extreme_precipitation_count),
                           fire_n = length(which(fire_count > 0)),
                           fire_pct = length(which(fire_count > 0))/length(fire_count)) %>% pivot_longer()





#### Supplemental table 5 ####

# get summary stats for the town-averaged values
plot_tbl <- combined_tbl %>%
  group_by(most_common_town) %>%
  dplyr::summarize(
    n = n(),
    #dplyr::across(ends_with("_percent"), ~ mean(. , na.rm = TRUE), .names = "mean_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.50, na.rm = TRUE), .names = "median_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.25, na.rm = TRUE), .names = "q25_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.75, na.rm = TRUE), .names = "q75_{.col}")
  ) 


idx1 <- grep("q25_.*median", colnames(plot_tbl), per = TRUE)
idx2 <- grep("q75_.*q25", colnames(plot_tbl), per = TRUE)
idx3 <- grep("q75_.*median", colnames(plot_tbl), per = TRUE)

plot_tbl <- plot_tbl[,-unique(c(idx1, idx2, idx3))]

write.csv(plot_tbl, "supp_tab5_6_city.csv", row.names = FALSE)


plot_tbl2 <- combined_tbl %>%
  dplyr::group_by(is_ACRES_town) %>%
  dplyr::summarize(
    n = n(),
    #dplyr::across(ends_with("_percent"), ~ mean(. , na.rm = TRUE), .names = "mean_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.50, na.rm = TRUE), .names = "median_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.25, na.rm = TRUE), .names = "q25_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.75, na.rm = TRUE), .names = "q75_{.col}")
  ) 


idx1 <- grep("q25_.*median", colnames(plot_tbl2), per = TRUE)
idx2 <- grep("q75_.*q25", colnames(plot_tbl2), per = TRUE)
idx3 <- grep("q75_.*median", colnames(plot_tbl2), per = TRUE)

plot_tbl2 <- plot_tbl2[,-unique(c(idx1, idx2, idx3))]

write.csv(plot_tbl2, "supp_tab5_6_subregion.csv", row.names = FALSE)




## Fig. 1 by subregion 

plot_tbl <- combined_tbl %>%
  mutate(is_ACRES_town = most_common_town %in% myrw_town) %>%
  dplyr::group_by(is_ACRES_town) %>%
  dplyr::summarize(
    n = n(),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.50, na.rm = TRUE), .names = "median_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.25, na.rm = TRUE), .names = "q25_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.75, na.rm = TRUE), .names = "q75_{.col}")
  ) %>%
  pivot_longer(cols = ends_with("_percent"))



idx1 <- grep("q25_.*median", plot_tbl$name, per = TRUE)
idx2 <- grep("q75_.*q25", plot_tbl$name, per = TRUE)
idx3 <- grep("q75_.*median", plot_tbl$name, per = TRUE)

plot_tbl <- plot_tbl[-unique(c(idx1, idx2, idx3)),]
plot_tbl


##
plot_tbl$cause <- NA
plot_tbl$metric <- NA

for(i in 1:nrow(plot_tbl)) {
  plot_tbl$cause[i] <- strsplit(plot_tbl$name[i], "_")[[1]][2]
  plot_tbl$metric[i] <- strsplit(plot_tbl$name[i], "_")[[1]][1]
}

tail(plot_tbl)

unique(plot_tbl$cause)
unique(plot_tbl$metric)

plot_tbl <-  plot_tbl %>%
  pivot_wider(id_cols = c(is_ACRES_town, n, cause), 
              names_from = metric,
              values_from = value)

hazard_terms <- c('flood', 'storm', 'heat', 'air', 'indoor',
                  'chemical', 'extreme', 'fire')

#
plot_tbl$is_hazard <- NA

for(i in 1:nrow(plot_tbl)) {
  plot_tbl$is_hazard[i] <- any(sapply(hazard_terms, function(x) {
    grepl(x, plot_tbl$cause[i])
  }))
}

x_labels <- c(
  "workshop" = "Workshop",
  "survey" = "Survey",
  "community" = "Community\nMeeting",
  "small" = "Small Group\nDiscussion",
  "conversation" = "Conversation",
  "inform" = "Inform",
  "mapping" = "Mapping",
  "flood" = "Flooding",
  "storm" = "Storms",
  "extreme" = "Extreme\nPrecipitation",
  "heat" = "Heat",
  "fire" = "Fire",
  "air" = "Air Pollution",
  "chemical" = "Chemical\nHazards",
  "indoor" = "Indoor\nAir Pollution"
)

plot_tbl$is_hazard_fct <- ifelse(
  plot_tbl$is_hazard, "a. Hazard terms",
  "b. Outreach terms"
)

plot_tbl$is_ACRES_town_fct <- ifelse(
  plot_tbl$is_ACRES_town, "MyRW",
  "Rest of GBA Inner Core"
)

#plot_tbl


plot_tbl %>%
  ggplot(.) + theme_classic2() +
  geom_point(aes(x = reorder(cause, -median), 
                 group = is_ACRES_town_fct,
                 y = median, color = is_ACRES_town_fct),
             position = position_dodge(width = 0.3)) +
  geom_errorbar(aes(x = reorder(cause, -median), 
                 group = is_ACRES_town_fct,
                 width = 0.25,
                 ymin = q25, ymax = q75, 
                 color = is_ACRES_town_fct),
             position = position_dodge(width = 0.3)) +
  facet_rep_wrap(~is_hazard_fct, nrow = 2, scales = 'free_x') +
  scale_x_discrete(labels = x_labels) +
  xlab(NULL) + 
  scale_color_manual(name = 'Geography', 
                     values = c('#d95f02', '#7570b3')) +
  ylab('Percent of hazard terms by report \n(median and IQR across reports by group)') + 
  theme(legend.position = 'bottom',
        strip.background = element_blank(),
        strip.text = element_text(hjust = 0, face = 'bold', size = 11))

ggsave("fig1_subregion.png", width = 7.5, height = 5)



## Fig. 1 overall

plot_tbl <- combined_tbl %>%
  mutate(is_ACRES_town = most_common_town %in% myrw_town) %>%
  #dplyr::group_by(is_ACRES_town) %>%
  dplyr::summarize(
    n = n(),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.50, na.rm = TRUE), .names = "median_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.25, na.rm = TRUE), .names = "q25_{.col}"),
    dplyr::across(ends_with("_percent"), ~ quantile(. , prob = 0.75, na.rm = TRUE), .names = "q75_{.col}")
  ) %>%
  pivot_longer(cols = ends_with("_percent"))



idx1 <- grep("q25_.*median", plot_tbl$name, per = TRUE)
idx2 <- grep("q75_.*q25", plot_tbl$name, per = TRUE)
idx3 <- grep("q75_.*median", plot_tbl$name, per = TRUE)

plot_tbl <- plot_tbl[-unique(c(idx1, idx2, idx3)),]
plot_tbl


##
plot_tbl$cause <- NA
plot_tbl$metric <- NA

for(i in 1:nrow(plot_tbl)) {
  plot_tbl$cause[i] <- strsplit(plot_tbl$name[i], "_")[[1]][2]
  plot_tbl$metric[i] <- strsplit(plot_tbl$name[i], "_")[[1]][1]
}

tail(plot_tbl)

unique(plot_tbl$cause)
unique(plot_tbl$metric)

plot_tbl <-  plot_tbl %>%
  pivot_wider(id_cols = c(cause), 
              names_from = metric,
              values_from = value)

hazard_terms <- c('flood', 'storm', 'heat', 'air', 'indoor',
                  'chemical', 'extreme', 'fire')

#
plot_tbl$is_hazard <- NA

for(i in 1:nrow(plot_tbl)) {
  plot_tbl$is_hazard[i] <- any(sapply(hazard_terms, function(x) {
    grepl(x, plot_tbl$cause[i])
  }))
}

x_labels <- c(
  "workshop" = "Workshop",
  "survey" = "Survey",
  "community" = "Community\nMeeting",
  "small" = "Small Group\nDiscussion",
  "conversation" = "Conversation",
  "inform" = "Inform",
  "mapping" = "Mapping",
  "flood" = "Flooding",
  "storm" = "Storms",
  "extreme" = "Extreme\nPrecipitation",
  "heat" = "Heat",
  "fire" = "Fire",
  "air" = "Air Pollution",
  "chemical" = "Chemical\nHazards",
  "indoor" = "Indoor\nAir Pollution"
)

plot_tbl$is_hazard_fct <- ifelse(
  plot_tbl$is_hazard, "a. Hazard terms",
  "b. Outreach terms"
)



#plot_tbl


plot_tbl %>%
  ggplot(.) + theme_classic2() +
  geom_point(aes(x = reorder(cause, -median), 
                 #group = is_ACRES_town_fct,
                 y = median), 
                 #color = is_ACRES_town_fct),
             position = position_dodge(width = 0.3)) +
  geom_errorbar(aes(x = reorder(cause, -median), 
                    #group = is_ACRES_town_fct,
                    width = 0.25,
                    ymin = q25, ymax = q75), 
                    #color = is_ACRES_town_fct),
                position = position_dodge(width = 0.3)) +
  facet_rep_wrap(~is_hazard_fct, nrow = 2, scales = 'free_x') +
  scale_x_discrete(labels = x_labels) +
  xlab(NULL) + 
  #scale_color_manual(name = 'Geography', 
  #                   values = c('#d95f02', '#7570b3')) +
  ylab('Percent of hazard terms by report \n(median and IQR across reports by group)') + 
  theme(legend.position = 'bottom',
        strip.background = element_blank(),
        strip.text = element_text(hjust = 0, face = 'bold', size = 11))

ggsave("fig1_all.png", width = 7.5, height = 5)
