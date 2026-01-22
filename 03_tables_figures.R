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

combined_tbl <- combined_tbl  %>% mutate(is_ACRES_town = most_common_town %in% myrw_town) # report-level file

#### Supplemental Table 4 ####

sTab_4 <- combined_tbl %>% dplyr::summarize(flood_n = length(which(flood_count > 0)),
                           flood_pct = length(which(flood_count > 0))/length(flood_count) * 100,
                           storm_n = length(which(storm_count > 0)),
                           storm_pct = length(which(storm_count > 0))/length(storm_count)* 100,
                           heat_n = length(which(heat_count > 0)),
                           heat_pct = length(which(heat_count > 0))/length(heat_count) * 100,
                           air_pollution_n = length(which(air_pollution_count > 0)),
                           air_pollution_pct = length(which(air_pollution_count > 0))/length(air_pollution_count) * 100,
                           indoor_air_quality_n = length(which(indoor_air_quality_count > 0)),
                           indoor_air_quality_pct = length(which(indoor_air_quality_count > 0))/length(indoor_air_quality_count) * 100,
                           chemical_hazards_n = length(which(chemical_hazards_count > 0)),
                           chemical_hazards_pct = length(which(chemical_hazards_count > 0))/length(chemical_hazards_count) * 100,
                           extreme_precipitation_n = length(which(extreme_precipitation_count > 0)),
                           extreme_precipitation_pct = length(which(extreme_precipitation_count > 0))/length(extreme_precipitation_count) * 100,
                           fire_n = length(which(fire_count > 0)),
                           fire_pct = length(which(fire_count > 0))/length(fire_count) * 100,
                           lood_term_pct = sum(flood_count)/sum(total_words) * 100,
                           storm_term_pct = sum(storm_count)/sum(total_words) * 100,
                           heat_term_pct = sum(heat_count)/sum(total_words) * 100,
                           air_pollution_term_pct = sum(air_pollution_count)/sum(total_words) * 100,
                           indoor_air_quality_term_pct = sum(indoor_air_quality_count)/sum(total_words) * 100,
                           chemical_hazards_term_pct = sum(chemical_hazards_count)/sum(total_words) * 100,
                           extreme_precipitation_term_pct = sum(extreme_precipitation_count)/sum(total_words) * 100,
                           fire_term_pct = sum(fire_count)/sum(total_words) * 100) %>% pivot_longer(cols = everything())
  

write.csv(sTab_4, "supp_tab4.csv", row.names = FALSE)

#### Supplemental table 5/6 ####

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

plot_tbl_longer <- plot_tbl %>% 
  select(c(most_common_town, starts_with("median"))) %>%
  pivot_longer(cols = starts_with("median"))

head(plot_tbl_longer)

plot_tbl_longer$plt_name <- gsub("median_", "", plot_tbl_longer$name)
plot_tbl_longer$plt_name <- gsub("_percent", "", plot_tbl_longer$plt_name)

hazards <- c('heat', 'flood', 'fire', 'indoor_air_quality',
             'extreme_precipitation', 'storm', 'chemical_hazards',
             'air_pollution')

hazplot <- subset(plot_tbl_longer, plt_name %in% hazards)

hazplot$most_common_town <- stringr::str_to_upper(hazplot$most_common_town)

a <- ggplot(hazplot) + 
  geom_tile(aes(y = reorder(plt_name, value), 
                x = most_common_town, fill = value),
            color = 'white', linewidth = 0.05) + 
  scale_fill_viridis_c(name = 'Median percent of\nwithin-document mentions') +
  ylab("Hazard") + xlab("Town") +
  theme(axis.text.x = element_text(angle = 25, 
                                   vjust = 1, hjust = 1)) + 
  ggtitle("a.")

ggsave("hazplot.png", plot = a, width = 10.3, height = 3.02)

##
outreach <- subset(plot_tbl_longer, !(plt_name %in% hazards))

outreach$most_common_town <- stringr::str_to_upper(outreach$most_common_town)

b <- ggplot(outreach) + 
  geom_tile(aes(y = reorder(plt_name, value), 
                x = most_common_town, fill = value),
            color = 'white', linewidth = 0.05) + 
  scale_fill_viridis_c(name = 'Median percent of\nwithin-document mentions') +
  ylab("Outreach Method") + xlab("Town") +
  theme(axis.text.x = element_text(angle = 25, 
                                   vjust = 1, hjust = 1)) + 
  ggtitle("b.")

ggsave("outreach.png",plot  = b, width = 10.3, height = 3.02)

library(patchwork)

a/b + patchwork::plot_layout(guides = 'collect')

ggsave("comb.png", width = 10.3, height = 3.02 * 2.2)

#########

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

# heatmap




#### Fig. 2 by subregion ####

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

ggsave("fig2_subregion.png", width = 7.5, height = 5)



#### Fig. 2 overall ####

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



plot_tbl


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

ggsave("fig2_all.png", width = 7.5, height = 5)


