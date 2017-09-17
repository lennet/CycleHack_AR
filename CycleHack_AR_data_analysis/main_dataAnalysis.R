# Ziel
# * Visualsierung der Daten auf iPhone
# * Warnung vor risikoreichen Kreuzungen
# 
# ToDo
# * generate interesting numbers
# * output final data as json


# install.packages("jsonlite")
require("tidyr")
require("data.table")
require("ggplot2")
require("stringr")
require("dplyr")
require("scales")

acciPoints <- fread(paste0(getwd(), "/data/accident_list_all_years.csv"), stringsAsFactors = TRUE)
acciPoints2016 <- fread(paste0(getwd(), "/data/out/accidents_list_2016.csv"), stringsAsFactors = TRUE)


histo <- ggplot(data = acciPoints, mapping = aes(x = count)) +
    geom_histogram() +
    scale_x_continuous(labels = scales::comma) +
    scale_y_continuous(labels = scales::comma) +
    labs(
        title = "Häufigkeit der Unfälle je Ort",
        subtitle = "2008 bis 2016",
        caption = "Verkehrunfallstatistik Berlin",
        x = "Anzahl Unfälle",
        y = "Häufigkeit der Unfälle"
    ) +
    theme_minimal()

temp <- df %>%
    mutate(
        accidentsPerLen = count / length
    )

ggplot(data = temp,
       mapping = aes(x = accidentsPerLen)) +
    scale_x_continuous(limits = c(0, 3000)) +
    geom_histogram(stat = "density")

direct <- acciPoints %>% 
    group_by(directorate) %>% 
    summarise(sum(count),
              list(as.character(street))) 

x <- sort(direct$`sum(count)`, decreasing = TRUE)
d <- ggplot(direct, mapping = aes(x = factor(directorate), y = x)) +
    geom_point() +
    # scale_x_continuous(labels = scales::comma) +
    scale_y_continuous(labels = scales::comma) +
    labs(
        title = "Anzahl der Unfälle je Direktorat",
        subtitle = "2008 bis 2016",
        caption = "Verkehrunfallstatistik Berlin",
        x = "Polizeidirektorat",
        y = "Anzahl der Unfälle"
    ) +
    theme_minimal()
ggsave(paste0(getwd(), "/plots/direktorate.png"), d)
ggsave(paste0(getwd(), "/plots/histo.png"), histo)
