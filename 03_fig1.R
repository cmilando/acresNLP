library(tidyverse)
library(ggpubr)
library(lemon)

combined_tbl <- read_tsv("combined_table_relevant_v10.tsv")

# remove the winthrop unscannable
# combined_tbl <- xx %>% filter(file_name != 'winthropurl35.json' & pass_checks3 == T)
# 
# View(combined_tbl %>%
#   filter(most_common_town == 'chelsea'))

MyRW_town <- read.table("MYRWA_towns.txt")
myrw_town <- tolower(MyRW_town$V1)

# get summary stats for the town-averaged values
plot_tbl <- combined_tbl %>%
  mutate(is_ACRES_town = most_common_town %in% myrw_town) %>%
  group_by(is_ACRES_town, most_common_town) %>%
  summarize(
    n = n(),
    across(ends_with("_percent"), ~ mean(. , na.rm = TRUE), .names = "mean_{.col}"),
  ) %>%
  group_by(is_ACRES_town) %>%
  summarize(
    n = n(),
    across(starts_with("mean_"), ~ quantile(. , prob = 0.50, na.rm = TRUE), .names = "median_{.col}_x"),
    across(starts_with("mean_"), ~ quantile(. , prob = 0.25, na.rm = TRUE), .names = "q25_{.col}_x"),
    across(starts_with("mean_"), ~ quantile(. , prob = 0.75, na.rm = TRUE), .names = "q75_{.col}_x")
  ) %>%
  pivot_longer(cols = ends_with("_percent_x"))

plot_tbl

##
plot_tbl$cause <- NA
plot_tbl$metric <- NA

for(i in 1:nrow(plot_tbl)) {
  plot_tbl$cause[i] <- strsplit(plot_tbl$name[i], "_")[[1]][3]
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

plot_tbl

#
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
  ylab('Town-averaged percentage (%) of term usage') + 
  theme(legend.position = 'bottom',
        strip.background = element_blank(),
        strip.text = element_text(hjust = 0, face = 'bold', size = 11))

ggsave("fig1_v2.png", width = 7.5, height = 5)

#
sup_tbl <- combined_tbl %>%
  mutate(is_ACRES_town = most_common_town %in% myrw_town) %>%
  group_by(is_ACRES_town, most_common_town) %>%
  summarize(
    n = n(),
    across(ends_with("_percent"), ~ mean(. , na.rm = TRUE), .names = "mean_{.col}"),
  )

View(sup_tbl)
write.csv(sup_tbl, file = 'sup_tbl.csv', quote = F, row.names = F)
