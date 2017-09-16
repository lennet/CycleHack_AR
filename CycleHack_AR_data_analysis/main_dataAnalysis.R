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

df <- as.data.frame(fread(paste0(getwd(), "/data/out/street_list_2008-15.csv"), stringsAsFactors = TRUE))
bbikeAccidentStreets <- as.data.frame(fread(paste0(getwd(), "/data/berlin_bike_accident_streets.csv"), stringsAsFactors = TRUE))

acciPoints <- fread(paste0(getwd(), "/data/accident_list_all_years.csv"), stringsAsFactors = TRUE)
acciPoints2016 <- fread(paste0(getwd(), "/data/out/accidents_list_2016.csv"), stringsAsFactors = TRUE)
summary(df)

ggplot(data = df, mapping = aes(x = crossing)) +
    geom_histogram()

temp <- df %>%
    mutate(
        accidentsPerLen = count / length
    )

ggplot(data = temp,
       mapping = aes(x = accidentsPerLen)) +
    scale_x_continuous(limits = c(0, 3000)) +
    geom_histogram(stat = "density")

direct <- temp %>% 
    group_by(directorate) %>% 
    summarise(sum(count),
              list(as.character(name)),
              list(osmid)) 


plot(sort(direct$`sum(count)`, decreasing = TRUE))
